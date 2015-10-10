//
//  CTimeSequence.m
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 9/25/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CTimeSequence.h"

static NSComparator CTimeComparator = ^(__strong id id1,
                                        __strong id id2)
{
    CTimeStampedObject * obj1 = (CTimeStampedObject *) id1;
    CTimeStampedObject * obj2 = (CTimeStampedObject *) id2;
    if (obj1.time == obj2.time) return NSOrderedSame;
    if (obj1.time < obj2.time) return NSOrderedAscending;
    return NSOrderedDescending;
};



@interface NSNumber (NSNumberAsTimeStampedObject) <CTimeStampedObjectMethods>
@property (readonly) CTime time;
+ (CTimeStampedObject *) numberWithTime: (CTime) time;
@end


@implementation NSNumber (NSNumberAsTimeStampedObject)
@dynamic time;

+ (CTimeStampedObject *) numberWithTime: (CTime) time
{
    return [NSNumber numberWithLongLong:time];
}

- (CTime) time
{
    return [self longLongValue];
}

@end



@interface CTimeSequence ()
@property NSUInteger nextIndex;
@end


@implementation CTimeSequence {
    NSMutableArray * _objects;
}
@synthesize nextIndex;
@dynamic objects;

- (id) init
{
    if (self = [super init]) {
        nextIndex = 0;
        _objects = [NSMutableArray new];
    }
    return self;
}


- (id) initWithObjects: (NSArray *) inObjects
{
    self = [self init];
    self.objects = [NSMutableArray arrayWithArray:inObjects];
    return self;
}


- (CTime) nextTime
{
    if (nextIndex < _objects.count) {
        return [_objects[nextIndex] time];
    } else {
        return CTime_Max;
    }
}



- (NSUInteger) insertionIndex: (CTime) time
{
    NSRange searchRange = NSMakeRange(0, _objects.count);
    CTimeStampedObject * searchObject = [NSNumber numberWithTime:time];
    return [_objects indexOfObject:searchObject
                     inSortedRange:searchRange
                           options:NSBinarySearchingInsertionIndex
                   usingComparator:CTimeComparator];
}



- (BOOL) indexOfTime: (CTime) time
               index: (NSUInteger *) idx
{
    NSAssert(nextIndex == _objects.count || (nextIndex == 0) || ([_objects[nextIndex-1] time] < [_objects[nextIndex] time]),
             @"CTimeSequence invariant violated");
    
    CTime nextTime;
    
    if (nextIndex ==  _objects.count) {
        nextIndex = [self insertionIndex:time];
        if (nextIndex == _objects.count) return NO;
        nextTime = [_objects[nextIndex] time];
        if (nextTime != time) return NO;
    } else {
        nextTime = [_objects[nextIndex] time];
        if (nextTime != time) {
            nextIndex = [self insertionIndex:time];
            if (nextIndex == _objects.count) return NO;
            nextTime = [_objects[nextIndex] time];
            if (nextTime != time) return NO;
        }
    }
    
    *idx = nextIndex++;
    
    
    while (nextIndex < _objects.count) {
        nextTime = [_objects[nextIndex] time];
        if (nextTime != time) break;
        nextIndex++;
    }
    
    return YES;
}



- (NSUInteger) countOfObjects {  return _objects.count; }
- (CTimeStampedObject *) objectInObjectsAtIndex:(NSUInteger)index
{
    return _objects[index];
}
- (void) insertObject:(CTimeStampedObject *)object inObjectsAtIndex:(NSUInteger)index
{
    NSUInteger idx;
    CTime time = object.time;
    idx = [self insertionIndex:time];
    [_objects insertObject:object atIndex:idx];
    if (idx <= nextIndex) {
        nextIndex++;
    }
}
- (void) removeObjectFromObjectsAtIndex:(NSUInteger)idx
{
    if (idx < nextIndex) {
        nextIndex--;
    }
    [_objects removeObjectAtIndex:idx];
}
- (void) addObjectsObject:(CTimeStampedObject *)object
{
    NSParameterAssert(_objects.count == 0 || ([[_objects lastObject] time] < object.time));
    if (nextIndex == _objects.count) {
        nextIndex++;
    }
    [_objects addObject:object];
 }
- (void) replaceObjectInObjectsAtIndex:(NSUInteger)index withObject:(CTimeStampedObject *)object
{
    NSParameterAssert(index == 0 || [_objects[index-1] time] <= object.time);
    NSParameterAssert(index >= _objects.count-1 || ([_objects[index+1] time] <= object.time));
    _objects[index] = object;
}
- (void) setObjects:(NSArray *)objects
{
    _objects = [NSMutableArray arrayWithArray:[objects sortedArrayUsingComparator:CTimeComparator]];
    nextIndex = 0;
}




- (CTimeStampedObject *) firstObjectAtTime:(CTime) time
{
    NSUInteger idx;
    if ([self indexOfTime:time index:&idx]) {
        return _objects[idx];
    }
    return nil;
}


- (NSArray *) allObjectsAtTime:(CTime)time
{
    NSMutableArray * objsAtTime = [NSMutableArray new];
    
    NSUInteger idx;
    if ([self indexOfTime:time index:&idx]) {
        for (; idx < nextIndex; idx++) {
            [objsAtTime addObject:_objects[idx]];
        }
    }
    return objsAtTime;
}





@end
