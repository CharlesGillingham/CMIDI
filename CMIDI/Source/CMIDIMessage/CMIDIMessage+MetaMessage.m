//
//  CMIDIMessage+MetaMessage.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 1/6/14.
//

#import "CMIDIMessage+MetaMessage.h"
#import "CMIDIVSNumber.h"
//#import "CDebugMessages.h"

// -----------------------------------------------------------------------------
#pragma mark            Meta Message Access
// -----------------------------------------------------------------------------

@implementation CMIDIMessage (MetaMessages)
@dynamic metaMessageType;

- (UInt8) metaMessageType  {
    if (self.status == MIDISystemMsg_Meta && self.data.length > 1) {
        return self.byte1;
    } else {
        return MIDIMeta_None;
    }
}

// Note that meta messages are indistinguishable from "system reset" messages in a stream, unless we consider the length of the message. This interface maintains all messages in a valid form.
- (BOOL) isMeta
{
    return (self.status == MIDISystemMsg_Meta &&
            self.data.length > 1);
}


- (BOOL) isTimeMessage
{
    return (self.status == MIDISystemMsg_Meta &&
            self.data.length > 1 &&
            (self.byte1 == MIDIMeta_TempoSetting ||
             self.byte1 == MIDIMeta_TimeSignature ||
             self.byte1 == MIDIMeta_SMPTEOffset));
}

// -----------------------------------------------------------------------------
#pragma mark             System Messages / Meta Messages / Meta Data
// -----------------------------------------------------------------------------

+ (CMIDIMessage *) metaMessageWithType: (UInt8) type
                                 bytes: (const void *) p
                                length: (NSUInteger) length
{
    CMIDIVSNumber * vs = [CMIDIVSNumber numberWithInteger: length];
    NSUInteger messageLength = 2 + vs.dataLength + length;
    NSMutableData * d = [NSMutableData dataWithCapacity:messageLength];
    Byte buf[2] = {MIDISystemMsg_Meta, type};
    [d appendBytes: buf length:2];
    [d appendBytes: vs.data length:vs.dataLength];
    [d appendBytes: p length:length];
    
    return [self messageWithData:d];
}


+ (CMIDIMessage *) readMetaMessage: (Byte *) bytes
                         maxLength: (NSUInteger) maxLength
{
    assert(bytes[0] == MIDISystemMsg_Meta);
    
    // If this isn't a meta message, then it must be a system reset, even though this might not make sense.
    if (maxLength < 3) return [CMIDIMessage messageWithBytes:bytes length:1];
    CMIDIVSNumber * vs = [CMIDIVSNumber numberWithBytes: bytes+2 maxLength:maxLength-2];
    NSUInteger messsageLength = 2 + vs.dataLength + vs.integerValue;
    assert(maxLength >= messsageLength);
    
    return [CMIDIMessage messageWithBytes: bytes length: messsageLength];
}


// Used for variable length messages inside this file.
// IMPLEMENTATION NOTE: For variable length messages we need a pointer to the data and the length of the data. We need this variable sized number to get either of them, because the bytes follow the vs number, and thus we need to know the length of the vs number first of all.
- (void) getMetaData: (Byte **) dataPtr length: (NSUInteger *) length
{
    CMIDIVSNumber * vs = [CMIDIVSNumber numberWithBytes:((Byte *)self.data.bytes) + 2
                                              maxLength: self.data.length];
    *dataPtr = (((Byte *)self.data.bytes) + 2 + vs.dataLength);
    *length = vs.integerValue;
}


// -----------------------------------------------------------------------------
#pragma mark             System Messages / Meta Messages / Sequence number
// -----------------------------------------------------------------------------
@dynamic sequenceNumber;

+ (CMIDIMessage *) messageWithSequenceNumber: (NSUInteger) number
{
    NSParameterAssert(number < 128);
    Byte buf[4] = {MIDISystemMsg_Meta, MIDIMeta_SequenceNumber, 1, (UInt8) number};
    return [CMIDIMessage messageWithBytes:buf length:4];
}


- (NSUInteger) sequenceNumber
{
    assert(self.status == MIDISystemMsg_Meta && self.byte1 == MIDIMeta_SequenceNumber);
    return ((UInt8 *) self.data.bytes)[3];
}



// -----------------------------------------------------------------------------
#pragma mark            System Message / Meta Message / Text
// -----------------------------------------------------------------------------
@dynamic text;

+ (CMIDIMessage *) messageWithText:(NSString *)text andType:(Byte)t
{
    NSData * textData = [text dataUsingEncoding:NSUTF8StringEncoding];
    return [self metaMessageWithType:t bytes:textData.bytes length:textData.length];
}


- (NSString *) text {
    NSParameterAssert(self.isText);
    Byte * p;
    NSUInteger length;
    [self getMetaData:&p length:&length];
    return [[NSString alloc] initWithBytes:p length:length encoding:NSASCIIStringEncoding];
}


- (BOOL) isText
{
    return (self.systemMessageType == MIDISystemMsg_Meta &&
            (self.metaMessageType >= MIDIMeta_FirstText &&
             self.metaMessageType <= MIDIMeta_LastText));
}



// -----------------------------------------------------------------------------
#pragma mark             System Messages / Meta Messages / Channel
// -----------------------------------------------------------------------------
// Note that channels in CMIDI are numbered 1 ... 16, thus we add or subtract one here.
@dynamic channelPrefix;

+ (CMIDIMessage *) messageWithChannelPrefix: (UInt8) channel
{
    NSParameterAssert(channel <= 16 && channel > 0);
    Byte buf[4] = {MIDISystemMsg_Meta, MIDIMeta_ChannelPrefix, 1, channel-1};
    return [CMIDIMessage messageWithBytes:buf length: 4];
}

- (UInt8) channelPrefix
{
    NSParameterAssert(self.status == MIDISystemMsg_Meta);
    NSParameterAssert(self.byte1 == MIDIMeta_ChannelPrefix);
    return ((UInt8 *) self.data.bytes)[3] + 1;
}


// -----------------------------------------------------------------------------
#pragma mark             System Messages / Meta Messages / Port
// -----------------------------------------------------------------------------
@dynamic portPrefix;


+ (CMIDIMessage *) messageWithPortPrefix: (UInt8) port
{
    Byte buf[4] = {MIDISystemMsg_Meta, MIDIMeta_PortPrefix, 1, port};
    return [CMIDIMessage messageWithBytes:buf length: 4];
}

- (UInt8) portPrefix
{
    NSParameterAssert(self.status == MIDISystemMsg_Meta && self.byte1 == MIDIMeta_PortPrefix);
    return ((UInt8 *) self.data.bytes)[3];
}



// -----------------------------------------------------------------------------
#pragma mark            System Message / Meta Message / Tempo
// -----------------------------------------------------------------------------
@dynamic BPM;
@dynamic MPB;

/* Note:
 I have from http://home.roadrunner.com/~jgglatt/tech/midifile/ppqn.htm, that a tempo where BPM = 120 is written in MIDI as O7 A1 20.
 
 Mathematica code that tests the code below works:
 (60000000)/120
 {BitShiftRight[ BitAnd[FromDigits["00FF0000", 16] , %], 16],
 BitShiftRight[BitAnd[FromDigits["0000FF00", 16] , %], 8],
 BitAnd[FromDigits["000000FF", 16] , %]}
 IntegerString[%, 16]
 
 this is not what the code does!! to be fixed...
*/

typedef struct CMIDITempo {
    UInt8 byte1;
    UInt8 byte2;
    UInt8 byte3;
} CMIDITempo;

#define microSecondsPerMinute (60000000.0)


+ (CMIDIMessage *) messageWithTempoInMicrosecondsPerBeat:(NSUInteger)MPB
{
    Byte buf[6] = {MIDISystemMsg_Meta, MIDIMeta_TempoSetting, 3,
        (0x00FF0000 & MPB) >> 16,
        (0x0000FF00 & MPB) >> 8,
        (0x000000FF & MPB)};
    return [CMIDIMessage messageWithBytes:buf length:6];
}


- (NSUInteger) MPB
{
    NSParameterAssert(self.status == MIDISystemMsg_Meta && self.byte1 == MIDIMeta_TempoSetting);
    CMIDITempo *tempo = (CMIDITempo *) (((UInt8 *)self.data.bytes) + 3);
    return (((UInt32) tempo->byte1) << 16 | ((UInt32) tempo->byte2) << 8 | tempo->byte3);
}


+ (CMIDIMessage *) messageWithTempoInBeatsPerMinute:(double)BPM
{
    return [CMIDIMessage
            messageWithTempoInMicrosecondsPerBeat:
            ((NSUInteger)round((microSecondsPerMinute)/(BPM)))];
}


- (Float64) BPM
{
    return( (microSecondsPerMinute) / ((Float64) self.MPB) );
}

// -----------------------------------------------------------------------------
#pragma mark            System Message / Meta Message / Key signature
// -----------------------------------------------------------------------------
@dynamic keyNumberOfSharps;
@dynamic keyIsMinor;
@dynamic keyPitchClass;

typedef struct CMIDIKeySignature {
    SInt8 nSharps;          // Negative is number of flats
    UInt8 isMinor;          // Should be set to MIDIKeyMode_Major or MIDIKeyMode_Minor
} CMIDIKeySignature;

#define	MIDIKeyMode_Major 0
#define MIDIKeyMode_Minor 1

// A little elementary music theory (not using code in Music.h to keep this independent).
UInt8 CMIDIMetaMessage_PitchClassFromNSharps_Major[15] = {11,6,1,8,3,10,5,0,7,2,9,4,11,6,1};
UInt8 CMIDIMetaMessage_PitchClassFromNSharps_Minor[15] = {8,3,10,5,0,7,2,9,4,11,6,1,8,3,10};
SInt8 CMIDIMetaMessage_NSharpsFromPitchClass_Major[12] = {0,-5,2,-3,4,-1,6,1,-4,3,-2,5};
SInt8 CMIDIMetaMessage_NSharpsFromPitchClass_Minor[12] = {-3,4,-1,6,1,-4,3,-2,5,0,-5,2};


+ (CMIDIMessage *) messageWithKeySignatureNumberOfSharps:(UInt8)nSharps isMinor:(BOOL)isMinor
{
    Byte buf[5] = {
        MIDISystemMsg_Meta, MIDIMeta_KeySignature, 2,
        nSharps, (isMinor ? MIDIKeyMode_Minor : MIDIKeyMode_Major)
    };
    return [CMIDIMessage messageWithBytes:buf length:5];
}


+ (CMIDIMessage *) messageWithKeySignaturePitchClass:(UInt8) pitchClass isMinor:(BOOL) isMinor
{
    SInt8 nSharps;
    if (isMinor) {
        nSharps = CMIDIMetaMessage_NSharpsFromPitchClass_Minor[pitchClass];
    } else {
        nSharps = CMIDIMetaMessage_NSharpsFromPitchClass_Major[pitchClass];
    }
    return [CMIDIMessage messageWithKeySignatureNumberOfSharps: nSharps isMinor: isMinor];
}


- (CMIDIKeySignature *) keySignature
{
    NSParameterAssert(self.status == MIDISystemMsg_Meta && self.byte1 == MIDIMeta_KeySignature);
    return (CMIDIKeySignature *) (((UInt8 *)self.data.bytes) + 3);
}


- (SInt8) keyNumberOfSharps
{
    return self.keySignature->nSharps;
}


- (UInt8) keyPitchClass
{
    CMIDIKeySignature * ks = self.keySignature;
    if (ks->isMinor) {
        return CMIDIMetaMessage_PitchClassFromNSharps_Minor[ks->nSharps + 7];
    } else {
        return CMIDIMetaMessage_PitchClassFromNSharps_Major[ks->nSharps + 7];
    }
}


- (BOOL) keyIsMinor
{
    return (self.keySignature->isMinor == MIDIKeyMode_Major ? NO : YES);
}



// -----------------------------------------------------------------------------
#pragma mark             System Messages / Meta Messages / Time signature
// -----------------------------------------------------------------------------
@dynamic numerator;
@dynamic denominatorPower;
@dynamic denominator;

typedef struct MIDITimeSignature {
    UInt8 numerator;
    UInt8 denominatorPower; // real denominator = 2^(denominatorPower)
    UInt8 ctpb;             // MIDI clock ticks per beat.
    UInt8 tsnp24ct;         // Thirty-Second notes per beat, if beat = 24 MIDI clock ticks. 8 is normal.
} MIDITimeSignature;


+ (CMIDIMessage *) messageWithTimeSignatureNumerator:(UInt8)numerator denominator:(UInt8)denominator
{
    UInt8 denominatorPower = (UInt8)(log2(denominator));
    
    Byte buf[7] = {
        MIDISystemMsg_Meta, MIDIMeta_TimeSignature, 4,
        numerator, denominatorPower, 24, 8
    };
    return [CMIDIMessage messageWithBytes:buf length:7];
}


+ (CMIDIMessage *) messageWithBeatsPerBar:(UInt8)beatsPerBar
                           eighthsPerBeat:(UInt8)eighthsPerBeat
{
    UInt8 numerator, denominatorPower, thirtySecondsPerBeat, ticksPerBeat;
    if (eighthsPerBeat == 3) { // e.g. 2:3 => 6/8, 3:3 => 9/8 4:3 => 12/8
        numerator = beatsPerBar * 3;
        denominatorPower = 3; // denominator == 8
    } else {
        numerator = beatsPerBar;
        denominatorPower = 2; // denominator == 4
    }
    thirtySecondsPerBeat = eighthsPerBeat * 4;
    ticksPerBeat = 24; // Does any application ever looks at this value?
    
    Byte buf[7] = {
        MIDISystemMsg_Meta, MIDIMeta_TimeSignature, 4,
        numerator, denominatorPower, ticksPerBeat, thirtySecondsPerBeat
    };
    return [CMIDIMessage messageWithBytes:buf length:7];
}


- (MIDITimeSignature *) timeSignature
{
    NSParameterAssert(self.status == MIDISystemMsg_Meta && self.metaMessageType == MIDIMeta_TimeSignature);
    return (MIDITimeSignature *) (((UInt8 *)self.data.bytes) + 3);
}


- (UInt8) numerator
{
    return self.timeSignature->numerator;
}


- (UInt8) denominatorPower {
    return (self.timeSignature->denominatorPower);
}


- (NSUInteger) denominator {
    return (((NSUInteger) 1) << self.timeSignature->denominatorPower);
}


- (UInt8) eighthsPerBeat
{
    if (self.denominatorPower == 3) { // denominator == 8
        return 3;
    } else {
        return 2;
    }
}


- (UInt8) beatsPerBar
{
    if (self.timeSignature->denominatorPower == 3) { // denominator == 8
#ifdef DEBUG
        if (self.timeSignature->numerator % 3 != 0) {
            printf("Strange time signature numerator detected: %d/%lu",self.numerator,self.denominator);
        }
#endif
        return self.timeSignature->numerator/3;
    } else {
        return self.timeSignature->numerator;
    }
}


// -----------------------------------------------------------------------------
#pragma mark             System Messages / Meta Messages / Key signature
// -----------------------------------------------------------------------------
@dynamic SMPTEOffset;

+ (CMIDIMessage *) messageWithSMPTEOffset:(CMIDISMPTEOffset)offset
{
    Byte buf[8] = {MIDISystemMsg_Meta, MIDIMeta_SMPTEOffset, 5,
        offset.hours, offset.minutes, offset.seconds, offset.frames, offset.fractionalFrames};
    return [CMIDIMessage messageWithBytes:buf length:8];
}


- (CMIDISMPTEOffset) SMPTEOffset {
    assert(self.status == MIDISystemMsg_Meta && self.byte1 == MIDIMeta_SMPTEOffset);
    return *(CMIDISMPTEOffset *)(((UInt8 *)self.data.bytes) + 3);
}


// -----------------------------------------------------------------------------
#pragma mark             System Messages / Meta Messages / Sequencer event
// -----------------------------------------------------------------------------
// NOT IMPLEMENTED

+ (CMIDIMessage *) messageWithSequencerEventManufacturer: (NSData *) manufacturerId
                                                 andData: (NSData *) data
{
    NSAssert(NO,@"NOT IMPLEMENTED");
    return nil;
}


// -----------------------------------------------------------------------------
#pragma mark            Meta Messages Constructors
// -----------------------------------------------------------------------------

+ (CMIDIMessage *) messageEndOfTrack
{
    Byte buf[3] = {MIDISystemMsg_Meta, MIDIMeta_EndOfTrack, 0};
    return [CMIDIMessage messageWithBytes:buf length: 3];
}


@end

