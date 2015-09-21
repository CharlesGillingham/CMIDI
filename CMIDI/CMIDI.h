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
#import <CMIDI/CMIDI Time.h>

// MIDI messages
#import <CMIDI/CMIDIMessage.h>

// Convenience methods for accessing and constructing messages
#import <CMIDI/CMIDIMessage+ChannelMessage.h>
#import <CMIDI/CMIDIMessage+SystemMessage.h>
#import <CMIDI/CMIDIMessage+MetaMessage.h>
#import <CMIDI/CMIDIMessage+Description.h>

// MIDI Files
#import <CMIDI/CMIDIFile.h>
#import <CMIDI/CMIDIFile+Description.h>

// Precision timing tools
#import <CMIDI/CMIDIClock.h>
#import <CMIDI/CMIDIClock+TimeString.h>

// A protocol for building MIDI signal chains
#import <CMIDI/CMIDIReceiver CMIDISender.h>

// MIDI sequencer
#import <CMIDI/CMIDISequence.h>
#import <CMIDI/CMIDISequence+FileIO.h>

// Communicating with external devices and applications
#import <CMIDI/CMIDIEndpoint.h>

// From CMusic
#import <CMIDI/CMNote.h>
#import <CMIDI/CTime.h>
#import <CMIDI/CTimeHierarchy.h>
#import <CMIDI/CTimeMap.h>
#import <CMIDI/CTimeMap+TimeString.h>

// Use CMusic to help format time strings
#import <CMIDI/CMIDITempoMeter.h>
#import <CMIDI/CMIDIMessage+DescriptionWithTime.h>
#import <CMIDI/CMIDIFile+DescriptionWithTime.h>

// Tools for building and debugging demo applications
#import <CMIDI/CMIDIMonitor.h>
#import <CMIDI/CMIDITransport.h>




