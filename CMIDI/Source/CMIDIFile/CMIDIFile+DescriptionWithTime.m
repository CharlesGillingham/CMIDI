//
//  CMIDIFile+CMIDIFile_DescriptionWithTime.m
//  CMIDIFilePlayerDemo
//
//  Created by CHARLES GILLINGHAM on 9/13/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDIFile+DescriptionWithTime.h"
#import "CMIDITempoMeter.h"
#import "CMIDIMessage+DescriptionWithTime.h"
#import "CMIDIMessage+ChannelMessage.h"


@implementation CMIDIFile (DescriptionWithTime)


- (NSString *) longDescriptionWithTime: (BOOL) hideNoteOff
{
    NSMutableString * s = [NSMutableString stringWithFormat:@"MIDI FILE %@\n\n", self.fileName];
    CMIDITempoMeter * timeMap = [CMIDITempoMeter mapWithMessageList: self.messages
                                                       ticksPerBeat: self.ticksPerBeat];
    [s appendFormat:@"%@\n",[CMIDIMessage tableHeaderWithTimeMap:timeMap]];
    for (CMIDIMessage * message in self.messages) {
        if (!hideNoteOff || !message.isNoteOff) {
            [s appendFormat:@"%@\n", [message tableRowStringWithTimeMap:timeMap]];
        }
    }
    return s;
}


- (void) showWithTime: (BOOL) hideNoteOff
{
    printf("\n\n\n%s\n\n\n",[self longDescriptionWithTime:hideNoteOff].UTF8String);
}


@end
