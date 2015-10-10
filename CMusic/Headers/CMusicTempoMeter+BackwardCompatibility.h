//
//  CMusicTempoMeter+BackwardCompatibility.h
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 9/29/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMusicTempoMeter.h"

// --------------------------------------------------------------------------------------------------------
// TIME UNITS
// --------------------------------------------------------------------------------------------------------

typedef CTime MTicks;        // aligned with CMIDIClockTicks
typedef CTime MNanoseconds;  // aligned with CMIDINanoseconds

// -----------------------------------------------------------------------------------------------------------------
// BEAT STRENGTH
// -----------------------------------------------------------------------------------------------------------------

typedef CTimeLine MBeatStrength;

enum {
    MBeatStrength_Max    = 11,
    MBeatStrength_Count  = 12
};


enum {
    MBeatstrength_OddNanoseconds              = CMusic_OddNanos,
    MBeatStrength_OddTicks                    = CMusic_OddTicks,
    MBeatStrength_Upbeat32nds                 = CMusic_Upbeat32nds,
    MBeatStrength_Upbeat16ths                 = CMusic_Upbeat16ths,
    MBeatStrength_Upbeat8ths                  = CMusic_Upbeat8ths,
    MBeatStrength_BackBeats                   = CMusic_BackBeats,
    MBeatStrength_MidBarDownBeats             = CMusic_MidBars,
    MBeatStrength_OddBarDownBeats             = CMusic_OddBarDownBeats,
    MBeatStrength_MiddleSectionDownBeats      = CMusic_MiddleSectionDownBeats,
    MBeatStrength_OddMovementDownBeats        = CMusic_LaterMovementDownBeats,
    MBeatStrength_EndPieceDownBeats           = CMusic_PieceEnds,
    MBeatStrength_StartPieceDownBeats         = CMusic_PieceStarts
};

// Things like chord and scale change on high beat strengths
enum {
    MHighBeatStrengths_Min = MBeatStrength_MidBarDownBeats,
    MHighBeatStrengths_Max = MBeatStrength_StartPieceDownBeats,
    MHighBeatStrengths_Count = MHighBeatStrengths_Max - MHighBeatStrengths_Min + 1
};

// Things like note events occur on low beat strengths
enum {
    MLowBeatStrengths_Min = MBeatStrength_Upbeat32nds,
    MLowBeatStrengths_Max = MBeatStrength_MiddleSectionDownBeats,
    MLowBeatStrengths_Count = (MLowBeatStrengths_Max - MLowBeatStrengths_Min + 1)
};

enum {
    MRhythm_MinHighTicks = 0,
    MRhythm_MaxHighTicks = (960000/48)
};



@interface CMusicTempoMeter (BackwardCompatibility)
- (CTimeLine) beatStrengthOfTick: (CTime) tick;
- (CTime) ticksPerBeatStrength: (CTimeLine) bs;
- (NSArray *) beatSignalOfTick: (MTicks) tick;
- (CTime) ticksPerBar;
@end

