//
//  CMIDISequence+FileI0.h
//  CMIDIFilePlayer
//
//  Created by CHARLES GILLINGHAM on 8/17/15.
//  Copyright (c) 2015 CHARLES GILLINGHAM. All rights reserved.
//

#import "CMIDISequence.h"

@interface CMIDISequence (FileIO)
- (BOOL) readFile: (NSURL *) fileURL error: (NSError **) error;
- (BOOL) writeFile: (NSURL *) fileURL error: (NSError **) error;
@end
