//
//  CMIDIClock+TimeStrings.m
//  CMIDIClockTest
//
//  Created by CHARLES GILLINGHAM on 9/19/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDIClock+TimeString.h"

@implementation CMIDIClock (TimeStrings)
@dynamic timeString;
@dynamic timeStringFormat;
@dynamic timeStringHeader;
@dynamic timeStringFormatNames;

- (NSString *) timeString
{
    if (self.timeMap) {
        return [self.timeMap timeString:self.currentTick timeLine:CMIDITimeLine_Ticks];
    } else {
        return [NSString stringWithFormat:@"%lld", self.currentTick];
    }
}


- (CTimeStringFormat) timeStringFormat {
    if (self.timeMap) {
        @synchronized(self) {
            return self.timeMap.timeStringFormat;
        }
    } else {
        return CMIDITimeLine_Ticks;
    }
}


- (void) setTimeStringFormat:(CTimeStringFormat)timeStringFormat
{
    if (self.timeMap) {
        @synchronized(self) {
            self.timeMap.timeStringFormat = timeStringFormat;
        }
    }
}

- (NSArray *) timeStringFormatNames
{
    if (self.timeMap) {
        return [self.timeMap timeStringFormatNames];
    } else {
        return @[@"Ticks"];
    }
}

- (NSString *) timeStringHeader {
    if (self.timeMap) {
        return self.timeMap.timeStringHeader;
    } else {
        return @"Current clock tick";
    }
}



@end
