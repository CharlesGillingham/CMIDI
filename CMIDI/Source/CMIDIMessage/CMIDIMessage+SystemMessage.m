//
//  CMIDIMessage+SystemMessage.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 1/6/14.
//

#import "CMIDIMessage+SystemMessage.h"
#import "CMIDIVSNumber.h"

@implementation CMIDIMessage (SystemMessageAccess)

// -----------------------------------------------------------------------------
#pragma mark            System Message
// -----------------------------------------------------------------------------
@dynamic systemMessageType;

- (UInt8) systemMessageType {
    if (self.type == MIDIMessage_System) {
        return (self.status);
    } else {
        return (MIDISystemMsg_None);
    }
}

- (BOOL) isSystemRealTime
{
    // Have to to check the data length to be sure this isn't a meta message.
    return (self.data.length == 1 && self.status >= MIDISystemMsg_FirstRealTime);
}

// -----------------------------------------------------------------------------
#pragma mark            System Message / System Exclusive
// -----------------------------------------------------------------------------
@dynamic sysExData;
@dynamic sysExManufacturerId;

- (NSUInteger) sysExManufacturerIdByteLength
{
    assert(self.status == MIDISystemMsg_SystemExclusive);
    return (self.byte1 == 0 ? 3 : 1);
}


- (NSData *) sysExManufacturerId
{
    NSUInteger length = [self sysExManufacturerIdByteLength];
    return [NSData dataWithBytes:((Byte *)self.data.bytes + 1) length: length];
}


- (NSData *) sysExData
{
    NSUInteger offset = [self sysExManufacturerIdByteLength]+1;
    NSUInteger length = self.data.length - offset - 1;
    return [NSData dataWithBytes:((Byte *)self.data.bytes+offset) length:length];
}


- (Byte *) sysExDataBytes
{
    // +1 for status byte
    NSUInteger offset = 1 + [self sysExManufacturerIdByteLength];
    return ((Byte *)self.data.bytes+offset);
}


- (NSUInteger) sysExDataBytesLength
{
    // -1 for MIDISystemMsg_EndOfSysEx.
    NSUInteger offset = 1 + [self sysExManufacturerIdByteLength];
    return self.data.length - offset - 1;
}


+ (CMIDIMessage *) messageWithSystemExclusiveManufacturer: (NSData *) m andData: (NSData *) sysExData
{
    NSMutableData * d = [NSMutableData dataWithCapacity: m.length + sysExData.length + 1];
    Byte b = MIDISystemMsg_SystemExclusive;
    [d appendBytes:&b length:1];
    [d appendData:m];
    [d appendData:sysExData];
    
    // Check that EndofSysEx is attached.
    if (((Byte *)sysExData.bytes)[sysExData.length-1] != MIDISystemMsg_EndofSysEx) {
        b = MIDISystemMsg_EndofSysEx;
        [d appendBytes:&b length: 1];
    }
    
    return [CMIDIMessage messageWithData:d];
}


// -----------------------------------------------------------------------------
#pragma mark            System Message / System Common messages / Song position
// -----------------------------------------------------------------------------
// Obscurely, the song position is stored in units of 6 clock ticks. See http://www.blitter.com/~russtopia/MIDI/~jglatt/tech/midispec/ssp.htm. Translate this into a unit we already need elsewhere: clock ticks.

@dynamic songPosition;


+ (CMIDIMessage *) messageWithSongPosition: (CMIDIClockTicks) t
{
    UInt16 v = (t/6);
    Byte buf[3] = {MIDISystemMsg_SongPosition, CMIDIMSBFromUInt16(v), CMIDILSBFromUInt16(v)};
    return [CMIDIMessage messageWithBytes:buf length:3];
}


- (CMIDIClockTicks) songPosition {
    assert(self.status == MIDISystemMsg_SongPosition);
    UInt16 v = CMIDIUInt16FromMSBandLSB(self.byte1, self.byte2);
    return v * 6;
}


// -----------------------------------------------------------------------------
#pragma mark            System Message / System Common messages / MTCQuarterframe
// -----------------------------------------------------------------------------

@dynamic MTCQuarterframe;


+ (CMIDIMessage *) messageWithMIDITimeCodeQtrFrame:(UInt8)v
{
    Byte buf[2] = {MIDISystemMsg_MIDITimeCodeQtrFrame, v};
    return [CMIDIMessage messageWithBytes:buf length:2];
}


- (UInt8) MTCQuarterframe
{
    assert(self.status == MIDISystemMsg_MIDITimeCodeQtrFrame);
    return self.byte1;
}

// -----------------------------------------------------------------------------
#pragma mark            System Message / System Common messages / Song selection
// -----------------------------------------------------------------------------

@dynamic songSelection;

+ (CMIDIMessage *) messageWithSongSelection: (UInt8) songSelection
{
    Byte buf[2] = {MIDISystemMsg_MIDITimeCodeQtrFrame, songSelection};
    return [CMIDIMessage messageWithBytes:buf length:2];
}

- (UInt8) songSelection
{
    assert(self.status == MIDISystemMsg_SongSelection);
    return self.byte1;
    
}

// -----------------------------------------------------------------------------
#pragma mark            System Message / System Real-time messages
// -----------------------------------------------------------------------------

+ (CMIDIMessage *) messageWithByte: (Byte) b { return [CMIDIMessage messageWithBytes:&b length:1]; }

+ (CMIDIMessage *) messageTuneRequest   { return [CMIDIMessage messageWithByte:MIDISystemMsg_TuneRequest]; }
+ (CMIDIMessage *) messageTimingClock   { return [CMIDIMessage messageWithByte:MIDISystemMsg_TimingClock]; }
+ (CMIDIMessage *) messageStart         { return [CMIDIMessage messageWithByte:MIDISystemMsg_Start]; }
+ (CMIDIMessage *) messageContinue      { return [CMIDIMessage messageWithByte:MIDISystemMsg_Continue]; }
+ (CMIDIMessage *) messageStop          { return [CMIDIMessage messageWithByte:MIDISystemMsg_Stop]; }
+ (CMIDIMessage *) messageActiveSensing { return [CMIDIMessage messageWithByte:MIDISystemMsg_ActiveSensing]; }
+ (CMIDIMessage *) messageSystemReset   { return [CMIDIMessage messageWithByte:MIDISystemMsg_SystemReset]; }

@end
