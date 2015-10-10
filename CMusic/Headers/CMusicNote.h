//
//  CMusicNote.h
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 9/4/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import <Foundation/Foundation.h>

//  CMusicNotes are aligned with MIDI notes, but allow more notes below 0 and above 127.
//  Middle C is defined as C4
//  Middle C is MIDI note 60

typedef SInt16 CMusicPitchClass;
typedef SInt16 CMusicOctave;
typedef SInt16 CMusicNote;

enum {
    CMusicPitchClass_Min   =  0,
    CMusicPitchClass_Max   = 11,
    CMusicPitchClass_Count = 12
};

enum {
    CMusicPitchClass_C          = 0,
    CMusicPitchClass_Csharp     = 1,
    CMusicPitchClass_Dflat      = 1,
    CMusicPitchClass_D          = 2,
    CMusicPitchClass_Dsharp     = 3,
    CMusicPitchClass_Eflat      = 3,
    CMusicPitchClass_E          = 4,
    CMusicPitchClass_F          = 5,
    CMusicPitchClass_Fsharp     = 6,
    CMusicPitchClass_Gflat      = 7,
    CMusicPitchClass_G          = 7,
    CMusicPitchClass_Gsharp     = 7,
    CMusicPitchClass_Aflat      = 8,
    CMusicPitchClass_A          = 9,
    CMusicPitchClass_Asharp     = 10,
    CMusicPitchClass_Bflat      = 10,
    CMusicPitchClass_B          = 11
};

enum {
    CMusicNote_MiddleC = 60,
    CMusicNote_A440    = 57
};

CMusicNote       CMusicNoteWithOctavePitchClass(CMusicOctave o, CMusicPitchClass pc);
CMusicOctave     CMusicOctaveWithNote(CMusicNote note);
CMusicPitchClass CMusicPitchClassWithNote(CMusicNote note);

Float64          CMusicFrequencyWithNote(CMusicNote note);

// Names
const char * CMusicPitchClassNameWithKey(CMusicPitchClass pitchClass, CMusicPitchClass key, BOOL isMinor);
const char * CMusicPitchClassName(CMusicPitchClass pitchClass);
NSString   * CMusicNoteNameWithKey(CMusicNote note, CMusicPitchClass key, BOOL isMinor);
NSString   * CMusicNoteName(CMusicNote note);

// These utilities are also used for scale degrees and other harmonic objects.
SInt16 SInt16Div(SInt16 a, SInt16 b);
SInt16 SInt16Mod(SInt16 a, SInt16 b);

