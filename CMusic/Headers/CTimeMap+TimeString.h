//
//  CTimeMap+TimeString.h
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 9/10/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CTimeMap.h"

enum {
    CTimeString_none        = 0,
    CTimeString_timeSignal = 1,
    // 2 ... depth+1 are values for each time line 
    // depth + 2 is the branch counts
};
typedef NSUInteger CTimeStringFormat;


@interface CTimeMap (TimeString)

@property            CTimeStringFormat      timeStringFormat;
@property            NSArray              * timeLineNames;

@property (readonly) NSString             * timeStringHeader;
@property (readonly) NSArray              * timeStringFormatNames;
@property (readonly) NSUInteger             timeStringFormatsCount;
@property (readonly) int                    timeStringMaxLength;


// Describe the time on the time line.
- (NSString *) timeString: (CTime) time
                 timeLine: (CTimeLine) timeLine;

// Used internally
- (void) initializeTimeStrings;
@end

// Assumes CTime is nanoseconds, prints as a seconds, with decimal.
NSString * CTimeSecondString(CTime t);
