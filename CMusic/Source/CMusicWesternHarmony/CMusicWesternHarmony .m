//
//  CMusicWesternHarmony.m
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 9/21/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMusicWesternHarmony.h"
#import "CMusicHarmony+Scales.h"
#import "CMusicHarmony+Chords.h"

NSArray * CMusicWesternHarmony_scaleForms[CMusicScaleType_Count];
NSArray * CMusic_Triad = nil;


@implementation CMusicWesternHarmony {
    CMusicScaleType _scaleType;
    CMusicScaleMode _scaleMode;
    SInt16 _number;
}

- (id) initWithType: (CMusicScaleType) type
               mode: (CMusicScaleMode) mode
                key: (CMusicPitchClass) k
          chordRoot: (CMusicScaleDegree) crsd
{
    if (self = [super init]) {
        [self setKey:k
                type:type
                mode:mode
           chordRoot:crsd];
    }
    return self;
}

+ (instancetype) CMajorI
{
    return [[self alloc] initWithType: CMusicScaleType_Major
                                 mode: CMusicMode_Ionian
                                  key: CMusicPitchClass_C
                            chordRoot: 0];
}

// -----------------------------------------------------------------------------
#pragma mark           Scale forms
// -----------------------------------------------------------------------------


+ (void) initialize
{
    CMusicWesternHarmony_scaleForms[CMusicScaleType_Major]         = @[@0,@2,@4,@5,@7,@9,@11];
    CMusicWesternHarmony_scaleForms[CMusicScaleType_MelodicMinor]  = @[@0,@2,@3,@5,@7,@9,@11];
    CMusicWesternHarmony_scaleForms[CMusicScaleType_HarmonicMinor] = @[@0,@2,@3,@5,@7,@8,@11];
    CMusicWesternHarmony_scaleForms[CMusicScaleType_HarmonicMajor] = @[@0,@2,@4,@5,@7,@8,@11];
    CMusicWesternHarmony_scaleForms[CMusicScaleType_WholeTone]     = @[@0,@2,@4,@6,@8,@10];
    CMusicWesternHarmony_scaleForms[CMusicScaleType_EightNote]     = @[@0,@2,@3,@5,@6,@8,@9,@11];
    CMusic_Triad = @[@0,@2,@4];
}


// -----------------------------------------------------------------------------
#pragma mark            Universal setter
// -----------------------------------------------------------------------------

- (void) setKey: (CMusicPitchClass) k
           type: (CMusicScaleType) t
           mode: (CMusicScaleMode) m
      chordRoot: (CMusicScaleDegree) cr
{
    // Set these before we set everything else, so that the KVC notifies with the correct values.
    _scaleMode = m;
    _scaleType = t;
    [self setKey:k
       scaleForm:CMusicWesternHarmony_scaleForms[t]
            mode:m
       chordRoot:cr
       chordForm:CMusic_Triad
       inversion:0];
}


// -----------------------------------------------------------------------------
#pragma mark            Type and Mode
// -----------------------------------------------------------------------------

- (CMusicScaleType) scaleType
{
    return _scaleType;
}

- (CMusicScaleMode) scaleMode
{
    return _scaleMode;
}

- (void) setScaleType: (CMusicScaleType) type
{
    [self setKey:self.key
            type:type
            mode:_scaleMode
       chordRoot:self.chordRootScaleDegree];
}


- (void) setScaleMode: (CMusicScaleMode) mode
{
    [self setKey:self.key
            type:_scaleType
            mode:mode
       chordRoot:self.chordRootScaleDegree];
}


// -----------------------------------------------------------------------------
#pragma mark            Number
// -----------------------------------------------------------------------------

enum {
    firstMajor         = 0,
    firstMelodicMinor  = (12*7*7),
    firstHarmonicMinor = (12*7*7)*2,
    firstHarmonicMajor = (12*7*7)*3,
    firstWholeTone     = (12*7*7)*4,
    firstEightNote     = (12*7*7)*4 + (12*6*1),
    firstImpossible    = (12*7*7)*4 + (12*6*1) + (12*8*2)
};

static const SInt16 FirstNumberOfScaleType[CMusicScaleType_Count+1] =
{firstMajor, firstMelodicMinor, firstHarmonicMinor, firstHarmonicMajor, firstWholeTone, firstEightNote, firstImpossible};

static const SInt16 ModeCountOfScaleType[CMusicScaleType_Count] = {7,7,7,7,1,2};

static const SInt16 ScaleDegreeCountOfScaleType[CMusicScaleType_Count] = {7,7,7,7,6,8};


- (SInt16) number
{
    SInt16 firstNumberOfType = FirstNumberOfScaleType[_scaleType];
    SInt16 nModes            = ModeCountOfScaleType[_scaleType];
    SInt16 nScaleDegrees     = ScaleDegreeCountOfScaleType[_scaleType];
    
    SInt16 n = firstNumberOfType;
    n += (self.key * nModes * nScaleDegrees);
    n += (_scaleMode * nScaleDegrees);
    n += (self.chordRootScaleDegree);
    return n;
}



- (void) setNumber:(SInt16)number
{
    CMusicScaleType type = -1;
    for (CMusicScaleType st = 0; st <= CMusicScaleType_Count; st++) {
        if (number < FirstNumberOfScaleType[st]) {
            type = st-1;
            break;
        }
    }
    if (type == -1) return;
    
    SInt16 firstNumberOfType = FirstNumberOfScaleType[type];
    SInt16 nModes = ModeCountOfScaleType[type];
    SInt16 nScaleDegrees = ScaleDegreeCountOfScaleType[type];
    
    SInt16 n    = number - firstNumberOfType;
    SInt16 key  = SInt16Div(n,nModes*nScaleDegrees);
           n    = SInt16Mod(n,nModes*nScaleDegrees);
    SInt16 mode = SInt16Div(n,nScaleDegrees);
    SInt16 sd   = SInt16Mod(n,nScaleDegrees);
    
    [self setKey:key
            type:type
            mode:mode
       chordRoot:sd];
}
 


// -----------------------------------------------------------------------------
#pragma mark            ENHARMONIC TRIADS FOR EACH SCALE TYPE
// -----------------------------------------------------------------------------

// These are Triad types, obviously.
// Most of these scale don't have this many scale degree, so we fill in the blanks by going around a second time.
static const CMusicChordType ChordTypeFromScaleDegreeInC[CMusicScaleType_Count][8] = {
    {CMusicChordTypeMajor,      CMusicChordTypeMinor,       CMusicChordTypeMinor,       CMusicChordTypeMajor,
        CMusicChordTypeMajor,      CMusicChordTypeMinor,       CMusicChordTypeDiminished,  CMusicChordTypeMajor},
    {CMusicChordTypeMinor,      CMusicChordTypeMinor,       CMusicChordTypeAugmented,   CMusicChordTypeMajor,
        CMusicChordTypeMajor,      CMusicChordTypeDiminished,  CMusicChordTypeDiminished,  CMusicChordTypeMinor},
    {CMusicChordTypeMinor,      CMusicChordTypeDiminished,  CMusicChordTypeAugmented,   CMusicChordTypeMinor,
        CMusicChordTypeMajor,      CMusicChordTypeMajor,       CMusicChordTypeDiminished,  CMusicChordTypeMinor},
    {CMusicChordTypeMajor,      CMusicChordTypeDiminished,  CMusicChordTypeMinor,       CMusicChordTypeMinor,
        CMusicChordTypeMajor,      CMusicChordTypeAugmented,   CMusicChordTypeDiminished,  CMusicChordTypeMajor},
    {CMusicChordTypeAugmented,  CMusicChordTypeAugmented,   CMusicChordTypeAugmented,   CMusicChordTypeAugmented,
        CMusicChordTypeAugmented,  CMusicChordTypeAugmented,   CMusicChordTypeAugmented,   CMusicChordTypeAugmented},
    {CMusicChordTypeDiminished, CMusicChordTypeDiminished,  CMusicChordTypeDiminished,  CMusicChordTypeDiminished,
        CMusicChordTypeDiminished, CMusicChordTypeDiminished,  CMusicChordTypeDiminished,  CMusicChordTypeDiminished}
};

/*  might use this for a more efficient "image count"
 static const UInt8 MScaleChordTypeCount[MScaleType_Count][MChordType_Count] = {
 //  Major,  Minor,      Augmented,  Diminished
 {3,         3,          0,          1},
 {2,         2,          1,          2},
 {2,         2,          1,          2},
 {2,         2,          1,          2},
 {0,         0,          6,          0},
 {0,         0,          0,          8}
 };
 */


- (CMusicChordType) chordType
{
    SInt16 sdInC = SInt16Mod(self.chordRootScaleDegree - _scaleMode, self.scaleTonesCount);
    return ChordTypeFromScaleDegreeInC[_scaleType][sdInC];
}



@end
