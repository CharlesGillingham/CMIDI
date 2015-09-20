//
//  CMIDIMessage+SystemMessage.h
//  Convenience properties for CMIDIMessages.
//
//  Created by CHARLES GILLINGHAM on 6/10/15.

#import "CMIDIMessage.h"
#import "CMIDI Time.h"

// -----------------------------------------------------------------------------
#pragma mark            Message access
// -----------------------------------------------------------------------------
// These properties are only defined for messages of the given types

@interface CMIDIMessage (SystemMessageAccess)
@property (readonly) Byte systemMessageType; // type == CMIDIMessage_System
@property (readonly) NSData * sysExManufacturerId;      //      systemMessageType == CMIDISystemMsg_SystemExclusive
@property (readonly) NSData * sysExData;                //      systemMessageType == CMIDISystemMsg_SystemExclusive
@property (readonly) UInt8 MTCQuarterframe;             //      systemMessageType == CMIDISystemMsg_MTCQuarterframe
@property (readonly) CMIDIClockTicks songPosition;      //      systemMessageType == CMIDISystemMsg_SongePosition
@property (readonly) UInt8 songSelection;
@property (readonly) BOOL isSystemRealTime;
@end

// -----------------------------------------------------------------------------
#pragma mark            Constructors
// -----------------------------------------------------------------------------

@interface CMIDIMessage (SystemMessageConstructors)
+ (CMIDIMessage *) messageWithSystemExclusiveManufacturer: (NSData *) m
                                                  andData: (NSData *) d;
+ (CMIDIMessage *) messageWithMIDITimeCodeQtrFrame: (UInt8) v;
+ (CMIDIMessage *) messageWithSongPosition: (CMIDIClockTicks) t;
+ (CMIDIMessage *) messageTuneRequest;
+ (CMIDIMessage *) messageTimingClock;
+ (CMIDIMessage *) messageStart;
+ (CMIDIMessage *) messageContinue;
+ (CMIDIMessage *) messageStop;
+ (CMIDIMessage *) messageActiveSensing;
+ (CMIDIMessage *) messageSystemReset;
@end

// -----------------------------------------------------------------------------
#pragma mark             Constants
// -----------------------------------------------------------------------------
// Values for message.systemMessageType

// System common messages
enum {
    MIDISystemMsg_SystemExclusive      = 0xF0,
    MIDISystemMsg_MIDITimeCodeQtrFrame = 0xF1,
    MIDISystemMsg_SongPosition         = 0xF2,
    MIDISystemMsg_SongSelection        = 0xF3,
    MIDISystemMsg_4_Undefined          = 0xF4,
    MIDISystemMsg_5_Undefined          = 0xF5,
    MIDISystemMsg_TuneRequest          = 0xF6,
    MIDISystemMsg_EndofSysEx           = 0xF7,
    MIDISystemMsg_SysExContinued       = 0xF7 // See note **
};
//  ** MIDISystemMsg_SysExContined == MIDISystemMsg_EndofSysEx, but one can only appear as the first byte of a data packet, and the other is the last byte in a MIDISystemMsg_SystemExclusive.

// System real time message
// These have no data bytes.
enum {
    MIDISystemMsg_TimingClock         = 0xF8,
    MIDISystemMsg_10_Undefined        = 0xF9,
    MIDISystemMsg_Start               = 0xFA,
    MIDISystemMsg_Continue            = 0xFB,
    MIDISystemMsg_Stop                = 0xFC,
    MIDISystemMsg_13_Undefined        = 0xFD,
    MIDISystemMsg_ActiveSensing       = 0xFE,
    MIDISystemMsg_SystemReset         = 0xFF,
    MIDISystemMsg_Meta                = 0xFF // See note **
};
//  ** MIDISystemMsg_SystemReset == MIDISysteMsg_Meta, but one only appears in live streams, and the other only in files.

// Some constants to help navigate the list
enum {
    MIDISystemMsg_First               = 0xF0,
    MIDISystemMsg_FirstRealTime       = 0xF8,
    MIDISystemMsg_Last                = 0xFF,
    
    // Returned by message.systemMessageType if this is not a system message
    MIDISystemMsg_None                = 0x0F
};

