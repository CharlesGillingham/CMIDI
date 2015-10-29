//
//  CAudioOutput.m
//  CAudioUnits
//
//  Created by CHARLES GILLINGHAM on 2/25/15.
//  Copyright (c) 2015 CHARLES GILLINGHAM. All rights reserved.
//
#import "CAudioUnit_Internal.h"
#import "CAUGraph_Internal.h"
#import "CAudioOutput.h"


@interface CAudioOutput ()
@end


@implementation CAudioOutput

// -----------------------------------------------------------------------------
#pragma mark                    Constructors
// -----------------------------------------------------------------------------
+ (NSArray *) subtypeNames
{
    return [CAudioUnit subtypesOfOSType:kAudioUnitType_Output];
}


- (instancetype) initWithSubtype: (NSString *) subtypeName
{
    return [self initWithOSType: kAudioUnitType_Output
                        subtype: subtypeName
                          graph: [CAUGraph currentGraph]];
}

- (instancetype) initWithSubtype: (NSString *) subtypeName
                           graph: (CAUGraph *) graph
{
    return [self initWithOSType: kAudioUnitType_Output
                        subtype: subtypeName
                          graph: graph];
}


@end
