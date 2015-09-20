//
//  CMIDIFile+Description.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 7/15/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDIFile.h"

@interface CMIDIFile (Description)
- (NSString *) longDescription: (BOOL) hideNoteOff;
- (void) show: (BOOL) hideNoteOff;
@end
