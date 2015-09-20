//
//  MIDIMonitor.h
//  Squeeze Box
//
//  Created by Charles Gillingham on 5/22/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CMIDIMessage.h"
#import "CMIDIReceiver CMIDISender.h"

@interface CMIDIMonitor : NSViewController <CMIDIReceiver, CMIDISender>

// Ignore "note off" messages to simplify the output
@property BOOL hideNoteOff;

// <CMIDIReceiver> Display the message
- (void) respondToMIDI: (CMIDIMessage *) mm;

// <CMIDISender> Pass the message on.
@property id<CMIDIReceiver> outputUnit;

@end
