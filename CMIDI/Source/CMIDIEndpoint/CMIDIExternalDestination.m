//
//  CMIDIExternalDestination.m
//  SqueezeBox
//
//  Created by CHARLES GILLINGHAM on 5/22/14.
//  Copyright (c) 2014 CHARLES GILLINGHAM. All rights reserved.
//

#import "CMIDIEndpoint.h"
#import "CMIDI CoreMIDI Utilities.h"

#define AssertNoErr(expr)  assert((expr) == 0)


@interface CMIDIExternalDestination ()
- (id) initWithEndpointRef: (MIDIEndpointRef) ref;
@end

//------------------------------------------------------------------------------
//      Persistant list of the current end points
//------------------------------------------------------------------------------

NSArray      * CMIDIExternalDestination_endpoints = nil;
NSDictionary * CMIDIExternalDestination_endpointDictionary = nil;

void CMIDIInitializeExternalDestinations()
{
    if (CMIDIExternalDestination_endpointDictionary != nil) return;
    
    CMIDIClient(); // Make sure the client exists.

    ItemCount n = MIDIGetNumberOfDestinations();
    NSMutableArray * destinations = [NSMutableArray arrayWithCapacity: n];
    for (ItemCount i = 0; i < n; i++) {
        [destinations addObject:[[CMIDIExternalDestination alloc] initWithEndpointRef:MIDIGetDestination(i)]];
    }
    CMIDIExternalDestination_endpoints = destinations;
    
    NSMutableDictionary * dict  = [NSMutableDictionary new];
    for (CMIDIExternalDestination * s in destinations) {
        [dict setObject:s forKey: s.name];
    }
    CMIDIExternalDestination_endpointDictionary = dict;
}


//------------------------------------------------------------------------------
//      CMIDIExternalDestination
//------------------------------------------------------------------------------


@implementation CMIDIExternalDestination {
    NSString *      _name;
    MIDIEndpointRef _endpointRef;
    MIDIPortRef     _port;
}

- (NSString *) name  { return _name; }
- (BOOL) isInternal  { return NO; }
- (BOOL) isReceiver  { return YES; }

//------------------------------------------------------------------------------
//      Construction
//------------------------------------------------------------------------------


- (id) initWithEndpointRef: (MIDIEndpointRef) ref
{
    if (self = [super init]) {
        _endpointRef = ref;
        _name = CMIDIEndpointName(_endpointRef);
        [self initPort];
    }
    return self;
}


+ (instancetype) endpointWithName:(NSString *)name
{
    CMIDIInitializeExternalDestinations();
    return [CMIDIExternalDestination_endpointDictionary objectForKey:name];
}


+ (NSArray *) endpoints
{
    CMIDIInitializeExternalDestinations();
    return CMIDIExternalDestination_endpoints;
}


+ (NSDictionary *) dictionary
{
    CMIDIInitializeExternalDestinations();
    return CMIDIExternalDestination_endpointDictionary;
}


- (void) dealloc
{
    MIDIPortDispose(_port);
    MIDIEndpointDispose(_endpointRef);
}



//------------------------------------------------------------------------------
//                              MIDI Data flow
//------------------------------------------------------------------------------

// Create an output port. We will produce MIDI and send it to the destination through this port.
- (void) initPort
{
    NSString * portName = [NSString stringWithFormat:@"Output port for destination: %@", [self name]];
    AssertNoErr( MIDIOutputPortCreate(CMIDIClient(),
                                        (__bridge CFStringRef)  portName,
                                      &_port) );
}


// This object receives MIDI here [respondToMIDI] and sends it through an output port to other applications
// Send MIDI to the other application.
- (void) respondToMIDI: (CMIDIMessage	*) message
                atTime: (CMIDINanoseconds)    time
{
    assert(message.data.length < 65436);
    Byte packetBuffer[message.data.length+100];
    MIDIPacketList * packetList = (MIDIPacketList *) packetBuffer;
    MIDIPacket     * packet     = MIDIPacketListInit(packetList);
    MIDIPacketListAdd(packetList, sizeof(packetBuffer), packet, time, message.data.length, message.data.bytes);
    MIDISend(_port, _endpointRef, packetList);
}


- (void) respondToMIDI:(CMIDIMessage *)message
{
    [self respondToMIDI:message atTime:0];
}


- (void) flushOutput
{
    MIDIFlushOutput(_endpointRef);
}

@end
