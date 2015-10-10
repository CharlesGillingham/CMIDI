//
//  CMusicWesternHarmony+Description.m
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 10/8/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMusicWesternHarmony+Description.h"
#import "CMusicHarmony+Chords.h"
#import "CMusicHarmony+Scales.h"

@implementation CMusicWesternHarmony (Description)

- (NSString *) description
{
    return [NSString stringWithFormat:@"<CMusicWesternHamronyHarmony: %@>", [self displayName]];
}

- (NSString *) displayName
{
    return [NSString stringWithFormat: @"%@, %@ of %@",
            [self chordName],
            [self scaleDegreeName: self.chordRootScaleDegree],
            [self scaleName]];
}



- (NSString *) scaleName
{
    if (self.scaleMode == 0) {
        return [NSString stringWithFormat:@"%@ %@ scale", self.keyName, self.scaleTypeName];
    } else {
        return [NSString stringWithFormat:@"%@ %@ mode of %@ %@",
                self.keyName,
                self.scaleModeName,
                [self pitchClassName:[self pitchClassFromScaleDegree:self.scaleTonesCount - self.scaleMode]],
                self.scaleTypeName
                ];
    }
}


- (NSString *) chordName
{
    return [NSString stringWithFormat:@"%@ %@",
            [self pitchClassName: self.chordRootPitchClass],
            [self chordTypeName]
            ];
}


// -------------------------------------------------------------------------------------
//     SCALE TYPE NAME
// -------------------------------------------------------------------------------------

NSArray * CMusicWesternHarmony_scaleTypeNames = nil;


- (const NSArray *) scaleTypeNames
{
    if (CMusicWesternHarmony_scaleTypeNames == nil) {
        CMusicWesternHarmony_scaleTypeNames =
        @[@"Major", @"Melodic Minor", @"Harmonic Minor", @"Harmonic Major", @"Whole Tone", @"Eight Note"];
    }
    
    return CMusicWesternHarmony_scaleTypeNames;
}


- (NSString *) scaleTypeName
{
    return [[self scaleTypeNames] objectAtIndex: self.scaleType];
}


- (void) setScaleTypeName:(NSString *)scaleTypeName
{
    NSUInteger pos = [[self scaleTypeNames] indexOfObject:scaleTypeName];
    if (pos != NSNotFound) {
        self.scaleType = (SInt16) pos;
    }
}

// -------------------------------------------------------------------------------------
//     SCALE MODE NAME
// -------------------------------------------------------------------------------------

NSArray * CMusicWesternHarmony_scaleModeNames = nil;

- (NSArray *) scaleModeNames
{
    if (CMusicWesternHarmony_scaleModeNames == nil) {
        CMusicWesternHarmony_scaleModeNames =
        @[@"Ionian", @"Dorian", @"Phrygian", @"Lydian", @"Mixolydian", @"Aeolian", @"Locrian", @"8th"];
    }
    NSRange r = {0, [self scaleTonesCount]};
    return [CMusicWesternHarmony_scaleModeNames subarrayWithRange:r];
}


- (NSString *) scaleModeName
{
    return [[self scaleModeNames] objectAtIndex: self.scaleMode];
}

- (void) setScaleModeName:(NSString *)scaleModeName
{
    NSUInteger pos = [[self scaleModeNames] indexOfObject:scaleModeName];
    if (pos != NSNotFound) {
        self.scaleMode = (SInt16) pos;
    }
}


// -------------------------------------------------------------------------------------
//     CHORD TYPE NAME
// -------------------------------------------------------------------------------------

// Need this to be an an instance method to be KVC compliant.
- (const NSArray *) chordTypeNames
{
    switch (self.scaleType) {
        case CMusicScaleType_EightNote: return @[@"Diminished"];
        case CMusicScaleType_WholeTone: return @[@"Augmented"];
        case CMusicScaleType_Major:     return @[@"Major", @"Minor", @"Diminished"];
        default:                        return @[@"Major", @"Minor", @"Augmented", @"Diminished"];
    }
}

- (NSString *) chordTypeName
{
    switch (self.chordType) {
        case CMusicChordTypeMajor:      return @"Major";
        case CMusicChordTypeMinor:      return @"Minor";
        case CMusicChordTypeAugmented:  return @"Augmented";
        case CMusicChordTypeDiminished: return @"Diminished";
        default: return @"Unknown";
    }
}

- (void) setChordTypeName: (NSString *)chordTypeName
{
/*
    NSParameterAssert([self.chordTypeNames containsObject:chordTypeName]);
    if ([chordTypeName isEqualToString:@"Major"]) {
        self.chordType = CMusicChordTypeMajor;
    } else if ([chordTypeName isEqualToString:@"Minor"]) {
        self.chordType = CMusicChordTypeMinor;
    } else if ([chordTypeName isEqualToString:@"Diminished"]) {
        self.chordType = CMusicChordTypeDiminished;
    } else if ([chordTypeName isEqualToString:@"Augmented"]) {
        self.chordType = CMusicChordTypeAugmented;
    }
 */
}

 
@end
