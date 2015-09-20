//
//  CMIDITransport.h
//  CMIDIFilePlayerDemo
//
//  Created by CHARLES GILLINGHAM on 9/14/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CMIDIClock.h"
#import "CMIDITempoMeter.h"

@interface CMIDITransport : NSViewController <CMIDITimeReceiver>

// The clock is not retained by the transport (to avoid a retain loop). CMIDITransport assumes that someone else is holding a pointer to the clock.
@property CMIDIClock      * clock;

// This is bound to the maximum and minimum values of the current time slider. If the clock sends a tick outside this range, these will be increased appropriately.
@property CMIDIClockTicks minTicks;
@property CMIDIClockTicks maxTicks;

- (instancetype) initWithClock: (CMIDIClock *) clock;
@end
