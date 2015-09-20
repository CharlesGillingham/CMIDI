//
//  CMIDIEndpoint.h
//  CMIDI
//
//  Created by Charles Gillingham on 2/16/13

#import "CMIDIMessage.h"
#import "CMIDIReceiver CMIDISender.h"

//--------------------------------------------------------------------------------
#pragma mark                    MIDI ENDPOINTS
//--------------------------------------------------------------------------------
// From a client point of view, there are only two things to consider:
// 1) How you create it
//    External:     An existing endpoint, maintained by another application.
//    Internal:     An endpoint created by this application which other applications can see.
// 2) How you communicate with it:
//    MIDIReceiver: Our application sends MIDI to other applications through this endpoint.
//    MIDISender:   Our application gets MIDI from other applications through this endpoint.
// 3) TODO: Whether it is online or not. (If an endpoint becomes unavailable temporarily, other objects need to see this. This should be a KVC-observable property.)

@protocol CMIDIEndpointMethods

// Get an endpoint from a class
+ (instancetype)   endpointWithName:(NSString *)name;

// List of existing endpoints
+ (NSArray *)      endpoints;

// Dictionary of endpoints keyed by endpoint name
+ (NSDictionary *) dictionary;

@property (readonly) NSString * name;
@property (readonly) BOOL isInternal;
@property (readonly) BOOL isReceiver;
@end
typedef NSObject <CMIDIEndpointMethods> CMIDIEndpoint;


//--------------------------------------------------------------------------------
#pragma mark                    EXTERNAL SOURCE
//--------------------------------------------------------------------------------
// A external source, such as a MIDI keyboard attached with MIDI cable or another application that produces MIDI.
// This is a named MIDI endpoint created by another application, which is broadcasting MIDI to anyone who attaches to it.
// Inside our application, we can attach <MIDIReceiver> objects to it and it will pass along the MIDI data to their [respondToMIDI:] methods.
// Clients should not allocate these objects: use [CMIDIEndpointManager manager]'s list, dictionary and search routine.
@interface CMIDIExternalSource : NSObject <CMIDIEndpointMethods, CMIDISender>
@property NSObject <CMIDIReceiver> * outputUnit;
@end


//--------------------------------------------------------------------------------
#pragma mark                    EXTERNAL DESTINATION
//--------------------------------------------------------------------------------
// An external destination, such as a hardware sound module attached with a MIDI cable.
// Messages sent to [respondToMIDI:ofSize:atTime] are sent to the external destination at the given time.
// Do not allocate these objects: use [CMIDIClient applicationMIDIClient]'s list, dictionary and search routine.
@interface CMIDIExternalDestination : NSObject <CMIDIEndpointMethods, CMIDIReceiver>
- (void) respondToMIDI:(CMIDIMessage *)message;
- (void) respondToMIDI:(CMIDIMessage *)message atTime:(CMIDINanoseconds) time;
- (void) flushOutput;
@end


//--------------------------------------------------------------------------------
#pragma mark                    INTERNAL ENDPOINT
//--------------------------------------------------------------------------------
// Can both receive and send.
// Other applications can see this endpoint and attach to it. (NOT TESTED YET)
// This endpoint can also act as an internal timing buffer to insure that messages are are sent with CoreMIDI's millisecond timing.
@interface CMIDIInternalEndpoint : NSObject <CMIDIEndpointMethods, CMIDIReceiver, CMIDISender>
- (void) respondToMIDI:(CMIDIMessage *)message;
- (void) respondToMIDI:(CMIDIMessage *)message atTime:(CMIDINanoseconds) time;
- (void) flushOutput;
@property NSObject <CMIDIReceiver> * outputUnit;
@end




