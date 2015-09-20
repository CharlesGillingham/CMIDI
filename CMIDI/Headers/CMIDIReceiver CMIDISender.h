//
//  DATA FLOW PROTOCOLS
//  CMIDI
//
//  This interface allows arbitrary objects to be connected together into a signal processing graph that handles MIDI signals.
//  Created by CHARLES GILLINGHAM on 1/13/14.
//
//  Copyright (c) 2014 CHARLES GILLINGHAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMIDIMessage.h"

// -------------------------------------------------------------------------------------
#pragma mark                            MIDIReceiver
// -------------------------------------------------------------------------------------
// Senders call receivers with this protocol.
// Receivers include external MIDI devices such as synthesizers, external applications, or internal devices such as AudioUnits and software instruments.
// Receivers should implement [respondToMIDI:], and expect to receive messages one at a time through this method.

@protocol CMIDIReceiver <NSObject>
- (void) respondToMIDI: (CMIDIMessage *) message;
@end

// -------------------------------------------------------------------------------------
#pragma mark                            MIDISender
// -------------------------------------------------------------------------------------
// Senders include MIDI source endpoints, such as external keyboards and internal sources such as sequencers.
// Senders should carry a pointer to a MIDIReceiver (or receivers) and send MIDI output to it through [respondToMIDI].

@protocol CMIDISender <NSObject>
@optional
- (NSObject <CMIDIReceiver> *) output;
- (NSArray *) outputs;
@end
