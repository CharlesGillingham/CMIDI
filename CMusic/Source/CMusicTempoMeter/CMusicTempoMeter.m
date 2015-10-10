//
//  CMusicTempoMeter.m
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 9/29/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMusicTempoMeter.h"

@implementation CMusicTempoMeter

- (id) init
{
    // 100 BPM, 24 ticks per beat, 4/4.
    CTimeHierarchy * th = [[CTimeHierarchy alloc] initWithBranchCounts:@[@2500000,@3,@2,@2,
                                                                         @2,@2,@2,@2,
                                                                         @2,@2,@2]];
    return [self initWithHierarchy:th];
}

@end
