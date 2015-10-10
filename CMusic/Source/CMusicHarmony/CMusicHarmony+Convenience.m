//
//  CMusicHarmony+Convenience.m
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 10/1/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMusicHarmony+Convenience.h"

@implementation CMusicHarmony (HarmonicStrengthConvenience)
@dynamic harmonicStrengths;

- (CMusicHarmonicStrength) harmonicStrengthOfNote:(CMusicNote)note {
    return [self harmonicStrength:CMusicPitchClassWithNote(note)];
}


// KVC Compliant array for harmonic strengths
- (NSArray *) harmonicStrengths
{
    return [self mutableArrayValueForKey:@"KVCHarmonicStrengths"];
}
- (NSUInteger) countOfKVCHarmonicStrengths
{
    return CMusicPitchClass_Count;
}
- (NSNumber *) objectInKVCHarmonicStrengthsAtIndex:(NSUInteger)index
{
    return [NSNumber numberWithInteger:[self harmonicStrength:index]];
}
- (void) insertObject:(NSObject *)object inKVCHarmonicStrengthsAtIndex:(NSUInteger)index {}
- (void) removeObjectFromKVCHarmonicStrengthsAtIndex:(NSUInteger)index {};

@end
