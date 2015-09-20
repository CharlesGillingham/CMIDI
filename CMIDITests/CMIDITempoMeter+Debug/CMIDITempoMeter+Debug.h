//
//  CMIDITimeMonitor+Debug.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 7/3/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//
#import "CMIDITempoMeter.h"

@interface CMIDITempoMeter (Debug)
// Requires CMusic+Debug, which isn't here.
//+ (void) inspectTicks;
//+ (void) inspectNanos;
//+ (void) inspectBeats;
+ (BOOL) testTicksPerBeat;
@end
