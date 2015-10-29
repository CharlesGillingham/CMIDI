//
//  CMIDIMessageCollector.m
//  CAudioMIDIMusic
//
//  Created by CHARLES GILLINGHAM on 9/15/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDIMessageCollector.h"
#import <CoreAudio/CoreAudio.h>

@implementation CMIDIMessageCollector
@synthesize clock;
@synthesize msgsReceived;
@synthesize hostTimesReceived;
@synthesize clockTicksReceived;
@synthesize hostTimesExpected;

- (id) init
{
    if (self = [super init]) {
        msgsReceived = [NSMutableArray new];
        hostTimesReceived = [NSMutableArray new];
        hostTimesExpected = [NSMutableArray new];
        clockTicksReceived = [NSMutableArray new];
        clock = nil;
    }
    return self;
}


- (void) respondToMIDI:(CMIDIMessage *)message
{
    CTime hostTime = AudioConvertHostTimeToNanos(AudioGetCurrentHostTime());
    [hostTimesReceived addObject:[NSNumber numberWithLongLong:hostTime]];
    [msgsReceived addObject:message];
    if (clock) {
        [hostTimesExpected addObject:[NSNumber numberWithLongLong:clock.timeOfCurrentTick]];
        [clockTicksReceived addObject:[NSNumber numberWithLongLong:clock.currentTick]];
    }
}


- (void) clockTicked: (CMIDIClock *) c
{
    CTime hostTime = AudioConvertHostTimeToNanos(AudioGetCurrentHostTime());
    printf(".");
    [hostTimesReceived addObject:[NSNumber numberWithLongLong:hostTime]];
    [hostTimesExpected addObject:[NSNumber numberWithLongLong:c.timeOfCurrentTick]];
    [clockTicksReceived addObject:[NSNumber numberWithLongLong:c.currentTick]];
}


- (void) reset
{
    [msgsReceived removeAllObjects];
    [hostTimesReceived removeAllObjects];
    [hostTimesExpected removeAllObjects];
    [clockTicksReceived removeAllObjects];
}


@end
