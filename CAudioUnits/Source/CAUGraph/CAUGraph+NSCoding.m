//
//  CAUGraph+NSCoding.m
//  CAudioUnits
//
//  Created by CHARLES GILLINGHAM on 9/2/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CAUGraph_Internal.h"

@interface CAUGraph (NSCoding)  <NSCoding>
@end

@implementation CAUGraph (NSCoding)
- (id ) initWithCoder:(NSCoder *)aDecoder { return [self init]; }
- (void) encodeWithCoder:(NSCoder *)aCoder { }
@end
