//
//  CMIDIClock+Debug.h
//  SqueezeBox 0.0.1
//
//  Created by CHARLES GILLINGHAM on 6/16/15.
//  Copyright (c) 2015 SqueezeBox. All rights reserved.
//

#import "CDebugSelfCheckingObject.h"
#import "CMIDIClock.h"

#define CMIDIClock_50_BPM_at_24_TPB  50000000
#define CMIDIClock_64_BPM_at_24_TPB  39062500
#define CMIDIClock_80_BPM_at_24_TPB  31250000
#define CMIDIClock_100_BPM_at_24_TPB 25000000
#define CMIDIClock_125_BPM_at_24_TPB 20000000
#define CMIDIClock_128_BPM_at_24_TPB 19531250
#define CMIDIClock_160_BPM_at_24_TPB 15625000
#define CMIDIClock_200_BPM_at_24_TPB 12500000
#define CMIDIClock_250_BPM_at_24_TPB 10000000



@interface CMIDIClock (Debug) <CDebugSelfCheckingObject>
// Run the clock without delays, on the main thread.
- (void) runForTesting: (CMIDIClockTicks) start : (CMIDIClockTicks) stop;


// Tests
+ (BOOL) basicTest: (CMIDINanoseconds) tempo; // Tests timing and tick order.
+ (BOOL) testBPM;
+ (BOOL) testTickOrderTempoChange;
+ (BOOL) testTickOrderStartStop; // Make sure that ticks are correct when we start, stop and reset the time.
+ (BOOL) timingInspectionTest;
@end