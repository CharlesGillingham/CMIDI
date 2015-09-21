//
//  CMIDISequence.m
//  CMIDIFilePlayer
//
//  Created by CHARLES GILLINGHAM on 8/17/15.
//  Copyright (c) 2015 CHARLES GILLINGHAM. All rights reserved.
//

#import "CMIDISequence.h"
#import "CMIDIMessage+ChannelMessage.h"
#import "CTime.h"

CMIDIClockTicks CMIDISequencePostRoll = 24;


@interface CMIDISequence ()
@end


@implementation CMIDISequence {
    NSMutableArray * _events;
    NSUInteger nextIndex;
}
@synthesize outputUnit;
@synthesize maxLength;
@synthesize trackCount;

- (id) init
{
    if (self == [super init]) {
        nextIndex = 0;
        maxLength = 0;
        _events = [NSMutableArray new];
        
        
    }
    return self;
}


- (void) dealloc
{
    printf("SEQUENCE DEALLOCATED\n");
}


// --------------------------------------------------------------------------------
#pragma mark            Modify Messages
// --------------------------------------------------------------------------------

- (void) addEvent: (CMIDIMessage *) msg
{
    @synchronized(self) {
        NSUInteger index = NSNotFound;
        
        // Since we typically add new messages at the end, check for this possibility first
        if (msg.time < [[_events lastObject] time]) {
            // Need to add the hint ; binary search by time ...
            index = [_events indexOfObjectPassingTest:^BOOL(CMIDIMessage * ev, NSUInteger idx, BOOL *stop) {
                return (ev.time > msg.time);
            }];
        }
        
        if (index == NSNotFound) {
            [_events addObject:msg];
            index = _events.count-1;
        } else {
            [_events insertObject:msg atIndex:index];
        }
        
        if (index < nextIndex) nextIndex++;
        
        if (msg.time + CMIDISequencePostRoll > maxLength) maxLength = msg.time + CMIDISequencePostRoll;
        if (msg.track > trackCount) trackCount = msg.track;
    }
}


- (void) removeEventEqualTo:(CMIDIMessage *)msg
{
    @synchronized(self) {
        // Need to add the hint ; binary search by time ...
        NSUInteger index = [_events indexOfObjectPassingTest:^BOOL(CMIDIMessage * ev, NSUInteger idx, BOOL *stop) {
            return [ev isEqualTo:msg];
        }];
        
        if (index != NSNotFound) {
            if (index < nextIndex) nextIndex--;
            [_events removeObjectAtIndex:index];
        }
    }
}


- (void) setEvents:(NSArray *)events
{
    @synchronized(self) {
        events = [CMIDIMessage sortedMessageList:events];
        _events = [NSMutableArray arrayWithArray:events];
        nextIndex = 0;
        maxLength = [[_events lastObject] time] + CMIDISequencePostRoll;
        trackCount = 0;
        for (CMIDIMessage * msg in events) {
            if (msg.track > trackCount) {
                trackCount = msg.track;
            }
        }
    }
}


- (NSArray *) events
{
    return _events;
}

// --------------------------------------------------------------------------------
#pragma mark            Purge
// ---------------------------------------------------------------------------------------
// Remove all messages that will no longer be needed. To be used for an open-ended sequence to save memory. Not needed yet, but with automatic composition we could theoretically have a composition that lasted for a year or more, up to CTime_Max.

- (void) purgeToTime: (CMIDIClockTicks) time
{
    assert(NO);
/*
    NSUInteger purgeTo;
    purgetTo = [_events indexOfObjectPassingTest:^BOOL(CMIDIMessage * msg, NSUInteger idx, BOOL *stop) {
            return msg.time > time;
        }];
    purgetTo = purgeTo-1;
 
    NSRange r = {0, purgeTo-1};
    
    [_events removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:r]];
    if (nextIndex <= purgeTo) {
        nextIndex = 0;
    } else {
        nextIndex = nextIndex - purgeTo;
    }
 */
}


// --------------------------------------------------------------------------------
#pragma mark            Play back
// ---------------------------------------------------------------------------------------
// Note: this code is convoluted because we have to exit the sync lock before we do anything

#define nanosecondsPerMicrosecond 1000

- (void) clockTicked:(CMIDIClock *)c
{
    // Note that this will call back through to the "stop" routine below.
    if (c.currentTick > maxLength) {
        [c stop];
    }

    // Retain a pointer to outputUnit, just in case it changes and is deallocated while we're sending it messages.
    NSObject <CMIDIReceiver> * receiver;
    @synchronized(self) {
        receiver = self.outputUnit;
    }
    
    CMIDIMessage * msg;
    while (YES) {
        
        // Get one event. Send it outside the synch lock.
        @synchronized(self) {
            if (nextIndex >= _events.count) return;
            msg = _events[nextIndex];
            if (msg.time > c.currentTick) return;
        }

        // If there is no receiver, step through the messages anyway, to keep them all on time when a receiver is set later.
        if (receiver) {
            [receiver respondToMIDI:msg];
        }
        
        nextIndex++;
    }
}



- (void) clockTimeSet: (CMIDIClock *) c
{
    @synchronized(self) {
        nextIndex = [_events indexOfObjectPassingTest:^BOOL(CMIDIMessage * obj, NSUInteger idx, BOOL *stop) {
            return obj.time >= c.currentTick;
        }];
    }
}


- (void) clockStarted:(CMIDIClock *)c
{
    // Reset the nextIndex on start, just in case we have been attached to a new clock.
    // Maybe I need "addReceiver" to send a notification?? To give people a chance to sync to a new clock??
    [self clockTimeSet:c];
}



- (void) clockStopped:(CMIDIClock *)c
{
    NSObject <CMIDIReceiver> * receiver;
    @synchronized(self) {
        receiver = self.outputUnit;
    }
    
    if (receiver) {
        CMIDIMessage *mm1, *mm2, *mm3;
        for (NSUInteger track = 0; track < trackCount; track++) {
            for (NSUInteger channel = MIDIChannel_Min; channel <= MIDIChannel_Max; channel++) {
                mm1 = [CMIDIMessage messageWithController:MIDIController_Sustain
                                                boolValue:NO
                                                  channel:channel];
                mm2 = [CMIDIMessage messageAllNotesOff:channel];
                mm3 = [CMIDIMessage messageAllSoundOff:channel];
                mm1.track = mm2.track = mm3.track = track;
                mm1.time = mm2.time = mm3.time = c.currentTick;
                [receiver respondToMIDI: mm1];
                [receiver respondToMIDI: mm2];
                [receiver respondToMIDI: mm3];
            }
        }
    }

}


@end
