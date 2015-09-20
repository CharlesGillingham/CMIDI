//
//  CMIDVSNumber+Debug.h
//  SqueezeBox 0.0.1
//
//  Created by CHARLES GILLINGHAM on 6/20/15.
//  Copyright (c) 2015 SqueezeBox. All rights reserved.
//

#import "CDebugSelfCheckingObject.h"
#import "CMIDIVSNumber.h"

// If this represents ticks, and ticks are saved at 480 ticks per beat 200 beats per minute, this is about 2.2 days.
// I think I need more bytes here ... just in case we need to represent thousands of ticks per beat for hours.
enum {
    CMIDIVSNumber_Max = 268435455 // == 0x0F FF FF FF (encodes as 0xFF FF FF F7)
};

@interface CMIDIVSNumber (Debug) <CDebugSelfCheckingObject>
- (BOOL) check;
+ (BOOL) test;
@end
