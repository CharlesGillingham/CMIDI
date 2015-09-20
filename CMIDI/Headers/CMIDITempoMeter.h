//
//  CMIDITempoMeter.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 9/11/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDI Time.h"
#import "CMIDIMessage.h"
#import "CMIDIReceiver CMIDISender.h"
#import "CTimeMap.h"

enum {
    CMIDITimeLine_Nanos   = 0,
    CMIDITimeLine_Ticks   = 1,
    CMIDITimeLine_Eighths = 2,
    CMIDITimeLine_Beats   = 3,
    CMIDITimeLine_Bars    = 4
};

enum {
    CMIDITimeString_None = 0,
    CMIDITimeString_TimeSignal = 1,
    CMIDITimeString_Seconds = 2,
    CMIDITImeString_Ticks = 3,
    CMIDITimeString_Eighths = 4,
    CMIDITimeString_Beats = 5,
    CMIDITImeString_Bars = 6,
    CMIDITimeString_TempoMeter = 7
};


@interface CMIDITempoMeter : CTimeMap <CMIDIReceiver>

@property (readonly) SInt64  ticksPerBeat;


- (instancetype) initWithTicksPerBeat: (SInt64) ticksPerBeat;

// -----------------------------------------------------------------------------
#pragma mark            Tempo changes
// -----------------------------------------------------------------------------
- (void) tempoChangesToNanosecondsPerTick: (CMIDINanoseconds) nanosecondsPerTick
                                   onTick: (CMIDIClockTicks) tick;
- (void) tempoChangesToBeatsPerMinute: (Float64) BPM
                               onTick: (CMIDIClockTicks) tick;
- (void) tempoChangesToMicrosecondsPerBeat: (SInt64) MPB
                                    onTick: (CMIDIClockTicks) tick;

// -----------------------------------------------------------------------------
#pragma mark            Tempo changes
// -----------------------------------------------------------------------------
- (void) meterChangesToBeatsPerBar: (NSUInteger) BPB
                    eighthsPerBeat: (NSUInteger) EPB
                             onBar: (SInt64) bar;
// -----------------------------------------------------------------------------
#pragma mark            MIDI Messages
// -----------------------------------------------------------------------------
// Set tempo and meter changes in the time map using MIDI messages

- (void) respondToMIDI: (CMIDIMessage *) msg;

+ (instancetype) mapWithMessageList: (NSArray *) messageList
                       ticksPerBeat: (CMIDIClockTicks) ticksPerBeat;

@end



// -----------------------------------------------------------------------------
#pragma mark            Some Old Notes
// -----------------------------------------------------------------------------
// Some old notes which may be useful in the future. Not currently using "hostTime" as a timeLine in the timeMap, although the clock has two timelines: tick and 

/* In a music application, there are three different time lines.
 
 1. "Host time" measured in integer CMIDINanoseconds; the "real" time, from the machine's clock.
 2. "Media time" measured in integer CMIDINanoseconds; a moment in "media" time, a point in the sequence (or composition).
 3. "Bar/Beat time" measured in integer CMIDIClockTicks.
 
 The relationship between "host time" and "media time" is determined by the clock. When the clock is running, media time and host time move in sync. When the clock is stopped, host time moves forward but media time stops, so the relationship between them will change depending on what the clock is doing.
 
 The relationship between "media time" and "bar/beat time" is determined by "ticksPerBeat", which appears in the header of MIDI files or may be set by an application. This is typically fixed for the lifetime of an application.
 
 A list of MIDI messages may contain either:
 1. Absolute times. This is usually these case with live/real time MIDI messages, where the time field may be the host time that the messages was received, or the time that the message be delivered to the external device.
 2. Relative times. In MIDI files, time stamps are stored as relative ticks for each track -- the time between each successive message.
 
 */

