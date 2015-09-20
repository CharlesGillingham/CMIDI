//
//  CMIDIMessageDataParser+MIDIPacketList.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 6/22/15.
//
#import "CMIDIDataParser.h"
#import <CoreMIDI/CoreMIDI.h>

@interface CMIDIDataParser (MIDIPacketList)
- (NSArray *) parsePacketList: (const MIDIPacketList *) pList;
@end
