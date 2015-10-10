//
//  CTimeHierarchy.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 9/8/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTime.h"

@interface CTimeHierarchy : NSObject <NSCopying, NSCoding>
@property (readonly) NSArray * branchCounts; 
- (NSUInteger) depth;       // Number of timeLines
- (NSUInteger) maxTimeLine; // Highest timeLine

- (id) initWithBranchCounts: (NSArray *) branchCounts
                    offsets: (NSArray *) offsets NS_DESIGNATED_INITIALIZER;

- (id) initWithBranchCounts: (NSArray *) branchCounts;

// -----------------------------------------------------------------------------
#pragma mark                Time Conversions
// -----------------------------------------------------------------------------
// Convert times between representations on various levels
// Note that time conversions to higher time lines are not typically reversible: details are lost.
- (CTime) AsPerB: (CTimeLine) timeLineA : (CTimeLine) timeLineB;
- (CTime) convertTime: (CTime) time from: (CTimeLine) timeLineA to: (CTimeLine) timeLineB;

// -----------------------------------------------------------------------------
#pragma mark                Time Signal
// -----------------------------------------------------------------------------
// Time signals
// A time signal is like an odometer, e.g
// @[bars, beat since bar started, 8ths since beat started, ticks since 8th, nanoseconds since tick]
// Or, similarly
// @[week, day of week, hour of day, minute of hour, second in minute, nanonsecond in second]
- (NSArray *) timeSignalForTime: (CTime) time timeLine: (CTimeLine) timeLine;
- (CTime) timeOnTimeLine: (CTimeLine) timeLine fromTimeSignal: (NSArray *) timeSignal;

// -----------------------------------------------------------------------------
#pragma mark                Time strength
// -----------------------------------------------------------------------------
// A  measure of the "importance" of a moment in time. E.g. time strength on a bar line is higher than that of an an upbeat eighth.
// If the timeStrength = S, then all relative times at levels L < S will be 0.
// If you retreive a time at level L, then the time strength S will be greater than or equal to L.
- (NSUInteger) timeStrengthOfTime: (CTime) time timeLine: (CTimeLine) timeLine;

// -----------------------------------------------------------------------------
#pragma mark                Change branch count
// -----------------------------------------------------------------------------
// Do not use these routines if the time hierarchy is part of a time map. Make changes to branch counts using the time map.

// Set the branch count, and reset the offsets so that [self timeAtLevel: outLevel withTime: B atLevel: levelA+1] is stays the same for all "outLevels". Used by the time map adding meter/tempo changes to a time map at time B -- the total times at B will stay exactly the same, regardless if retrieve them from the previous hierarchy or the following hierarchy.
- (void) setBranchCount: (CTime) AsPerB
                atLevel: (CTimeLine) levelA
        withTimeFixedAt: (CTime) B; // Where levelB = levelA+1

// Set the branch count directly. Used by the time map for setting branch count changes for time period 0.
- (void) setBranchCount: (CTime) AsPerB
                atLevel: (CTimeLine) levelA;

@end





