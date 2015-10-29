//  CMIDIMessage.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 12/4/13.
//  Copyright (c) 2013 CharlesGillingham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMIDI Time.h"

@interface CMIDIMessage : NSObject

- (id) initWithData: (NSData *) d NS_DESIGNATED_INITIALIZER;

// The message is stored in raw MIDI format, ready to be sent or received. Client-friendly properties for each type of message are provided in categories.
@property NSData * data;

// There are eight possible types (see below)
@property (readonly) Byte type;

// Convenience properties for the three common bytes. Used internally. No error checking (data.length is assumed to be long enough to contain the byte).
@property (readonly) Byte status;
@property (readonly) Byte byte1;
@property (readonly) Byte byte2;


// A time field is provided because this is useful in creating sequences.
// This application stores time as integer "MIDI clock ticks". To retrieve other time units (such as bars, beats or seconds), a client needs to know the tempo, the resolution and the meter. These are stored in a "CTimeHierarchy". See CMIDI Time.h.
@property CMIDIClockTicks time;

// A track field is set for MIDI messages which originate in type 1 MIDI files.
@property NSUInteger      track;

// Constructors used internally. No error checking. Does not copy the NSData. Client-friendly constructors are provided elsewhere.
+ (CMIDIMessage *) messageWithData: (NSData *) data;
+ (CMIDIMessage *) messageWithBytes: (const Byte *) bytes
                             length: (NSUInteger) length;

// Sorts first by time, then intelligently sort simultaneous messages.
+ (NSArray *) sortedMessageList: (NSArray *) messages;
- (BOOL) isEqual: (CMIDIMessage *) msg;

@end



// -----------------------------------------------------------------------------
#pragma mark             Constants
// -----------------------------------------------------------------------------

// Values for message.type
enum {
    MIDIMessage_NoteOff		    =	0x80,
    MIDIMessage_NoteOn		    =	0x90,
    MIDIMessage_NotePressure    =   0xA0,
    MIDIMessage_ControlChange   =   0xB0,  // Includes mode, global and RPN messages.
    MIDIMessage_ProgramChange   =   0xC0,
    MIDIMessage_ChannelPressure	=   0xD0,
    MIDIMessage_PitchWheel		=   0xE0,
    MIDIMessage_System          =   0xF0,  // Includes meta messages
};


// Initial value of the track. If it's not set, it will remain at this value.
enum {
    CMIDIMessage_NoTrack        = 0xFFFF
};


