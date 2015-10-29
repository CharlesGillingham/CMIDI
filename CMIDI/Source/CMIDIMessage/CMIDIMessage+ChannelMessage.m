//
//  CMIDIMessage+ChannelMessage.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 1/6/14.
//

#import "CMIDIMessage+ChannelMessage.h"
#import "CMIDIVSNumber.h"

@implementation CMIDIMessage (ChannelMessages)

// -----------------------------------------------------------------------------
#pragma mark            Channel messages / Channel Messages
// -----------------------------------------------------------------------------
@dynamic channel;

- (UInt8) channel             {
    if(self.type == MIDIMessage_System) return 0; // Fail value.
    return ((self.status & 0x0F) + 1);
}

- (void) setChannel:(UInt8)c
{
    assert(c > 0 && c <= 16 && self.type != MIDIMessage_System);
    ((Byte*)self.data.bytes)[0] = ((self.status & 0xF0) | (c - 1));
}


// -----------------------------------------------------------------------------
#pragma mark            Channel messages / Note Messages
// -----------------------------------------------------------------------------
@dynamic noteNumber;
@dynamic velocity;
@dynamic releaseVelocity;
@dynamic notePressure;
@dynamic percussionInstrument;

+ (CMIDIMessage *) messageWithNoteOn:(UInt8)n velocity:(UInt8)v channel:(UInt8)c
{
    assert(c > 0 && c <= 16 && n <= 127 && v <= 127);
    Byte buf[3] = {MIDIMessage_NoteOn | (c-1), n, v};
    return [CMIDIMessage messageWithBytes: buf length: 3];
}

+ (CMIDIMessage *) messageWithNoteOff:(UInt8)n releaseVelocity:(UInt8)v channel:(UInt8)c
{
    assert(c > 0 && c <= 16 && n <= 127 && v <= 127);
    Byte buf[3] = {MIDIMessage_NoteOff | (c-1), n, v};
    return [CMIDIMessage messageWithBytes: buf length: 3];
}

+ (CMIDIMessage *) messageWithNotePressure:(UInt8)n pressure:(UInt8)p channel:(UInt8)c
{
    assert(c > 0 && c <= 16 && n <= 127 && p <= 127);
    Byte buf[3] = {MIDIMessage_NotePressure | (c-1), n, p};
    return [CMIDIMessage messageWithBytes: buf length: 3];
}


- (UInt8) noteNumber {
    assert(self.isNoteMessage);
    return self.byte1;
}


- (BOOL) isNoteMessage
{
    return (self.type == MIDIMessage_NoteOn  ||
            self.type == MIDIMessage_NoteOff ||
            self.type == MIDIMessage_NotePressure);
}

- (BOOL) isNoteOff
{
    return (self.type == MIDIMessage_NoteOff ||
            (self.type == MIDIMessage_NoteOn && self.velocity == 0));
}


- (UInt8) velocity   {
    assert(self.type == MIDIMessage_NoteOn);
    return self.byte2;
}


- (UInt8) releaseVelocity {
    assert(self.type == MIDIMessage_NoteOff);
    return self.byte2;
}


- (UInt8) notePressure {
    assert(self.type == MIDIMessage_NotePressure);
    return self.byte2;
}


- (Byte) percussionInstrument {
    assert([self isNoteMessage]);
    return self.byte1;
}


// -----------------------------------------------------------------------------
#pragma mark            Channel Message / ControlMessage
// -----------------------------------------------------------------------------
@dynamic controlNumber;
@dynamic controlType;
@dynamic byteValue;
@dynamic boolValue;


+ (CMIDIMessage *) messageWithController:(Byte)control value:(UInt8)v channel:(UInt8)c
{
    assert(c > 0 && c <= 16);
    assert(v <= 127);
    Byte t = [CMIDIMessage controlTypeFromControlNumber:control];
    assert(t == CMIDIControllerType_Continuous ||
           t == CMIDIControllerType_Fine);
    
    Byte buf[3] = {MIDIMessage_ControlChange | (c-1), control, v};
    return [CMIDIMessage messageWithBytes:buf length:3];
}


+ (CMIDIMessage *) messageWithController:(Byte) control boolValue:(BOOL)v channel:(UInt8)c
{
    assert(c > 0 && c <= 16);
    assert([CMIDIMessage controlTypeFromControlNumber:control] == CMIDIControllerType_Binary);
    Byte buf[3] = {MIDIMessage_ControlChange | (c-1), control, (v ? 127 : 0)};
    return [CMIDIMessage messageWithBytes:buf length:3];
}


- (UInt8) controlNumber {
    assert(self.type == MIDIMessage_ControlChange);
    return self.byte1;
}


+ (Byte) controlTypeFromControlNumber: (UInt8) controlNumber
{
    switch (controlNumber) {
        case MIDIController_BankSelect          ...
        MIDIController_GeneralPurpose4:                return CMIDIControllerType_Continuous;
        case MIDIController_FineBankSelect      ...
        MIDIController_FineGeneralPurpose4:            return CMIDIControllerType_Fine;
        case MIDIController_Sustain             ...
        MIDIController_Hold2:                          return CMIDIControllerType_Binary;
        case MIDIController_SoundVariation      ...
        MIDIController_Celeste:                        return CMIDIControllerType_Continuous;
        case MIDIController_RPN_NonRegisteredParameter_LSB ...
        MIDIController_RPN_RegisteredParameter_MSB:    return CMIDIControllerType_RPN;
        case MIDIController_Mode_AllSoundOff    ...
        MIDIController_Mode_PolyOperation:             return CMIDIControllerType_Mode;
        default:                                       return CMIDIControllerType_Undefined;
    }
}

- (UInt8) controlType
{
    if (self.type != MIDIMessage_ControlChange) return CMIDIControllerType_Undefined;
    return [CMIDIMessage controlTypeFromControlNumber: self.controlNumber];
}


- (UInt8) byteValue {
    assert(self.type == MIDIMessage_ControlChange);
    assert(self.data.length > 2); // Allow any message to access the "byteValue"
    return self.byte2;
}


// For binary controllers, the data byte is set to 127 for "on" and 0 for "off"
- (BOOL) boolValue {
    assert(self.type == MIDIMessage_ControlChange);
    assert(self.controlType == CMIDIControllerType_Binary);
    return (self.byte2 != 0);
}


// -----------------------------------------------------------------------------
#pragma mark            Channel messages / Control Message / Registered Parameters
// -----------------------------------------------------------------------------

+ (NSArray *) messageListWithRPNController: (UInt16) rpn value: (UInt16) value channel: (UInt8) c
{
    assert(c > 0 && c <= 16);
    
    Byte buf[12] = {
        MIDIMessage_ControlChange | c+1, MIDIController_RPN_NonRegisteredParameter_LSB, CMIDILSBFromUInt16(rpn),
        MIDIMessage_ControlChange | c+1, MIDIController_RPN_NonRegisteredParameter_MSB, CMIDIMSBFromUInt16(rpn),
        MIDIMessage_ControlChange | c+1, MIDIController_RPN_DataEntry_LSB, CMIDILSBFromUInt16(value),
        MIDIMessage_ControlChange | c+1, MIDIController_RPN_DataEntry_MSB, CMIDIMSBFromUInt16(value),
    };
    return [NSArray arrayWithObjects:
            [CMIDIMessage messageWithBytes: buf + 0 length: 3],
            [CMIDIMessage messageWithBytes: buf + 3 length: 3],
            [CMIDIMessage messageWithBytes: buf + 6 length: 3],
            [CMIDIMessage messageWithBytes: buf + 9 length: 3],
            nil];
}


+ (NSArray *) messageListToIncrementRPNController: (UInt16) rpn channel: (UInt8) c
{  // TODO
    return nil;
}


+ (NSArray *) messageListToDecrementRPNController: (UInt16) rpn channel: (UInt8) c
{  // TODO
    return nil;
}


// -----------------------------------------------------------------------------
#pragma mark            Channel messages / Control Message / Global Control
// -----------------------------------------------------------------------------

+ (CMIDIMessage *) messageAllSoundOff: (UInt8) channel {
    Byte buf[3] = {MIDIMessage_ControlChange | (channel -1), MIDIController_Mode_AllSoundOff, 0};
    return [CMIDIMessage messageWithBytes:buf length:3];
}

+ (CMIDIMessage *) messageAllControllersOff: (UInt8) channel {
    Byte buf[3] = {MIDIMessage_ControlChange | (channel -1), MIDIController_Mode_AllControllersOff, 0};
    return [CMIDIMessage messageWithBytes:buf length:3];
}


+ (CMIDIMessage *) messageLocalKeyboardOff: (UInt8) channel {
    Byte buf[3] = {MIDIMessage_ControlChange | (channel -1), MIDIController_Mode_LocalKeyboardOff, 0};
    return [CMIDIMessage messageWithBytes:buf length:3];
}


+ (CMIDIMessage *) messageAllNotesOff: (UInt8) channel {
    
    Byte buf[3] = {MIDIMessage_ControlChange | (channel -1), MIDIController_Mode_AllNotesOff, 0};
    return [CMIDIMessage messageWithBytes:buf length:3];
}

// -----------------------------------------------------------------------------
#pragma mark            Channel messages / Control Message / Channel Mode
// -----------------------------------------------------------------------------

+ (CMIDIMessage *) messageOmniModeOff: (UInt8) channel {
    assert(channel > 0 && channel <= 16);
    Byte buf[3] = {MIDIMessage_ControlChange | (channel-1), MIDIController_Mode_OmniModeOff, 0};
    return [CMIDIMessage messageWithBytes:buf length:3];
}


+ (CMIDIMessage *) messageOmniModeOn:(UInt8)channel {
    assert(channel > 0 && channel <= 16);
    Byte buf[3] = {MIDIMessage_ControlChange | (channel-1), MIDIController_Mode_OmniModeOn, 0};
    return [CMIDIMessage messageWithBytes:buf length:3];
}


+ (CMIDIMessage *) messageMonoMode:(UInt8)channel {
    assert(channel > 0 && channel <= 16);
    Byte buf[3] = {MIDIMessage_ControlChange | (channel-1), MIDIController_Mode_MonoOperation, 0};
    return [CMIDIMessage messageWithBytes:buf length:3];
}


+ (CMIDIMessage *) messagePolyMode:(UInt8)channel {
    assert(channel > 0 && channel <= 16);
    Byte buf[3] = {MIDIMessage_ControlChange | (channel-1), MIDIController_Mode_PolyOperation, 0};
    return [CMIDIMessage messageWithBytes:buf length:3];
}


// -----------------------------------------------------------------------------
#pragma mark            Channel messages / Program Change
// -----------------------------------------------------------------------------
@dynamic programNumber;

+ (CMIDIMessage *) messageWithProgramChange:(UInt8)program channel:(UInt8)c
{
    assert(c > 0 && c <= 16 && program <= 127);
    Byte buf[2] = {MIDIMessage_ProgramChange | (c-1), program};
    return [CMIDIMessage messageWithBytes:buf length:2];
}

- (UInt8) programNumber {
    assert(self.type == MIDIMessage_ProgramChange);
    return self.byte1;
}


// -----------------------------------------------------------------------------
#pragma mark            Channel messages / Pitch Wheel
// -----------------------------------------------------------------------------
@dynamic pitchWheelValue;

+ (CMIDIMessage *) messageWithPitchWheelValue:(UInt16)v channel:(UInt8)c
{
    assert(c > 0 && c <= 16);
    assert(v <= MIDIPitchWheel_Max);
    Byte buf[3] = {MIDIMessage_PitchWheel | (c-1), CMIDIMSBFromUInt16(v), CMIDILSBFromUInt16(v)};
    return [CMIDIMessage messageWithBytes:buf length:3];
}


- (UInt16) pitchWheelValue {
    assert(self.type == MIDIMessage_PitchWheel);
    return CMIDIUInt16FromMSBandLSB(self.byte1, self.byte2);
}

// -----------------------------------------------------------------------------
#pragma mark            Channel messages / Channel pressure
// -----------------------------------------------------------------------------
@dynamic channelPressure;


+ (CMIDIMessage *) messageWithChannelPressure:(UInt8)pressure channel:(UInt8)c;
{
    assert(c > 0 && c <= 16);
    assert(pressure < 127);
    Byte buf[2] = {MIDIMessage_ChannelPressure | (c-1), pressure};
    return [CMIDIMessage messageWithBytes:buf length:2];
}


- (UInt8) channelPressure {
    assert(self.type == MIDIMessage_ChannelPressure);
    return self.byte1;
}

@end


