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

#import "CMIDIFileParser.h"


//------------------------------------------------------------------------------
#pragma mark                   CMIDIFile
//------------------------------------------------------------------------------


@interface CMIDIFile ()
@property (readwrite) NSString * fileName;
@property (readwrite) NSURL * fileURL;
@end

@implementation CMIDIFile
@synthesize messages;
@synthesize fileName;
@synthesize fileURL;
@synthesize format;
@synthesize ticksPerBeat;
@synthesize trackCount;
@synthesize songLength;
@synthesize endOfTrackTimes;
//@synthesize firstError;
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


+ (instancetype) MIDIFileWithMessages: (NSArray *) messages
{
    CMIDIFile * mf = [CMIDIFile new];
    mf.messages = [NSMutableArray arrayWithArray:messages];
    return mf;
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
    NSMutableArray * msgs;
    CMIDIFileParser * parser = [CMIDIFileParser new];
    if ([parser parseFileData:fileData
                     format:&fmt
               ticksPerBeat:&tpb
                 trackCount:&ntrks
                   messages:&msgs])
    {
        fileName = fURL.path;
        fileURL = fURL;
        format = fmt;
        ticksPerBeat = tpb;
        trackCount = ntrks;
        messages = msgs;
        
        // Correct any errors in the messsage list that we can.
        
        // Tempo and meter messages go on track 0.
        [self cleanTempoAndMeterTrack];
        [self setTrackCountAndEndOfTrackTimes];
        [self standardizeNoteOff];
        [self removeEndOfTrackMessages];
        messages = [NSMutableArray arrayWithArray:[CMIDIMessage sortedMessageList:messages]];
        return YES;
    } else {
        * error = parser.firstError;
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
    
    CMIDIFileParser * parser = [CMIDIFileParser new];
    NSData * fileData = [parser fileData:messages
                                  format:format
                              trackCount:trackCount
                            ticksPerBeat:ticksPerBeat];
    
    if (!fileData) {
        * error = parser.firstError;
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


@end
