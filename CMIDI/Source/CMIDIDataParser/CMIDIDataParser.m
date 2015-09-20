//
//  CMIDIMessageStream.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 6/20/15.
//  Copyright (c) 2015 Charles Gillingham. All rights reserved.
//

#import "CMIDIDataParser.h"
#import "CMIDIMessage.h"
#import "CMIDIMessage+Description.h"
#import "CMIDIMessage+MetaMessage.h"
#import "CMIDIVSNumber.h"
#import "CMIDIMessageByteCount.h"

#define MIDIByteIsStatus(b)           ((b) >= 0x80)
#define MIDIByteIsData(b)             ((b) < 0x80)
#define MIDIByteIsSystemRealTime(b)   (!isFromFile && (b) >= MIDISystemMsg_FirstRealTime)


@interface CMIDIDataParser ()
@property NSMutableData  * pendingSystemExclusiveData; // System Exclusive message extended over multiple blocks.
@end

@implementation CMIDIDataParser {
    Byte *           _dataPtr;
    Byte *           _startOfDataPtr;
    Byte *           _endOfDataPtr;
    NSMutableArray * _messages;
}
@synthesize pendingSystemExclusiveData;
@synthesize firstError;

- (id) init
{
    if (self = [super init]) {
        pendingSystemExclusiveData = nil;
    }
    return self;
}



//------------------------------------------------------------------------------
#pragma mark                   Parse real time messages
//------------------------------------------------------------------------------

//  parseMessageData (and [CMIDIFile parseTrackMessages]) messages are basically a simple loop:
//  1) find out the expected length of the message
//  2) copy the data into a CMIDIMessage and queue it.
//
//  There are several complications which completely convolute the code.
//  - Real time message bytes, which can interrupt any message at any time (except meta messages).
//  - Running status: it's permissable to omit the first byte of the message, and we use the first byte of the previous message.
//  - System Real Time messages can extend over multiple data blocks.
//  - Messages from a file also have a time stamp, which must be read between each message.
//  - Some MIDI files miscalculate the length of the track. (Solution: ignore length, rely on endOfTrack message)
//  - The stream ends in different ways depending on whethre we're reading from files or live data streams (files use an endofTrack message, real time messages arrive with a length).
//  - Meta message may contain bytes which look like the start of new message (i.e. they look like status bytes)
//  - Some system exclusive messages forget to use 0xF7 to end the system message. (Solution: in a live stream, we fix it. In a file, the problem is fatal (the time stamp of the next message will wind up attached to the system exclusive message, and we will look for a time stamp on the second byte of the following messsage, and so on to failure.)
//  - Some system exclusive messages that extend over multiple packets forget to put 0xF7 at the start of the second packet. (Solution: Just step over it if it's there, start reading if it's not.)
//  Because these complications are very different for files and data streams, we have two message reading routines below.


- (NSArray *) parseMessageData: (const Byte *) data
                        length: (NSUInteger) length
{
    UInt8 status = 0;
    firstError = nil;
    _dataPtr        = (Byte *)data;
    _endOfDataPtr   = _dataPtr+length;
    _startOfDataPtr = _dataPtr;
    _messages = [NSMutableArray new];
    
    // Eliminate leading system real time messages
    if (![self parseSystemRealTime]) return nil;
    
    // Handle System Exclusive Continued messages (which should only appear at the start of a packet)
    if (![self parseSysExContinued]) return nil;
    
    while (_dataPtr < _endOfDataPtr) {
        
        // Running status -- keep the status the same for the next message.
        if (MIDIByteIsStatus(*_dataPtr)) {
            status = *_dataPtr++;
            [self parseSystemRealTime];
        }
        
        // Get the length, even if we are doing running status, for variable length messages.
        NSUInteger nBytes = [self expectedNumberOfBytes:status];
        if (nBytes == 0) return nil; // Fatal error occurred.
        
        NSMutableData * messageData = [NSMutableData dataWithCapacity:nBytes];
        [messageData appendBytes:&status length:1];
        
        // Read data bytes, check for interrupting real-time bytes
        // (Note: this loop will not work in files, because meta messages may contain "status" bytes.)
        while (messageData.length < nBytes) {
            
            // Check for premature end (also catches MIDISystemMsg_EndOFSysEx)
            if ((_dataPtr >= _endOfDataPtr) || (MIDIByteIsStatus(*_dataPtr))) {
                break;
            }
            
            [messageData appendBytes:_dataPtr++ length:1];
            [self parseSystemRealTime];
        }
        
        if (status == MIDISystemMsg_SystemExclusive) {
            [self parseEndOfSysEx: messageData];
        } else if (messageData.length < nBytes) {
            [self shortMessageError:messageData]; // Report error and skip.
        } else {
            CMIDIMessage * msg = [CMIDIMessage messageWithData:messageData];
     //     [msg show];
            [_messages addObject:msg];
        }
        
        // Very rare bug: if we have a one-byte message (e.g. "TuneRequest") followed by a data byte, the code above would assume that we have running status with zero data bytes, and would loop infinitely reading 0 bytes each loop. This code (which is very fast) removes this bizarre case. (We would expect this to happen about once every 32768 times we are called with random data.)
        if (nBytes == 1) {
            while (_dataPtr < _endOfDataPtr && MIDIByteIsData(*_dataPtr)) _dataPtr++;
        }
        
    }
    return _messages;
}



- (BOOL) parseSystemRealTime
{
    while (_dataPtr < _endOfDataPtr && *_dataPtr >= MIDISystemMsg_FirstRealTime) {
        CMIDIMessage * msg = [CMIDIMessage messageWithData:[NSData dataWithBytes:_dataPtr++ length:1]];
//      [msg show];
        [_messages addObject:msg];
    }
    return YES;
}




// This code recovers from all the following errors
// 1) System exclusive message at the end of the previous packet had no terminating MIDISystemMsg_EndOfSysEx.
// 2) Client forgot to add "MIDISystemMsg_SysExContinued" at the top of the current packet.
// 3) Previous packet did not contain a system exclusive message (e.g., a packet was lost), but this packet starts with MIDISystemMsg_SysExContinued. We leave things as they are, and the remaining code will produce a system exclusive message with partial data, and processing can continue.

- (BOOL) parseSysExContinued
{
    NSMutableData * messageData = nil;
    
    if (pendingSystemExclusiveData) {
        
        if (_dataPtr < _endOfDataPtr && *_dataPtr == MIDISystemMsg_SysExContinued) {
            _dataPtr++;
            [self parseSystemRealTime];
        }
    
        messageData = pendingSystemExclusiveData;
        pendingSystemExclusiveData = nil;

        while (_dataPtr < _endOfDataPtr && MIDIByteIsData(*_dataPtr)) {
            [messageData appendBytes:_dataPtr++ length:1];
            [self parseSystemRealTime];
        }
        
        [self parseEndOfSysEx:messageData];
    }
    
    return YES;
}



// This assumes we have read data up to the point were MIDISystemMsg_EndofSysEx is expected.

- (void) parseEndOfSysEx: (NSMutableData *) messageData
{
    if (_dataPtr >= _endOfDataPtr) {
        
        // Data packet ended without terminating the SysEx; assume it will be continued in the next packet.
        pendingSystemExclusiveData = messageData;
        
    } else {
        
        // If the client did not terminate the system exclusive with the right message, we can recover.
        if (*_dataPtr == MIDISystemMsg_EndofSysEx) {
            _dataPtr++;
            [self parseSystemRealTime];
        }
        
        Byte b = MIDISystemMsg_EndofSysEx;
        [messageData appendBytes:&b length:1];
        CMIDIMessage * msg = [CMIDIMessage messageWithData: messageData];
 //       [msg show];
        [_messages addObject:msg];
        
    }
}






//------------------------------------------------------------------------------
#pragma mark                 Expected number of bytes
//------------------------------------------------------------------------------


- (NSUInteger) expectedNumberOfBytes: (UInt8) status
{
    OSStatus errCode;
    NSUInteger len = CMIDIMessageByteCount(status, _dataPtr, _endOfDataPtr-_dataPtr, NO, &errCode);
    if (len == 0) {
        [self byteCountError:_dataPtr];
    }
    return len;
}


//------------------------------------------------------------------------------
#pragma mark                 Errors
//------------------------------------------------------------------------------


- (void) reportError: (NSString *) errString
{
    errString = [NSString stringWithFormat:@"%@\nReading bytes[%ld] == %X", errString, _dataPtr-_startOfDataPtr, (Byte) *_dataPtr];
    
    if (!firstError) {
        NSDictionary * errorDict = @{ NSLocalizedDescriptionKey : errString };
        firstError = [NSError errorWithDomain:@"com.CMIDI"
                                         code:1
                                     userInfo:errorDict];
    }
}


- (void) reportMessageReadingError: (NSString *) errString
                            status: (UInt8) status
                             byte1: (UInt8) b1
{
    Byte buf[3] = {status, b1, 64};
    CMIDIMessage * msg = [CMIDIMessage messageWithBytes:buf length:3];
    errString = [NSString stringWithFormat:@"Error reading %@:\n%@", msg.messageName, errString];
    [self reportError:errString];
}


- (void) noStartingStatusErr  { [self reportError:@"Data is corrupt (first byte is not a status byte)."]; }


- (void) shortMessageError: (NSData *) messageData
{
    if (messageData.length == 0) {
        [self reportError:@"BUG: Status byte note found"];
    } else if (messageData.length == 1) {
        [self reportError:@"No data bytes found for message"];
    } else {
        UInt8 status = ((Byte *)messageData.bytes)[0];
        UInt8 byte1 = ((Byte *)messageData.bytes)[1];
        [self reportMessageReadingError:@"Not enough bytes for message." status:status byte1:byte1];
    }
}


- (void) byteCountError: (Byte *) dataPtr
{
    if (*dataPtr == MIDISystemMsg_Meta) {
        [self reportMessageReadingError:@"Could not read meta message length or meta message length is wrong" status:MIDISystemMsg_Meta byte1:*(_dataPtr+1)];
    } else {
        [self reportError:@"Corrupt status byte"];
    }
}


- (void) trackCountError: (UInt16) expectedCount : (UInt16) finalCount
{
    if (finalCount == 0) {
        [self reportError:@"No tracks read"];
    } else {
        [self reportError:[NSString stringWithFormat:@"File does not appear to have the right number of tracks.\nTracks expected: %hu Tracks read: %hu\n",expectedCount, finalCount]];
    }
}

@end
