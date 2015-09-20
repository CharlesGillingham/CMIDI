//
//  CMIDIFile.m
//
//  Created by Charles Gillingham on 11/15/12.
//
//  TODO: KVO for fileName and URL.

#import <AudioToolBox/AudioToolBox.h>
#import "CDebugMessages.h"
#import "CMIDIFileByApple.h"

#import "CMIDIMessage+MetaMessage.h"
#import "CMIDIMessage+SystemMessage.h"
#import "CMIDIMessage+ChannelMessage.h"
#import "CMIDIMessage+Description.h"
#import "CMIDIVSNumber.h"
#import "CMIDIMessageByteCount.h"
#import "CMIDITempoMeter.h"
#import "CMIDIMessage+DescriptionWithTime.h"

@interface CMIDIFileByApple ()
@property (readwrite) NSString * fileName;
@property (readwrite) NSURL    * URL;
@end


@implementation CMIDIFileByApple {
    MusicSequence         _sequence;
    MusicSequenceType     _type;
}
@synthesize fileName;
@synthesize URL;
@synthesize messages;
@synthesize ticksPerBeat;


// -----------------------------------------------------------------------------
#pragma mark                Constructors
// -----------------------------------------------------------------------------

- (id) initWithTicksPerBeat: (CMIDIClockTicks) tpb
{
    if (self = [super init]) {
        // Objects are created on an "as needed" basis.
        _sequence = nil;
        ticksPerBeat = tpb;
    }
    return self;
}


CENFORCE_DESIGNATED_INITIALIZER


+ (instancetype) MIDIFileWithContentsOfFile: (NSURL *) fURL
                               ticksPerBeat: (CMIDIClockTicks) ticksPerBeat
                                      error: (NSError **) error
{
    OSStatus err;
    MusicSequence newSequence;
    CNOERR( NewMusicSequence(&newSequence) );
    
    if ((err = MusicSequenceFileLoad(newSequence, (__bridge CFURLRef) fURL, 0, 0))) {
        *error = [NSError errorWithDomain:@"com.OSStatus" code:err userInfo:NULL];
        return nil;
    }
    *error = nil;
    
    CMIDIFileByApple * af =  [[self alloc] initWithMusicSequence: newSequence ticksPerBeat:ticksPerBeat];
    af.fileName = fURL.path;
    af.URL = fURL;
    
    return af;
}


- (id) initWithMusicSequence: (MusicSequence) newSequence
                ticksPerBeat: (CMIDIClockTicks) tpb
{
    if (self = [super init]) {
        _sequence = newSequence;
        ticksPerBeat = tpb;
        
        // This interface only supports "beats" at the present time.
        CNOERR( MusicSequenceGetSequenceType(newSequence, &_type) );
        if (!CASSERT(_type == kMusicSequenceType_Beats)) return nil;
        
        UInt32 nTracks;
        CNOERR(MusicSequenceGetTrackCount(_sequence, &nTracks));
        messages = [NSMutableArray new];
        for (UInt32 i = 0; i < nTracks+1; i++) {
            [self addMessagesOnTrack:i];
        }
        messages = [NSMutableArray arrayWithArray:[CMIDIMessage sortedMessageList:messages]];

    }
    return self;
}


- (void) dealloc
{
    DisposeMusicSequence(_sequence);
}




- (void) addMessagesOnTrack: (UInt32) i
{
    MusicTrack track;
    if (i == 0) {
        CNOERR(MusicSequenceGetTempoTrack(_sequence, &track));
    } else {
        CNOERR(MusicSequenceGetIndTrack(_sequence, i-1, &track));
    }
    
    MusicEventIterator iter;
    Boolean fMore = true;
    CNOERR( NewMusicEventIterator(track, &iter) );
    
    // For each event
    CNOERR(MusicEventIteratorHasCurrentEvent(iter, &fMore));
    MusicTimeStamp eventTime = 0;
    CMIDIClockTicks t, maxt = 0;
    while (fMore) {
        MusicEventType eventType;
        const void *eventData;
        UInt32 size;
        
        CNOERR( MusicEventIteratorGetEventInfo(iter, &eventTime, &eventType, &eventData, &size) );
        
        // Event time is in beats.
        t = (CMIDIClockTicks) round(eventTime * ticksPerBeat);
        if (t > maxt) maxt = t;
        
        [self addEventWithType: eventType
                          data: (MusicEventData *) eventData
                          size: size
                   timeInBeats: eventTime
                   timeInTicks: t
                   trackNumber: i];
        
        CNOERR( MusicEventIteratorNextEvent(iter) );
        CNOERR( MusicEventIteratorHasCurrentEvent(iter, &fMore) );
    }
 }






typedef union MusicEventData {
    MIDINoteMessage noteMessage;            // returned as two MIDI messages.
    MIDIChannelMessage channelMessage;      // returned as a MIDI message.
    MIDIRawData rawData;                    // returned as a SystemExclusive MIDI message.
    MIDIMetaEvent metaEvent;                // returned as a Meta MIDI message
    ExtendedTempoEvent tempoEvent;          // returned as a Meta Tempo Setting
    MusicEventUserData userData;            // not currently returned.
    ExtendedNoteOnEvent extendedNoteOnEvent;// not currently returned.
    ParameterEvent parameterEvent;          // not currently returned.
    AUPresetEvent auPresetEvent;            // not currently returned.
} MusicEventData;



- (void) addEventWithType: (MusicEventType) typ
                     data: (const MusicEventData *) eData
                     size: (UInt32) size
                     timeInBeats: (Float64) beats
              timeInTicks: (CMIDIClockTicks) t
              trackNumber: (NSUInteger) track
{
    CMIDIMessage * msg;
    
    switch (typ) {
            
        case kMusicEventType_MIDIChannelMessage: {
            Byte       status = eData->channelMessage.status;
            const Byte * data = (const Byte *) &(eData->channelMessage.data1);
            NSUInteger    len = 3;
            
            // Truncate messages with length shorter than three, such as MIDIMessage_ProgramChange.
            OSStatus errCode;
            len = CMIDIMessageByteCount(status, data, len, YES, &errCode);
            
            msg = [CMIDIMessage messageWithBytes:(const Byte *) eData
                                          length:len];
            break;
        }
        case kMusicEventType_Meta: {
            CMIDIVSNumber * vs = [CMIDIVSNumber numberWithInteger:eData->metaEvent.dataLength];
            NSUInteger msgLength = 2 + vs.dataLength + eData->rawData.length;
            NSMutableData * d = [NSMutableData dataWithCapacity:msgLength];
            Byte buf[2] = {MIDISystemMsg_Meta, eData->metaEvent.metaEventType};
            [d appendBytes:buf length:2];
            [d appendBytes:vs.data length:vs.dataLength];
            [d appendBytes:eData->metaEvent.data length:eData->metaEvent.dataLength];
            msg = [CMIDIMessage messageWithData:d];
            break;
        }
        case kMusicEventType_MIDIRawData: {
            NSUInteger len     = eData->rawData.length;
            const Byte * bytes = (const Byte *) &(eData->rawData.data);
            // NSMutableData * d  = [NSMutableData dataWithBytes:bytes length:len]; Looks it works, but actually doesn't ...
   
            // Not really clear what Apple is doing here. My file reader (which is pretty simple) and Apple disagree about the contents of these messages. This block of raw data looks exactly like a system exclusive message, but, inexplicably, the "manufacturer ID" has been removed. It's also possible that I'm misunderstanding what my tests are showing me. This is unimportant to my current project -- call it a "possible issue".
            // In other cases, Apple misreads the SysEx or skips it all together.
            if (!CASSERT_MSG(*bytes == MIDISystemMsg_SystemExclusive && len > 1, @"Can't read Apple's kMusicEventType_MIDIRawData"))
                return;
            
            NSMutableData * d = [NSMutableData dataWithCapacity:len];
            Byte sysx = MIDISystemMsg_SystemExclusive;
            [d appendBytes:&sysx length:1];
            Byte manID = 1; // Adding a "1" manufacturerID.
            [d appendBytes:&manID length:1];
            [d appendBytes:bytes+1 length:len-1];
            if (bytes[len-1] != MIDISystemMsg_EndofSysEx) {
                Byte eosx = MIDISystemMsg_EndofSysEx;
                [d appendBytes:&eosx length:1];
            }
            
            msg = [CMIDIMessage messageWithData:d];
             
            break;
        }
        case kMusicEventType_ExtendedTempo: {
            msg = [CMIDIMessage messageWithTempoInBeatsPerMinute:eData->tempoEvent.bpm];
            break;
        }
        case kMusicEventType_MIDINoteMessage: {
            msg = [CMIDIMessage messageWithNoteOn:eData->noteMessage.note
                                         velocity:eData->noteMessage.velocity
                                          channel:eData->noteMessage.channel+1];
            msg.time = t;
            msg.track = track;
            [messages addObject: msg];
            
            msg = [CMIDIMessage messageWithNoteOff:eData->noteMessage.note
                                   releaseVelocity:eData->noteMessage.releaseVelocity
                                           channel:eData->noteMessage.channel+1];
            Float64 endBeats = beats + eData->noteMessage.duration;
            msg.time =  (CMIDIClockTicks) round(endBeats * ticksPerBeat);
            msg.track = track;
            [messages addObject: msg];
            return;
        }
        default: {
            // The remaining events are not supported, nor are they expected in normal MIDI files
            printf("WARNING: UNSUPPORTED MESSAGE IN APPLE'S MUSICSEQUENCE\n");
            return;
        }
    }
    
    msg.time = t;
    msg.track = track;
    [messages addObject:msg];
}


//------------------------------------------------------------------------------
#pragma mark                   Description
//------------------------------------------------------------------------------

- (NSString *) description
{
    return [NSString stringWithFormat:@"<CMIDIFile:%@>", self.fileName];
}


- (NSString *) longDescription: (BOOL) hideNoteOff
{
    NSMutableString * s = [NSMutableString stringWithFormat:@"MIDI FILE BY APPLE %@\n\n", self.fileName];
    CMIDITempoMeter * timeMap = [CMIDITempoMeter mapWithMessageList: self.messages
                                                       ticksPerBeat: self.ticksPerBeat];
    [s appendFormat:@"%@\n",[CMIDIMessage tableHeaderWithTimeMap:timeMap]];
    for (CMIDIMessage * message in self.messages) {
        if (!hideNoteOff || !message.isNoteOff) {
            [s appendFormat:@"%@\n", [message tableRowStringWithTimeMap:timeMap]];
        }
    }
    return s;
}

- (void) show: (BOOL) hideNoteOff
{
    printf("\n\n\n%s\n\n\n",[self longDescription:hideNoteOff].UTF8String);
}

@end
