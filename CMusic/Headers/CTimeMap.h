//
//  CTimeMap.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 9/8/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//


#import "CTimeHierarchy.h"

// -----------------------------------------------------------------------------
#pragma mark                    CTimeMap
// -----------------------------------------------------------------------------
// Hierarchies inside the time map should be considered immutable -- they should
// only be changed using the routines provided, because any changes can effect
// the entire map.

@interface CTimeMap : NSObject

@property (readonly) NSUInteger depth;
@property (readonly) NSUInteger maxTimeLine; // = depth-1. For convenience.
@property (readonly) NSUInteger countOfTimePeriods;

// This first hierarchy covers the time period "min" to "max"
- (id) initWithHierarchy: (CTimeHierarchy *) ht NS_DESIGNATED_INITIALIZER;

// Convenience
+ (instancetype) mapWithBranchCounts:(SInt64 *)bcData count:(NSUInteger)count;

// -----------------------------------------------------------------------------
#pragma mark                Access time periods
// -----------------------------------------------------------------------------
// The time map contains of list of time periods. Each period has a time hierarchy.
- (NSUInteger) timePeriodOfTime: (CTime) t timeLine: (CTimeLine) level;
- (NSUInteger) timePeriodOfTimeSignal: (NSArray *) times;
- (CTime) startOfTimePeriod: (NSUInteger) tp;
- (CTime) endOfTimePeriod: (NSUInteger) tp;
- (CTimeHierarchy *) hierarchyDuringTimePeriod: (NSUInteger) tp;

// -----------------------------------------------------------------------------
#pragma mark                Hierarchy
// -----------------------------------------------------------------------------
// Convenience
- (CTimeHierarchy *) hierarchyAtTime: (CTime) t timeLine: (CTimeLine) timeLine;
- (CTimeHierarchy *) lastHierarchy;

// -----------------------------------------------------------------------------
#pragma mark                Time Conversions
// -----------------------------------------------------------------------------
// Convert times between representations on various levels
// Note that time conversions to higher time lines are not typically reversible: details are lost.
- (CTime) convertTime: (CTime) time
                 from: (CTimeLine) timeLineA
                   to: (CTimeLine) timeLineB;

// -----------------------------------------------------------------------------
#pragma mark                Time Signal
// -----------------------------------------------------------------------------
// Time signals
// A time signal is like an odometer, e.g for music you might have:
// @[bars, beat since bar started, 8ths since beat started, ticks since 8th, nanoseconds since tick]
// Or, similarly for a general time:
// @[week, day of week, hour of day, minute of hour, second in minute, nanonsecond in second]
- (NSArray *) timeSignalForTime: (CTime) time
                       timeLine: (CTimeLine) timeLine;

- (CTime) timeOnTimeLine: (CTimeLine) timeLine
          fromTimeSignal: (NSArray *) timeSignal;

// -----------------------------------------------------------------------------
#pragma mark                Time strength
// -----------------------------------------------------------------------------
// A  measure of the "importance" of a moment in time. E.g. time strength on a bar line is higher than that of an an upbeat eighth.
// If the timeStrength = S, then all relative times at levels L < S will be 0.
// If you retreive a time at level L, then the time strength S will be greater than or equal to L.
- (NSUInteger) timeStrengthOfTime: (CTime) time timeLine: (CTimeLine) timeLine;

// -----------------------------------------------------------------------------
#pragma mark                Add a tempo or meter change
// -----------------------------------------------------------------------------
// Add a branch count change "AsPerB" on the timeline levelA, at the time given by B on timeline levelA+1
// E.g., add a meter change at bar 20 to 4 beats per bar (levelA = beats, levelA+1 = bars, AsPerB = 4, B = 20

// POSSIBLE ISSUE 1:
// Branch count changes can be added only at the end of the map. If the client sets a change at a time before the end of the map, all the following changes are erased. (This interface assumes a new, earlier branch count means that the clock has been rewound into the past, and that we can expect to receive the new branch counts as time progresses.)
// (It is possible to support "inserting" a branch count change, but this entails a lot more work and a second method that allows this. The base time of all following branch count changes will need to be moved to preserve the original intent. For example, a meter change that was on a bar line may now appear to be in the middle of a bar, which should be impossible. The solution would be for the interface to remember the original time line of each change and then we would need to recalculate the base time of all following changes and finally recalculate the all the offsets in the hiearchies. This is complicated enough to require extensive testing and is beyond the scope of my current projects.)

// POSSIBLE ISSUE 2:
// All branch count change times B > 0. If B <= 0, this will assume that the caller intended to call the second interface, setBranchCount:atLevel, which sets the branch counts for time period 0.
// All these invariants follow: time period 0 begins at CTime_Min (i.e. -Infinity) and extends past zero to the first branch count change (or to CTime_Max, if there are no branch count changes). Time 0 (at any level) is always in time period 0. Total times at time=0 are 0 for all levels. Relative times at time=0 are 0 for all levels.
// (It is possible to support branch counts at times less than zero. The caller probably wants to preserve all the invariants for time 0, as well as the relevant time values B. We should leave time period 0 alone and add a PRECEDING time period. The best way to represent this is with negative and positive time periods, and a few appropriate switches on B in the code. This is easy to get wrong, and is well beyond the scope of what I need for my current projects.)

// POSSIBLE ISSUE 3:
// Calling [setBranchCount:atLevel:] erases the time map except for time period 0. I.e, it sets the branch count for the entire map. (This follows from 1 & 2).

// Setter
- (void) branchCountAtLevel: (CTimeLine) levelA
                  changesTo: (CTime) AsPerB
                     atTime: (CTime) B; // levelB = levelA+1


// Set a branch count for the entire time line. (Erases any branch count changes.)
- (void) setBranchCount: (CTime) AsPerB atLevel: (CTime) levelA;


// Getter
- (CTime) branchCountAtLevel: (CTimeLine) levelA
                      atTime: (CTime) t
                       level: (CTimeLine) level;


@end




