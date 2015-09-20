//
//  CMIDI.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 6/28/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//! Project version number for CMIDI.
FOUNDATION_EXPORT double CMIDIVersionNumber;

//! Project version string for CMIDI.
FOUNDATION_EXPORT const unsigned char CMIDIVersionString[];

// Representing time
#import "CMIDI Time.h"

// MIDI messages
#import "CMIDIMessage.h"

// Convenience methods for accessing and constructing messages
#import "CMIDIMessage+ChannelMessage.h"
#import "CMIDIMessage+SystemMessage.h"
#import "CMIDIMessage+MetaMessage.h"
#import "CMIDIMessage+Description.h"

// MIDI Files
#import "CMIDIFile.h"
#import "CMIDIFile+Description.h"

// Precision timing tools
#import "CMIDIClock.h"
#import "CMIDIClock+TimeString.h"

// A protocol for building MIDI signal chains
#import "CMIDIReceiver CMIDISender.h"

// MIDI sequencer
#import "CMIDISequence.h"
#import "CMIDISequence+FileIO.h"

// Communicating with external devices and applications
#import "CMIDIEndpoint.h"

// MIDI Software Instrument

// Use CMusic to help format time strings
#import "CMusic.h"
#import "CMIDITempoMeter.h"
#import "CMIDIMessage+DescriptionWithTime.h"
#import "CMIDIFile+DescriptionWithTime.h"

// Tools for building and debugging demo applications
#import "CMIDIMonitor.h"
#import "CMIDITransport.h"




