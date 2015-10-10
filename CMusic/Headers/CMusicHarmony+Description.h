//
//  CMusicHarmony+Description.h
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 10/5/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMusicHarmony.h"
#import "CMusicHarmony+Scales.h"

@interface CMusicHarmony (Description)
- (NSString *) noteName: (CMusicNote) n;
- (NSString *) pitchClassName: (CMusicPitchClass) pc;
- (NSString *) scaleDegreeName: (CMusicScaleDegree) sd;
- (NSString *) scaleDegreePitchClassName: (CMusicScaleDegree) sd;

@property (readonly) NSArray  * pitchClassNames;
@property (readonly) NSArray  * scaleDegreeNames;
@property (readonly) NSArray  * scaleDegreePitchClassNames;
@property (readonly) NSArray  * chordFormNames; 

@property (readonly) NSString * keyName;
@property (readonly) NSString * chordFormName;
@property (readonly) NSString * chordRootScaleDegreeName;
@property (readonly) NSString * chordRootPitchClassName;
@end
