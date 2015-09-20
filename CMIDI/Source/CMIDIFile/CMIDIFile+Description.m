//
//  CMIDIFile+Description.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 7/15/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDIFile+Description.h"
#import "CMIDIMessage+Description.h"
#import "CMIDIMessage+DescriptionWithTime.h"
#import "CMIDIMessage+ChannelMessage.h"
#import "CMIDITempoMeter.h"

const char * CMIDIFile_separatorLine =  "---------------------------------------------------------------------------------------------------------";


@implementation CMIDIFile (Description)

- (NSString *) description
{
    return [NSString stringWithFormat:@"<CMIDIFile:%@>", self.fileName];
}


- (NSString *) longDescription: (BOOL) hideNoteOff
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


- (void) show: (BOOL) hideNoteOff
{
    printf("\n\n\n%s\n\n\n",[self longDescription:hideNoteOff].UTF8String);
}

@end
