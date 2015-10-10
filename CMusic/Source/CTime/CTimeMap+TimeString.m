//
//  CTimeMap+TimeStrings.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 9/10/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CTimeMap+TimeString.h"


// Not used (yet)
int IntegerStringMaxWidth(int max)  {  return ((int)floor(log10( abs(max)))) + (max < 0 ? 2 : 1); }


@interface CTimeMap ()
@property (readwrite) NSString    * timeStringHeader;
@property (readwrite) NSArray     * timeStringFormatNames;
@property (readwrite) int           timeStringMaxLength;
@property CTimeStringFormat        _timeStringFormat;
@property NSArray                * _timeLineNames;
@end



@implementation CTimeMap (TimeString)
@dynamic timeStringFormat;
@dynamic timeLineNames;


- (void) initializeTimeStrings
{
    self._timeStringFormat = CTimeString_none;
    
    NSMutableArray * a = [NSMutableArray arrayWithCapacity:self.depth];
    for (int i = 0; i < self.depth; i++) {
        [a addObject:[NSString stringWithFormat:@"TL%d", i]];
    }
    self._timeLineNames = a;
    [self initializeFormatNames];
    [self initializeHeaderAndWidth];
}


- (NSUInteger) timeStringFormatsCount
{
    return self.depth + 3;
}


- (void) setTimeStringFormat:(CTimeStringFormat)timeStringFormat
{
    self._timeStringFormat = timeStringFormat;
    [self initializeHeaderAndWidth];
}


- (CTimeStringFormat) timeStringFormat
{
    return self._timeStringFormat;
}


- (void) setTimeLineNames:(NSArray *)timeLineNames
{
    NSParameterAssert(timeLineNames.count == self.depth);
    self._timeLineNames = timeLineNames;
    [self initializeFormatNames];
    [self initializeHeaderAndWidth];
}



- (NSArray *) timeLineNames
{
    return self._timeLineNames;
}


//--------------------------------------------------------------------------------------
#pragma mark                         Initialize
//--------------------------------------------------------------------------------------

- (void) initializeFormatNames
{
    NSString * fn[self.depth+3];
    fn[0] = @"None";
    fn[1] = @"Time signal";
    for (NSUInteger i = 0; i < self.depth; i++) {
        fn[i+2] = self._timeLineNames[i];
    }
    fn[self.depth+2] = @"Tempo/Meter";
    
#ifdef CTime_Level0_is_nanoseconds
    fn[2] = @"Seconds";
#endif
    
    self.timeStringFormatNames = [NSArray arrayWithObjects:fn count:self.depth+3];
}


- (void) initializeHeaderAndWidth
{
    NSString * h;
    
    int w; // Assign the width only once, to avoid double notificatios in KVC.
    w = 0;
    switch (self._timeStringFormat) {
        case CTimeString_none: {
            h = @"";
            break;
        }
        case CTimeString_timeSignal: {
            h = [self timeSignalStringHeader];
            w = [self timeSignalStringMaxWidth:self.depth-1];
            break;
        }
        default: {
            CTimeLine tl = (self._timeStringFormat - 2);
            if (tl >= self.depth) {
                h = [self branchCountHeader];
                w = [self branchCountMaxWidth];
            } else {
                h = [self timeLineNames][tl];
                w = CTimeIntegerStringMaxWidth;
#ifdef CTime_Level0_is_nanoseconds
                if (tl == 0) w = CTimeSecondStringMaxWidth;
#endif
            }
            break;
            
        }
    }
    
    if (h.length > w) {
        w = (int)h.length;
    }
    // Should also take into account ceiling(log10(branchCount)) for formats that care.
    
    // KVC-compliant assignment.
    self.timeStringHeader = h;
    self.timeStringMaxLength = w;
}



//--------------------------------------------------------------------------------------
#pragma mark                        Time signal string
//--------------------------------------------------------------------------------------

- (NSString *) timeSignalString: (CTime) t
                               : (CTimeLine) inLevel
                               : (CTimeLine) outLevel

{
    CTime outTime = [self convertTime:t from:inLevel to:self.depth-1];
    NSArray * timeSignal = [self timeSignalForTime:t timeLine:inLevel];
   
    NSMutableString * s = [NSMutableString stringWithFormat:@"%*lld",
                           [self timeSignalFieldWidth:outLevel],outTime];
    for (NSInteger i = ((NSInteger)outLevel)-1; i >= 0; i--) {
        [s appendFormat:@":%*llu", [self timeSignalFieldWidth:i], [timeSignal[i] longLongValue]];
    }
    return s;
}


- (NSString *) timeSignalStringHeader
{
    CTimeLine outLevel = self.depth-1;
    NSArray * names = [self timeLineNames];
    
    NSMutableString * s = [NSMutableString stringWithFormat:@"%-*s",
                           [self timeSignalFieldWidth:outLevel],[names[outLevel] UTF8String]];
    for (NSInteger i = outLevel-1; i >= 0; i--) {
        [s appendFormat:@":%-*s", [self timeSignalFieldWidth:i], [names[i] UTF8String]];
    }
    return s;
}


- (int) timeSignalStringMaxWidth: (CTimeLine) outLevel
{
    int ret = (int) outLevel-1;
    for (NSInteger i = outLevel; i >= 0; i--) {
        ret += [self timeSignalFieldWidth:i];
    }
    return ret;
}


- (int) timeSignalFieldWidth: (NSInteger) level
{
   int width = (int)[self.timeLineNames[level] length];
    
    // This should really be ceiling(log10(branchCount))
    if (width < 4) width = 4;
    return width;
}


//--------------------------------------------------------------------------------------
#pragma mark                        Integer String
//--------------------------------------------------------------------------------------

const int CTimeIntegerStringMaxWidth = 11;

- (NSString *) integerString: (CTime) t
                            : (CTimeLine) inLevel
                            : (CTimeLine) outLevel

{
    CTime outTime = [self convertTime:t from:inLevel to:outLevel];
    return [NSString stringWithFormat:@"%lld",outTime];
}


//--------------------------------------------------------------------------------------
#pragma mark                        Second String
//--------------------------------------------------------------------------------------


// Put a decimal point into the host time so we can clearly read it. Do it typographically, by simply inserting a decimal point 5 positions from the left. Don't use math to do this, because we can't trust the floating point conversions to be perfectly accurate; it will most likely add or subtract a few nanoseconds. (Floating point calculations are particularly bad for moving decimal points, because dividing by 10 creates a repeating decimal in binary "2`s complement" arithemetic.)

// Max Width: 0..10: seconds (11 digits) 11: decimal 12-20 nanoseconds (9 digits) = 22
int CTimeSecondStringMaxWidth = 22;

NSString * CTimeSecondString(CTime t)
{
    char intStr[CTimeSecondStringMaxWidth];
    char str[CTimeSecondStringMaxWidth];
    unsigned long len, secDigitCount, nSDigitCount;
    
    const char * sign;
    sign = "";
    if (t < 0) {
        sign = "-";
        t = -t;
    }
    
    // Let sprintf write the number as an integer.
    sprintf(intStr, "%llu", t);
    
    len = strlen(intStr);
    secDigitCount = (len > 9 ? len-9 : 0);
    nSDigitCount  = (len - secDigitCount);
    
    int i = 0, j = 0;
    if (secDigitCount == 0) {
        str[i++] = '0';
    } else {
        while (j < secDigitCount) {
            str[i++] = intStr[j++];
        }
    }
    if (nSDigitCount > 0) {
        str[i++] = '.';
        int k = 0;
        while (k++ < 9 - nSDigitCount) {
            str[i++] = '0';
        }
        while (j < len) {
            str[i++] = intStr[j++];
        }
    }
    str[i] = 0;
    return [NSString stringWithFormat:@"%s%s", sign, str];
}


- (NSString *) secondString : (CTime) t
                            : (CTimeLine) inLevel
                            : (CTimeLine) outLevel
{
    CTime outTime = [self convertTime:t from:inLevel to:outLevel];
    return CTimeSecondString(outTime);
}


//--------------------------------------------------------------------------------------
#pragma mark                         Branch Count String
//--------------------------------------------------------------------------------------



- (NSString *) branchCountString: (CTime) t
                                : (CTimeLine) inLevel
{
    NSArray * branchCounts = [self hierarchyAtTime:t timeLine:inLevel].branchCounts;
    
    NSUInteger i = self.depth-2;
    NSMutableString * s = [NSMutableString new];
    [s appendFormat:@"%*lld",[self branchCountFieldWidth:i],[branchCounts[i] longLongValue]];
    for (NSInteger i = self.depth-3; i >= 0; i--) {
        [s appendFormat:@":%*lld", [self branchCountFieldWidth:i], [branchCounts[i] longLongValue]];
    }
    return s;
}


- (NSString *) branchCountHeader
{
    NSUInteger i = self.depth-2;
    NSMutableString * s = [NSMutableString stringWithString:[self branchCountFieldHeader:i]];
    for (NSInteger i = self.depth-3; i >= 0; i--) {
        [s appendFormat:@":%@", [self branchCountFieldHeader:i]];
    }
    return s;
}


- (int) branchCountMaxWidth
{
    NSUInteger i = self.depth-2;
    int ret = [self branchCountFieldWidth:i];
    for (NSInteger i = self.depth-3; i >= 0; i--) {
        ret += [self branchCountFieldWidth:i];
    }
    return ret;
}


- (int) branchCountFieldWidth: (NSInteger) level
{
    // Could also take into account ceiling(log10(branchCount))
    int width = (int)([self.timeLineNames[level] length] + [self.timeLineNames[level+1] length] + 2);
    if (width < 4) width = 4;
    return width;
}


- (NSString *) branchCountFieldHeader: (NSInteger) level
{
    return [NSString stringWithFormat:@"%@s/%@",self.timeLineNames[level],self.timeLineNames[level+1]];
}



//--------------------------------------------------------------------------------------
#pragma mark                         Description
//--------------------------------------------------------------------------------------


- (NSString *) timeString: (CTime) t
                        timeLine: (CTimeLine) inLevel
{
    switch (self._timeStringFormat) {
        case CTimeString_none:      return @"";
        case CTimeString_timeSignal:return [self timeSignalString:t:inLevel:self.depth-1];
        default: {
            CTimeLine tl = (self._timeStringFormat - 2);
            if (tl >= self.depth) {
                return [self branchCountString:t:inLevel];
#ifdef CTime_Level0_is_nanoseconds
            } else if (tl == 0) {
                return [self secondString:t :inLevel:tl];
#endif
            } else {
                return [self integerString :t:inLevel:tl];
            }
        }
    }
}




@end



