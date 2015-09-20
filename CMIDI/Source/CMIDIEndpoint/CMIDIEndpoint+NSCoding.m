//
//  CMIDIEndpoint+NSCoding.m
//  SqueezeBox 0.0.1
//
//  Created by CHARLES GILLINGHAM on 6/24/15.
//  Copyright (c) 2015 SqueezeBox. All rights reserved.
//

#import "CMIDIEndpoint.h"
#ifdef CMIDI_USE_COREMIDI

@interface CMIDIExternalDestination (NSCoding) <NSCoding>
@end

@interface CMIDIExternalSource (NSCoding) <NSCoding>
@end

@interface CMIDIInternalEndpoint (NSCoding) <NSCoding>
@end


@implementation CMIDIExternalDestination (NSCoding)

- (id) initWithCoder:(NSCoder *)aDecoder
{
    NSString * name = [aDecoder decodeObjectForKey:@"name"];
    return [[self class] endpointWithName: name];
}


- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject: self.name forKey:@"name"];
}


@end


@implementation CMIDIExternalSource (NSCoding)

- (id) initWithCoder:(NSCoder *)aDecoder
{
    NSString * name = [aDecoder decodeObjectForKey:@"name"];
    if ((self = [[self class] endpointWithName: name])) {
        self.outputUnit = [aDecoder decodeObjectForKey:@"outputUnit"];
    } else {
        [NSException raise:@"Endpoint not found" format:@"Endpoint \'%@\' not found", name];
    }
    return self;
}



- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name   forKey:@"name"];
    [aCoder encodeObject:self.outputUnit forKey:@"outputUnit"];
}

@end



@implementation CMIDIInternalEndpoint (NSCoding)

- (id) initWithCoder:(NSCoder *)aDecoder
{
    NSString * name = [aDecoder decodeObjectForKey:@"name"];
    if ((self = [[self class] endpointWithName: name])) {
        self.outputUnit = [aDecoder decodeObjectForKey:@"outputUnit"];
    } else {
        [NSException raise:@"Endpoint not found" format:@"Endpoint \'%@\' not found", name];
    }
    return self;
}



- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name   forKey:@"name"];
    [aCoder encodeObject:self.outputUnit forKey:@"outputUnit"];
}


@end

#endif
