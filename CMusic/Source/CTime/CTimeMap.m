//
//  CTimeMap.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 7/11/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

// Invariant:
// Time period of time 0 (at any level) is 0.
// All "totalTimes" at 0 are all 0.
// Relative times at time 0 are all 0.
// All offsets for the time hierarchy of time period 0 are always 0.

#import "CTimeMap.h"
#import "CTimeMap+TimeString.h"


@interface CTimeMap ()
@property (readwrite) NSMutableArray * _hierarchyChangeTimes; // List of CCurrentTimes
@property (readwrite) NSMutableArray * _hierarchyDuringTimePeriod;

// These four properties are used by CTimeMap+Description
@property (readwrite) NSString    * timeStringHeader;
@property (readwrite) NSArray     * timeStringFormatNames;
@property (readwrite) NSUInteger    timeStringMaxLength;
@property CTimeStringFormat        _timeStringFormat;
@property NSArray                * _timeLineNames;
@end


@implementation CTimeMap
@synthesize _hierarchyChangeTimes;
@synthesize _hierarchyDuringTimePeriod;
@synthesize depth;
@synthesize maxTimeLine;
@dynamic countOfTimePeriods;

// Synthesize these for CTimeMap+Description
@synthesize timeStringHeader;
@synthesize timeStringFormatNames;
@synthesize timeStringMaxLength;
@synthesize _timeStringFormat;
@synthesize _timeLineNames;

- (id) initWithHierarchy: (CTimeHierarchy *) ht
{
    NSParameterAssert(depth <= CTime_MaxDepth);
    
    if (self = [super init]) {
        _hierarchyChangeTimes      = [NSMutableArray new];
        _hierarchyDuringTimePeriod = [NSMutableArray arrayWithObject:ht];
        depth = ht.depth;
        maxTimeLine = ht.depth-1;
        _timeLineNames = nil;
        [self initializeTimeStrings];
    }
    return self;
}

// Enforce designated initializer
- (id) init { NSAssert(NO,@"This class has a designated initializer or initializers.");
    return [self initWithHierarchy:nil]; /* for the compiler */ }


// Convenience
+ (instancetype) mapWithBranchCounts:(CTime *)bcData count:(NSUInteger)count
{
    NSMutableArray * branchCounts = [NSMutableArray arrayWithCapacity:count];
    for (CTimeLine i = 0; i < count; i++) {
        [branchCounts addObject:[NSNumber numberWithLongLong:bcData[i]]];
    }
    CTimeHierarchy * th = [[CTimeHierarchy alloc] initWithBranchCounts:branchCounts];
    return [[[self class] alloc] initWithHierarchy:th];
}


// -----------------------------------------------------------------------------
#pragma mark        CTimeMap: Time Periods
// -----------------------------------------------------------------------------

- (NSUInteger) countOfTimePeriods
{
    return _hierarchyDuringTimePeriod.count;
}


- (NSUInteger) timePeriodOfTime: (CTime) t timeLine: (CTimeLine) level
{
    for (NSUInteger i = 0; i < _hierarchyChangeTimes.count; i++) {
        CTime changeTime   = [_hierarchyChangeTimes[i] longLongValue];
        CTimeHierarchy * th = _hierarchyDuringTimePeriod[i];
        CTime tPrime = [th convertTime:t from:level to:0];
        if (tPrime < changeTime) {
            return i;
        }
    }
    return _hierarchyChangeTimes.count; // last time period.
}


NSComparisonResult CTimeRelativeTimeOrder(NSArray * r1,
                                          NSArray * r2)
{
    NSInteger count = r1.count;
    for (NSInteger level = count-1; level >= 0; level--) {
        if ([r1[level] isGreaterThan: r2[level]]) return NSOrderedDescending;
        if ([r1[level] isLessThan: r2[level]]) return NSOrderedAscending;
    }
    return NSOrderedSame;
}



- (NSUInteger) timePeriodOfTimeSignal: (NSArray *) rt
{
    for (NSUInteger i = 0; i < _hierarchyChangeTimes.count; i++) {
        CTime changeTime   = [_hierarchyChangeTimes[i] longLongValue];
        CTimeHierarchy * th = _hierarchyDuringTimePeriod[i];
        
        // This is the first moment of the time period FOLLOWING time period i.
        // We know we are greater than or equal to every time that preceded this one.
        // If rt is strictly less than this time, then we know that i is the right time perdio.
        NSArray * relativeTimes = [th timeSignalForTime:changeTime timeLine:0];
        if (CTimeRelativeTimeOrder(relativeTimes, rt) == NSOrderedDescending) {
            return i;
        }
    }
    
    // Last time period.
    return _hierarchyChangeTimes.count;
}


- (CTime) startOfTimePeriod: (NSUInteger) tp
{
    if (tp == 0) {
        return CTime_Min;
    } else {
        return [_hierarchyChangeTimes[tp-1] longLongValue];
    }
}


- (CTime) endOfTimePeriod: (NSUInteger) tp
{
    if (tp >= _hierarchyChangeTimes.count) {
        return CTime_Max;
    } else {
        return [_hierarchyChangeTimes[tp] longLongValue];
    }
}


// -----------------------------------------------------------------------------
#pragma mark               Retreive hierarchies
// -----------------------------------------------------------------------------

- (CTimeHierarchy *) lastHierarchy
{
    return _hierarchyDuringTimePeriod.lastObject;
}

- (CTimeHierarchy *) hierarchyDuringTimePeriod: (NSUInteger) tp;
{
    return _hierarchyDuringTimePeriod[tp];
}


- (CTimeHierarchy *) hierarchyAtTime: (CTime) t timeLine: (NSUInteger) level
{
    NSUInteger tp = [self timePeriodOfTime:t timeLine:level];
    return _hierarchyDuringTimePeriod[tp];
    
}

- (CTimeHierarchy *) hierarchyForTimeSignal: (NSArray *) timeSignal
{
    NSUInteger tp = [self timePeriodOfTimeSignal:timeSignal];
    return _hierarchyDuringTimePeriod[tp];
}

// -----------------------------------------------------------------------------
#pragma mark                Time Conversions
// -----------------------------------------------------------------------------

- (CTime) convertTime: (CTime) time from: (CTimeLine) timeLineA to: (CTimeLine) timeLineB
{
    return [[self hierarchyAtTime:time timeLine:timeLineA] convertTime:time from:timeLineA to:timeLineB];
}

- (NSArray *) timeSignalForTime: (CTime) time timeLine: (CTimeLine) timeLine
{
    return [[self hierarchyAtTime:time timeLine:timeLine] timeSignalForTime:time timeLine:timeLine];
}

- (CTime) timeOnTimeLine: (CTimeLine) timeLine fromTimeSignal: (NSArray *) timeSignal
{
    return [[self hierarchyForTimeSignal:timeSignal] timeOnTimeLine:timeLine fromTimeSignal:timeSignal];
}

- (NSUInteger) timeStrengthOfTime: (CTime) time timeLine: (CTimeLine) timeLine
{
    return [[self hierarchyAtTime:time timeLine:timeLine] timeStrengthOfTime:time timeLine:timeLine];
}


// -----------------------------------------------------------------------------
#pragma mark   Set branch count
// -----------------------------------------------------------------------------


// e.g. suppose Bs = bars. When the current bar = B, beats per bar changes to AsPerBs.
- (void) branchCountAtLevel: (CTimeLine) levelA
                  changesTo: (CTime) AsPerB
                     atTime: (CTime) B
{
    NSParameterAssert(levelA+1 < self.depth);
    
    // We don't currently allow meter changes before zero. The hierarchy at time zero applies to all earlier times.
    // Setting a branch count at 0 or below sets the branch count at zero.
    // Note that there is an alternative interface for this case.
    if (B <= 0) {
        [self setBranchCount:AsPerB atLevel:levelA];
        return;
    }
    
    CTimeLine        levelB            = levelA+1;
    CTimeLine        tp = [self timePeriodOfTime:B timeLine:levelA+1];
    CTimeHierarchy * th = _hierarchyDuringTimePeriod[tp];
    CTime            s  = [self startOfTimePeriod:tp];
    
    // No change.
    if ([th AsPerB:levelA:levelB] == AsPerB) return;
    
    // Adding a tempo or meter change before the end of the map erases the rest of the map.
    // This guarantees that we are adding a branch count at the end of the time map.
    if (tp+1 < self.countOfTimePeriods) {
        
        // Just writing all these out so I don't get confused ...
        NSUInteger newCountOfTimePeriods = tp+1;
        NSUInteger nTimePeriodsToRemove = self.countOfTimePeriods - newCountOfTimePeriods;
        NSUInteger firstTimePeriodToRemove = tp+1;
        NSRange r = {firstTimePeriodToRemove, nTimePeriodsToRemove};
        [_hierarchyDuringTimePeriod removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:r]];
        
        NSAssert(self.countOfTimePeriods-1 == tp,@"FENCEPOST BUG");
        
        NSRange r2 = {firstTimePeriodToRemove-1, nTimePeriodsToRemove};
        [_hierarchyChangeTimes removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:r2]];
        
        NSAssert(_hierarchyChangeTimes.count+1 == _hierarchyDuringTimePeriod.count,@"FENCEPOST BUG");
    }
    
    // Just to make it clear to myself
    CTimeHierarchy * lastTimeHierarchy = th;
    CTime            lastStartTime     = s;
    
    CTime startTime = [lastTimeHierarchy convertTime:B from:levelB to:0];
    
    // Note B <= 0 -- _hierarchyDuringTimePeriod[0] keeps the branch counts for
    if (lastStartTime == startTime || B <= 0) {
        th = lastTimeHierarchy;
        
    } else {
        
        // Add a hierarchy at the end.
        th = [lastTimeHierarchy copy];
        [_hierarchyDuringTimePeriod addObject:th];
        [_hierarchyChangeTimes      addObject:[NSNumber numberWithLongLong:startTime]];
    }
    
    [th setBranchCount:AsPerB atLevel:levelA withTimeFixedAt:B];
}




// Convenience for setting branch count for the entire time line.
// This is equivalent to the above with B <= 0.
- (void) setBranchCount: (CTime) AsPerB atLevel: (CTime) levelA
{
    NSParameterAssert(levelA+1 < self.depth);
    
    CTimeHierarchy * th = _hierarchyDuringTimePeriod[0];
        
    // Adding a tempo or meter change before the end of the map erases the rest of the map.
    // This guarantees that we are adding a branch count at the end of the time map.
    if (self.countOfTimePeriods > 1) {
        _hierarchyDuringTimePeriod = [NSMutableArray arrayWithObject:th];
        [_hierarchyChangeTimes removeAllObjects];
    }
    
    [th setBranchCount:AsPerB atLevel:levelA];
}



// Convenience getter
- (CTime) branchCountAtLevel:(CTimeLine)levelA atTime:(CTime)t level:(CTimeLine)level
{
    CTimeHierarchy * th = [self hierarchyAtTime:t timeLine:level];
    return [th AsPerB:levelA:levelA+1];
}


@end

