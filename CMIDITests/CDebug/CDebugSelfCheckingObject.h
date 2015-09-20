//
//  CDebugSelfCheckingObject.h
//  CAudioUnitTests
//
//  Created by CHARLES GILLINGHAM on 5/9/15.
//  Copyright (c) 2015 SqueezeBox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CDebugSelfCheckingObject <NSObject>
- (BOOL) check;

@optional
- (BOOL) checkIsEqual: (id) object; // "isEqual" with detailed error messages
+ (BOOL) test;
- (void) show;
- (NSString *) displayName;
@end
