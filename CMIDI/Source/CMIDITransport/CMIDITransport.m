//
//  CMIDITransport.m
//  CMIDIFilePlayerDemo
//
//  Created by CHARLES GILLINGHAM on 9/14/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDITransport.h"
#import "CMIDITempoMeter.h"
#import "CTimeMap+TimeString.h"

@interface CMIDITransport ()
@end

NSString *const CMIDITransportNibFileName = @"CMIDITransport.nib";

@implementation CMIDITransport
@synthesize clock;
@synthesize maxTicks;
@synthesize minTicks;


- (instancetype) init
{
    return [super initWithNibName:CMIDITransportNibFileName bundle:[NSBundle bundleForClass:[self class]]];
}

- (instancetype) initWithClock: (CMIDIClock *) cl
{
    self = [self init];
    if (self) {
    
        clock = cl;
        [clock.receivers addObject:self];
        
        // A reasonable number of ticks; 64 bars of 4/4 with ticksPerBeat = 24.
        maxTicks = 24 * 256;
        minTicks = 0;
  
        // Set the time string double check max and min ticks
        [self clockTicked:cl];
    }
    return self;
}


- (void) loadView
{
    NSAssert(clock.timeMap != nil,@"Transport can only function if the clock has time map.");
    [super loadView];
}


- (void) viewWillDisappear
{
    // Break retain cycle.
    [clock.receivers removeObject:self];
    // Don't set clock to nil, because observers are still registered with it.
}


- (void) dealloc
{
    printf("TRANSPORT DEALLOCATED\n");

    // Trying to get the clock to deallocate; not working so great.
    clock = nil;
}



- (void) updateCurrentTick: (NSUInteger) currentTick
{
    if (currentTick > maxTicks) {
        // Add 32 bars at 4/4
        self.maxTicks = currentTick + clock.timeMap.ticksPerBeat * 128;
    }
    if (currentTick < minTicks) {
        self.minTicks = currentTick - clock.timeMap.ticksPerBeat * 128;
    }
}


- (void) clockTicked: (CMIDIClock *) cl
{
    // Don't retain the clock on the other thread.
    CMIDIClockTicks tick = cl.currentTick;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateCurrentTick:tick];
    });
}


@end
