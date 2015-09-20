//
//  CMIDIClockTickTester.m
//  SqueezeBox 0.0.1
//
//  Created by CHARLES GILLINGHAM on 6/18/15.
//  Copyright (c) 2015 SqueezeBox. All rights reserved.
//

#import "CMIDIClock+Debug.h"
#import "CMIDITempoMeter+Debug.h"
#import "CMIDIClockTickTester.h"
#import "CDebugMessages.h"

#ifdef DEBUG
@interface CMIDIClockTickTester ()
@end


@implementation CMIDIClockTickTester
@synthesize testClock;
@synthesize firstTickAfterStart;
@synthesize startTick;
@synthesize firstTickAfterReset;
@synthesize resetTick;
@synthesize prevTick;
@synthesize testPassed;

- (id) init
{
    if (self = [super init]) {
        testPassed = YES;
        resetTick = 0;
        firstTickAfterReset = YES;
    }
    return self;
}


- (void) clockStarted: (CMIDIClock *) c {
    printf("start");
    CMIDIClockTicks tick = c.currentTick;
    firstTickAfterStart = YES;
    startTick = tick;
}


- (void) clockTicked:  (CMIDIClock *) c
{
    @synchronized(self) {
        CMIDIClockTicks tick = c.currentTick;
        if (firstTickAfterStart) {
            printf(":");
        }
        if (firstTickAfterReset) {
            printf(";");
        }
        printf(".");
        
        // First tick after start should be the same tick as the one we started with.
        if (firstTickAfterStart) {
            testPassed = (testPassed && CASSERTEQUAL(startTick, tick));
            firstTickAfterStart = NO;
        }
        
        // First tick after reset should be the tick that was set, regardless if the clock was stopped or not.
        if (firstTickAfterReset) {
            testPassed = (testPassed && CASSERTEQUAL(resetTick, tick));
            firstTickAfterReset = NO;
        } else {
            testPassed = (testPassed && CASSERTEQUAL(prevTick+1, tick));
        }
        
        prevTick = tick;
    }
}


- (void) clockTempoSet: (CMIDIClock *) c
{
    @synchronized(self) {
        printf("temposet");
    }
}


- (void) clockTimeSet: (CMIDIClock *) c
{
    @synchronized(self) {
        resetTick = c.currentTick;
        printf("timeset");
        firstTickAfterReset = YES;
    }
}


- (void) clockStopped: (CMIDIClock *) c
{
    @synchronized(self) {
        printf("stop");
        CMIDIClockTicks tick = c.currentTick;
        testPassed = (testPassed && CASSERTEQUAL(prevTick, tick));
    }
}


@end
#endif