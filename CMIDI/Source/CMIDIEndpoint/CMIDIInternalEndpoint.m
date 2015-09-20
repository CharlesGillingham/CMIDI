//
//  CMIDIInternalEndpoint.m
//  SqueezeBox
//
//  Created by CHARLES GILLINGHAM on 5/21/14.
//  Copyright (c) 2014 CHARLES GILLINGHAM. All rights reserved.
//


#import "CMIDIEndpoint.h"
#import "CMIDIDataParser+MIDIPacketList.h"
#import "CMIDI CoreMIDI Utilities.h"

#define AssertNoErr(expr)  assert((expr) == 0)

//------------------------------------------------------------------------------
#pragma mark               MIDIInternalEndpoint
//------------------------------------------------------------------------------

@implementation CMIDIInternalEndpoint {
    MIDIEndpointRef             _endpointRef;
    NSString                  * _name;
    MIDIPortRef                 _port;
    CMIDIDataParser           * _parser;
    NSObject <CMIDIReceiver>  * _output;
}

- (NSString *) name     { return _name; }
- (BOOL) isInternal     { return YES; }
- (BOOL) isReceiver     { return YES; }

//------------------------------------------------------------------------------
#pragma mark      Persistant list of the current end points
//------------------------------------------------------------------------------

NSMutableArray      * CMIDIInternalEndpoints = nil;
NSMutableDictionary * CMIDIInternalEndpoint_Dictionary = nil;

+ (void) initialize
{
    CMIDIClient();
    CMIDIInternalEndpoints = [NSMutableArray new];
    CMIDIInternalEndpoint_Dictionary = [NSMutableDictionary new];
}



//------------------------------------------------------------------------------
//                          Construction
//------------------------------------------------------------------------------


- (id) initWithName: (NSString *) name andIndex: (NSUInteger) i
{
    if (self = [super init]) {
    
        MIDIEndpointRef ref;
        OSStatus err = MIDIDestinationCreate(CMIDIClient(),
                                             (__bridge CFStringRef) name,
                                             MIDIInternalEndpoint_ReadProc,
                                             (void *) i, // Sets the refCon, which we will read in the ReadProc below.
                                             &ref);
        if (err) return nil;
    
        _endpointRef = ref;
        _name = CMIDIEndpointName(_endpointRef);
        _parser = [CMIDIDataParser new];
        [self initPort];
    }
    return self;
}



// Allow "new"
- (id) init {
    return [CMIDIInternalEndpoint endpointWithName: @"Internal endpoint"];
}



+ (instancetype) endpointWithName: (NSString *) name
{
    CMIDIInternalEndpoint * ep = [CMIDIInternalEndpoint_Dictionary objectForKey:name];
    
    if (!ep) {
        NSUInteger i = CMIDIInternalEndpoints.count;
        ep = [[CMIDIInternalEndpoint alloc] initWithName:name andIndex:i++];
        [CMIDIInternalEndpoints addObject:ep];
        [CMIDIInternalEndpoint_Dictionary setObject:ep forKey:name];
    }
    
    return ep;
}

+ (NSArray *) endpoints
{
    return CMIDIInternalEndpoints;
}


+ (NSDictionary *) dictionary
{
    return CMIDIInternalEndpoint_Dictionary;
}


- (void) dealloc
{
    MIDIEndpointDispose(_endpointRef);
    MIDIPortDispose(_port);
}


//------------------------------------------------------------------------------
//                      Output Unit
//------------------------------------------------------------------------------

- (NSObject <CMIDIReceiver> *) outputUnit { return _output; }
- (void) setOutputUnit: (NSObject <CMIDIReceiver> *) obj
{
    if (!obj || [obj respondsToSelector:@selector(respondToMIDI:)]) {
        @synchronized(self) {
            _output = obj;
        }
    }
}



//------------------------------------------------------------------------------
//                      MIDI Data Flow
//------------------------------------------------------------------------------


// Send the output unit message at the time given.
- (void) respondToMIDI: (CMIDIMessage	*) message
                atTime: (CMIDINanoseconds)    nanos
{
    
    assert(message.data.length < 65435);
    Byte packetBuffer[message.data.length+100];
    MIDITimeStamp         time = nanos;
    MIDIPacketList *packetList = (MIDIPacketList*)packetBuffer;
    MIDIPacket     *packet     = MIDIPacketListInit(packetList);
    MIDIPacketListAdd(packetList, sizeof(packetBuffer), packet, time, message.data.length, message.data.bytes);
    
    // NOT SURE WHICH I NEED HERE ... DOES THIS WORK???
    //MIDIReceived(_endpointRef, packetList);
    MIDISend(_port, _endpointRef, packetList);
}


// Send this message the output unit(s) immediately.
- (void) respondToMIDI: (CMIDIMessage *) message
{
    [self respondToMIDI:message atTime: 0];
}


- (void) initPort
{
    NSString * portName = [NSString stringWithFormat:@"Output port for destination: %@", _name];
    AssertNoErr( MIDIOutputPortCreate(CMIDIClient(),
                                        (__bridge CFStringRef) portName,
                                      &_port) );
}


// Read proc was connected when the EndpointRef was created.
void MIDIInternalEndpoint_ReadProc(const MIDIPacketList *packetList, void *refCon, void *unused)
{
    NSUInteger i = (NSUInteger) refCon;
    CMIDIInternalEndpoint * sender = nil;
    NSObject <CMIDIReceiver> * receiver = nil;
    
    @synchronized(CMIDIInternalEndpoints) {
        sender = CMIDIInternalEndpoints[i];
        if (sender) {
            receiver = sender->_output;
        }
    }
    
    if (receiver) {
        NSArray * messages = [sender->_parser parsePacketList:packetList];
        for (CMIDIMessage * message in messages) {
            [receiver respondToMIDI:message];
        }
   }
}



- (void) flushOutput
{
    MIDIFlushOutput(_endpointRef);
}


@end
