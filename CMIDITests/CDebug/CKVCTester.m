//
//  CKVCTester.m
//  SqueezeBox 0.2.2
//
//  Created by CHARLES GILLINGHAM on 4/5/15.
//  Copyright (c) 2015 CHARLES GILLINGHAM. All rights reserved.
//

#import "CKVCTester.h"
#import "CDebugMessages.h"

@interface CKVCTester ()
@property NSMutableDictionary * counts;
@property NSArray * keys;
@property BOOL fError;
@end


#ifdef DEBUG
@implementation CKVCTester
@synthesize objectBeingObserved;
@synthesize keys;
@synthesize counts;
@synthesize fError;

- (id) initWithObject: (NSObject *) observed
         expectedKeys: (NSArray *) ps;
{
    if (self = [super init]) {
        objectBeingObserved = observed;
        keys = ps;
        counts = [NSMutableDictionary dictionaryWithCapacity:keys.count];
        for (NSString * keyPath in keys) {
            [objectBeingObserved addObserver:self forKeyPath:keyPath options:0 context:NULL];
            [counts setValue:[NSNumber numberWithInteger:0] forKey:keyPath];
        }
        fError = NO;
    }
    return self;
}



- (void) dealloc
{
    for (NSString * keyPath in [counts allKeys]) {
        [objectBeingObserved removeObserver:self forKeyPath:keyPath];
    }
}



+ (CKVCTester *) testerWithObject: (NSObject *) observed expectedKeys: (NSArray *) ps
{
    return [[self alloc] initWithObject:observed expectedKeys:ps];
}



- (NSString *) description
{
    if (objectBeingObserved) {
        return [NSString stringWithFormat: @"CKVCTester for %@", objectBeingObserved.description];
    } else {
        return @"CKVCTester (idle)";
    }
}




- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(NSObject *)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if (!CASSERT(object == objectBeingObserved)) {
        printf("   ERROR: OBJECT EXPECTED: %s\n", objectBeingObserved.description.UTF8String);
        printf("   ERROR: OBJECT OBSERVED: %s\n", object.description.UTF8String);
        fError = YES;
    }
    
    NSNumber * count = [counts objectForKey:keyPath];
    if (!CASSERT(count != nil)) {
        printf("   UNEXPECTED KEYPATH OBSERVED: %s\n", keyPath.UTF8String);
        fError = YES;
    }
    
    count = [NSNumber numberWithInteger:[count integerValue]+1];
    [counts setObject:count forKey:keyPath];
}



- (BOOL) testCounts: (NSArray *) expectedCounts
{
    if (expectedCounts.count != keys.count) {

        CFAIL(@"ERROR: Expected counts does not have the right number of objects");
        fError = YES;
  
    } else {
        
        for (NSUInteger i = 0; i < keys.count; i++) {
            NSString * keyPath = keys[i];
            NSUInteger expectedCount = [expectedCounts[i] integerValue];
            NSUInteger count = ((NSNumber *)[counts objectForKey:keyPath]).integerValue;
            if (count != expectedCount) {
                if (count == 0) {
                    CFAIL(([NSString stringWithFormat:
                           @"KEYPATH \"%@\" NOT OBSERVED. EXPECTED %lu OBSERVATIONS.",
                           keyPath, expectedCount]));
                } else {
                    CFAIL(([NSString stringWithFormat:
                           @" KEYPATH \"%@\" OBSERVED %lu TIMES. EXPECTED %lu.",
                           keyPath, count, expectedCount]));
                }
                fError = YES;
            }
        }
    }
    
    // Reset for next test
    for (NSString * keyPath in [counts allKeys]) {
        [counts setObject:[NSNumber numberWithInteger:0] forKey:keyPath];
    }
    if (fError) {
        fError = NO;
        return NO;
    }
    return YES;
}




// -------------------------------------------------------------------------------------------
#pragma mark                       Convenience functions
// -------------------------------------------------------------------------------------------

- (BOOL) testCount: (NSUInteger) cnt
{
    NSMutableArray * expectedCounts = [NSMutableArray arrayWithCapacity:keys.count];
    NSNumber * expectedCount = [NSNumber numberWithInteger:cnt];
    for (NSUInteger i = 0; i < keys.count; i++) {
        [expectedCounts addObject:expectedCount];
    }
    return [self testCounts: expectedCounts];
}


- (BOOL) testWhenModified
{
    return [self testCount: 1];
}


- (BOOL) testWhenNotModified
{
    return [self testCount: 0];
}


- (BOOL) testCount: (NSUInteger) cnt except: (NSString *) key withCount: (NSUInteger) count
{
    NSUInteger indexOfKey = [keys indexOfObject:key];
    
    NSMutableArray * expectedCounts = [NSMutableArray arrayWithCapacity:keys.count];
    NSNumber * expectedCount = [NSNumber numberWithInteger:cnt];
    for (NSUInteger i = 0; i < keys.count; i++) {
        if (i == indexOfKey) {
            [expectedCounts addObject:[NSNumber numberWithInteger:count]];
        } else {
            [expectedCounts addObject:expectedCount];
        }
    }
    return [self testCounts: expectedCounts];
}


@end
#endif

