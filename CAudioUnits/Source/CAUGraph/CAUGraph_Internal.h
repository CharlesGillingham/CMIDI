//
//  CAUGraph.h
//  CAudioUnits
//
//  Created by CHARLES GILLINGHAM on 8/31/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CAudioUnit.h"
#import "CAUGraph.h"
#import <AudioToolBox/AudioToolBox.h> // AudioComponentDescription

@interface CAUGraph ()

- (BOOL) initializeUnit: (CAudioUnit *) unit
        withDescription: (AudioComponentDescription) acd;

- (void) cleanUpUnit: (CAudioUnit *) unit;
- (BOOL) connectUnits: (CAudioUnit *) source : (CAudioUnit *) destination;
- (BOOL) disconnectOutput: (CAudioUnit *) unit;

@end
