//
//  CKVCTester.h
//  SqueezeBox 0.2.2
//
//  Created by CHARLES GILLINGHAM on 4/5/15.
//  Copyright (c) 2015 CHARLES GILLINGHAM. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CKVCTester : NSObject
@property NSObject * objectBeingObserved;


+ (CKVCTester *) testerWithObject: (NSObject *) observed expectedKeys: (NSArray *) ps;


// Check if the counts are correct.

- (BOOL) testCounts: (NSArray *) expectedCounts;

// Convenience functions
- (BOOL) testCount: (NSUInteger) count;
- (BOOL) testWhenModified;
- (BOOL) testWhenNotModified;
- (BOOL) testCount: (NSUInteger) cnt except: (NSString *) key withCount: (NSUInteger) count;

@end

