//
//  CMIDIMessage+CMIDIMessage_Debug.m
//  SqueezeBox 0.0.1
//
//  Created by CHARLES GILLINGHAM on 6/20/15.
//  Copyright (c) 2015 SqueezeBox. All rights reserved.
//
#import "CDebugMessages.h"
#import "CMIDIMessage+Debug.h"
#import "CMIDIMessage+ChannelMessage.h"
#import "CMIDIMessage+SystemMessage.h"
#import "CMIDIMessage+MetaMessage.h"
#import "CMIDIMessage+Description.h"
#import "CMIDIMessageByteCount.h"
#import "CMIDIMessage+DescriptionWithTime.h"
#import "CTimeMap+TimeString.h"

#define MIDIByteIsData(b) ((b) < 0x80)
#define MIDINote_MiddleC (60)
#define MIDINote_A440    (57)


#ifdef DEBUG
@implementation CMIDIMessage (Debug)

- (BOOL) check
{
    // ALL MESSAGES
    Byte * bytes = (Byte *) self.data.bytes;
    Byte status = (*bytes);
    
    // Check status byte is a status byte
    if (!CASSERT_MSG(!MIDIByteIsData(status),@"Data byte in status byte position")) return NO;
    
    // Check the data bytes are data bytes
    // Two exceptions: meta messages, and system exclusive's last byte (which should equal MIDISystemMsg_EndOfSysex).
    if (!self.isMeta) {
        
        NSUInteger length = self.data.length;
        if (status == MIDISystemMsg_SystemExclusive) length--;
        
        for (NSUInteger i = 1; i < length; i++) {
            Byte b = bytes[i];
            if (!CASSERT_MSG(MIDIByteIsData(b),
                             ([NSString stringWithFormat:@"Status byte discovered in data. %lu of %lu bytes",i, length]))) {
                return NO;
            }
        }
    }
    
    // Check that it has the right length
    OSStatus errCode;
    NSUInteger expectedBytes = CMIDIMessageByteCount(status,
                                                     bytes+1,
                                                     self.data.length-1,
                                                     self.isMeta,
                                                     &errCode);
    if (!CASSERT(expectedBytes != 0)) return NO;
    if (!CASSERT(expectedBytes == self.data.length)) return NO;
    
    
    
    // CHANNEL MESSAGES
    // Channel messages use every possible value so there's nothing to check. (Except binary controllers; but it seems that different files use different values for "true" (127, 64, 1, etc.) so there's point checking this value.)
    
    // SYSTEM MESSAGES:
    switch (self.systemMessageType) {
        case MIDISystemMsg_None: // Channel messages
            return YES;
            
        case MIDISystemMsg_SystemExclusive:
            if (!CASSERT(((Byte *)self.data.bytes)[self.data.length-1] == MIDISystemMsg_EndofSysEx)) return NO;
            return YES;
            
        case MIDISystemMsg_MIDITimeCodeQtrFrame:
        case MIDISystemMsg_SongPosition:
        case MIDISystemMsg_SongSelection:
        case MIDISystemMsg_TuneRequest:
            return YES;
            
        case MIDISystemMsg_EndofSysEx:
            CFAIL(@"MIDISystemMsg_EndofSysEx (or MIDISystemMsg_SysExContinued) appears as a standalone message.");
            return NO;
  
        case MIDISystemMsg_TimingClock:
        case MIDISystemMsg_Start:
        case MIDISystemMsg_Continue:
        case MIDISystemMsg_Stop:
        case MIDISystemMsg_ActiveSensing:
            return YES;
            
        case MIDISystemMsg_Meta:
            if (!self.isMeta) { // This is a system real time message
                return YES;
            }
            break;
            
        case MIDISystemMsg_4_Undefined:
        case MIDISystemMsg_5_Undefined:
        case MIDISystemMsg_10_Undefined:
        case MIDISystemMsg_13_Undefined:
        default:
            CFAIL(@"Bad status byte -- unsupported system message");
            return NO;
    }
    
    // Check that we are have a defined message:
    switch (self.metaMessageType) {
        case MIDIMeta_FirstText...MIDIMeta_LastText:
            // No point checking the encoding, because some example files use European encodings. Just let them be what they are.
            break;
            
        case MIDIMeta_ChannelPrefix: {
            if (!CASSERT(self.channelPrefix >= 1 && self.channelPrefix <= 16)) return NO;
            break;
        }
            
        case MIDIMeta_PortPrefix:
        case MIDIMeta_TempoSetting:
        case MIDIMeta_SMPTEOffset:
        case MIDIMeta_TimeSignature:
        case MIDIMeta_KeySignature:
        case MIDIMeta_EndOfTrack:
            // Not checking these now
            break;
            
        case MIDIMeta_SequencerEvent: {
            // Not supported by CMIDI at this point (can't even parse these).
            break;
        }
        case MIDIMeta_SequenceNumber: {
            // Barely supported by CMIDI (no description and no acessors)
            break;
        }
        default: {
            CFAIL(([NSString stringWithFormat:@"WARNING: Unknown meta message: %@", self.description]));
            break;
        }
    }
    
    
    return YES;
}





- (BOOL) checkIsEqual: (CMIDIMessage *) message
{
    // This handles several unusual cases ...
    if ([self isEqual:message]) {
        return YES;
    }
    
    // Eliminate all of these errors, which probably means these are not anything like each other.
    // Check the data.
    if (CASSERT([message isKindOfClass:[CMIDIMessage class]]) &&
        CASSERTEQUAL(self.time, message.time) &&
        CASSERTEQUAL(self.channel, message.channel) &&
        CASSERTEQUAL(self.messageName, message.messageName) &&
        CASSERTEQUAL(self.data, message.data))
    {
        return YES;
    }
    return NO;
}


- (void) show
{
    printf("%s\n",[self tableRowString].UTF8String);
}

+ (void) showHeader
{
    printf("%s\n",[CMIDIMessage tableHeader].UTF8String);
}

- (void) show: (CMIDITempoMeter *) tm
{
    printf("%s\n",[self tableRowStringWithTimeMap: tm].UTF8String);
}


+ (void) showHeader: (CMIDITempoMeter *) tm
{
    printf("%s\n", [self tableHeaderWithTimeMap:tm].UTF8String);
}

//------------------------------------------------------------------------------
#pragma mark                   Tests
//------------------------------------------------------------------------------
// The main test uses every constructor and every accessor (except a few that have essentially identical code).
// isEqual is tested multiple times by CMIDIFile+Debug, as is sortedMessageList.
// Thus CMIDIMessage is completely tested.

NSArray * CMIDIMessage_Debug_OneOfEachMessage = nil;


+ (BOOL) test
{
    if (CMIDIMessage_Debug_OneOfEachMessage) {
        printf("\n    [CMIDIMessage test] has already been run\n\n");
        return YES;
    }
    
    CMIDIMessage * msg;
    NSMutableArray * channelMessages = [NSMutableArray new];
    
    msg =[CMIDIMessage messageWithNoteOn: MIDINote_MiddleC velocity:100 channel:1];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.type == MIDIMessage_NoteOn);
    CASSERT_RET(msg.velocity == 100);
    CASSERT_RET(msg.noteNumber == MIDINote_MiddleC);
    CASSERT_RET(msg.channel == 1);
    CASSERT_RET(msg.isNoteMessage == YES);
    CASSERT_RET(msg.isNoteOff == NO);
    [channelMessages addObject:msg];
    
    msg =[CMIDIMessage messageWithNoteOn: MIDINote_A440 velocity:100 channel:2];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.type == MIDIMessage_NoteOn);
    CASSERT_RET(msg.velocity == 100);
    CASSERT_RET(msg.noteNumber == MIDINote_A440);
    CASSERT_RET(msg.channel == 2);
    CASSERT_RET(msg.isNoteMessage == YES);
    CASSERT_RET(msg.isNoteOff == NO);
    [channelMessages addObject:msg];
    
    msg = [CMIDIMessage messageWithNoteOn: MIDIPercussionInstrument_AcousticBassDrum velocity:1 channel:MIDIChannel_Percussion];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.type == MIDIMessage_NoteOn);
    CASSERT_RET(msg.velocity == 1);
    CASSERT_RET(msg.noteNumber == MIDIPercussionInstrument_AcousticBassDrum);
    CASSERT_RET(msg.channel == MIDIChannel_Percussion);
    CASSERT_RET(msg.isNoteMessage == YES);
    CASSERT_RET(msg.isNoteOff == NO);
    [channelMessages addObject:msg];

    
    msg = [CMIDIMessage messageWithNoteOff: MIDINote_MiddleC releaseVelocity:101 channel:1];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.type == MIDIMessage_NoteOff);
    CASSERT_RET(msg.releaseVelocity == 101);
    CASSERT_RET(msg.noteNumber == MIDINote_MiddleC);
    CASSERT_RET(msg.channel == 1);
    CASSERT_RET(msg.isNoteMessage == YES);
    CASSERT_RET(msg.isNoteOff == YES);
    [channelMessages addObject:msg];
    
    // Use note on with 0 to turn it off.
    msg =[CMIDIMessage messageWithNoteOn: MIDINote_A440 velocity:0 channel:2];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.type == MIDIMessage_NoteOn);
    CASSERT_RET(msg.velocity == 0);
    CASSERT_RET(msg.noteNumber == MIDINote_A440);
    CASSERT_RET(msg.channel == 2);
    CASSERT_RET(msg.isNoteMessage == YES);
    CASSERT_RET(msg.isNoteOff == YES);
    [channelMessages addObject:msg];
    
    msg = [CMIDIMessage messageWithNoteOff: MIDIPercussionInstrument_AcousticBassDrum releaseVelocity:101 channel:MIDIChannel_Percussion];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.type == MIDIMessage_NoteOff);
    CASSERT_RET(msg.releaseVelocity == 101);
    CASSERT_RET(msg.noteNumber == MIDIPercussionInstrument_AcousticBassDrum);
    CASSERT_RET(msg.channel == MIDIChannel_Percussion);
    CASSERT_RET(msg.isNoteMessage == YES);
    CASSERT_RET(msg.isNoteOff == YES);
    [channelMessages addObject:msg];

    
    msg = [CMIDIMessage messageWithNotePressure: MIDINote_A440 pressure:27 channel:4];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.type == MIDIMessage_NotePressure);
    CASSERT_RET(msg.notePressure == 27);
    CASSERT_RET(msg.noteNumber == MIDINote_A440);
    CASSERT_RET(msg.channel == 4);
    CASSERT_RET(msg.isNoteMessage == YES);
    CASSERT_RET(msg.isNoteOff == NO);
    [channelMessages addObject:msg];
    
    
    msg =[CMIDIMessage messageWithController: MIDIController_ChannelVolume value:27 channel:5];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.type == MIDIMessage_ControlChange);
    CASSERT_RET(msg.controlNumber == MIDIController_ChannelVolume);
    CASSERT_RET(msg.byteValue == 27);
    CASSERT_RET(msg.channel == 5);
    CASSERT_RET(msg.isNoteMessage == NO);
    CASSERT_RET(msg.isNoteOff == NO);
    [channelMessages addObject:msg];
    
    msg =[CMIDIMessage messageWithController: MIDIController_BankSelect value:127 channel:6];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.type == MIDIMessage_ControlChange);
    CASSERT_RET(msg.controlNumber == MIDIController_BankSelect);
    CASSERT_RET(msg.byteValue == 127);
    CASSERT_RET(msg.channel == 6);
    CASSERT_RET(msg.isNoteMessage == NO);
    CASSERT_RET(msg.isNoteOff == NO);
    [channelMessages addObject:msg];
    
    msg =[CMIDIMessage messageWithController: MIDIController_Sustain boolValue:YES channel:7];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.type == MIDIMessage_ControlChange);
    CASSERT_RET(msg.controlNumber == MIDIController_Sustain);
    CASSERT_RET(msg.boolValue == YES);
    CASSERT_RET(msg.channel == 7);
    CASSERT_RET(msg.isNoteMessage == NO);
    CASSERT_RET(msg.isNoteOff == NO);
    [channelMessages addObject:msg];
    
    msg =[CMIDIMessage messageWithController: MIDIController_Sustain boolValue:NO channel:8];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.type == MIDIMessage_ControlChange);
    CASSERT_RET(msg.controlNumber == MIDIController_Sustain);
    CASSERT_RET(msg.boolValue == NO);
    CASSERT_RET(msg.channel == 8);
    CASSERT_RET(msg.isNoteMessage == NO);
    CASSERT_RET(msg.isNoteOff == NO);
    [channelMessages addObject:msg];
    
    msg = [CMIDIMessage messageAllSoundOff: 9];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.type == MIDIMessage_ControlChange);
    CASSERT_RET(msg.controlNumber == MIDIController_Mode_AllSoundOff);
    CASSERT_RET(msg.channel == 9);
    CASSERT_RET(msg.isNoteMessage == NO);
    CASSERT_RET(msg.isNoteOff == NO);
    [channelMessages addObject:msg];
    
    msg = [CMIDIMessage messageWithProgramChange: MIDIProgramNumber_Accordion channel:10];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.type == MIDIMessage_ProgramChange);
    CASSERT_RET(msg.programNumber == MIDIProgramNumber_Accordion);
    CASSERT_RET(msg.channel == 10);
    CASSERT_RET(msg.isNoteMessage == NO);
    CASSERT_RET(msg.isNoteOff == NO);
    [channelMessages addObject:msg];
    
    msg = [CMIDIMessage messageWithChannelPressure: 44 channel:11];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.type == MIDIMessage_ChannelPressure);
    CASSERT_RET(msg.channelPressure == 44);
    CASSERT_RET(msg.channel == 11);
    CASSERT_RET(msg.isNoteMessage == NO);
    CASSERT_RET(msg.isNoteOff == NO);
    [channelMessages addObject:msg];
    
    msg = [CMIDIMessage messageWithChannelPressure: 44 channel:12];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.type == MIDIMessage_ChannelPressure);
    CASSERT_RET(msg.channelPressure == 44);
    CASSERT_RET(msg.channel == 12);
    CASSERT_RET(msg.isNoteMessage == NO);
    CASSERT_RET(msg.isNoteOff == NO);
    [channelMessages addObject:msg];
    
    msg = [CMIDIMessage messageWithPitchWheelValue:430 channel:13];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.type == MIDIMessage_PitchWheel);
    CASSERT_RET(msg.pitchWheelValue == 430);
    CASSERT_RET(msg.channel == 13);
    CASSERT_RET(msg.isNoteMessage == NO);
    CASSERT_RET(msg.isNoteOff == NO);
    [channelMessages addObject:msg];
    
    msg = [CMIDIMessage messageWithPitchWheelValue:MIDIPitchWheel_Min channel:14];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.type == MIDIMessage_PitchWheel);
    CASSERT_RET(msg.pitchWheelValue == MIDIPitchWheel_Min);
    CASSERT_RET(msg.channel == 14);
    CASSERT_RET(msg.isNoteMessage == NO);
    CASSERT_RET(msg.isNoteOff == NO);
    [channelMessages addObject:msg];
    
    msg = [CMIDIMessage messageWithPitchWheelValue:MIDIPitchWheel_Max channel:15];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.type == MIDIMessage_PitchWheel);
    CASSERT_RET(msg.pitchWheelValue == MIDIPitchWheel_Max);
    CASSERT_RET(msg.channel == 15);
    CASSERT_RET(msg.isNoteMessage == NO);
    CASSERT_RET(msg.isNoteOff == NO);
    [channelMessages addObject:msg];
    
    msg = [CMIDIMessage messageWithPitchWheelValue:MIDIPitchWheel_Zero channel:16];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.type == MIDIMessage_PitchWheel);
    CASSERT_RET(msg.pitchWheelValue == MIDIPitchWheel_Zero);
    CASSERT_RET(msg.channel == 16);
    CASSERT_RET(msg.isNoteMessage == NO);
    CASSERT_RET(msg.isNoteOff == NO);
    [channelMessages addObject:msg];
    
    for (msg in channelMessages) {
        CASSERT_RET(msg.isSystemRealTime == NO);
        CASSERT_RET(msg.systemMessageType == MIDISystemMsg_None);
        CASSERT_RET(msg.isSystemRealTime == NO);
        CASSERT_RET(msg.isMeta == NO);
        CASSERT_RET(msg.metaMessageType == MIDIMeta_None);
        CASSERT_RET(msg.isText == NO);
    }
    
    NSMutableArray * systemMessages = [NSMutableArray new];
    
    Byte db[21] = {3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23};
    NSData * d = [NSData dataWithBytes:db length:20];
    
    // Two byte manufacturer ID
    Byte mb[3] = {0,1,2};
    NSData * m = [NSData dataWithBytes:mb length:3];
    
    msg = [CMIDIMessage messageWithSystemExclusiveManufacturer: m andData: d];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.systemMessageType == MIDISystemMsg_SystemExclusive);
    if (!CASSERTEQUAL(d, msg.sysExData)) return NO;
    if (!CASSERTEQUAL(m, msg.sysExManufacturerId)) return NO;
    CASSERT_RET(msg.isSystemRealTime == NO);
    [systemMessages addObject:msg];
    
    // One byte manufacturer ID
    Byte b = 14;
    m = [NSData dataWithBytes:&b length:1];
    
    msg = [CMIDIMessage messageWithSystemExclusiveManufacturer: m andData: d];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.systemMessageType == MIDISystemMsg_SystemExclusive);
    if (!CASSERTEQUAL(d, msg.sysExData)) return NO;
    if (!CASSERTEQUAL(m, msg.sysExManufacturerId)) return NO;
    CASSERT_RET(msg.isSystemRealTime == NO);
    [systemMessages addObject:msg];
    
    msg = [CMIDIMessage messageWithMIDITimeCodeQtrFrame:127];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.systemMessageType == MIDISystemMsg_MIDITimeCodeQtrFrame);
    CASSERT_RET(msg.MTCQuarterframe == 127);
    CASSERT_RET(msg.isSystemRealTime == NO);
    [systemMessages addObject:msg];
    
    msg = [CMIDIMessage messageWithSongPosition:0];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.systemMessageType == MIDISystemMsg_SongPosition);
    CASSERT_RET(msg.songPosition == 0);
    CASSERT_RET(msg.isSystemRealTime == NO);
    [systemMessages addObject:msg];

    // Note: we can only accurately measure song position in sets of 6 clock ticks.
    msg = [CMIDIMessage messageWithSongPosition:6*10];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.systemMessageType == MIDISystemMsg_SongPosition);
    CASSERT_RET(msg.songPosition == 6*10);
    CASSERT_RET(msg.isSystemRealTime == NO);
    [systemMessages addObject:msg];
    
    msg = [CMIDIMessage messageTuneRequest];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.systemMessageType == MIDISystemMsg_TuneRequest);
    CASSERT_RET(msg.isSystemRealTime == NO);
    [systemMessages addObject:msg];
    
    msg = [CMIDIMessage messageTimingClock];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.systemMessageType == MIDISystemMsg_TimingClock);
    CASSERT_RET(msg.isSystemRealTime == YES);
    [systemMessages addObject:msg];
    
    msg = [CMIDIMessage messageStart];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.systemMessageType == MIDISystemMsg_Start);
    CASSERT_RET(msg.isSystemRealTime == YES);
    [systemMessages addObject:msg];
    
    msg = [CMIDIMessage messageContinue];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.systemMessageType == MIDISystemMsg_Continue);
    CASSERT_RET(msg.isSystemRealTime == YES);
    [systemMessages addObject:msg];
    
    msg = [CMIDIMessage messageStop];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.systemMessageType == MIDISystemMsg_Stop);
    CASSERT_RET(msg.isSystemRealTime == YES);
    [systemMessages addObject:msg];
    
    msg = [CMIDIMessage messageActiveSensing];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.systemMessageType == MIDISystemMsg_ActiveSensing);
    CASSERT_RET(msg.isSystemRealTime == YES);
    [systemMessages addObject:msg];
        
    msg = [CMIDIMessage messageSystemReset];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.systemMessageType == MIDISystemMsg_SystemReset);
    CASSERT_RET(msg.isSystemRealTime == YES);
    [systemMessages addObject:msg];
    
    for (msg in systemMessages) {
        CASSERT_RET(msg.type == MIDIMessage_System);
        CASSERT_RET(msg.channel == MIDIChannel_None);
        CASSERT_RET(msg.isNoteMessage == NO);
        CASSERT_RET(msg.isNoteOff == NO);
        CASSERT_RET(msg.isMeta == NO);
        CASSERT_RET(msg.metaMessageType == MIDIMeta_None);
        CASSERT_RET(msg.isText == NO);
    }
    
    NSMutableArray * metaMessages = [NSMutableArray new];
    
    msg = [CMIDIMessage messageWithSequenceNumber: 44];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.metaMessageType == MIDIMeta_SequenceNumber);
    CASSERT_RET(msg.sequenceNumber == 44);
    CASSERT_RET(msg.isText == NO);
    [metaMessages addObject:msg];
    
    msg = [CMIDIMessage messageWithText: @"Text" andType: MIDIMeta_Text];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.metaMessageType == MIDIMeta_Text);
    if (!CASSERTEQUAL(msg.text, @"Text")) return NO;
    CASSERT_RET(msg.isText == YES);
    [metaMessages addObject:msg];
    
    msg = [CMIDIMessage messageWithText: @"Sequence name" andType: MIDIMeta_SequenceName];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.metaMessageType == MIDIMeta_SequenceName);
    if (!CASSERTEQUAL(msg.text, @"Sequence name")) return NO;
    CASSERT_RET(msg.isText == YES);
    [metaMessages addObject:msg];
    
    msg = [CMIDIMessage messageWithText: @"Marker text" andType: MIDIMeta_MarkerText];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.metaMessageType == MIDIMeta_MarkerText);
    if (!CASSERTEQUAL(msg.text, @"Marker text")) return NO;
    CASSERT_RET(msg.isText == YES);
    [metaMessages addObject:msg];

    NSMutableString * longString = [NSMutableString stringWithCapacity:1100];
    for (NSUInteger i = 0; i < 1000; i++) {
        [longString appendFormat:@"%lu", i % 10];
    }
    
    msg = [CMIDIMessage messageWithText: longString andType: MIDIMeta_Text];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.metaMessageType == MIDIMeta_Text);
    CASSERTEQUAL(msg.text, longString);
    CASSERT_RET(msg.isText == YES);
    [metaMessages addObject:msg];
    
    msg = [CMIDIMessage messageWithChannelPrefix:7];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.metaMessageType == MIDIMeta_ChannelPrefix);
    CASSERT_RET(msg.channelPrefix == 7);
    CASSERT_RET(msg.isText == NO);
    [metaMessages addObject:msg];
    
    msg = [CMIDIMessage messageWithPortPrefix: 4];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.metaMessageType == MIDIMeta_PortPrefix);
    CASSERT_RET(msg.portPrefix == 4);
    CASSERT_RET(msg.isText == NO);
    [metaMessages addObject:msg];
    
    msg = [CMIDIMessage messageWithTempoInMicrosecondsPerBeat:600000];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.metaMessageType == MIDIMeta_TempoSetting);
    CASSERT_RET(msg.BPM == 100.0);
    CASSERT_RET(msg.MPB == 600000);
    CASSERT_RET(msg.isText == NO);
    [metaMessages addObject:msg];

    msg = [CMIDIMessage messageWithTempoInBeatsPerMinute:100.0];
   if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.metaMessageType == MIDIMeta_TempoSetting);
    CASSERT_RET(msg.BPM == 100.0);
    CASSERT_RET(msg.MPB == 600000);
    CASSERT_RET(msg.isText == NO);
    [metaMessages addObject:msg];
    
    NSMutableArray * keySignatureMessages = [NSMutableArray new];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_C isMinor:NO];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_C);
    CASSERT_RET(msg.keyNumberOfSharps == 0);
    [keySignatureMessages addObject:msg];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_Db isMinor:NO];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_Db);
    CASSERT_RET(msg.keyNumberOfSharps == -5);
    [keySignatureMessages addObject:msg];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_D isMinor:NO];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_D);
    CASSERT_RET(msg.keyNumberOfSharps == 2);
    [keySignatureMessages addObject:msg];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_Eb isMinor:NO];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_Eb);
    CASSERT_RET(msg.keyNumberOfSharps == -3);
    [keySignatureMessages addObject:msg];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_E isMinor:NO];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_E);
    CASSERT_RET(msg.keyNumberOfSharps == 4);
    [keySignatureMessages addObject:msg];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_F isMinor:NO];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_F);
    CASSERT_RET(msg.keyNumberOfSharps == -1);
    [keySignatureMessages addObject:msg];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_Gb isMinor:NO];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_Gb);
    CASSERT_RET(msg.keyNumberOfSharps == 6);
    [keySignatureMessages addObject:msg];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_G isMinor:NO];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_G);
    CASSERT_RET(msg.keyNumberOfSharps == 1);
    [keySignatureMessages addObject:msg];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_Ab isMinor:NO];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_Ab);
    CASSERT_RET(msg.keyNumberOfSharps == -4);
    [keySignatureMessages addObject:msg];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_A isMinor:NO];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_A);
    CASSERT_RET(msg.keyNumberOfSharps == 3);
    [keySignatureMessages addObject:msg];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_Bb isMinor:NO];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_Bb);
    CASSERT_RET(msg.keyNumberOfSharps == -2);
    [keySignatureMessages addObject:msg];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_B isMinor:NO];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_B);
    CASSERT_RET(msg.keyNumberOfSharps == 5);
    
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_C isMinor:YES];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_C);
    CASSERT_RET(msg.keyNumberOfSharps == -3);
    [keySignatureMessages addObject:msg];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_Db isMinor:YES];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_Db);
    CASSERT_RET(msg.keyNumberOfSharps == 4);
    [keySignatureMessages addObject:msg];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_D isMinor:YES];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_D);
    CASSERT_RET(msg.keyNumberOfSharps == -1);
    [keySignatureMessages addObject:msg];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_Eb isMinor:YES];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_Eb);
    CASSERT_RET(msg.keyNumberOfSharps == 6);
    [keySignatureMessages addObject:msg];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_E isMinor:YES];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_E);
    CASSERT_RET(msg.keyNumberOfSharps == 1);
    [keySignatureMessages addObject:msg];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_F isMinor:YES];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_F);
    CASSERT_RET(msg.keyNumberOfSharps == -4);
    [keySignatureMessages addObject:msg];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_Gb isMinor:YES];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_Gb);
    CASSERT_RET(msg.keyNumberOfSharps == 3);
    [keySignatureMessages addObject:msg];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_G isMinor:YES];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_G);
    CASSERT_RET(msg.keyNumberOfSharps == -2);
    [keySignatureMessages addObject:msg];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_Ab isMinor:YES];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_Ab);
    CASSERT_RET(msg.keyNumberOfSharps == 5);
    [keySignatureMessages addObject:msg];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_A isMinor:YES];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_A);
    CASSERT_RET(msg.keyNumberOfSharps == 0);
    [keySignatureMessages addObject:msg];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_Bb isMinor:YES];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_Bb);
    CASSERT_RET(msg.keyNumberOfSharps == -5);
    [keySignatureMessages addObject:msg];
    msg = [CMIDIMessage messageWithKeySignaturePitchClass:CMIDIPitchClass_B isMinor:YES];
    CASSERT_RET(msg.keyPitchClass == CMIDIPitchClass_B);
    CASSERT_RET(msg.keyNumberOfSharps == 2);
    
    for (msg in keySignatureMessages) {
        CASSERT_RET(msg.metaMessageType == MIDIMeta_KeySignature);
    }
    [metaMessages addObjectsFromArray:keySignatureMessages];
  
    msg = [CMIDIMessage messageWithTimeSignatureNumerator:2 denominator:4];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.metaMessageType == MIDIMeta_TimeSignature);
    CASSERT_RET(msg.numerator == 2);
    CASSERT_RET(msg.denominator == 4);
    CASSERT_RET(msg.eighthsPerBeat == 2);
    CASSERT_RET(msg.beatsPerBar == 2);
    CASSERT_RET(msg.isText == NO);
    [metaMessages addObject:msg];
    
    msg = [CMIDIMessage messageWithBeatsPerBar:2 eighthsPerBeat:2];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.metaMessageType == MIDIMeta_TimeSignature);
    CASSERT_RET(msg.numerator == 2);
    CASSERT_RET(msg.denominator == 4);
    CASSERT_RET(msg.eighthsPerBeat == 2);
    CASSERT_RET(msg.beatsPerBar == 2);
    CASSERT_RET(msg.isText == NO);
    [metaMessages addObject:msg];

    CMIDISMPTEOffset smpte = {1,2,3,4,5};
    msg = [CMIDIMessage messageWithSMPTEOffset: smpte];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.SMPTEOffset.hours == 1);
    CASSERT_RET(msg.SMPTEOffset.minutes == 2);
    CASSERT_RET(msg.SMPTEOffset.seconds == 3);
    CASSERT_RET(msg.SMPTEOffset.frames == 4);
    CASSERT_RET(msg.SMPTEOffset.fractionalFrames == 5);
    CASSERT_RET(msg.isText == NO);
    [metaMessages addObject:msg];
    
    // PUT END OF TRACK LAST
    msg = [CMIDIMessage messageEndOfTrack];
    if (!CCHECK(msg)) return NO;
    CASSERT_RET(msg.metaMessageType == MIDIMeta_EndOfTrack);
    CASSERT_RET(msg.isText == NO);
    [metaMessages addObject:msg];
    
    for (msg in metaMessages) {
        CASSERT_RET(msg.type == MIDIMessage_System);
        CASSERT_RET(msg.systemMessageType == MIDISystemMsg_Meta);
        CASSERT_RET(msg.channel == MIDIChannel_None);
        CASSERT_RET(msg.isNoteMessage == NO);
        CASSERT_RET(msg.isNoteOff == NO);
        CASSERT_RET(msg.isMeta == YES);
    }
    
    // Create a set of examples for other tests to use.
    NSMutableArray * allMessages = [NSMutableArray arrayWithCapacity:
                                    channelMessages.count + systemMessages.count+ metaMessages.count];
    [allMessages addObjectsFromArray:channelMessages];
    [allMessages addObjectsFromArray:systemMessages];
    [allMessages addObjectsFromArray:metaMessages];
    
    for (CMIDIMessage * msg in allMessages) {
        if (!CCHECK_CLASS(msg, CMIDIMessage)) return NO;
    }
    
    // Give them a time, so that sorting will not effect their order.
    NSUInteger i = 0;
    for (CMIDIMessage * msg in allMessages) {
        msg.time = (i++) * 480;
    }
    
    CMIDIMessage_Debug_OneOfEachMessage = allMessages;
    return YES;
}



+ (NSArray *) oneOfEachMessage
{
    if (!CMIDIMessage_Debug_OneOfEachMessage) {
        [self test];
    }
    return CMIDIMessage_Debug_OneOfEachMessage;
}


+ (NSArray *) oneOfEachMessageForFiles
{
    if (!CMIDIMessage_Debug_OneOfEachMessage) {
        [self test];
    }
    NSMutableArray * trimmedMsgs = [NSMutableArray arrayWithCapacity:CMIDIMessage_Debug_OneOfEachMessage.count];
    for (CMIDIMessage * m in CMIDIMessage_Debug_OneOfEachMessage) {
        if (!m.isSystemRealTime ||
            // I'm not sure if these can appear in files, but Apple's MusicSequence will refuse to store these.
            m.systemMessageType == MIDISystemMsg_MIDITimeCodeQtrFrame ||
            m.systemMessageType == MIDISystemMsg_TuneRequest ||
            m.systemMessageType == MIDISystemMsg_SongPosition)
        {
            CMIDIMessage * newMsg = [CMIDIMessage messageWithData:m.data];
            newMsg.time = m.time;
            [trimmedMsgs addObject:newMsg];
        }
    }
    return trimmedMsgs;
}



+ (NSArray *) oneOfEachMessageForRealTime
{
    if (!CMIDIMessage_Debug_OneOfEachMessage) {
        [self test];
    }
    NSMutableArray * trimmedMsgs = [NSMutableArray arrayWithCapacity:CMIDIMessage_Debug_OneOfEachMessage.count];
    for (CMIDIMessage * m in CMIDIMessage_Debug_OneOfEachMessage) {
        if (!m.isMeta) {
               // Don't copy the time
            [trimmedMsgs addObject:[CMIDIMessage messageWithData:m.data]];
        }
    }
    return trimmedMsgs;
}



+ (void) inspectionTest
{
    CDebugInspectionTestHeader("MIDI Message Inspection Test", "Check that all the messages are printed correctly.");

    CMIDITempoMeter * tm = [[CMIDITempoMeter alloc] initWithTicksPerBeat:480];
    tm.timeStringFormat = CMIDITimeString_TimeSignal;
    [CMIDIMessage showHeader:tm];
    for (CMIDIMessage * message in [self oneOfEachMessage]) {
        [message show: tm];
    }
    
    printf("---------------------------------------------------------------------------");
    printf("----------------------------------------------------------------------\n\n\n");
    
    [CMIDIMessage showHeader];
    for (CMIDIMessage * message in [self oneOfEachMessage]) {
        [message show];
    }
    CDebugInspectionTestFooter();
}




@end
#endif
