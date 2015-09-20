//
//  CMIDIMessageByteCount.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 8/22/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDIMessageByteCount.h"
#import "CMIDIMessage.h"
#import "CMIDIMessage+ChannelMessage.h"
#import "CMIDIMessage+SystemMessage.h"
#import "CMIDIMessage+MetaMessage.h"
#import "CMIDIVSNumber.h"


#define MIDIByteIsData(b)             ((b) < 0x80)


NSUInteger CMIDIMetaMessageByteCount(UInt8 metaMessageType)
{
    NSUInteger len;
    switch (metaMessageType) {
        case MIDIMeta_SequenceNumber: len = 1; break; // CHECK THIS.
        case MIDIMeta_ChannelPrefix:  len = 1; break;
        case MIDIMeta_PortPrefix:     len = 1; break;
        case MIDIMeta_TempoSetting:   len = 3; break;
        case MIDIMeta_KeySignature:   len = 2; break;
        case MIDIMeta_TimeSignature:  len = 4; break;
        case MIDIMeta_SMPTEOffset:    len = 5; break;
        default:                      len = 0; break; // Variable length
    }
    return len;
}



NSUInteger CMIDIMessageByteCount (UInt8 status,
                                          const Byte * data, // data AFTER the status byte
                                          NSUInteger maxLength,
                                          BOOL isFromFile,
                                          OSStatus * errCode)
{
    *errCode = noErr;
    
    UInt8 messageType = (0xF0 & status);
    switch (messageType) {
        case MIDIMessage_NoteOff ... MIDIMessage_ControlChange:
        case MIDIMessage_PitchWheel: {
            return 3;
        }
        case MIDIMessage_ChannelPressure:
        case MIDIMessage_ProgramChange:
            return 2;
            
        case MIDIMessage_System: {
            switch (status) {
                case MIDISystemMsg_SystemExclusive:
                case MIDISystemMsg_SysExContinued: {
                    NSUInteger cnt = 1; // 1 for the status byte
                    for (NSUInteger i = 0; i < maxLength; i++) {
                        Byte b = *(data+i);
                        // Don't count system real time messages that may interrupt the message.
                        if (isFromFile || b < MIDISystemMsg_FirstRealTime) {
                            if (b == MIDISystemMsg_EndofSysEx) {
                                return cnt+1;
                            } else if (MIDIByteIsData(b)) {
                                cnt++;
                            } else {
                                // Error: non-terminated sysex message -- terminated by a status byte of some other message.
                                // Read this many bytes, then recover from the error.
                                return cnt;
                            }
                        }
                    }
                    // Error: non-terminated sysex message -- terminated by the end of data.
                    // Read this many bytes, then recover from the error.
                    return cnt;
                }
                    
                case MIDISystemMsg_SongSelection:
                case MIDISystemMsg_SongPosition:
                    return 3;
                    
                case MIDISystemMsg_MIDITimeCodeQtrFrame:
                    return 2;
                    
                case MIDISystemMsg_TuneRequest:
                case MIDISystemMsg_FirstRealTime...MIDISystemMsg_SystemReset-1:
                    return 1;
                    
                case MIDISystemMsg_SystemReset...MIDISystemMsg_Meta:
                {
                    if (!isFromFile) return 1; // This is MIDISystemMsg_SystemReset, not MIDISystemMsg_Meta
                    
                    CMIDIVSNumber * vs = [CMIDIVSNumber numberWithBytes:data+1 //+1 skip meta Message type.
                                                              maxLength:maxLength-1];
                    if (!vs) {
                        *errCode = CMIDIMessageDataErr_badVariableSizedNumber;
                        return 0; // Fail -- unreadable variable sized number.
                    }
                    
                    // Check that the length given in the vs number is correct.
                    NSUInteger len = CMIDIMetaMessageByteCount(*(data));
                    if (len != 0 && vs.integerValue != len) {
                        *errCode = CMIDIMessageDataErr_badMetaMessageLength;
                        return 0; // Fail -- corrupt or incorrect variable sized number.
                    }
                    
                    return 2 + vs.dataLength + vs.integerValue; //+2 count status & meta message type.
                }
                default:
                    // Fail -- undefined system message.
                    *errCode = CMIDIMessageDataErr_undefinedMessage;
                    return 0;
            }
        }
        default:
            // Fail -- data byte in status position. (Note that this can't happen, because the code above checks before sending it here).
            * errCode = CMIDIMessageDataErr_corrupt;
            return 0;
    }
}

