//
//  CAudioInstrument.h
//  CAudioUnits
//
//  Created by CHARLES GILLINGHAM on 2/25/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CAudioOutput.h"
#import "CAUGraph.h"

@interface CAudioInstrument : CAudioUnit <CAudioUnitRequiredMethods>
// -----------------------------------------------------------------------------
#pragma mark                    Constructors
// -----------------------------------------------------------------------------
+ (NSArray *) subtypeNames;
- (id) initWithSubtype: (NSString *) subtypeName;
- (id) initWithSubtype: (NSString *) subtypeName graph:(CAUGraph *)graph;

// -----------------------------------------------------------------------------
#pragma mark                    MIDI
// -----------------------------------------------------------------------------
- (void) respondToMIDI: (Byte *) message ofSize: (NSUInteger) size;
@end