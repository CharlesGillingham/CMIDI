//
//  CMNote.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 9/4/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import <Foundation/Foundation.h>

//  CMNotes are aligned with MIDI notes, but allow more notes below 0 and above 127.
//  Middle C is defined as C4
//  Middle C is MIDI note 60

typedef SInt16 CMPitchClass;
typedef SInt16 CMOctave;
typedef SInt16 CMNote;

enum {
    CMPitchClass_Min = 0,
    CMPitchClass_Max = 11,
    CMPitchClass_Count = 12
};

enum {
    CMPitchClass_C          = 0,
    CMPitchClass_Csharp     = 1,
    CMPitchClass_Dflat      = 1,
    CMPitchClass_D          = 2,
    CMPitchClass_Dsharp     = 3,
    CMPitchClass_Eflat      = 3,
    CMPitchClass_E          = 4,
    CMPitchClass_F          = 5,
    CMPitchClass_Fsharp     = 6,
    CMPitchClass_Gflat      = 7,
    CMPitchClass_G          = 7,
    CMPitchClass_Gsharp     = 7,
    CMPitchClass_Aflat      = 8,
    CMPitchClass_A          = 9,
    CMPitchClass_Asharp     =10,
    CMPitchClass_Bflat      =10,
    CMPitchClass_B          =11
};

enum {
    CMNote_MiddleC = 60,
    CMNote_A440 = 57
};

CMNote       CMNoteWithOctavePitchClass(CMOctave o, CMPitchClass pc);
CMOctave     CMOctaveWithNote(CMNote note);
CMPitchClass CMPitchClassWithNote(CMNote note);

NSString * CMNoteNameWithNoteAndKey(CMNote note, CMPitchClass key, BOOL isMinor);
NSString * CMNoteName(CMNote note);

Float64 CMFrequencyWithNote(CMNote note);
