//
//  CMIDISequence.h
//  CMIDIFilePlayer
//
//  Created by CHARLES GILLINGHAM on 8/17/15.
//  Copyright (c) 2015 CHARLES GILLINGHAM. All rights reserved.
//

//  USAGE:
//  seq = [CMIDISequence new];
//  ... add events to the sequence
//  clock = [CMIDIClock new];
//  [clock.receivers addObject:seq];
//  ... play the sequence using the clock's start/stop etc.

#import "CMIDIClock.h"
#import "CMIDIReceiver CMIDISender.h"

@interface CMIDISequence : NSObject <CMIDITimeReceiver, CMIDISender>
@property NSString           * displayName;
@property (readonly) NSArray * events;
@property CMIDIClockTicks      maxLength;
@property NSUInteger           trackCount;

// Messages
- (void) setEvents: (NSArray *) events;
- (void) addEvent: (CMIDIMessage *) msg;
- (void) removeEventEqualTo: (CMIDIMessage *) msg;

@property NSObject <CMIDIReceiver> * outputUnit;

@end
