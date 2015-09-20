//
//  CMIDIMessage+DescriptionWithTimeMap.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 9/11/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//
#import "CMIDIMessage+DescriptionWithTime.h"
#import "CMIDIMessage+ChannelMessage.h"
#import "CTimeMap+TimeString.h"

NSString * CMIDIMessageIndentAndSplitInnerLines(NSString * s, int indent, NSUInteger maxLineWidth);

@interface CMIDIMessage ()
- (NSString *) valueString: (BOOL *) containsMessageName;
@end



@implementation CMIDIMessage (DescriptionWithTime)

- (NSString *) timeString:(CMIDITempoMeter *)map
{
    return [map timeString:self.time timeLine:CMIDITimeLine_Ticks];
}


- (NSString *) descriptionWithTimeMap: (CMIDITempoMeter *) map
{
    NSMutableString * s = [NSMutableString stringWithCapacity:200];
    [s appendFormat:@"<CMIDIMessage:"];
    
    BOOL containsMessageName;
    NSString * sValue = [self valueString:&containsMessageName];
    if (containsMessageName) {
        [s appendString:sValue];
    } else {
        [s appendString:self.messageName];
    }
    
    if (map.timeStringFormat != CTimeString_none) {
        [s appendFormat:@", Time=%@", [self timeString:map]];
    }
    
    if (self.track != CMIDIMessage_NoTrack) {
        [s appendFormat:@", Track=%@", [self trackName]];
    }
    
    if (self.type != MIDIMessage_System) {
        [s appendFormat:@", Channel=%@", self.channelName];
    }
    
    if (self.isNoteMessage) {
        [s appendFormat:@", Note=%@", self.noteName];
    }
    
    if (!containsMessageName && sValue.length > 0) {
        sValue = CMIDIMessageIndentAndSplitInnerLines(sValue,(int)(s.length+2),80);
        [s appendFormat:@", %@", sValue];
    }
    
    [s appendFormat:@">"];
    
    return s;
}



- (NSString *) tableRowStringWithTimeMap:(CMIDITempoMeter *)map
{
    // Adjust the maxwidth for the new format.
    int maxWidth = CMIDIMessageDescriptionMaxLength - CMIDITimeStringMaxLength + map.timeStringMaxLength;
    if (map.timeStringFormat == CTimeString_none) maxWidth--; // count the blank.
    NSString * sValue = [self valueString];
    sValue = CMIDIMessageIndentAndSplitInnerLines(sValue, maxWidth - CMIDIValueStringMaxLength, maxWidth);
 
    int tWidth;
    NSString * tString;
    if (map.timeStringFormat == CTimeString_none) {
        return [NSString stringWithFormat:@"%-*s %-*s %-*s %-*s %-*s",
                CMIDIMessageNameMaxLength,            self.messageName.UTF8String,
                CMIDITrackNameMaxLength,              self.trackName.UTF8String,
                CMIDIChannelNameMaxLength,            self.channelName.UTF8String,
                CMIDINoteNameMaxLength,               self.noteName.UTF8String,
                CMIDIValueStringMaxLength,            sValue.UTF8String];
    } else {
        tWidth = map.timeStringMaxLength;
        tString = [map timeString:self.time timeLine:CMIDITimeLine_Ticks];
        return [NSString stringWithFormat:@"%-*s %-*s %-*s %-*s %-*s %-*s",
                map.timeStringMaxLength,              [self timeString:map].UTF8String,
                CMIDIMessageNameMaxLength,            self.messageName.UTF8String,
                CMIDITrackNameMaxLength,              self.trackName.UTF8String,
                CMIDIChannelNameMaxLength,            self.channelName.UTF8String,
                CMIDINoteNameMaxLength,               self.noteName.UTF8String,
                CMIDIValueStringMaxLength,            sValue.UTF8String];
    }
}

                

+ (NSString *) tableHeaderWithTimeMap: (CMIDITempoMeter *) map
{
    if (map.timeStringFormat == CTimeString_none) {
        return [NSString stringWithFormat:@"%-*s %-*s %-*s %-*s %-*s",
                CMIDIMessageNameMaxLength,   "Message",
                CMIDITrackNameMaxLength,     "Track",
                CMIDIChannelNameMaxLength,   "Channel",
                CMIDINoteNameMaxLength,      "Note",
                CMIDIValueStringMaxLength,   "Value"];
    } else {
        return [NSString stringWithFormat:@"%-*s %-*s %-*s %-*s %-*s %-*s",
            map.timeStringMaxLength,     map.timeStringHeader.UTF8String,
            CMIDIMessageNameMaxLength,   "Message",
            CMIDITrackNameMaxLength,     "Track",
            CMIDIChannelNameMaxLength,   "Channel",
            CMIDINoteNameMaxLength,      "Note",
            CMIDIValueStringMaxLength,   "Value"];
    }
    
}

@end
