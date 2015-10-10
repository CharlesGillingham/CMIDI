//
//  CMusicHarmony+KVC.m
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 10/7/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMusicHarmony.h"

@interface CMusicHarmony (KVC)
@end


@implementation CMusicHarmony (KVC)

+ (NSSet *) keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    if ([key isEqualToString:@"key"]) return [NSSet new];
    if ([key isEqualToString:@"harmonicStrengths"]) return [NSSet new];
    return [NSSet setWithObject:@"harmonicStrengths"];
}

// All notifications are through keyPathsForValuesAffectingValueForKey.
// Harmonic strengths notifies whenever it is modified.
+ (BOOL) automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}

@end
