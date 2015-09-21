//
//  CMIDIFileParser.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 9/21/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDIFileParser.h"
#import "CTime.h"
#import "CMIDIMessage.h"
#import "CMIDIMessage+MetaMessage.h"
#import "CMIDIMessage+Description.h"
#import "CMIDIMessageByteCount.h"
#import "CMIDIVSNumber.h"


typedef struct CMIDIFileHeader {
    char magic[4];                  // = "MThd"
    UInt8 unusedHeaderSizeBytes[2]; // Must be zero (or the header is more than 256 bytes long).
    UInt8 headerSize[2];            // 16 bit, MSB first. Always = 6 (I think)
    UInt8 format[2];                // 16 bit, MSB first.
    UInt8 trackCount[2];            // 16 bit, MSB first.
    UInt8 division[2];              // Rather complicated
} CMIDIFileHeader;

typedef struct CMIDITrackHeader {
    char magic[4];          // = "MTrk"
    UInt8 trackLength[4];   // Ignore, because it is occasionally wrong.
} CMIDITrackHeader;

#define UInt16FromLittleEndian2(n)   ((n)[1] | (n)[0] << 8)
#define LittleEndian2FromUInt16(n)   {(Byte)(((n) & 0xFF00) >> 8), (Byte)((n) & 0x00FF)}
#define LittleEndian4FromUInt16(n)   {0,0,(Byte)(((n) & 0xFF00) >> 8), (Byte)((n) & 0x00FF)}

#define MIDIByteIsStatus(b)           ((b) >= 0x80)
#define MIDIByteIsData(b)             ((b) < 0x80)




@implementation CMIDIFileParser {
    Byte * _dataPtr;
    Byte * _startOfDataPtr;
    Byte * _endOfDataPtr;
    NSMutableArray * _messages;
}

@synthesize firstError;



//------------------------------------------------------------------------------
#pragma mark                   Data from File
//------------------------------------------------------------------------------


- (BOOL) parseFileData: (NSData *) data
                format: (UInt16 *) fmt
          ticksPerBeat: (UInt16 *) division
            trackCount: (UInt16 *) nTracks
              messages: (NSMutableArray **) messages;
{
    firstError = nil;
    _dataPtr        = (Byte *)data.bytes;
    _endOfDataPtr   = _dataPtr+data.length;
    _startOfDataPtr = _dataPtr;
    _messages       = [NSMutableArray new];
    
    if (![self parseFileHeader:fmt:nTracks:division]) return NO;
    
    NSUInteger trackNumber = 0;
    while (_dataPtr < _endOfDataPtr) {
        if (![self parseTrackHeader]) return NO;
        if (![self parseTrackMessages:trackNumber++]) return NO;
    }
    
    if (trackNumber != *nTracks) {
        *nTracks = trackNumber;
        [self trackCountError:*nTracks:trackNumber];
    }
    
    *messages = _messages;
    
    return YES;
}


/*
@property UInt16                format;
@property NSUInteger            trackCount;
@property CMIDIClockTicks       songLength;
@property NSMutableArray      * endOfTrackTimes;
*/

- (NSMutableData *) fileData: (NSArray *) messages
                     format: (UInt16) format
                 trackCount: (NSUInteger) trackCount
               ticksPerBeat: (CMIDIClockTicks)ticksPerBeat

{
    NSMutableArray * tracks = [NSMutableArray new];
    for (CMIDIMessage * msg in messages) {
        while (msg.track >= tracks.count) {
            [tracks addObject:[NSMutableArray new]];
        }
        [tracks[msg.track] addObject:msg];
    }
    
    // Find all the data lengths
    UInt16 trackLengths[tracks.count];
    NSUInteger totalLength = sizeof(CMIDIFileHeader);
    for (NSUInteger i = 0; i < tracks.count; i++) {
        UInt16 len = 0;
        for (CMIDIMessage * message in tracks[i]) {
            len += message.data.length;
        }
        trackLengths[i] = len;
        totalLength += (len + sizeof(CMIDITrackHeader));
    }
    
    NSMutableData * fData = [NSMutableData dataWithCapacity:totalLength];
    [self appendHeaderDataTo:fData
                      format:format
                  trackCount:trackCount
                ticksPerBeat:ticksPerBeat];
    
    for (NSUInteger i = 0; i < tracks.count; i++) {
        [self appendTrackHeaderDataTo:fData
                      withTrackLength:trackLengths[i]];
        SInt64 currentTime = 0;
        for (CMIDIMessage * message in tracks[i]) {
            [self appendTimeStamp: message.time currentTime: &currentTime to:fData];
            [fData appendData:message.data];
        }
    }
    
    return fData;
}


//------------------------------------------------------------------------------
#pragma mark                   File Headers and Track Headers
//------------------------------------------------------------------------------


- (BOOL) parseFileHeader: (UInt16 *) fmt
                        : (UInt16 *) nTracks
                        : (UInt16 *) division

{
    if (_dataPtr + sizeof(CMIDIFileHeader) >= _endOfDataPtr) return NO;
    CMIDIFileHeader * header = (CMIDIFileHeader *)_dataPtr;
    _dataPtr += sizeof(CMIDIFileHeader);
    
    UInt16 unused     = UInt16FromLittleEndian2(header->unusedHeaderSizeBytes);
    UInt16 headerSize = UInt16FromLittleEndian2(header->headerSize);
    *fmt              = UInt16FromLittleEndian2(header->format);
    *nTracks          = UInt16FromLittleEndian2(header->trackCount);
    *division         = UInt16FromLittleEndian2(header->division);
    
    // Check for bad or corrupt data
    if (memcmp(&(header->magic[0]),"MThd",4) != 0)
    { [self badHeaderError]; return NO; }
    if (unused != 0)                  { [self badHeaderError]; return NO; }
    if (headerSize < 6)               { [self badHeaderError]; return NO; }
    if (*fmt > 2)                     { [self badHeaderError]; return NO; }
    if (*nTracks > 1 && *fmt == 0) { [self badHeaderError]; return NO; }
    if (*division > 0x8000) {
        [self SMPTEError];
        return NO;
    }
    
    if (headerSize > 6) {
        _dataPtr += (headerSize - 6);
    }
    
    return YES;
    
}




- (void) appendHeaderDataTo: (NSMutableData *) data
                     format: (UInt16) format
                 trackCount: (NSUInteger) trackCount
               ticksPerBeat: (CMIDIClockTicks)ticksPerBeat
{
    CMIDIFileHeader header = {
        {'M','T','h','d'},
        LittleEndian2FromUInt16(0),
        LittleEndian2FromUInt16(6), // Header size
        LittleEndian2FromUInt16(format),
        LittleEndian2FromUInt16(trackCount),
        LittleEndian2FromUInt16(ticksPerBeat)
    };
    [data appendBytes:&header length:sizeof(CMIDIFileHeader)];
}




- (BOOL) parseTrackHeader
{
    if (_dataPtr + sizeof(CMIDITrackHeader) >= _endOfDataPtr) return NO;
    CMIDITrackHeader * header = (CMIDITrackHeader *)_dataPtr;
    _dataPtr += sizeof(CMIDITrackHeader);
    
    // Check for corrupt data
    if (memcmp(&(header->magic[0]),"MTrk",4) != 0) {
        [self badTrackHeaderError];
        return NO;
    }
    
    // We will ignore the size, because I'm told it's often wrong.
    return YES;
}




- (void) appendTrackHeaderDataTo: (NSMutableData *) data
                 withTrackLength: (UInt16) trackLength
{
    CMIDITrackHeader header = {
        {'M','T','r','k'},
        LittleEndian4FromUInt16(trackLength)
    };
    [data appendBytes:&header length:sizeof(CMIDITrackHeader)];
}



//------------------------------------------------------------------------------
#pragma mark                   Parse track messages
//------------------------------------------------------------------------------

//  parseTrackMessages (and [CMIDIDataParser parseMessages]) are basically a simple loop:
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

- (BOOL) parseTrackMessages: (NSUInteger) trackNo
{
    // If the first message does not begin with a status byte, this will be passed to "expectedNumberOfBytes" and fail at that point.
    // (This is kludgy, but it's too awkward to step over the first timeStamp to check this. This works.)
    UInt8 status = 0;
    UInt64 timeStamp = 0;
    CMIDIMessage * msg;
    
    while (_dataPtr < _endOfDataPtr) {
        
        if (![self parseTimeStamp: &timeStamp]) return NO;
        
        // Running status -- keep the status the same for the next message.
        // Running status in files follows the time stamp.
        if (MIDIByteIsStatus(*_dataPtr)) {
            status = *_dataPtr++;
        }
        
        // Get the length, even if this is running status in case this is a variable-length messages.
        OSStatus errCode = 0;
        NSUInteger nBytes = CMIDIMessageByteCount(status, _dataPtr, _endOfDataPtr-_dataPtr, YES, &errCode);
        if (nBytes == 0) {
            [self byteCountError:_dataPtr];
            return NO;
        }
        NSUInteger nDataBytes = nBytes - 1; // Don't count status byte.
        
        NSMutableData * messageData = [NSMutableData dataWithCapacity:nBytes];
        [messageData appendBytes:&status length:1];
        
        if (nDataBytes + _dataPtr > _endOfDataPtr) { // File ends unexpectedly
            [self endOfTrackErr];
            return NO;
        }
        
        // Read data bytes
        [messageData appendBytes:_dataPtr length:nDataBytes];
        _dataPtr += nDataBytes;
        
        // Create the message
        msg = [CMIDIMessage messageWithData:messageData];
        msg.time = timeStamp;
        msg.track = trackNo;
        [_messages addObject:msg];
        
        if (msg.metaMessageType == MIDIMeta_EndOfTrack) {
            return YES;
        }
    }
    
    // Recover: missing end-of-track at the end of file.
    [self endOfTrackErr];
    msg = [CMIDIMessage messageEndOfTrack];
    msg.track = trackNo;
    // We will set the time in "standardize"
    [_messages addObject:msg];
    return YES;
}



//------------------------------------------------------------------------------
#pragma mark                   Time stamp
//------------------------------------------------------------------------------


- (BOOL) parseTimeStamp: (UInt64 *) timeStamp
{
    CMIDIVSNumber * vs = [CMIDIVSNumber numberWithBytes:_dataPtr
                                              maxLength:_endOfDataPtr - _dataPtr];
    if (!vs) {
        [self timeError];
        return NO;
    }
    
    // Time in files is in relative ticks.
    *timeStamp = *timeStamp +  vs.integerValue;
    
    _dataPtr += vs.dataLength;
    return YES;
}



- (void) appendTimeStamp: (SInt64) timeStamp currentTime: (SInt64 *) currentTime to: (NSMutableData *) data
{
    NSUInteger relativeTime = timeStamp - *currentTime;
    *currentTime = timeStamp;
    CMIDIVSNumber * vs = [CMIDIVSNumber numberWithInteger:relativeTime];
    [data appendBytes:vs.data length:vs.dataLength];
}



//------------------------------------------------------------------------------
#pragma mark                 Errors
//------------------------------------------------------------------------------


- (void) reportError: (NSString *) errString
{
    errString = [NSString stringWithFormat:@"%@\nReading bytes[%ld] == %X", errString, _dataPtr-_startOfDataPtr, (Byte) *_dataPtr];
    //    CFAIL(errString);
    
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


- (void) badHeaderError       { [self reportError:@"MIDI file is corrupt, has an unusable header or this is not a MIDI file"]; }
- (void) badTrackHeaderError  { [self reportError:@"Bad track header; previous track may be missing end-of-track"]; }
- (void) SMPTEError           { [self reportError:@"SMPTE time format is not currently supported"]; }
- (void) noStartingStatusErr  { [self reportError:@"Data is corrupt (first byte is not a status byte)."]; }
- (void) timeError            { [self reportError:@"Could not read time stamp."]; }
- (void) endOfTrackErr        { [self reportError:@"File ends abruptly: no final end-of-track marker."]; }

- (void) shortMessageError: (NSData *) messageData
{
    if (messageData.length == 0) {
        [self reportError:@"BUG: no bytes in message"];
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
