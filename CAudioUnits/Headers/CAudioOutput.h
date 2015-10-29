//
//  CAudioOutput.h
//  CAudioUnits
//
//  Created by CHARLES GILLINGHAM on 2/25/15.
//  Copyright (c) 2015 CHARLES GILLINGHAM. All rights reserved.
//

#import "CAudioUnit.h"
#import "CAUGraph.h"

@interface CAudioOutput : CAudioUnit <CAudioUnitRequiredMethods>
// -----------------------------------------------------------------------------
#pragma mark                    Constructors
// -----------------------------------------------------------------------------
+ (NSArray *) subtypeNames;
- (id) initWithSubtype: (NSString *) subtypeName;
- (id) initWithSubtype: (NSString *) subtypeName graph:(CAUGraph *)graph;
@end
