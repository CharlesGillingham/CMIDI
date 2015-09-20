//
//  CMIDIMessageData+MIDIPacketList.m
//  SqueezeBox 0.0.1
//
//  Created by CHARLES GILLINGHAM on 6/22/15.
//  Copyright (c) 2015 SqueezeBox. All rights reserved.
//

#import "CMIDIDataParser+MIDIPacketList.h"
#import "CMIDIMessage.h"

@implementation CMIDIDataParser (MIDIPacketList)

- (NSArray *) parsePacketList: (const MIDIPacketList *) pList;
{
    @autoreleasepool {
        NSMutableArray * messages = [NSMutableArray new];
        const MIDIPacket * packet;
        int i;
        for (i = 0, packet = (MIDIPacket *)pList->packet;
             i < pList->numPackets;
             i++, packet = MIDIPacketNext(packet))
        {
            NSArray * newMessages = [self parseMessageData:packet->data length:packet->length];
            if (newMessages) {
                for (CMIDIMessage * msg in newMessages) {
                   msg.time = packet->timeStamp;
                }
                [messages addObjectsFromArray:newMessages];
            }
        }
        return messages;
    }
}


@end
