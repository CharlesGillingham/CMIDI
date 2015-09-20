//
//  CMIDIFakeClock.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 9/4/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMIDIReceiver CMIDISender.h"
#import "CMIDIClock.h"

@interface CMIDIFakeClock : NSObject
+ (CMIDIClock *) fakeClock;
@property CMIDINanoseconds            nanosecondsPerTick; // Tempo.
@property CMIDIClockTicks             currentTick;        // The current clock tick.
@property (readonly) CMIDINanoseconds timeOfCurrentTick;  // Host time when the current
- (void) start;
- (void) stop;
@property BOOL isRunning;
@property NSMutableArray * receivers;
@property Float64 beatsPerMinute;               // Tempo.
@property Float64 timeInSecondsOfCurrentTick;   // Host time when the current clock tick
@property CMIDITempoMeter * timeMap;
@end
