//
//  CMIDIMessage+NSCoding.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 6/19/15.
//

#import "CMIDIMessage.h"

@interface CMIDIMessage (NSCoding) <NSCoding>
@end

@implementation CMIDIMessage (NSCoding)

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [self initWithData:[aDecoder decodeObjectForKey:@"data"]]) {
        self.time = [aDecoder decodeIntegerForKey:@"time"];
        self.track = [aDecoder decodeIntegerForKey:@"track"];
    }
    return self;
}


- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.data forKey:@"data"];
    [aCoder encodeInteger:self.time forKey:@"time"];
    [aCoder encodeInteger:self.track forKey:@"track"];
}

@end
