//
//  MIDIMessage.m
//  SqueezeBox 0.2.1
//
//  Created by CHARLES GILLINGHAM on 12/4/13.
//  Copyright (c) 2013 CHARLES GILLINGHAM. All rights reserved.
//

#import "CMIDIMessage.h"
#import "CMIDIMessage+ChannelMessage.h"
#import "CMIDIMessage+SystemMessage.h"
#import "CMIDIMessage+MetaMessage.h"
//#import "CDebugMessages.h"




// -----------------------------------------------------------------------------
#pragma mark                    CMIDIMessage
// -----------------------------------------------------------------------------
// INVARIANT: data != nil

@implementation CMIDIMessage
@synthesize data;
@synthesize time;
@synthesize track;

// Designated initializer. Used internally by constructors. No error checking. Does not copy the data.
- (id) initWithData: (NSData *) d
{
    if (self = [super init]) {
        self.data = d;
        self.time = 0;
        self.track = CMIDIMessage_NoTrack;
    }
    return self;
}

// Enforce designated initializer
- (id) init {
    NSAssert(NO,@"This class has a designated initializer or initializers.");
    return [self initWithData:nil]; // for the compiler
}

// -----------------------------------------------------------------------------
#pragma mark                    Constructors
// -----------------------------------------------------------------------------

// Constructors used internally; no error checking is done here. Individual messages have constructors which produce valid messages.
+ (CMIDIMessage *) messageWithBytes: (const Byte *) bytes
                             length: (NSUInteger) length
{
    return [[CMIDIMessage alloc] initWithData:[NSData dataWithBytes: bytes length: length]];
}


+ (CMIDIMessage *) messageWithData: (NSData *) data
{
    return [[CMIDIMessage alloc] initWithData: data];
}


// -----------------------------------------------------------------------------
#pragma mark                    status, byte1, byte2, type
// -----------------------------------------------------------------------------
// There are three possible values we can retrieve from status byte: the message number, the channel or the system message number.
// The message number is stored in the higher four bits of the status byte.
// The channel or system message type is stored in the lower four bits. (See the categories for "Channel message" and "System message")

@dynamic type;
- (Byte) type {
    return ((((Byte *) data.bytes)[0]) & 0xF0);
}

// Convenience properties, used internally; no error checkng: e.g., data.length is assumed to be long enough.
@dynamic status;
@dynamic byte1;
@dynamic byte2;
- (Byte) status  {  return ((Byte *) data.bytes)[0]; }
- (Byte) byte1   {  return ((Byte *) data.bytes)[1]; }
- (Byte) byte2   {  return ((Byte *) data.bytes)[2]; }


// -----------------------------------------------------------------------------
#pragma mark                    comparisons
// -----------------------------------------------------------------------------

- (BOOL) isEqual: (CMIDIMessage *) message
{
    if (![message isKindOfClass:[CMIDIMessage class]]) return NO;
    if (!(time == message.time)) return NO;
    if ([data isEqualToData:message.data]) return YES;
    
    // "Note off" has two representations; consider them equal.
    if (self.isNoteOff && message.isNoteOff && self.noteNumber == message.noteNumber) return YES;
    
    // For some reason, Apple's MusicSequence changes the manufacturer ID in system exclusive messages ... don't understand why. For now, my regression tests are easier to write if we ignore the manufacturer ID.
#ifdef DEBUG
    if (self.status == MIDISystemMsg_SystemExclusive && message.status == MIDISystemMsg_SystemExclusive &&
        [self.sysExData isEqualToData:message.sysExData])
    {
        return YES;
    }
#endif
    
    return NO;
}



- (NSUInteger) typeOrder
{
    
    // Sort these so that, if multiple messages arrive on the same tick, they can be sent to the downstream object in an order that makes sense.
    if (self.metaMessageType == MIDIMeta_EndOfTrack) return 0xFFFF; // End of track must come last
    switch(self.type) {
        case MIDIMessage_System:         return self.status;
        case MIDIMessage_NoteOff:        return 0x0100; // So the current note is stopped before it is re-attacked.
        case MIDIMessage_ProgramChange:  return 0x0200; // The next three should be set before the note starts,
        case MIDIMessage_PitchWheel:     return 0x0300; // because they apply to new notes, and shouldn't
        case MIDIMessage_ControlChange:  return 0x0400; // apply to notes that have ended.
        case MIDIMessage_NoteOn:         return 0x0500; // The note starts
        case MIDIMessage_ChannelPressure:return 0x0600; // These two effect a note after it starts.
        case MIDIMessage_NotePressure:   return 0x0700;
        default: {
            return 0xFFFF; // This message is corrupt
        }
    }
}

// Had to add this because form some reason [_NSInlineData compare:] seems to have disappeared.
- (SInt64) dataOrder
{
    if (data.length > 1) {
        return self.byte1;
    } else {
        return 0;
    }
}


// Sort by time, and then intelligently on the type of messages. The final sort by data is needed so that every pair of messages has a canonical order.

+ (NSArray *) sortedMessageList:(NSArray *)messages
{
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
    NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"track" ascending:YES];
 // NSSortDescriptor *sort3 = [NSSortDescriptor sortDescriptorWithKey:@"channel" ascending:YES]; // Why does this mess it up.
    NSSortDescriptor *sort4 = [NSSortDescriptor sortDescriptorWithKey:@"typeOrder" ascending:YES];
    NSSortDescriptor *sort5 = [NSSortDescriptor sortDescriptorWithKey:@"dataOrder" ascending:YES];
    return [messages sortedArrayUsingDescriptors:@[sort1, sort2, /* sort3, */ sort4, sort5]];
}


@end


