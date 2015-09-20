//
//  CMIDIEndpoint+Debug.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 6/28/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CDebugSelfCheckingObject.h"
#import "CMIDIEndpoint.h"

@interface CMIDIInternalEndpoint (Debug) <CDebugSelfCheckingObject>
+ (BOOL) test1;
+ (BOOL) test2;
+ (void) inspectionTest;
@end
