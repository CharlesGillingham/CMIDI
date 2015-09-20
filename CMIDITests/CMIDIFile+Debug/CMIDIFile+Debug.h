//
//  CMIDIFile+Debug.h
//  SqueezeBox 0.0.1
//
//  Created by CHARLES GILLINGHAM on 6/20/15.
//  Copyright (c) 2015 SqueezeBox. All rights reserved.
//

#import "CDebugSelfCheckingObject.h"
#import "CMIDIFile.h"

@interface CMIDIFile (Debug) <CDebugSelfCheckingObject>

+ (BOOL) inspectionTest;
+ (BOOL) appleMIDIFileInspectionTest;

+ (BOOL) writeReadTest;
+ (BOOL) readWriteReadTest;

+ (NSArray *) exampleMIDIFiles;

@end
