//
//  CTimeSequence.h
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 9/25/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTime.h"


@interface CTimeSequence : NSObject
@property NSArray * objects;

// These are optimized for iteration in order.
- (NSObject *) firstObjectAtTime: (CTime) time;
- (NSArray *) allObjectsAtTime: (CTime) time;
@end


@protocol CTimeStampedObjectMethods
- (CTime) time;
@end
typedef NSObject <CTimeStampedObjectMethods> CTimeStampedObject;