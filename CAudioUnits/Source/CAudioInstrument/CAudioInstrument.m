//
//  CAudioInstrument.m
//  CAudioUnits
//
//  Created by Charles Gillingham on 7/23/12.
//  Copyright (c) 2012 Charles Gillingham. All rights reserved.
//
#import "CAudioUnit_Internal.h"
#import "CAUGraph_Internal.h"
#import "CAudioInstrument.h"

enum {
    MIDISystemMsg_SystemExclusive = 0xF0
};

@interface CAudioInstrument ()
@end

 
@implementation CAudioInstrument {
    MusicDeviceMIDIEventProc    _fastDispatchProc;
}



// -----------------------------------------------------------------------------
#pragma mark                    Constructors
// -----------------------------------------------------------------------------

+ (NSArray *) subtypeNames
{
    return [CAudioUnit subtypesOfOSType:kAudioUnitType_MusicDevice];
}


- (instancetype) initWithSubtype: (NSString *) subtypeName
{
    return [self initWithOSType: kAudioUnitType_MusicDevice
                        subtype: subtypeName
                          graph: [CAUGraph currentGraph]];
}

- (instancetype) initWithSubtype: (NSString *) subtypeName
                           graph: (CAUGraph *) graph
{
    return [self initWithOSType: kAudioUnitType_MusicDevice
                        subtype: subtypeName
                          graph: graph];
}


- (instancetype) initWithOSType:(OSType)type
                        subtype:(NSString *)subtype
                          graph:(CAUGraph *)graph
{
    if (self = [super initWithOSType:type subtype:subtype graph:graph]) {
        _fastDispatchProc = nil;
    }
    return self;
}


// -----------------------------------------------------------------------------
#pragma mark                    MIDI
// -----------------------------------------------------------------------------


- (void) reInitialize
{
        // Initialize the "fast dispatch" proc. if it hasn't already been initialized
        MusicDeviceMIDIEventProc proc;
        UInt32 size = sizeof(proc);
        OSStatus err = AudioUnitGetProperty(self.audioUnit,
                                            kAudioUnitProperty_FastDispatch,
                                            kAudioUnitScope_Global,
                                            0,
                                            &proc,
                                            &size);
        
        if (err || !proc) {
            proc = (MusicDeviceMIDIEventProc) (MusicDeviceMIDIEvent);
        }
        _fastDispatchProc = proc;
}



- (void) respondToMIDI: (Byte *) message ofSize: (NSUInteger) size
{
    AudioUnit unit = [self audioUnit];
    assert(unit != nil);
   
    if (!_fastDispatchProc) [self reInitialize];
    
    OSStatus err;
    
    UInt8 statusByte = *message;
    if (statusByte == MIDISystemMsg_SystemExclusive) {
         err = MusicDeviceSysEx(unit,
                                message + 1,
                                ((UInt32)size)-1); // -1 for the status byte.
    } else {                   
        MusicDeviceMIDIEventProc MIDIEventProc = _fastDispatchProc;
            err = MIDIEventProc(unit,
                                statusByte,
                                (size > 0 ? *(message+1) : 0),
                                (size > 1 ? *(message+2) : 0),
                                0);
    }
       
   
    // These errors are common but they tend to be very innocent; i.e, a message from a MIDI file is attempting to set the chorus level on a device that doesn't have chorus.
    if (err) {
        printf("CAudioInstrument: Error %d returned by Audio Instrument\n", err);
    }
}


@end