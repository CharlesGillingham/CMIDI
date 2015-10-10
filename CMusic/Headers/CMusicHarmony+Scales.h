//
//  CMusicHarmony+Scales.h
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 10/1/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMusicHarmony.h"

typedef SInt16 CMusicScaleDegree;
typedef SInt16 CMusicAccidental;

@interface CMusicHarmony (Scales)
- (BOOL) pitchClassIsMemberOfScale: (CMusicPitchClass) pc;
- (BOOL) noteIsMemberOfScale: (CMusicNote) note;


// -----------------------------------------------------------------------------
#pragma mark     Scale form
// -----------------------------------------------------------------------------
// Scale tones per octave -- the number of notes in the scale.
- (SInt16) scaleTonesCount;

// An array of pitchClass distances.
@property NSArray * scaleForm;

// -----------------------------------------------------------------------------
#pragma mark     Scale degree (as a measure of the distance between notes)
// -----------------------------------------------------------------------------
- (SInt16) distanceInScaleDegreesFrom: (CMusicNote) n1 to: (CMusicNote) n2;
- (CMusicNote) noteAt: (CMusicScaleDegree) sd scaleDegreesFrom: (CMusicNote) n1;

// -----------------------------------------------------------------------------
#pragma mark     Scale degree (as distance from key in octave 0)
// -----------------------------------------------------------------------------
// Map the notes into "scale degrees". Every note has unique combination of "scale degree" and "accidental". The scale degree is incremented on each member of the scale. The accidental is the number of sharps to the note from the pitch class of the scale degree. The scale degree of the key (in octave 0) is 0.

- (CMusicNote) noteFromScaleDegree: (CMusicScaleDegree) sd;
- (CMusicScaleDegree) scaleDegreeFromNote: (CMusicNote) note;

- (SInt16) accidentalFromNote: (CMusicNote) n;

- (CMusicPitchClass) pitchClassFromScaleDegree: (CMusicScaleDegree) sd;
- (CMusicScaleDegree) scaleDegreeFromPitchClass: (CMusicPitchClass) pc;

@end
