//
//  CMIDIExternalInstrument.m
//  SqueezeBox 0.0.1
//
//  Created by CHARLES GILLINGHAM on 10/13/15.
//  Copyright (c) 2015 Charles Gillingham. All rights reserved.
//

#import "CMIDIInstrument.h"
#import "CMIDIEndpoint.h"

@implementation CMIDIInstrument (ExternalInstrument)

- (id) initWithEndpointName: (NSString *) name
{
    CMIDIExternalDestination * ed;
    ed = [CMIDIExternalDestination endpointWithName:name];
    if (!ed) return nil;
    if (self = [self initWithReceiver:ed]) {
        self.displayName = name;
    }
    return self;
}


+ (NSArray *) endpointNames
{
    return [[CMIDIExternalDestination dictionary] allKeys];
}

@end
