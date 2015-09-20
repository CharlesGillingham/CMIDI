//
//  CTimeHierarchy.m
//  CTime
//
//  Created by CHARLES GILLINGHAM on 7/13/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

//  Just a very simple data object

#import "CTimeHierarchy.h"


@interface CTimeHierarchy ()
@property (readwrite) CTimeLine depth;
@property (readwrite) CTimeLine maxTimeLine;
@end


@implementation CTimeHierarchy {
    CTime _branchCounts[CTime_MaxDepth-1];
    CTime _offsets[CTime_MaxDepth];
}
@synthesize depth;
@synthesize maxTimeLine;
@dynamic branchCounts;
//@dynamic offsets;

- (id) initWithBranchCounts:(NSArray *)branchCounts
{
    CTimeLine d = branchCounts.count+1;
    NSMutableArray * offsets = [NSMutableArray arrayWithCapacity:d];
    for (CTimeLine i = 0; i < d; i++) {
        [offsets addObject:@0];
    }
    return [self initWithBranchCounts:branchCounts offsets:offsets];
}


- (id) initWithBranchCounts: (NSArray *) branchCounts
                    offsets: (NSArray *) offsets
{
    NSParameterAssert(offsets.count == branchCounts.count+1);
    NSParameterAssert(offsets.count < CTime_MaxDepth);
    
    if (self = [super init]) {
        depth = offsets.count;
        maxTimeLine = depth-1;
        for (CTimeLine i = 0; i < depth-1; i++) {
            _branchCounts[i] = [branchCounts[i] longLongValue];
            _offsets[i] = [offsets[i] longLongValue];
        }
        _branchCounts[depth-1] = 0;
        _offsets[depth-1] = [offsets[depth-1] longLongValue];
        for (CTimeLine i = depth; i < CTime_MaxDepth-1; i++) {
            _offsets[i] = 0;
            _branchCounts[i] = CTime_Max;
        }
    }
    return self;
}


// Enforce designated initializer
- (id) init {
    NSAssert(NO,@"This class has a designated initializer or initializers.");
    return [self initWithBranchCounts:nil]; // for the compiler
}

// -----------------------------------------------------------------------------
#pragma mark            NSCopying
// -----------------------------------------------------------------------------

- (instancetype) copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithBranchCounts:self.branchCounts offsets:self.offsets];
}

// -----------------------------------------------------------------------------
#pragma mark            NSCoding
// -----------------------------------------------------------------------------

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSArray * branchCounts = [aDecoder decodeObjectForKey:@"branchCounts"];
    NSArray * offsets      = [aDecoder decodeObjectForKey:@"offsets"];
    return [self initWithBranchCounts:branchCounts offsets:offsets];
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.branchCounts forKey:@"branchCounts"];
    [aCoder encodeObject:self.offsets      forKey:@"offsets"];
}


// -----------------------------------------------------------------------------
#pragma mark            Convenience arrays
// -----------------------------------------------------------------------------

- (NSArray *) branchCounts {
    NSMutableArray * ret = [NSMutableArray arrayWithCapacity:depth-1];
    for (CTimeLine i = 0; i < depth-1; i++) {
        [ret addObject:[NSNumber numberWithLongLong:_branchCounts[i]]];
    }
    return ret;
}

- (NSArray *) offsets {
    NSMutableArray * ret = [NSMutableArray arrayWithCapacity:depth-1];
    for (CTimeLine i = 0; i < depth; i++) {
        [ret addObject:[NSNumber numberWithLongLong:_offsets[i]]];
    }
    return ret;
}

// -----------------------------------------------------------------------------
#pragma mark                Time Conversions
// -----------------------------------------------------------------------------
// Convert times between representations on various levels
// Note that time conversions to higher time lines are not typically reversible: details are lost.

- (CTime) AsPerB: (CTimeLine) timeLineA : (CTimeLine) timeLineB
{
    register CTime r = 1;
    for (CTimeLine i = timeLineA; i < timeLineB; i++) {
        r *= _branchCounts[i];
    }
    return r;
}


- (CTime) convertTime: (CTime) time from: (CTimeLine) inLevel to: (CTimeLine) outLevel
{
    CTime t = time - _offsets[inLevel];
    if (outLevel <= inLevel) {
        t = t * [self AsPerB: outLevel:inLevel];
    } else  {
        t = CTimeDiv(t,[self AsPerB:inLevel:outLevel]);
    }
    return t + _offsets[outLevel];
}


// -----------------------------------------------------------------------------
#pragma mark                Time Signal
// -----------------------------------------------------------------------------
// Time signals
// A time signal is like an odometer, e.g
// @[bars, beat since bar started, 8ths since beat started, ticks since 8th, nanoseconds since tick]
// Or, similarly
// @[week, day of week, hour of day, minute of hour, second in minute, nanonsecond in second]
- (NSArray *) timeSignalForTime: (CTime) time timeLine: (CTimeLine) inLevel
{
    if (inLevel >= depth) return nil;
    
    NSMutableArray * relativeTimes = [NSMutableArray arrayWithCapacity:depth];
    for (NSInteger i = 0; i < inLevel; i++) {
        [relativeTimes addObject:@0];
    }
    
    register CTime tt, rt;
    tt = time - _offsets[inLevel];
    
    for (NSInteger i = inLevel; i < depth-1; i++) {
        CTime r = _branchCounts[i];
        rt = CTimeMod(tt,r);
        [relativeTimes addObject:[NSNumber numberWithLongLong:rt]];
        tt = CTimeDiv(tt,r);
    }
    [relativeTimes addObject:[NSNumber numberWithLongLong:tt]];
    
    return relativeTimes;
}


- (CTime) timeOnTimeLine: (CTimeLine) outLevel fromTimeSignal: (NSArray *) timeSignal
{
    NSAssert(timeSignal.count == self.depth,@"CTime");
    register CTime outTime = [[timeSignal lastObject] longLongValue];
    for (NSInteger i = depth-2; i >= (NSInteger)outLevel; i--) {
        outTime = outTime * _branchCounts[i] + [timeSignal[i] longLongValue];
    }
    return outTime + _offsets[outLevel];
}


// -----------------------------------------------------------------------------
#pragma mark                Time strength
// -----------------------------------------------------------------------------
// A  measure of the "importance" of a moment in time. E.g. time strength on a bar line is higher than that of an an upbeat eighth.
// If the timeStrength = S, then all relative times at levels L < S will be 0.
// If you retreive a time at level L, then the time strength S will be greater than or equal to L.

- (NSUInteger) timeStrengthOfTime: (CTime) time timeLine: (CTimeLine) inLevel
{
    register CTime tt, rt;
    tt = time - _offsets[inLevel];
    for (NSInteger i = inLevel; i < depth-1; i++) {
        CTime r = _branchCounts[i];
        rt = CTimeMod(tt,r);
        if (rt > 0) {
            return i;
        }
        tt = CTimeDiv(tt,r);
    }
    if (tt > 0) {
        return self.depth-1;
    }
    return self.depth;
}


// -----------------------------------------------------------------------------
#pragma mark                Change branch count
// -----------------------------------------------------------------------------
// Set the branch count, and reset the offsets so that [self timeAtLevel: outLevel withTime: B atLevel: levelA+1] is stays the same for all "outLevels". Used when adding meter/tempo changes to a time map at time B -- the total times at B will stay exactly the same, regardless if retrieve them from the previous hierarchy or the following hierarchy.
- (void) setBranchCount: (CTime) AsPerB
                atLevel: (CTimeLine) levelA
        withTimeFixedAt: (CTime) B; // Where levelB = levelA+1
{
    NSParameterAssert(B > 0);
    
    CTime OldAsPerB = _branchCounts[levelA];
    _branchCounts[levelA] = AsPerB;
    
    CTime levelB = levelA+1;
    
    CTime diff = (B - _offsets[levelB]) * (OldAsPerB - AsPerB);
    
    CTime r[depth];
    r[levelA] = 1;
    for (NSInteger i = levelA-1; i >= 0; i--) {
        r[i] = r[i+1] * _branchCounts[i];
    }
    
    for (NSInteger i = levelA; i >= 0; i--) {
        _offsets[i]  = diff * r[i] + _offsets[i];
    }
}


// Separate interface for the simple case.
// This is equivalent to the above if (1) all the offsets are zero (2) "B" is zero.
// This is true in the time map for the hierarchy of time period = 0.

-(void) setBranchCount:(CTime)AsPerB atLevel:(CTimeLine)levelA
{
    _branchCounts[levelA] = AsPerB;
}

@end
