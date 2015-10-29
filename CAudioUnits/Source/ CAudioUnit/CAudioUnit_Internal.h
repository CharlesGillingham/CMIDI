//
//  CAudioUnit (Internal).h
//  CAudioUnit
//
//  Created by CHARLES GILLINGHAM on 2/4/14.
//  Copyright (c) 2014 CHARLES GILLINGHAM. All rights reserved.
//
#import "CAudioUnit.h"
#import <CoreAudio/CoreAudio.h>
#import <AudioToolBox/AudioToolBox.h> // AudioComponentDescription
#import <CoreAudioKit/CoreAudioKit.h>

@class CAUGraph;

@interface CAudioUnit ()
@property __weak CAudioUnit       * _inputUnit;
@property CAudioUnit              * _outputUnit;
@property CAUGraph                * cauGraph;
@property AudioUnit                 audioUnit;
@property AUNode                    auNode;
@property AudioComponentDescription auDescription;
@property (readwrite) NSString    * subtypeName;

// Called from subclasses
- (instancetype) initWithOSType: (OSType) type
                        subtype: (NSString *) subtype
                          graph: (CAUGraph *) graph NS_DESIGNATED_INITIALIZER;
+ (NSArray *) subtypesOfOSType: (OSType) type;

@end


