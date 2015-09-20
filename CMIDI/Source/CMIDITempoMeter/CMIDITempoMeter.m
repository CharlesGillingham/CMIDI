//
//  CMIDITempoMeter.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 9/11/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDITempoMeter.h"
#import "CMIDIMessage+MetaMessage.h"
#import "CTimeMap+TimeString.h"

#define CMIDIDefaultTempoAt24TPB (250000000)
#define CMIDIDefaultTempoAt480TPB  (1250000)


@interface CMIDITempoMeter ()
@property (readwrite) SInt64 ticksPerBeat;
@end

@implementation CMIDITempoMeter
@synthesize ticksPerBeat;

#define nanosecondsPerMinute (60000000000.0)

// Branch counts for common time (4/4) with BPM = 100
- (NSArray *) defaultBranchCounts: (SInt64) tpb
{
    CTime BPM = 100;
    CTime NPT = nanosecondsPerMinute / (BPM * tpb);
    CTime tp8 = tpb / 2;
    NSNumber * ticksPerEighth = [NSNumber numberWithLongLong:tp8];
    NSNumber * nanosPerTick   = [NSNumber numberWithLongLong:NPT];
    return @[nanosPerTick, ticksPerEighth, @2, @4];
}


- (id) initWithTicksPerBeat: (SInt64) tpb
{
    CTimeHierarchy  * th = [CTimeHierarchy alloc];
    th = [th initWithBranchCounts:[self defaultBranchCounts:tpb]];
    if (self = [super initWithHierarchy:th]) {
        ticksPerBeat = tpb;
        self.timeLineNames = @[@"Nano", @"Tick", @"8th", @"Beat", @"Bar"];
        self.timeStringFormat = CTimeString_timeSignal;
     }
    return self;
}


- (void) tempoChangesToNanosecondsPerTick: (SInt64) nanosecondsPerTick onTick: (SInt64) tick
{
    [self branchCountAtLevel:CMIDITimeLine_Nanos changesTo:nanosecondsPerTick atTime:tick];
}


- (void) tempoChangesToMicrosecondsPerBeat: (SInt64) MPB onTick: (SInt64) tick
{
    SInt64 NPT = (MPB * 1000) / ticksPerBeat;
    [self branchCountAtLevel:CMIDITimeLine_Nanos changesTo:NPT atTime:tick];
}


- (void) tempoChangesToBeatsPerMinute: (Float64) BPM onTick:(SInt64)tick
{
    SInt64 NPT = nanosecondsPerMinute / (BPM * ticksPerBeat);
    [self branchCountAtLevel:CMIDITimeLine_Nanos changesTo:NPT atTime:tick];
}


- (void) meterChangesToBeatsPerBar: (NSUInteger) bpb
                    eighthsPerBeat: (NSUInteger) epb
                             onBar: (SInt64)  bar
{
    SInt64 eighth = [self convertTime:bar from:CMIDITimeLine_Bars to:CMIDITimeLine_Eighths];
    SInt64 beat   = [self convertTime:bar from:CMIDITimeLine_Bars to:CMIDITimeLine_Beats];
    
    // Keep 8ths per beat steady, by modifying ticks/eighth
    SInt64 tp8 = ticksPerBeat/epb;
    
    [self branchCountAtLevel:CMIDITimeLine_Beats   changesTo:bpb atTime:bar];
    [self branchCountAtLevel:CMIDITimeLine_Eighths changesTo:epb atTime:beat];
    [self branchCountAtLevel:CMIDITimeLine_Ticks   changesTo:tp8 atTime:eighth];
}


// -----------------------------------------------------------------------------
#pragma mark            MIDI Messages
// -----------------------------------------------------------------------------
// Although we could make CMIDITempoMeter a "CMIDIReceiver", I don't think this is really useful, because we don't respond to a number of important timing messages, such as MIDISystemMsg_MIDITimeCodeQtrFrame, SMPTE offset, etc., etc.. If support is added for these messages, then this makes sense.


- (void) respondToMIDI: (CMIDIMessage *) msg
{
    switch (msg.metaMessageType) {
        case MIDIMeta_TimeSignature: {
            NSInteger bar = [self convertTime:msg.time
                                         from:CMIDITimeLine_Ticks
                                           to:CMIDITimeLine_Bars];
            [self meterChangesToBeatsPerBar:msg.beatsPerBar
                             eighthsPerBeat:msg.eighthsPerBeat
                                      onBar:bar];
            break;
        }
        case MIDIMeta_TempoSetting: {
            [self tempoChangesToMicrosecondsPerBeat:msg.MPB
                                             onTick:msg.time];
            break;
        }
        default:
            break;
            
    }
}


// Used with files
+ (instancetype) mapWithMessageList: (NSArray *) messageList
                       ticksPerBeat: (CMIDIClockTicks) ticksPerBeat
{
    CMIDITempoMeter * tm = [[CMIDITempoMeter alloc] initWithTicksPerBeat:ticksPerBeat];
    if (tm) {
        for (CMIDIMessage * msg in messageList) {
            [tm respondToMIDI:msg];
        }
    }
    return tm;
}



@end

