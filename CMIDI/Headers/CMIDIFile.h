//
//  CMIDIFile.h
//  SqueezeBox 0.0.1
//
//  Created by CHARLES GILLINGHAM on 6/19/15.
//  Copyright (c) 2015 SqueezeBox. All rights reserved.
//

#import "CMIDI Time.h"

@interface CMIDIFile : NSObject
@property (readonly) NSString * fileName;
@property (readonly) NSURL * fileURL;

@property NSMutableArray      * messages; // An array CMIDIMessages
@property CMIDIClockTicks       ticksPerBeat;
@property UInt16                format;
@property NSUInteger            trackCount;
@property CMIDIClockTicks       songLength;
@property NSMutableArray      * endOfTrackTimes;

+ (instancetype) MIDIFileWithContentsOfFile: (NSURL *) fURL
                                      error: (NSError **) error;
+ (instancetype) emptyMIDIFile;

- (BOOL) readFile: (NSURL *) fURL
            error: (NSError **) error;

- (BOOL) writeFile: (NSURL *) fURL
             error: (NSError **) error;

- (BOOL) save:   (NSError **) error;
- (BOOL) reload: (NSError **) error;

@end
