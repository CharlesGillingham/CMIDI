//
//  CMusicWesternHarmony.h
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 10/2/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMusicHarmony.h"
#import "CMusicHarmony+Scales.h"

// These six scales are the only scales where all intervals at a scale distance of 2 are major and minor thirds; i.e., these scales are exactly those that have a particular density of notes. For performance reasons, it is easier for this application to choose randomly between these predetermined choices, rather than reinventing the nature of scales on the fly. We can extend this to include other scales (such as pentatonic), but adding a distribution of the scale "density" is beyond me now.
// As a side effect, the distributions are easier to control, and they have names that you can recognize.
typedef SInt16 CMusicScaleType;
enum {
    CMusicScaleType_Major         = 0,
    CMusicScaleType_MelodicMinor  = 1,
    CMusicScaleType_HarmonicMinor = 2,
    CMusicScaleType_HarmonicMajor = 3,
    CMusicScaleType_WholeTone     = 4,
    CMusicScaleType_EightNote     = 5
};
enum {
    CMusicScaleType_Min   = 0,
    CMusicScaleType_Max   = 5,
    CMusicScaleType_Count = 6
};


// An integer between 0 and 7, although the maximum depends on the scale.
// (Mode is zero-based here, unlike common practice.)
typedef SInt16 CMusicScaleMode;
enum {
    CMusicMode_Ionian     = 0,
    CMusicMode_Dorian     = 1,
    CMusicMode_Phrygian   = 2,
    CMusicMode_Lydian     = 3,
    CMusicMode_Mixolydian = 4,
    CMusicMode_Aeolian    = 5,
    CMusicMode_Locrian    = 6,
    CMusicMode_8thMode    = 7
};

enum {
    CMusicScaleMode_Min   = 0, // Just to emphasize this is zero based, unlike common practice
    CMusicWScaleMode_Count = 8, // The maximum number of modes for any western scale (actual count varies by type)
    CMusicWScaleMode_Max   = 7  // The maximum mode of any scale.
};






// These are the four types of triads, defined in terms of pitchClass distances.
typedef SInt16 CMusicChordType;
enum {
    CMusicChordTypeMajor      = 0,
    CMusicChordTypeMinor      = 1,
    CMusicChordTypeAugmented  = 2,
    CMusicChordTypeDiminished = 3
};
enum {
    MChordType_Max = 3,
    MChordType_Count = 4
};


// Every western harmony represented here has a unique number. The total number of scales is:
// 4 seven note scales, in 12 keys with 7 modes and 7 chord roots.
// 1 six note scale, in 12 keys with 6 roots and 1 mode
// 1 eight note scale, in 12 keys with
// Note: the last two scales will have identical harmonic strengths for some key/chord combinations.
enum {
    CMusicWesternHarmony_Count = (12*7*7)*4 + 12*6*1 + 12*8*2,
    CMusicWesternHarmony_Min   = 0,
    CMusicWesternHarmony_Max   = CMusicWesternHarmony_Count-1
};


@interface CMusicWesternHarmony : CMusicHarmony
@property CMusicScaleType   scaleType;
@property CMusicScaleMode   scaleMode;
@property SInt16            number;
@property (readonly) CMusicChordType chordType;

- (id) initWithType: (CMusicScaleType) type
               mode: (CMusicScaleMode) mode
                key: (CMusicPitchClass) key
          chordRoot: (CMusicScaleDegree) sd;

+ (instancetype) CMajorI;
@end
