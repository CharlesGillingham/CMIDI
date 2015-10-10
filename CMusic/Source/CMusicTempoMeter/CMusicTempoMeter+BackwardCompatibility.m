//
//  CMusicTempoMeter+BackwardCompatibility.m
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 9/29/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMusicTempoMeter+BackwardCompatibility.h"



@implementation CMusicTempoMeter (BackwardCompatibility)

- (CTimeLine) beatStrengthOfTick: (MTicks) tick
{
    return [self timeStrengthOfTime:tick timeLine:CMusic_Ticks]-1;
}

- (CTime) ticksPerBeatStrength: (MBeatStrength) bs
{
    return [self AsPerB:CMusic_Ticks:bs atTime:0 level:0];
}

- (CTime) ticksPerBar
{
    return [self AsPerB:CMusic_Ticks :CMusic_Bars atTime:0 level:0];
}


- (NSArray *) beatSignalOfTick: (MTicks) tick
{
    NSArray * ts = [self timeSignalForTime:tick timeLine:CMusic_Ticks];
    NSMutableArray * rev = [NSMutableArray arrayWithCapacity:ts.count];
    for (NSInteger i = ts.count-1; i >= 0; i--) {
        [rev addObject:ts[i]];
    }
    return rev;
}

@end
