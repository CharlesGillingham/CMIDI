//
//  CMIDITimer+Debug.h
//  SqueezeBox 0.0.1
//
//  Created by CHARLES GILLINGHAM on 6/17/15.
//  Copyright (c) 2015 SqueezeBox. All rights reserved.
//

#import "CDebugSelfCheckingObject.h"
#import "CMIDITimer.h"

@interface CMIDITimer (Debug) <CDebugSelfCheckingObject>
+ (BOOL) testTiming;
@end
