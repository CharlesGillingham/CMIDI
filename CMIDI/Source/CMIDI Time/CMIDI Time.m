//
//  CCurrentTime+CMIDI.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 7/12/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDI Time.h"
#import <CoreAudio/CoreAudio.h>

CMIDINanoseconds CMIDINow()
{
    return AudioConvertHostTimeToNanos(AudioGetCurrentHostTime());
}

