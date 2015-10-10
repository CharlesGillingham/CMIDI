//
//  CMusicTempoMeter.h
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 9/29/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CTimeMap.h"

// Time lines.
// Use >= to determine if a time is above a certain strength; e.g., to find out if this is the downbeat of a bar, ask is timeStrength >= CMusic_Bars.
enum {
    CMusic_Nanos          = 0,
    CMusic_Ticks          = 1,
    CMusic_32nds          = 2,
    CMusic_16ths          = 3,
    CMusic_8ths           = 4,
    CMusic_Beats          = 5,
    CMusic_HalfBars       = 6,
    CMusic_Bars           = 7,
    CMusic_Section        = 8,
    CMusic_Movement       = 9,
    CMusic_PieceOrInterim = 10,
    CMusic_Piece          = 11
};

// Time strength: every nanosecond in the piece falls into exactly one of these categories.
enum {
    CMusic_OddNanos               = 0,
    CMusic_OddTicks               = 1,
    CMusic_Upbeat32nds            = 2,
    CMusic_Upbeat16ths            = 3,
    CMusic_Upbeat8ths             = 4,
    CMusic_BackBeats              = 5,
    CMusic_MidBars                = 6,
    CMusic_OddBarDownBeats        = 7,
    CMusic_MiddleSectionDownBeats = 8,
    CMusic_LaterMovementDownBeats = 9,
    CMusic_PieceEnds              = 10,
    CMusic_PieceStarts            = 11
};


@interface CMusicTempoMeter : CTimeMap
@end


#import "CMusicTempoMeter+BackwardCompatibility.h"