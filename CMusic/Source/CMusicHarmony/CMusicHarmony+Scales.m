//
//  CMusicHarmony+Scales.m
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 10/1/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//


#import "CMusicHarmony+Scales.h"
#import "CMusicHarmony+Chords.h"

@implementation CMusicHarmony (Scales)

- (BOOL) pitchClassIsMemberOfScale: (CMusicPitchClass) pc {
    return ([self harmonicStrength:pc] >= kCMusic_scaleTone);
}


- (BOOL) noteIsMemberOfScale: (CMusicNote) note {
    return [self pitchClassIsMemberOfScale:CMusicPitchClassWithNote(note)];
}


// -----------------------------------------------------------------------------
#pragma mark            Scale form
// -----------------------------------------------------------------------------

// Scale tones per octave -- the number of notes in the scale.
- (SInt16) scaleTonesCount
{
    SInt16 cnt = 0;
    for (CMusicPitchClass pc = 0; pc < CMusicPitchClass_Count; pc++) {
       if ([self pitchClassIsMemberOfScale:pc]) cnt++;
    }
    return cnt;
}


- (NSArray *) scaleForm
{
    NSMutableArray * scaleForm = [NSMutableArray arrayWithCapacity:CMusicPitchClass_Count];
    CMusicNote key = self.key;
    for (CMusicNote n = key; n < CMusicPitchClass_Count+key; n++) {
        if ([self noteIsMemberOfScale:n]) {
            CMusicPitchClass dn = (n - key);
            [scaleForm addObject:[NSNumber numberWithInteger:dn]];
        }
    }
    return scaleForm;
}


- (void) setScaleForm:(NSArray *)scaleForm
{
    [self setKey: self.key
       scaleForm: scaleForm
       chordRoot: self.chordRootScaleDegree
       chordForm: self.chordForm];
}


// -----------------------------------------------------------------------------
#pragma mark            Scale degree distance
// -----------------------------------------------------------------------------


- (SInt16) distanceInScaleDegreesFrom: (CMusicNote) n1
                                   to: (CMusicNote) n2
{
    SInt16 p1 = CMusicPitchClassWithNote(n1);
    SInt16 p2 = CMusicPitchClassWithNote(n2);
    SInt16 o1 = CMusicOctaveWithNote(n1);
    SInt16 o2 = CMusicOctaveWithNote(n2);
    
    SInt16 pcDiff = 0;
    if (p1 > p2) {
        for (CMusicPitchClass pc = p2+1; pc <= p1; pc++) {
            if ([self pitchClassIsMemberOfScale:pc]) pcDiff--;
        }
    } else {
        for (CMusicPitchClass pc = p1+1; pc <= p2; pc++) {
            if ([self pitchClassIsMemberOfScale:pc]) pcDiff++;
        }
    }
    
    SInt16 octDiff = o2 - o1;
    
    return octDiff * [self scaleTonesCount] + pcDiff;
}



- (CMusicNote) noteAt: (CMusicScaleDegree) sd scaleDegreesFrom: (CMusicNote) n1
{
    SInt16 nPitchCl = CMusicPitchClassWithNote(n1);
    SInt16 nOctaves = CMusicOctaveWithNote(n1);
    
    SInt16 sdCount = [self scaleTonesCount];
    SInt16 sdInOctave = SInt16Mod(sd, sdCount);
    SInt16 sdOctaves  = SInt16Div(sd, sdCount);
    
    CMusicNote n = CMusicNoteWithOctavePitchClass(sdOctaves + nOctaves, nPitchCl);
    
    // Take the "scale degree floor" of the note, before adding to it. Possible issue/odd case: clients may be confused by the behavior of this routine when it is passed an accidental. if we have C# in C major, the note at zero scale degrees is C natural. (I.e., the previous note). This is because we can only really take the scale degree distance between two members of a scale; the accidental must first be reduced to an element of the scale, by "flooring" it. This is a little weird, but it's the only thing that makes sense.
    while (![self noteIsMemberOfScale:n]) n--;
    
    for (SInt16 s = 0; s < sdInOctave; s++) {
        n++;
        while (![self noteIsMemberOfScale:n]) n++;
    }
    
    return n;
}


// -----------------------------------------------------------------------------
#pragma mark            Scale degree (as distance from key in octave 0)
// -----------------------------------------------------------------------------


- (CMusicNote) noteFromScaleDegree: (CMusicScaleDegree) sd
{
    return [self noteAt:sd scaleDegreesFrom:self.key];
}


- (CMusicScaleDegree) scaleDegreeFromNote: (CMusicNote) note
{
    return [self distanceInScaleDegreesFrom:self.key to:note];
}



- (CMusicPitchClass) pitchClassFromScaleDegree: (CMusicScaleDegree) sd
{
    return CMusicPitchClassWithNote([self noteFromScaleDegree:sd]);
}


- (CMusicScaleDegree) scaleDegreeFromPitchClass: (CMusicPitchClass) pc
{
    SInt16 sdCount = [self scaleTonesCount];
    SInt16 sd = [self distanceInScaleDegreesFrom:self.key to:pc];
    return SInt16Mod(sd, sdCount);
}


- (SInt16) accidentalFromNote: (CMusicNote) n
{
    SInt16 acc = 0;
    while (![self noteIsMemberOfScale:n-acc]) {
        acc++;
        NSAssert(acc < 12,@"EMPTY SCALE");
    }
    return acc;
}


@end
