//
//  CClock.h
//  SqueezeBox 0.2.2
//
//  Created by CHARLES GILLINGHAM on 2/28/15.
//  Copyright (c) 2015 CHARLES GILLINGHAM. All rights reserved.
//


#import "CMIDI Time.h"
#import "CMIDITempoMeter.h"
#import "CTimeMap+TimeString.h"



// -----------------------------------------------------------------------------
#pragma mark            CClock
// -----------------------------------------------------------------------------

@interface CMIDIClock : NSObject

// Time is represented with this set of three integers.
@property CMIDINanoseconds            nanosecondsPerTick; // Tempo.
@property CMIDIClockTicks             currentTick;        // The current clock tick.
@property (readonly) CMIDINanoseconds timeOfCurrentTick;  // Host time when the current tick began.

// Transport
- (void) start;
- (void) stop;
@property BOOL isRunning;

// Receivers
// Clients should take care the objects in "receivers" all conform to CMIDITimeReceiver and are prepared to receive ticks as soon as the clock starts.
// Clients should stop the clock when adding receivers; NSMutableArray is not thread safe.
@property NSMutableArray * receivers;

// -----------------------------------------------------------------------------
#pragma mark            Other formats
// -----------------------------------------------------------------------------
// Note that float numbers are subject to floating point errors.
@property Float64 beatsPerMinute;               // Tempo.
@property Float64 timeInSecondsOfCurrentTick;   // Host time when the current clock tick began.

// -----------------------------------------------------------------------------
#pragma mark            Time map
// -----------------------------------------------------------------------------
// Used to store tempo changes, as when we are playing back a MIDI file. Can also be used to:
// - Store tempo changes for later times.
// - Find values for other time lines, such as the current beat or current bar.
// - Translate times from different time lines, taking into consideration meter changes and tempo changes.
// - Produce strings that express the time in other formats, such as bars:beats:ticks:nanos
// - Give the "time strength"; a measure of the "importance" of each clock tick.
// See CMIDITempoMeter.h, CTimeMap.h and CTimeMap+TimeString.h
@property CMIDITempoMeter * timeMap;
@end


// -----------------------------------------------------------------------------
#pragma mark            CTimeReceiver protocol
// -----------------------------------------------------------------------------
// A "time receiver" is notified on each "clock tick" (24 times per beat or more).
// These are called on the CoreMIDI thread. No autoreleasepool is in place.

@class CMIDIClock;


@protocol CMIDITimeReceiver
- (void) clockTicked:  (CMIDIClock *) c;
@optional
- (void) clockStarted:  (CMIDIClock *) c;
- (void) clockStopped:  (CMIDIClock *) c;
- (void) clockTempoSet: (CMIDIClock *) c;
- (void) clockTimeSet:  (CMIDIClock *) c;
@end

