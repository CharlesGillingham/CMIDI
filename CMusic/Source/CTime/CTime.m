//
//  CTime.m
//  CMIDIClockTest
//
//  Created by CHARLES GILLINGHAM on 9/18/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CTime.h"


CTime CTimeDiv(CTime a, CTime b) {
    return a/b - (a%b < 0 ? 1 : 0);
}

CTime CTimeMod(CTime a, CTime b) {
    CTime c = a % b;
    return (c < 0 ? c + b : c);
}

