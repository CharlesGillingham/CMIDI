//
//  CMIDITrackSplitter.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 8/23/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDISplitter.h"
#import "CMIDIMessage+ChannelMessage.h"


@implementation CMIDITrackSplitter 
@synthesize outputUnits;

- (void) respondToMIDI:(CMIDIMessage *)message
{
    if (message.track < outputUnits.count) {
        [outputUnits[message.track] respondToMIDI:message];
    }
}

@end



@implementation CMIDIChannelSplitter
@synthesize outputUnits;

- (void) respondToMIDI:(CMIDIMessage *)message
{
    if (message.channel-1 < outputUnits.count) {
        [outputUnits[message.channel-1] respondToMIDI:message];
    }
}

@end


