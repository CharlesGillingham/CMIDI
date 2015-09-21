//
//  CMIDIFile+Parser.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 9/21/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMIDI Time.h"

@interface CMIDIFileParser : NSObject
@property NSError * firstError;

- (BOOL) parseFileData: (NSData *) data
                format: (UInt16 *) fmt
          ticksPerBeat: (UInt16 *) division
            trackCount: (UInt16 *) nTracks
              messages: (NSMutableArray **) messages;

- (NSMutableData *) fileData: (NSArray *) messages
                      format: (UInt16) format
                  trackCount: (NSUInteger) trackCount
                ticksPerBeat: (CMIDIClockTicks)ticksPerBeat;

@end
