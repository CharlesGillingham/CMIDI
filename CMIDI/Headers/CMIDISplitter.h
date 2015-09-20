//
//  CMIDITrackSplitter.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 8/23/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMIDIReceiver CMIDISender.h"

@interface CMIDITrackSplitter : NSObject <CMIDIReceiver, CMIDISender>
@property NSArray * outputUnits; // Output by track
@end

@interface CMIDIChannelSplitter : NSObject <CMIDIReceiver, CMIDISender>
@property NSArray * outputUnits; // Output by channel-1
@end

