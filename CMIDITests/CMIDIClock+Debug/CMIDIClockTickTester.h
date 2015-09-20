//
//  CMIDIClockTickTester.h
//  SqueezeBox 0.0.1
//
//  Created by CHARLES GILLINGHAM on 6/18/15.
//  Copyright (c) 2015 SqueezeBox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMIDIClockTickTester : NSObject
@property CMIDIClock * testClock;
@property BOOL firstTickAfterStart;
@property CMIDIClockTicks startTick;
@property BOOL firstTickAfterReset;
@property CMIDIClockTicks resetTick;
@property CMIDIClockTicks prevTick;
@property BOOL testPassed;
@end
