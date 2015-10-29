//
//  CAudioEffect.h
//  CAudioUnits
//
//  Created by CHARLES GILLINGHAM on 2/25/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CAudioUnit.h"
#import "CAudioOutput.h"

@interface CAudioEffect : CAudioUnit <CAudioUnitRequiredMethods>
// -----------------------------------------------------------------------------
#pragma mark                    Constructors
// -----------------------------------------------------------------------------
+ (NSArray *) subtypeNames;
- (id) initWithSubtype: (NSString *) subtypeName;
- (id) initWithSubtype: (NSString *) subtypeName graph:(CAUGraph *)graph;
@end
