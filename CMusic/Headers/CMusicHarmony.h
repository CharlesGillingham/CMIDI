//
//  CMusicHarmony.h
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 10/1/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMusicNote.h"

// Harmony represents the chord and the scale. It assigns a "harmonic strength" to each pitch class. A harmonic strength is an integer between 0 and 2. 0 - not in scale, 1 - in scale, not in chord, 2 - in chord (and thus in scale)
typedef SInt16 CMusicHarmonicStrength;
enum {
    CMusicHarmonicStrength_Max = 3,
    CMusicHarmonicStrength_Count = 4
};

enum {
    kCMusic_outOfKey  = 0,
    kCMusic_scaleTone = 1,
    kCMusic_chordTone = 2,
    kCMusic_chordRoot = 3
    
};


@interface CMusicHarmony : NSObject

- (id) initWithHarmonicStrengths: (NSArray *) harmonicStrengths
                             key: (CMusicPitchClass) key NS_DESIGNATED_INITIALIZER;

// An example, or default value.
+ (instancetype) CMajorI;

// Setting the key directly will rotate the scale.
@property CMusicPitchClass key;

- (CMusicHarmonicStrength) harmonicStrength: (CMusicPitchClass) pc;
- (void) setHarmonicStrength: (CMusicHarmonicStrength) hs
                ofPitchClass: (CMusicPitchClass) pc;
- (void) setHarmonicStrengths: (NSArray *) strengths;

// Rotate the harmony by the amount given. May be negative or positive.
- (void) transpose: (CMusicPitchClass) deltaPC;

// Set the harmonic strengths using chord and scale.
- (void) setKey: (CMusicPitchClass) newKey
      scaleForm: (NSArray *) scaleForm
      chordRoot: (SInt16) chordRootScaleDegree
      chordForm: (NSArray *) chordForm;

// Rotate the forms by mode & inversion. (Mode and inversion are not stored)
- (void) setKey: (CMusicPitchClass) newKey
      scaleForm: (NSArray *) scaleForm
           mode: (SInt16) mode
      chordRoot: (SInt16) chordRootScaleDegree
      chordForm: (NSArray *) chordForm
      inversion: (SInt16) inversion;

@end



