//
//  CMIDIMessage+Simplified.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 10/22/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDIMessage+Simplified.h"
#import "CMIDIMessage+ChannelMessage.h"
#import "CMIDIMessage+SystemMessage.h"
#import "CMIDIMessage+MetaMessage.h"

// Define level set of number for each possible message.
enum {
    CMIDICurrentState_FirstNote = 0,
    CMIDICurrentState_FirstNotePressure = 128, //THIS IS WRONG; WE NEED TO STORE RELEASE VELOCITY!!!
    CMIDICurrentState_FirstControl = 256,
    CMIDICurrentState_ProgramIndex = 384,
    CMIDICurrentState_ChannelPressureIndex = 385,
    CMIDICurrentState_PitchWheelIndex = 386,
    CMIDICurrentState_FirstSystem = 387,
    CMIDICurrentState_FirstMeta = CMIDICurrentState_FirstSystem+15,

    CMIDICurrentState_Count   = CMIDICurrentState_FirstMeta+128,
    CMIDICurrentState_Corrupt = CMIDICurrentState_Count + 1
};

enum {
    CMIDIValueType_None,
    CMIDIValueType_Integer,
    CMIDIValueType_Boolean,
    CMIDIValueType_ArrayOfInteger,
    CMIDIValueType_Text,
    CMIDIValueType_Other
};



@implementation CMIDIMessage (Simplified)

- (UInt16) simpleType
{
    switch (self.type) {
        case MIDIMessage_NoteOn:
        case MIDIMessage_NoteOff:
            return self.noteNumber;
        case MIDIMessage_NotePressure:
            return self.noteNumber + CMIDICurrentState_FirstNotePressure;
        case MIDIMessage_ControlChange:
            return self.controlNumber + CMIDICurrentState_FirstControl;
        case MIDIMessage_ChannelPressure:
            return CMIDICurrentState_ChannelPressureIndex;
        case MIDIMessage_PitchWheel:
            return CMIDICurrentState_PitchWheelIndex;
        case MIDIMessage_ProgramChange:
            return CMIDICurrentState_ProgramIndex;
        case MIDIMessage_System:
            if (self.type == MIDISystemMsg_Meta) {
                return self.metaMessageType + CMIDICurrentState_FirstMeta;
            } else {
                return self.systemMessageType + CMIDICurrentState_FirstSystem;
            }
        default:
            return CMIDICurrentState_Corrupt;
    }
}




- (NSUInteger) valueType
{
    switch (self.type) {
        case MIDIMessage_NoteOn:
        case MIDIMessage_NoteOff:
        case MIDIMessage_NotePressure:
        case MIDIMessage_ChannelPressure:
        case MIDIMessage_PitchWheel:
        case MIDIMessage_ProgramChange:                 return CMIDIValueType_Integer;
        case MIDIMessage_ControlChange:
            switch (self.controlType) {
                case CMIDIControllerType_Binary:        return CMIDIValueType_Boolean;
                case CMIDIControllerType_Continuous:
                case CMIDIControllerType_Fine:          return CMIDIValueType_Integer;
                case CMIDIControllerType_RPN:           return CMIDIValueType_Other;
                case CMIDIControllerType_Mode:          return CMIDIValueType_None;
                case CMIDIControllerType_Undefined:
                default: {
                    NSAssert(NO, @"Undefined control found in CMIDI");
                    return NSNotFound;
                }
            }
        case MIDIMessage_System:
            switch (self.systemMessageType) {
            }
            
            // TODO
        default:
            NSAssert(NO, @"Corrupt message found in CMIDI");
            return NSNotFound;
    }
}


- (NSObject *) value
{
    switch (self.type) {
        case MIDIMessage_NoteOn:
        case MIDIMessage_NoteOff:
        case MIDIMessage_NotePressure:
            return [NSNumber numberWithInteger:self.byte2];
            
        case MIDIMessage_ChannelPressure:
        case MIDIMessage_ProgramChange:
            return [NSNumber numberWithInteger:self.byte1];

        case MIDIMessage_PitchWheel:
            return [NSNumber numberWithInteger:self.pitchWheelValue];
            
        case MIDIMessage_ControlChange:
            switch (self.controlType) {
                case CMIDIControllerType_Binary:        return [NSNumber numberWithBool:self.byte2];
                case CMIDIControllerType_Continuous:
                case CMIDIControllerType_Fine:          return [NSNumber numberWithInteger:self.byte2];
                case CMIDIControllerType_Mode:          return nil;
                case CMIDIControllerType_RPN: {
                    NSAssert(NO, @"RPN controls not implmented in CMIDI");
                    return nil;
                }
                case CMIDIControllerType_Undefined:
                default: {
                    NSAssert(NO, @"Undefined control found in CMIDI");
                    return nil;
                }
            }
  
        case MIDIMessage_System:
            switch (self.systemMessageType) {
                case MIDISystemMsg_SystemExclusive:
                    return @[self.sysExManufacturerId,
                             self.sysExData];

                case MIDISystemMsg_SongSelection:
                    return [NSNumber numberWithInteger: self.byte2];
                    
                case MIDISystemMsg_SongPosition:
                    return [NSNumber numberWithInteger: self.songPosition];
                    
                case MIDISystemMsg_MIDITimeCodeQtrFrame:
                    return [NSNumber numberWithInteger: self.byte2];
                    
                case MIDISystemMsg_SystemReset:
                    if (!self.isMeta) {
                        return nil;
                    }
               //case MIDISystemMsg_Meta:
                    
                    switch (self.metaMessageType) {
                            
                        case MIDIMeta_FirstText ... MIDIMeta_LastText:
                            return self.text;
                            
                        case MIDIMeta_SequenceNumber:
                            return [NSNumber numberWithInteger:self.sequenceNumber];
                            
                        case MIDIMeta_ChannelPrefix:
                            return [NSNumber numberWithInteger:self.channelPrefix];
                            
                        case MIDIMeta_PortPrefix:
                            return [NSNumber numberWithInteger:self.portPrefix];
                            
                        case MIDIMeta_TempoSetting:
                            return [NSNumber numberWithInteger:self.MPB];
                            
                        case MIDIMeta_TimeSignature:
                            return @[[NSNumber numberWithInteger:self.numerator],
                                     [NSNumber numberWithInteger:self.denominator]];
                            
                        case MIDIMeta_SMPTEOffset: {
                            CMIDISMPTEOffset s = self.SMPTEOffset;
                            return @[[NSNumber numberWithInteger:s.hours],
                                     [NSNumber numberWithInteger:s.minutes],
                                     [NSNumber numberWithInteger:s.seconds],
                                     [NSNumber numberWithInteger:s.frames],
                                     [NSNumber numberWithInteger:s.fractionalFrames]];
                        }
                            
                        case MIDIMeta_KeySignature:
                            return @[[NSNumber numberWithInteger:self.keyPitchClass],
                                     [NSNumber numberWithBool:self.keyIsMinor]];
                            
                        case MIDIMeta_SequencerEvent: {
                            NSAssert(NO,@"MIDI Meta Sequencer Event is not supported by CMIDI");
                            return nil;
                        }
                           
                        case MIDIMeta_EndOfTrack:
                            return nil;
                            
                        default:
                            NSAssert(NO,@"Bad Meta message number in CMIDI");
                            return nil;
                    }
                default: {
                    return nil;
                }
            }

        default:
            NSAssert(NO, @"Corrupt message found in CMIDI");
            return nil;
    }
}



+ (CMIDIMessage *) messageWithType: (SInt16) type
                             value: (NSObject *) value
{
    // TODO
    return nil;
}


@end
