//
//  CMIDISequence+FileI0.m
//  CMIDIFilePlayer
//
//  Created by CHARLES GILLINGHAM on 8/17/15.
//  Copyright (c) 2015 CHARLES GILLINGHAM. All rights reserved.
//

#import "CMIDISequence+FileIO.h"
#import "CMIDIFile.h"

@implementation CMIDISequence (FileIO)


- (BOOL) readFile: (NSURL *) fileURL error: (NSError **) error
{
    CMIDIFile * mf = [CMIDIFile MIDIFileWithContentsOfFile:fileURL error:error];
    if (!mf) return NO;

    if (!self.displayName) {
        self.displayName = fileURL.lastPathComponent;
    }
    self.events     = mf.messages;
    return YES;
}



- (BOOL) writeFile: (NSURL *) fileURL error: (NSError **) error
{
    // Use a sync clock, just in case the message list changes while it's being saved.
    NSMutableArray * msgs;
    @synchronized(self) {
        msgs = [NSMutableArray arrayWithArray:[self events]];
    }
    CMIDIFile * mf = [CMIDIFile emptyMIDIFile];
    mf.messages = msgs;
    if (![mf writeFile:fileURL error:error]) {
        return NO;
    }
    return YES;
}


@end
