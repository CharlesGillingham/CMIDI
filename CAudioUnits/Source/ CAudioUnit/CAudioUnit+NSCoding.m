//
//  CAudioUnit+NSCoding.m
//  CAudioUnits
//
//  Created by CHARLES GILLINGHAM on 6/27/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CAudioUnit_Internal.h"
#import "CAUGraph_Internal.h"


@interface CAudioUnit (NSCoding) <NSCoding>
@end

@implementation CAudioUnit (NSCoding)

// -----------------------------------------------------------------------------
#pragma mark                    NSCoding
// -----------------------------------------------------------------------------

// For the compiler; couldn't get it to ignore the NS_DESIGNATED_INITIALIZER errors
// This actually works -- this will fail in theory if there.
- (instancetype) initWithSubtype: (NSString *) subtypeName
                           graph: (CAUGraph *) graph
{
    return [self initWithOSType: 0
                        subtype: subtypeName
                          graph: graph];
}


-(void) encodeWithCoder: (NSCoder *) coder
{
    [coder encodeObject:self.subtypeName forKey:@"subtypeName"];
    [coder encodeObject:self.cauGraph    forKey:@"cauGraph"];
    [coder encodeObject:self.outputUnit  forKey:@"outputUnit"];
    [coder encodeObject:self.displayName forKey:@"displayName"];
    
    // TODO: PROPERTIES
}



- (id) initWithCoder: (NSCoder *) coder
{
    NSString * subtype  = [coder decodeObjectForKey:@"subtypeName"];
    CAUGraph * graph    = [coder decodeObjectForKey:@"cauGraph"];
    CAudioUnit * output = [coder decodeObjectForKey:@"outputUnit"]; // Build from the bottom.
    if ([self initWithSubtype:subtype graph:graph]) {
        self.outputUnit  = output;
        self.displayName = [coder decodeObjectForKey:@"displayName"];

        // TODO: PROPERTIES
    }
    
    return self;
    
 }




@end
