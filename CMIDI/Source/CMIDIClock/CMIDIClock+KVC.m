//
//  CMIDIClock+KVC.m
//  CAudioMIDIMusic
//
//  Created by CHARLES GILLINGHAM on 9/17/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDIClock.h"

@interface CMIDIClock (KVC)
@end

@implementation CMIDIClock (KVC)

// For these three basic properties we will do the notification ourselves to keep control of the thread.
+ (BOOL) automaticallyNotifiesObserversOfNanosecondsPerTick { return NO; }
+ (BOOL) automaticallyNotifiesObserversOfIsRunning { return NO; }
+ (BOOL) automaticallyNotifiesObserversOfCurrentTick { return NO; }

// Host time changes whenever the currentTick changes. Property is readonly.
+ (NSSet *) keyPathsForValuesAffectingTimeOfCurrentTick
{
    return [NSSet setWithObject:@"currentTick"];
}

// BPM is derived from nanoseconds per tick.
+ (BOOL) automaticallyNotifiesObserversOfBeatsPerMinute { return NO; }
+ (NSSet *) keyPathsForValuesAffectingBeatsPerMinute
{
    return [NSSet setWithObject:@"nanosecondsPerTick"];
}

// Time in seconds is derived from current tick and nanoseconds per tick.
+ (BOOL) automaticallyNotifiesObserversOfTimeInSecondsOfCurrentTick { return NO; }
+ (NSSet *) keyPathsForValuesAffectingTimeInSecondsOfCurrentTick
{
    return [NSSet setWithObjects:@"currentTick", @"nanosecondsPerTick", nil];
}

// These public properties of CMIDIClock are derived from internal properties.
// (Note: timeString is currently readonly, so doesn't need the "automatically" routine, but I'm doing it just in case some day we add code to parse the time string, i.e., let the user set the time with text.)
+ (BOOL) automaticallyNotifiesObserversOfTimeString       { return NO; }
+ (BOOL) automaticallyNotifiesObserversOfTimeStringFormat { return NO; }
+(NSSet *) keyPathsForValuesAffectingTimeString
{
    return [NSSet setWithObjects:
            @"currentTick",
            @"timeMap.timeStringFormat",
            nil];
}
+ (NSSet *) keyPathsForValuesAffectingTimeStringHeader
{
    return [NSSet setWithObject:
            @"timeMap.timeStringFormat"];
}
+ (NSSet *) keyPathsForValuesAffectingTimeStringFormat
{
    return [NSSet setWithObject:
            @"timeMap.timeStringFormat"];
}


@end
