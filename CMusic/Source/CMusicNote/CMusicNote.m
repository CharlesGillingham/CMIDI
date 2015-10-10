//
//  CMusicNote.m
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 9/4/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMusicNote.h"

// Python-style mod and div
SInt16 SInt16Div(SInt16 a, SInt16 b) {
    return a/b - (a%b < 0 ? 1 : 0);
}

SInt16 SInt16Mod(SInt16 a, SInt16 b) {
    SInt16 c = a % b;
    return (c < 0 ? c + b : c);
}

// -----------------------------------------------------------------------------
#pragma mark                    Getters/Setters
// -----------------------------------------------------------------------------

CMusicNote CMusicNoteWithOctavePitchClass(CMusicOctave octave, CMusicPitchClass pitchClass)
{
    return (octave+1)*12 + pitchClass;
}

// Python style mod.
CMusicPitchClass CMusicPitchClassWithNote(CMusicNote note)
{
   return SInt16Mod(note, 12);
}

// Python style div (- 1 to get middle C to equal to C4).
CMusicOctave CMusicOctaveWithNote(CMusicNote note)
{
    return SInt16Div(note,12)-1;
}

// -----------------------------------------------------------------------------
#pragma mark                     Frequency
// -----------------------------------------------------------------------------


Float64 CMusicNFrequencyWithNote(CMusicNote note)
{
return (440*pow(2,(Float64)(note - CMusicNote_A440))/12);
}


// -----------------------------------------------------------------------------
#pragma mark                     Note Name
// -----------------------------------------------------------------------------

const char * CMusicNote_MajorKeyNoteNames[12][12] =
{
    /* C */ {"C",  "C#", "D",  "Eb", "E",  "F",  "F#", "G",  "G#/Ab","A",  "Bb",    "B"},
    /* Db*/ {"C",  "Db", "Dn", "Eb", "En", "F",  "Gb", "Gn", "Ab",   "An", "Bb",    "Bn"},
    /* D */ {"Cn", "C#", "D",  "D#", "E",  "Fn", "F#", "G",  "G#",   "A",  "A#",    "B"},
    /* Eb*/ {"C",  "Db", "D",  "Eb", "En", "F",  "Gb", "G",  "Ab",   "An", "Bb",    "Bn"},
    /* E */ {"Cn", "C#", "Dn", "D#", "E",  "Fn", "F#", "Gn", "G#",   "A",  "A#",    "B"},
    /* F */ {"C",  "Db", "D",  "Eb", "E",  "F",  "Gb", "G",  "Ab",   "A",  "Bb",    "Bn"},
    /* Gb*/ {"Cn", "Db", "Dn", "Eb", "En", "F",  "Gb", "Gn", "Ab",   "An", "Bb",    "Cb"},
    /* G */ {"C",  "C#", "D",  "D#", "E",  "Fn", "F#", "G",  "G#",   "A",  "A#/Bb", "B"},
    /* Ab*/ {"C",  "Db", "Dn", "Eb", "En", "F",  "Gb", "G",  "Ab",   "An", "Bb",    "Bn"},
    /* A */ {"Cn", "C#", "D",  "D#", "E",  "Fn", "F#", "Gn", "G#",   "A",  "A#",    "B"},
    /* Bb*/ {"C",  "Db", "D",  "Eb", "En", "F",  "Gb", "G",  "Ab",   "A",  "Bb",    "Bn"},
    /* B */ {"Cn", "C#", "Dn", "D#", "E",  "Fn", "F#", "Gn", "G#",   "An", "A#",    "B"}
};

const char * CMusicNote_MinorKeyNoteNames[12][12] =
{
    /* C */ {"C",  "C#", "D",  "Eb", "En", "F",  "Gb", "G",  "Ab",   "An", "Bb",    "Bn"},
    /* C#*/ {"B#", "C#", "Dn", "D#", "E",  "Fn", "F#", "Gn", "G#",   "A",  "A#",    "B"},
    /* D */ {"C",  "C#", "D",  "Eb", "E",  "F",  "Gb", "G",  "Ab",   "A",  "Bb",    "Bn"},
    /* Eb*/ {"Cn", "Db", "Dn", "Eb", "En", "F",  "Gb", "Gn", "Ab",   "An", "Bb",    "Cb"},
    /* E */ {"C",  "C#", "D",  "D#", "E",  "Fn", "F#", "G",  "G#",   "A",  "A#",    "B"},
    /* F */ {"C",  "Db", "Dn", "Eb", "En", "F",  "Gb", "G",  "Ab",   "An", "Bb",    "Bn"},
    /* F#*/ {"Cn", "C#", "D",  "D#", "E",  "E#", "F#", "Gn", "G#",   "A",  "A#",    "B"},
    /* G */ {"C",  "Db", "D",  "Eb", "En", "F",  "F#", "G",  "Ab",   "A",  "Bb",    "Bn"},
    /* G#*/ {"Cn", "C#", "Dn", "D#", "E",  "Fn", "F#", "Gn", "G#",   "An", "A#",    "B"},
    /* A */ {"C",  "C#", "D",  "Eb", "E",  "F",  "F#", "G",  "G#",   "A",  "Bb",    "B"},
    /* Bb*/ {"C",  "Db", "Dn", "Eb", "En", "F",  "Gb", "Gn", "Ab",   "An", "Bb",    "Bn"},
    /* B */ {"Cn", "C#", "D",  "D#", "E",  "Fn", "F#", "G",  "G#",   "A",  "A#",    "B"}
};


const char * CMusicPitchClassNameWithKey(CMusicPitchClass pitchClass, CMusicPitchClass key, BOOL isMinor)
{
    assert(pitchClass < 12 && pitchClass >= 0);
    assert(key < 12        && key >= 0);
    if (isMinor) {
        return CMusicNote_MinorKeyNoteNames[key][pitchClass];
    } else {
        return CMusicNote_MajorKeyNoteNames[key][pitchClass];
    }
}


const char * CMusicPitchClassName(CMusicPitchClass pitchClass)
{
    return CMusicPitchClassNameWithKey(pitchClass, CMusicPitchClass_C, NO);
}



NSString * CMusicNoteNameWithKey(CMusicNote note, CMusicPitchClass key, BOOL isMinor)
{
    CMusicOctave     octave     = CMusicOctaveWithNote(note);
    CMusicPitchClass pitchClass = CMusicPitchClassWithNote(note);
    const char * noteName = CMusicPitchClassNameWithKey(pitchClass, key, isMinor);
    return [NSString stringWithFormat:@"%s%d", noteName, octave];
}



NSString * CMusicNoteName(CMusicNote note)
{
    return CMusicNoteNameWithKey(note, CMusicPitchClass_C, NO);
}
