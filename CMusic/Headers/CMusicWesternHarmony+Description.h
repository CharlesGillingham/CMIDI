//
//  CMusicWesternHarmony+Description.h
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 10/8/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMusicWesternHarmony.h"
#import "CMusicHarmony+Description.h"

@interface CMusicWesternHarmony (Description)
@property (readonly) NSString * displayName;
@property (readonly) NSString * chordName;
@property (readonly) NSString * scaleName;
@property            NSString * scaleTypeName;
@property (readonly) NSArray  * scaleTypeNames;
@property            NSString * scaleModeName;
@property (readonly) NSArray  * scaleModeNames;
@property            NSString * chordTypeName;
@property (readonly) NSArray  * chordTypeNames;
@end
