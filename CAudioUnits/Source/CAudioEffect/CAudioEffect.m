//
//  CAudioEffect.m
//  SqueezeBox 0.2.2
//
//  Created by CHARLES GILLINGHAM on 2/25/15.
//  Copyright (c) 2015 CHARLES GILLINGHAM. All rights reserved.
//

#import "CAudioUnit_Internal.h"
#import "CAUGraph_Internal.h"
#import "CAudioEffect.h"

@interface CAudioEffect ()
@end

@implementation CAudioEffect

// -----------------------------------------------------------------------------
#pragma mark                    Constructors
// -----------------------------------------------------------------------------

+ (NSArray *) subtypeNames
{
    return [CAudioUnit subtypesOfOSType:kAudioUnitType_Effect];
}

- (instancetype) initWithSubtype: (NSString *) subtypeName
                           graph: (CAUGraph *) graph
{
    return [self initWithOSType: kAudioUnitType_Effect
                        subtype: subtypeName
                          graph: graph];
}


- (instancetype) initWithSubtype: (NSString *) subtypeName
{
    return [self initWithSubtype:subtypeName graph:[CAUGraph currentGraph]];
}

@end
