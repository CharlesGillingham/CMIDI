//
//  CMIDIFileByApple
//  CMIDI (DEBUG)
//
//  Created by CHARLES GILLINGHAM on 1/4/14.
//  Copyright (c) 2014 CHARLES GILLINGHAM. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "CMIDI Time.h"

@interface CMIDIFileByApple : NSObject
@property (readonly) NSURL    * URL;
@property (readonly) NSString * fileName;
@property SInt64                ticksPerBeat;
@property NSMutableArray      * messages; // An array of CMIDIMessages. tracks[0] is the tempo track.

+ (instancetype) MIDIFileWithContentsOfFile: (NSURL *) fURL
                               ticksPerBeat: (CMIDIClockTicks) ticksPerBeat // Does the sequence hold this number??
                                      error: (NSError **) error;

- (void) show: (BOOL) hideNoteOff;

@end
