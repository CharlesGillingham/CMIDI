//
//  CMIDIFile+DescriptionWithTime.h
//  CMIDIFilePlayerDemo
//
//  Created by CHARLES GILLINGHAM on 9/13/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDIFile.h"

@interface CMIDIFile (DescriptionWithTime)
- (NSString *) longDescriptionWithTime: (BOOL) hideNoteOff;
- (void) showWithTime: (BOOL) hideNoteOff;
@end
