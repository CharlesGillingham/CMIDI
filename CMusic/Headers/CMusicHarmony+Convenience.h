//
//  CMusicHarmony+Convenience.h
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 10/1/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMusicHarmony.h"


@interface CMusicHarmony (HarmonicStrengthConvenience)

// An array of 12 strengths, one for each pitch class. This is a proxy.
@property (readonly) NSMutableArray * harmonicStrengths;

// Harmonic strength for note
- (CMusicHarmonicStrength) harmonicStrengthOfNote: (CMusicNote) note;

@end



