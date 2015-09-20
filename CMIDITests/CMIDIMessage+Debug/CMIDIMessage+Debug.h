//
//  CMIDIMessage+CMIDIMessage_Debug.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 6/20/15.
//  Copyright (c) 2015 Charles Gillingham. All rights reserved.
//

#import "CDebugSelfCheckingObject.h"
#import "CMIDIMessage.h"

@interface CMIDIMessage (Debug) <CDebugSelfCheckingObject>
- (BOOL) check;
- (BOOL) checkIsEqual: (id) object;

// Tests
+ (BOOL) test;
+ (void) inspectionTest;

// Examples
+ (NSArray *) oneOfEachMessage;
+ (NSArray *) oneOfEachMessageForFiles;
+ (NSArray *) oneOfEachMessageForRealTime;

@end
