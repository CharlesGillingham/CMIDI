//
//  CMIDIInstrument.m
//  SqueezeBox 0.0.1
//
//  Created by CHARLES GILLINGHAM on 10/11/15.
//  Copyright (c) 2015 SqueezeBox. All rights reserved.
//

#import "CMIDIInstrument.h"
#import "CMIDIMessage+ChannelMessage.h"
#import "CDebugMessages.h"
#import "CMIDIMessage+Description.h"


enum {
    // CurrentState 0..127 are the controllers.
    CMIDICurrentState_ProgramIndex = 128,
    CMIDICurrentState_ChannelPressureIndex = 129,
    CMIDICurrentState_PitchWheelIndex = 130,
    CMIDICurrentState_Count = 131
};


@interface CMIDIInstrument ()
@end


@implementation CMIDIInstrument {

    // Either (1) a CMIDIEndpoint or (2) a CAudioInstrument, depending on whether this is an exteral or internal instrument.
    NSObject <CMIDIReceiver> * _output;
    
    CMIDIMessage * _currentState[MIDIChannel_Count][CMIDICurrentState_Count];
    
    // Mute control
    BOOL _clockMute;
    BOOL _applicationMute;
    BOOL _userMute;
    NSUInteger _muteCount;
}

- (id) initWithReceiver: (NSObject <CMIDIReceiver> *) receiver
{
    if (self = [super init]) {
        _output = receiver;
        _muteCount = 0;
    }
    return self;
}

// -----------------------------------------------------------------------------
#pragma mark                    Set output
// -----------------------------------------------------------------------------
// Not currently public; but if in the future there was a need to change the internal signal chain, this would do it.

- (NSObject <CMIDIReceiver> *) outputUnit {
    @synchronized(self) {
        return _output;
    }
}


- (void) setOutputUnit:(NSObject<CMIDIReceiver> *)outputUnit
{
    NSObject <CMIDIReceiver> * old;
    
    @synchronized(self) {
        old = _output;
        _output = outputUnit;
    }
    
    if (old) {
        [self killOutput:old];
    }
    
    [self restoreState];
}



// -----------------------------------------------------------------------------
#pragma mark            Save state / Restore state
// -----------------------------------------------------------------------------

- (void) storeMessage: (CMIDIMessage *) msg
{
    NSUInteger n;
    switch (msg.type) {
        case MIDIMessage_ControlChange:   n = msg.controlNumber; break;
        case MIDIMessage_PitchWheel:      n = CMIDICurrentState_PitchWheelIndex; break;
        case MIDIMessage_ChannelPressure: n = CMIDICurrentState_ChannelPressureIndex; break;
        case MIDIMessage_ProgramChange:   n = CMIDICurrentState_ProgramIndex; break;
        default: return;
    }
    NSUInteger c = msg.channel-1;
    
    [self willChangeValueForKey:@"currentState"];
    _currentState[c][n] = msg;
    [self didChangeValueForKey:@"currentState"];
}



- (void) restoreState
{
    NSObject <CMIDIReceiver> * receiver;
    @synchronized(self) {
        receiver = _output;
    }
    
    for (NSUInteger c = 0; c < 16; c++) {
        for (NSUInteger n = 0; n < CMIDICurrentState_Count; n++) {
            if (_currentState[c][n]) {
                [receiver respondToMIDI:_currentState[c][n]];
            }
        }
    }
}


// Called from NSCoding routines, which need an object.

- (NSArray *) stateList
{
    NSMutableArray * csList = [NSMutableArray arrayWithCapacity:CMIDICurrentState_Count];
    for (NSUInteger c = 0; c < 16; c++) {
        for (NSUInteger n = 0; n < CMIDICurrentState_Count; n++) {
            if (_currentState[c][n]) {
                [csList addObject:_currentState[c][n]];
            }
        }
    }
    return csList;
}



- (void) setStateList: (NSArray *) csList
{
    for (CMIDIMessage * msg in csList) {
        [self respondToMIDI:msg];
    }
}



// -----------------------------------------------------------------------------
#pragma mark         Kill output
// -----------------------------------------------------------------------------

- (void) killOutput: (NSObject <CMIDIReceiver> *) obj
{
    CMIDIMessage *mm1, *mm2;
    for (NSUInteger channel = MIDIChannel_Min; channel <= MIDIChannel_Max; channel++) {
        mm1 = [CMIDIMessage messageAllNotesOff:channel];
        mm2 = [CMIDIMessage messageAllSoundOff:channel];
        [obj respondToMIDI: mm1];
        [obj respondToMIDI: mm2];
    }
}


// -----------------------------------------------------------------------------
#pragma mark          MIDIReceiver, MIDISender
// -----------------------------------------------------------------------------


- (void) respondToMIDI:(CMIDIMessage *)msg
{
    NSObject <CMIDIReceiver> * receiver;
    @synchronized(self) {
        receiver = _output;
    }
    
    // Pass through
    if (_muteCount == 0 && receiver) {
        [receiver respondToMIDI: msg];
    }
    
    // Do this on the main queue, so that we avoid any jitter caused by updating the UI.
//    dispatch_async(dispatch_get_main_queue(), ^{
        [self storeMessage:msg];
 //   });
}


// -----------------------------------------------------------------------------
#pragma mark                    Mute control
// -----------------------------------------------------------------------------

- (void) clockTicked:(CMIDIClock *)c
{ }


- (void) clockStopped: (CMIDIClock *) clock
{
    if (_clockMute != YES) {
        _clockMute = YES;
        [self addMute: YES];
    }
}


- (void) clockStarted: (CMIDIClock *) clock
{
    if (_clockMute != NO) {
        _clockMute = NO;
        [self addMute: NO];
    }
}


- (void) setIsVisible:(BOOL)applicationIsVisible
{
    if (applicationIsVisible == _applicationMute) {
        _applicationMute = !applicationIsVisible;
        [self addMute: !applicationIsVisible];
    }
}
- (BOOL) isVisible { return !_applicationMute;  }



- (void) setMute: (BOOL) mute
{
    if (mute != _userMute) {
        _userMute = mute;
        [self addMute: mute];
    }
}
- (BOOL) mute {  return _userMute;  }



- (void) addMute: (BOOL) mute
{
    if (mute) {
        if (_muteCount <= 0) {
            NSObject <CMIDIReceiver> * receiver;
            @synchronized(self) {
                receiver = _output;
            }
            
            [self killOutput:receiver];
        }
        _muteCount++;
    } else {
        if (_muteCount == 1) {
            [self restoreState];
        }
        _muteCount--;
    }
}


@end
