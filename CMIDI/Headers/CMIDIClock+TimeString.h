//
//  CMIDIClock+TimeStrings.h
//  CMIDIClockTest
//
//  Created by CHARLES GILLINGHAM on 9/19/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDIClock.h"

// Time string is a string representation of the current time.
// The others are here for convenience, because their declaration is far away in CTimeMap+TimeString.h. Time string

@interface CMIDIClock (TimeStrings)
@property (readonly) NSString          * timeString;
@property            CTimeStringFormat   timeStringFormat;
@property (readonly) NSString          * timeStringHeader;
@property (readonly) NSArray           * timeStringFormatNames;
@end
