//
//  CAudioGenerator.m
//  SqueezeBox 0.2.2
//
//  Created by CHARLES GILLINGHAM on 2/25/15.
//  Copyright (c) 2015 CHARLES GILLINGHAM. All rights reserved.
//

#import "CAudioUnit_Internal.h"
#import "CAUGraph_Internal.h"
#import "CAudioGenerator.h"

@interface CAudioGenerator ()
@end

@implementation CAudioGenerator


// -----------------------------------------------------------------------------
#pragma mark                    Constructors
// -----------------------------------------------------------------------------

+ (NSArray *) subtypeNames
{
    return [CAudioUnit subtypesOfOSType:kAudioUnitType_Generator];
}



- (instancetype) initWithSubtype: (NSString *) subtypeName
{
    return [self initWithOSType: kAudioUnitType_Generator
                        subtype: subtypeName
                          graph: [CAUGraph currentGraph]];
}

- (instancetype) initWithSubtype: (NSString *) subtypeName
                           graph: (CAUGraph *) graph
{
    return [self initWithOSType: kAudioUnitType_Generator
                        subtype: subtypeName
                          graph: graph];
}

@end
