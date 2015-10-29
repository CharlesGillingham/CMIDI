//
//  CMIDInstrument+NSCoding.m
//  SqueezeBox 0.0.1
//
//  Created by CHARLES GILLINGHAM on 10/13/15.
//  Copyright (c) 2015 SqueezeBox. All rights reserved.
//

#import "CMIDIInstrument.h"

@interface CMIDIInstrument ()
@property NSArray * stateList;
@end


@interface CMIDIInstrument (NSCoding) <NSCoding>
@end

@implementation CMIDIInstrument (NSCoding)


- (id) initWithCoder:(NSCoder *)aDecoder
{
    NSObject <CMIDIReceiver> * receiver = [aDecoder decodeObjectForKey:@"outputUnit"];
    if (self = [self initWithReceiver:receiver]) {
        self.stateList   = [aDecoder decodeObjectForKey:@"stateList"];
        self.displayName = [aDecoder decodeObjectForKey:@"displayName"];
    }
    return self;
}


- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.outputUnit forKey:@"outputUnit"];
    [aCoder encodeObject:self.stateList forKey:@"currentState"];
    [aCoder encodeObject:self.displayName forKey:@"displayName"];
}


@end

