//
//  CMIDITimeHierarchy+Debug.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 7/3/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDITempoMeter+Debug.h"
//#import "CTimeMap+Debug.h"
#import "CDebugMessages.h"
#import "CTimeMap+TimeString.h"

@implementation CMIDITempoMeter (Debug)

/*
+ (void) inspectionTest: (SInt64) ticksPerBeat
         incrementLevel: (NSUInteger) level
{
    CMIDITempoMeter * map = [[CMIDITempoMeter alloc] initWithTicksPerBeat:ticksPerBeat];
    [map showAllFormats:level];
}


+ (void) inspectTicks { [self inspectionTest:10       incrementLevel:CMIDITimeLine_Ticks]; }
+ (void) inspectNanos { [self inspectionTest:10000000 incrementLevel:CMIDITimeLine_Nanos]; }
+ (void) inspectBeats { [self inspectionTest:10       incrementLevel:CMIDITimeLine_Beats]; }
*/



+ (BOOL) testTicksPerBeat
{
    CMIDITempoMeter * td = [[CMIDITempoMeter alloc] initWithTicksPerBeat:24];
    
    if (!CASSERTEQUAL(td.ticksPerBeat, 24)) return NO;
    
    [td meterChangesToBeatsPerBar:14 eighthsPerBeat:3 onBar:0];
    if (!CASSERTEQUAL(td.ticksPerBeat,24)) return NO;
    
    [td meterChangesToBeatsPerBar:7 eighthsPerBeat:4 onBar:0];
    if (!CASSERTEQUAL(td.ticksPerBeat,24)) return NO;
  
    [td meterChangesToBeatsPerBar:1000 eighthsPerBeat:2 onBar:0];
    if (!CASSERTEQUAL(td.ticksPerBeat,24)) return NO;
    
    [td tempoChangesToNanosecondsPerTick:457 onTick:0];
    if (!CASSERTEQUAL(td.ticksPerBeat,24)) return NO;
    
    return YES;
}


@end


