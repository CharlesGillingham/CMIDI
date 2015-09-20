//
//  CTime.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 9/10/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SINT64_MAX  (9223372036854775807)
#define SINT64_MIN  (-SINT64_MAX - 1)

// All math in CTime is done with SInt64s, so that we don't have to worry about conversions, floating point errors or overflow into the negatives.
typedef SInt64 CTime;

enum {
    CTime_MaxDepth = 31,
    CTime_Min = SINT64_MIN,
    CTime_Max = SINT64_MAX
};

// Python-style mod and div.
CTime CTimeMod( CTime i, CTime m );
CTime CTimeDiv( CTime i, CTime m );

// Every CTime is associated with a particular time line, such as seconds, beats, bars, etc.  A CTimeMap keeps track of all the different time lines, provides conversions between them and so on.
typedef NSUInteger CTimeLine;
