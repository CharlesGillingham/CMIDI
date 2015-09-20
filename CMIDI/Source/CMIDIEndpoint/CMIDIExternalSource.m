//
//  CMIDIExternalSource.m
//  SqueezeBox
//
//  Created by CHARLES GILLINGHAM on 5/21/14.
//  Copyright (c) 2014 CHARLES GILLINGHAM. All rights reserved.
//

#import "CMIDIEndpoint.h"
#import "CMIDIDataParser+MIDIPacketList.h"
#import "CMIDI CoreMIDI Utilities.h"


// Forward declaration
@interface CMIDIExternalSource ()
- (id) initWithEndpointRef: (MIDIEndpointRef) ref
                  andIndex: (NSUInteger) i;
@end


//------------------------------------------------------------------------------
//      Persistant list of the current endpoints
//------------------------------------------------------------------------------

NSArray      * CMIDIExternalSource_endpoints = nil;
NSDictionary * CMIDIExternalSource_endpointDictionary = nil;

void CMIDIInitializeExternalSources()
{
    if (CMIDIExternalSource_endpointDictionary != nil) return;
    
    CMIDIClient(); // Make sure the client exists.
    
    ItemCount n = MIDIGetNumberOfDestinations();
    NSMutableArray * sources = [NSMutableArray arrayWithCapacity: n];
    for (ItemCount i = 0; i < n; i++) {
        [sources addObject:[[CMIDIExternalSource alloc] initWithEndpointRef:MIDIGetSource(i)
                                                                   andIndex:i]];
    }
    CMIDIExternalSource_endpoints = sources;
    
    NSMutableDictionary * dict  = [NSMutableDictionary new];
    for (CMIDIExternalSource * s in sources) {
        [dict setObject:s forKey: s.name];
    }
    CMIDIExternalSource_endpointDictionary = dict;
}


//------------------------------------------------------------------------------
//      CMIDIExternalSource
//------------------------------------------------------------------------------

@implementation CMIDIExternalSource {
    NSString                 * _name;
    MIDIEndpointRef            _endpointRef;
    MIDIPortRef                _port;
    NSObject <CMIDIReceiver> * _output;
    CMIDIDataParser   * _parser;
}

- (NSString *) name    { return _name; }
- (BOOL) isInternal    { return NO; }
- (BOOL) isReceiver    { return NO; }

//------------------------------------------------------------------------------
//      Construction
//------------------------------------------------------------------------------


- (id) initWithEndpointRef: (MIDIEndpointRef) ref
                  andIndex: (NSUInteger) i

{
    if (self = [super init]) {
        _endpointRef = ref;
        _name = CMIDIEndpointName(_endpointRef);
        _parser = [CMIDIDataParser new];
        [self initPortWithIndex:i];
    }
    return self;
}




+ (instancetype) endpointWithName:(NSString *)name
{
    CMIDIInitializeExternalSources();
    return [CMIDIExternalSource_endpointDictionary objectForKey:name];
}


+ (NSArray *) endpoints
{
    CMIDIInitializeExternalSources();
    return CMIDIExternalSource_endpoints;
}


+ (NSDictionary *) dictionary
{
    CMIDIInitializeExternalSources();
    return CMIDIExternalSource_endpointDictionary;
}


- (void) dealloc
{
    MIDIPortDispose(_port);
    MIDIEndpointDispose(_endpointRef);
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
// Create a port and connect it to the source; the source will send MIDI to use through the read proc.

- (void) initPortWithIndex: (NSUInteger) i
{
    NSString *portName = [NSString stringWithFormat:@"Input port for source: %@",[self name]];
    void *refCon = (__bridge void *) self;
    OSStatus err;
    err = MIDIInputPortCreate(CMIDIClient(),
                                (__bridge CFStringRef) portName,
                                CMIDIExternalSource_ReadProc,
                                (void *) i,
                                &_port);
    NSAssert(err == 0,@"CoreMIDI from CMIDI");
    err = MIDIPortConnectSource(_port, _endpointRef, refCon);
    NSAssert(err == 0,@"CoreMIDI from CMIDI");
}


static
void CMIDIExternalSource_ReadProc(const MIDIPacketList *packetList,
                                  void *refCon,
                                  void *unused)
{
    NSUInteger i = (NSUInteger) refCon;
    CMIDIExternalSource * sender;
    NSObject <CMIDIReceiver> * receiver;
    @synchronized(CMIDIExternalSource_endpoints) {
        sender = CMIDIExternalSource_endpoints[i];
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



@end
