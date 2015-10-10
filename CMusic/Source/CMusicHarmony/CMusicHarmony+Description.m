//
//  CMusicHarmony+Description.m
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 10/5/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMusicNote.h"
#import "CMusicHarmony+Description.h"
#import "CMusicHarmony+Chords.h"
#import "CMusicHarmony+Scales.h"


@implementation CMusicHarmony (Description)

- (NSString *) description
{
    NSMutableString * s = [NSMutableString stringWithFormat:
                           @"<CMusicHarmony: Harmonic strengths:[%d",[self harmonicStrength:0]];
    for (CMusicPitchClass p = 1; p < 12; p++) {
        [s appendFormat:@", %d",[self harmonicStrength:p]];
    }
    [s appendString:@"] >"];
    return s;
}


// -------------------------------------------------------------------------------------
#pragma mark                    Harmonic strength string
// -------------------------------------------------------------------------------------

- (NSString *) harmonicStrengthString
{
    NSMutableString * s = [NSMutableString stringWithFormat:
                           @"[%d",[self harmonicStrength:0]];
    for (CMusicPitchClass p = 1; p < 12; p++) {
        [s appendFormat:@", %d",[self harmonicStrength:p]];
    }
    [s appendString:@"]"];
    return s;
}


// -------------------------------------------------------------------------------------
#pragma mark                    Note Name
// -------------------------------------------------------------------------------------

- (NSString *) noteName: (CMusicNote) n
{
    BOOL isMinor = ([self harmonicStrength:3] >= kCMusic_scaleTone);
    return CMusicNoteNameWithKey(n, self.key, isMinor);
}


// -------------------------------------------------------------------------------------
#pragma mark                    Pitch Class Name
// -------------------------------------------------------------------------------------


// Specialized in Western Harmony
- (NSString *) pitchClassName: (CMusicPitchClass) pc
{
    BOOL isMinor = ([self harmonicStrength:3] >= kCMusic_scaleTone);
    return [NSString stringWithFormat:@"%s", CMusicPitchClassNameWithKey(pc, self.key, isMinor)];
}


- (NSArray *) pitchClassNames
{
    // Created dynamically, because the pitch class names depend on the key.
    NSMutableArray * pcN = [NSMutableArray arrayWithCapacity:CMusicPitchClass_Count];
    for (CMusicPitchClass pc = 0; pc <= CMusicPitchClass_Max; pc++) {
        [pcN addObject:[self pitchClassName:pc]];
    }
    return pcN;
}


// -------------------------------------------------------------------------------------
//     KEY NAMES
// -------------------------------------------------------------------------------------

- (NSArray *) keyNames
{
    // Created dynamically, because the pitch class names depend on the key.
    NSMutableArray * pcN = [NSMutableArray arrayWithCapacity:CMusicPitchClass_Count];
    for (CMusicPitchClass pc = 0; pc <= CMusicPitchClass_Max; pc++) {
        [pcN addObject:[NSString stringWithFormat:@"%s", CMusicPitchClassNameWithKey(pc, CMusicPitchClass_C, NO)]];
    }
    return pcN;
}


- (NSString *) keyName
{
    return [NSString stringWithFormat:@"%s",CMusicPitchClassName(self.key)];
}


// -------------------------------------------------------------------------------------
//     SCALE DEGREE NAMES
// -------------------------------------------------------------------------------------


NSArray * CMusicScaleDegreeNames = nil;

void CMusic_initScaleDegreeNames()
{
    if (CMusicScaleDegreeNames == nil) {
        CMusicScaleDegreeNames = @[@"I", @"II", @"III", @"IV", @"V", @"VI", @"VII",
                                   @"VIII",@"IX",@"X",@"XI",@"XII"];
    }
}


- (NSArray *) scaleDegreeNames
{
    CMusic_initScaleDegreeNames();
    NSRange r = {0, [self scaleTonesCount]};
    return [CMusicScaleDegreeNames subarrayWithRange:r];
}


- (NSString *) scaleDegreeName: (CMusicScaleDegree) sd
{
    CMusic_initScaleDegreeNames();
    SInt16 cnt =  self.scaleTonesCount;
    SInt16 sd1 = SInt16Mod(sd, cnt);
    SInt16 oct = SInt16Div(sd, cnt);
    NSString * sdName = CMusicScaleDegreeNames[sd1];
    if (oct == 0) {
        return sdName;
    }
    return [NSString stringWithFormat:@"%@ %d", sdName, oct];
}


- (NSArray *) scaleDegreePitchClassNames
{
    NSUInteger cnt = [self scaleTonesCount];
    NSMutableArray * crn = [NSMutableArray arrayWithCapacity:cnt];
    for (CMusicScaleDegree sd = 0; sd < cnt; sd++) {
        [crn addObject:[self scaleDegreePitchClassName:sd]];
    }
    return crn;
}



- (NSString *) scaleDegreePitchClassName: (CMusicScaleDegree) sd
{
    return [self pitchClassName:[self pitchClassFromScaleDegree:sd]];
}


// -------------------------------------------------------------------------------------
//     CHORD FORM NAMES
// -------------------------------------------------------------------------------------
// Not implemented

- (const NSArray *) chordFormNames
{
    return @[@"Triad"];
}

- (NSString *) chordFormName
{
    return @"Triad";
}


// -------------------------------------------------------------------------------------
//     CHORD ROOT NAMES
// -------------------------------------------------------------------------------------

- (NSString *) chordRootScaleDegreeName
{
    return [self scaleDegreeName:[self chordRootScaleDegree]];
}


// -------------------------------------------------------------------------------------
//     CHORD ROOT PITCH CLASS NAME
// -------------------------------------------------------------------------------------

- (NSString *) chordRootPitchClassName
{
    return [self pitchClassName:[self chordRootPitchClass]];
}

@end
