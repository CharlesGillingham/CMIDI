//
//  CMIDIFile.m
//  SqueezeBox 0.0.1
//
//  Created by CHARLES GILLINGHAM on 6/19/15.
//  Copyright (c) 2015 SqueezeBox. All rights reserved.
//

#import "CMIDIFile.h"
#import "CMIDIMessage.h"
#import "CMIDIMessage+ChannelMessage.h"
#import "CMIDIMessage+MetaMessage.h"
#import "CMIDIMessage+Description.h"
#import "CMIDIVSNumber.h"
#import "CMIDIMessageByteCount.h"
#import "string.h"

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

//------------------------------------------------------------------------------
#pragma mark                   CMIDIFile
//------------------------------------------------------------------------------


@interface CMIDIFile ()
@property (readwrite) NSString * fileName;
@property (readwrite) NSURL * fileURL;
@property NSError * firstError;
@end

@implementation CMIDIFile {
    Byte * _dataPtr;
    Byte * _startOfDataPtr;
    Byte * _endOfDataPtr;
    NSMutableArray * _messages; // Messages DURING PARSING (So if there is a catastrophic failure, the current messages are not touched
}
@synthesize messages;
@synthesize fileName;
@synthesize fileURL;
@synthesize format;
@synthesize ticksPerBeat;
@synthesize trackCount;
@synthesize songLength;
@synthesize endOfTrackTimes;
@synthesize firstError;
//@synthesize ticksPerFrame; SMPTE not supported.
//@synthesize framesPerSecond;

//------------------------------------------------------------------------------
#pragma mark                   Constructors
//------------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        messages = nil;
        fileName = nil;
        format = 1;
        trackCount = 0;
        endOfTrackTimes = [NSMutableArray new];
        songLength = 0;
    }
    return self;
}



+ (instancetype) MIDIFileWithContentsOfFile: (NSURL *) fURL
                                      error: (NSError **) error
{
    CMIDIFile * mf = [CMIDIFile new];
    if ([mf readFile:fURL error:error]) {
        return mf;
    } else {
        return nil;
    }
}


+ (instancetype) emptyMIDIFile
{
    return [CMIDIFile new];
}


//------------------------------------------------------------------------------
#pragma mark                   File i/0
//------------------------------------------------------------------------------


- (BOOL) readFile: (NSURL *) fURL
            error: (NSError **) error
{
    NSData * fileData = [NSData dataWithContentsOfURL:fURL options:0 error:error];
    if (!fileData) {
        return NO;
    }
    
    UInt16 fmt, tpb, ntrks;
    if ([self parseFileData:fileData
                       format:&fmt
                 ticksPerBeat:&tpb
                   trackCount:&ntrks])
    {
        fileName = fURL.path;
        fileURL = fURL;
        format = fmt;
        ticksPerBeat = tpb;
        trackCount = ntrks;
        messages = _messages;
        
        // Correct any errors in the messsage list that we can.
        
        // Tempo and meter messages go on track 0.
        [self cleanTempoAndMeterTrack];
        [self setTrackCountAndEndOfTrackTimes];
        [self standardizeNoteOff];
        [self removeEndOfTrackMessages];
        messages = [NSMutableArray arrayWithArray:[CMIDIMessage sortedMessageList:messages]];
        return YES;
    } else {
        return NO;
    }
}




- (BOOL) writeFile: (NSURL *) fURL
             error: (NSError **) error
{
    // Correct any errors in the messsage list that we can.
   
    // Place all messages without a track onto track 1.
    [self setTrack];
    
    // Tempo and meter messages go on track 0.
    [self cleanTempoAndMeterTrack];
    
    // Make sure that the end of track markers are in place and make sense
    [self setTrackCountAndEndOfTrackTimes];
    [self removeEndOfTrackMessages];
    [self addEndOfTrackMessages];
    
    // Remove meaningless note-ons or note-offs
    [self standardizeNoteOff];

    messages = [NSMutableArray arrayWithArray:[CMIDIMessage sortedMessageList:messages]];

    NSData * fileData = [self fileData];
    if (!fileData) {
        return NO;
    }
    [self removeEndOfTrackMessages];

    if ([fileData writeToURL:fURL options:0 error:error]) {
        self.fileURL = fURL;
        self.fileName = fURL.path;
        return YES;
    } else {
        return NO;
    }
    
}


- (BOOL) save: (NSError **) error
{
    return [self writeFile: fileURL error:error];
}



- (BOOL) reload: (NSError **) error
{
    return [self readFile: fileURL error:error];
}



//------------------------------------------------------------------------------
#pragma mark                   Data from File
//------------------------------------------------------------------------------


- (BOOL) parseFileData: (NSData *) data
                format: (UInt16 *) fmt
          ticksPerBeat: (UInt16 *) division
            trackCount: (UInt16 *) nTracks
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
    
    return YES;
}



- (NSMutableData *) fileData
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
    [self appendHeaderDataTo:fData];
    
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
#pragma mark                   Standardize the tracks
//------------------------------------------------------------------------------

- (void) setTrack
{
    for (CMIDIMessage * msg in messages) {
        if (msg.track == CMIDIMessage_NoTrack) {
            msg.track = 1;
        }
    }
}


// Make sure all tempo, meter and SMPTE offset messages are on track 0 and that no other messages are on track 0.
// Postconditions: If there are extra messages on the tempo track, all the track numbers will increase by one, and the tempo track will have no end-of-track message.
- (void) cleanTempoAndMeterTrack
{
    BOOL incrementTrackNumbers = NO;
    for (CMIDIMessage * msg in messages) {
        if ((msg.track == 0)  && !(msg.isTimeMessage) && !(msg.metaMessageType == MIDIMeta_EndOfTrack)) {
            printf("CMIDIFile: Found on tempo track: %s\n", msg.description.UTF8String);
            printf("           Moving this to track one, and moving all messages up one track.\n");
            incrementTrackNumbers = YES;
            break;
        }
    }
    
    if (incrementTrackNumbers) {
        for (CMIDIMessage * msg in messages) {
            if (msg.isTimeMessage) {
                msg.track = 0;
            } else {
                msg.track = msg.track+1;
            }
        }
    } else {
        for (CMIDIMessage * msg in messages) {
            if (msg.isTimeMessage) msg.track = 0;
        }
    }
}



// Fix trackCount, songLength, trackLength
- (void) setTrackCountAndEndOfTrackTimes
{
    trackCount = 0;
    for (CMIDIMessage * msg in messages) {
        if (msg.track >= trackCount) trackCount = msg.track+1;
    }
    
    CMIDIClockTicks eotTimes[trackCount];
    
    for (NSUInteger trackNo = 0; trackNo < trackCount; trackNo++) {
        eotTimes[trackNo] = 0;
    }
    songLength = 0;
    
    for (CMIDIMessage * msg in messages) {
        if (msg.time > eotTimes[msg.track]) eotTimes[msg.track] = msg.time;
        if (msg.time > songLength) songLength = msg.time;
    }
    eotTimes[0] = songLength; // The tempo track is the same length as the song.
    
    // Add end of track messages with lengths longer than any element of the track.
    // (If the end of track had a correct time, then we are just re-adding it).
    endOfTrackTimes = [NSMutableArray new];
    for (NSUInteger trackNo = 0; trackNo < trackCount; trackNo++) {
        [endOfTrackTimes addObject:[NSNumber numberWithInteger:eotTimes[trackNo]]];
    }
}


- (void) removeEndOfTrackMessages
{
    // Remove all the existing end-of-track messages.
    NSIndexSet * idxs = [messages indexesOfObjectsPassingTest:^BOOL(CMIDIMessage * msg, NSUInteger idx, BOOL *stop) {
        return msg.metaMessageType == MIDIMeta_EndOfTrack;
    }];
    [messages removeObjectsAtIndexes:idxs];

}


- (void) addEndOfTrackMessages
{
    for (NSUInteger i = 0; i < self.trackCount; i++) {
        CMIDIMessage * msg = [CMIDIMessage messageEndOfTrack];
        msg.time = [endOfTrackTimes[i] integerValue];
        msg.track = i;
        [messages addObject:msg];
    }
}

// Change Note-On with velocity=0 into "Note Off" so that these are sorted into the right position for comparison.
// Remove meaningless note offs (note offs that do not follow any note on)
// Report notes left on at the end of the song.
- (void) standardizeNoteOff
{
    NSUInteger noteOns[128][17][trackCount];
    for (NSUInteger note = 0; note < 128; note++) {
        for (NSUInteger channel = 1; channel < 17; channel++) {
            for (NSUInteger track = 0; track < trackCount; track++) {
                noteOns[note][channel][track] = 0;
            }
        }
    }
    
    NSMutableArray * newMessages = [NSMutableArray arrayWithCapacity:messages.count];
    for (CMIDIMessage * msg in messages) {
        
        UInt8 t = msg.type;
        
        // Change "Note On" with velocity = 0 into a "Note Off" message, for standardization.
        if (t == MIDIMessage_NoteOn && msg.velocity == 0) {
            t = MIDIMessage_NoteOff;
            msg.data = [CMIDIMessage messageWithNoteOff:msg.noteNumber releaseVelocity:0 channel:msg.channel].data;
        }
        
        // Elminate meaningless note off messages.
        if (t == MIDIMessage_NoteOff &&
            noteOns[msg.noteNumber][msg.channel][msg.track] == 0)
        {
            printf("CMIDIFile: Meaningless note-off message found; ignoring. Track=%lu Channel=%s Time=%llu Note=%s\n",
                   msg.track, msg.channelName.UTF8String, msg.time, msg.noteName.UTF8String);
        } else {
            [newMessages addObject:msg];
            
            // Count the note-ons and note-offs
            if (t == MIDIMessage_NoteOn) {
                noteOns[msg.noteNumber][msg.channel][msg.track]++;
            } else if (t == MIDIMessage_NoteOff) {
                noteOns[msg.noteNumber][msg.channel][msg.track]--;
            }
        }
        
    }
    
    for (int i = 0; i < 128; i++) {
        for (int j = 1; j <= 16; j++) {
            for (int k = 0; k < trackCount; k++) {
                if (noteOns[i][j][k] > 0) {
                    printf("CMIDIFile: Note left on at the end of the track: Ignoring problem. Track=%d Channel=%d Note number=%d\n",k,j,i);
                }
            }
        }
    }
    
    messages = newMessages;
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
