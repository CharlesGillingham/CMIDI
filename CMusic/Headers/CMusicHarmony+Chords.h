//
//  CMusicHarmony+Chords.h
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 10/1/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMusicHarmony.h"
#import "CMusicHarmony+Scales.h"



@interface CMusicHarmony (Chords)

// Chords and pitch classes
- (BOOL) pitchClassIsMemberOfChord: (CMusicPitchClass) pc;
- (BOOL) pitchClassIsChordRoot:     (CMusicPitchClass) pc;

// Chords and notes
- (BOOL) noteIsMemberOfChord:       (CMusicNote) note;
- (BOOL) noteIsChordRoot:           (CMusicNote) note;

// Given a key, the chord scale degree and the chord form define the chord.
// chordForm is the set of scale degree distances to each member of the chord, for example a "triad" has the chord form [0,2,4].
// To specify a the IV chord of the key, the chordRootScaleDegree is 3 and the chord form [0,2,4].
@property NSArray * chordForm;
@property (readonly) NSUInteger chordMemberCount;
@property CMusicScaleDegree chordRootScaleDegree;
@property CMusicPitchClass  chordRootPitchClass;

@end
