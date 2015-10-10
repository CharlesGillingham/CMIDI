//
//  CMusicHarmony+Chords.m
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 10/1/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMusicHarmony+Chords.h"
#import "CMusicHarmony+Scales.h"

@implementation CMusicHarmony (Chords)

- (BOOL) pitchClassIsMemberOfChord: (CMusicPitchClass) pc {
    return ([self harmonicStrength:pc] >= kCMusic_chordTone);
}


- (BOOL) pitchClassIsChordRoot: (CMusicPitchClass) pc {
    return ([self harmonicStrength:pc] >= kCMusic_chordRoot);
}


- (BOOL) noteIsMemberOfChord: (CMusicNote) note {
    return [self pitchClassIsMemberOfChord:CMusicPitchClassWithNote(note)];
}


- (BOOL) noteIsChordRoot: (CMusicNote) note {
    return [self pitchClassIsChordRoot:CMusicPitchClassWithNote(note)];
}


- (NSUInteger) chordMemberCount
{
    NSUInteger cnt = 0;
    for (CMusicPitchClass pc = 0; pc < CMusicPitchClass_Count; pc++) {
        if ([self harmonicStrength:pc] >= kCMusic_chordRoot) cnt++;
    }
    return cnt;
}



- (CMusicPitchClass) chordRootPitchClass
{
    for (CMusicPitchClass pc = 0; pc < CMusicPitchClass_Count; pc++) {
        if ([self harmonicStrength:pc] >= kCMusic_chordRoot) {
            return pc;
        }
    }
    return (CMusicPitchClass) NSNotFound;
}



- (CMusicScaleDegree) chordRootScaleDegree
{
    return [self scaleDegreeFromPitchClass:[self chordRootPitchClass]];
}



// A list of the scale degrees in the chord, counting from the chord root.
- (NSArray *) chordForm
{
    CMusicPitchClass crpc = [self chordRootPitchClass];
    NSMutableArray * chordForm = [NSMutableArray new];
    if (crpc != (SInt16)NSNotFound) {
        SInt16 sd = 0;
        for (CMusicPitchClass i = 0; i < CMusicPitchClass_Count; i++) {
            CMusicPitchClass pc = SInt16Mod(crpc+i,12);
            if ([self pitchClassIsMemberOfScale:pc]) {
                if ([self pitchClassIsMemberOfChord:pc]) {
                    [chordForm addObject:[NSNumber numberWithInteger:sd]];
                }
                sd++;
            }
        }
    }
    return chordForm;
}

// -----------------------------------------------------------------------------
#pragma mark            Setters
// -----------------------------------------------------------------------------


-  (void) setChordRootPitchClass: (CMusicPitchClass) crpc
{
    [self setKey: self.key
       scaleForm: self.scaleForm
       chordRoot: [self scaleDegreeFromPitchClass:crpc]
       chordForm: self.chordForm];
}


- (void) setChordRootScaleDegree:(CMusicScaleDegree)sd
{
    [self setKey: self.key
       scaleForm: self.scaleForm
       chordRoot: sd
       chordForm: self.chordForm];
}


- (void) setChordForm:(NSArray *)chordForm
{
    [self setKey: self.key
       scaleForm: self.scaleForm
       chordRoot: self.chordRootScaleDegree
       chordForm: chordForm];
}




@end
