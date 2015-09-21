//
//  CMIDISequence+Debug.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 9/20/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDISequence.h"

@interface CMIDISequence (Debug)
+ (BOOL) testWithMessageList: (NSArray *) msgs;
+ (BOOL) testWithMIDIFile: (NSURL *) fileName;
@end