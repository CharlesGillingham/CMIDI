//
//  CMNote.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 9/4/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMNote.h"

// -----------------------------------------------------------------------------
#pragma mark                    Getters/Setters
// -----------------------------------------------------------------------------


CMNote CMNoteWithOctavePitchClass(CMOctave octave, CMPitchClass pitchClass)
{
    return (octave+1)*12 + pitchClass;
}


// Python style mod.

CMPitchClass CMPitchClassWithNote(CMNote note)
{
    if (note >= 0) {
        return note % 12;
    } else {
        return  (11 - ((-note-1) % 12));
    }
}


// Python style div (- 1 to get middle C to equal to C4).

CMOctave CMOctaveWithNote(CMNote note)
{
    if (note >= 0) {
        return ((SInt16)floor(note/12))-1;
    } else {
        return -(((SInt16)floor((-note-1)/12)))-2;
    }
}

// -----------------------------------------------------------------------------
#pragma mark                     Frequency
// -----------------------------------------------------------------------------


Float64 CMNFrequencyWithNote(CMNote note)
{
return (440*pow(2,(Float64)(note - CMNote_A440))/12);
}


// -----------------------------------------------------------------------------
#pragma mark                     Note Name
// -----------------------------------------------------------------------------

const char * CMNote_MajorKeyNoteNames[12][12] =
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

const char * CMNote_MinorKeyNoteNames[12][12] =
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



NSString * CMNoteNameWithKey(CMNote note, CMPitchClass key, BOOL isMinor)
{
    CMOctave     octave     = CMOctaveWithNote(note);
    CMPitchClass pitchClass = CMPitchClassWithNote(note);
    const char * noteName;
    if (isMinor) {
        noteName = CMNote_MinorKeyNoteNames[key][pitchClass];
    } else {
        noteName = CMNote_MajorKeyNoteNames[key][pitchClass];
    }
    return [NSString stringWithFormat:@"%s%d", noteName, octave];
}



NSString * CMNoteName(CMNote note)
{
    return CMNoteNameWithKey(note, CMPitchClass_C, NO);
}
