//
//  CMIDIClock+NSCoding.m
//  CAudioMIDIMusic
//
//  Created by CHARLES GILLINGHAM on 9/17/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDIClock.h"

@interface CMIDIClock (NSCoding) <NSCoding>
@end

@implementation CMIDIClock (NSCoding)

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [self init]) {
        // Setting the time map also sets the current tempo.
        self.timeMap = [aDecoder decodeObjectForKey:@"timeMap"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.timeMap forKey:@"timeMap"];
}

@end
