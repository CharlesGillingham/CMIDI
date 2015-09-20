//
//  CMIDIMessage+MetaMessage.h
//  Convenience properties for CMIDIMessages.
//
//  Created by CHARLES GILLINGHAM on 6/10/15.

#import "CMIDIMessage.h"
#import "CMIDIMessage+SystemMessage.h"


typedef struct CMIDISMPTEOffset {
    UInt8 hours;
    UInt8 minutes;
    UInt8 seconds;
    UInt8 frames;
    UInt8 fractionalFrames;  // Cents of a frame
} CMIDISMPTEOffset;


@interface CMIDIMessage (MetaMessages)
// -----------------------------------------------------------------------------
#pragma mark            Message access
// -----------------------------------------------------------------------------
// These properties are only defined for messages of the given types
@property (readonly) Byte metaMessageType;
@property (readonly) BOOL isMeta;
@property (readonly) BOOL isTimeMessage;
@property (readonly) NSUInteger sequenceNumber;    // metaMessageType == CMIDIMeta_SequenceNumber
@property (readonly) NSString * text;              // metaMessageType is one of the 16 type of meta text messages.
@property (readonly) BOOL isText;
@property (readonly) UInt8 channelPrefix;          // metaMessageType == CMIDIMeta_channelPrefix
@property (readonly) UInt8 portPrefix;             // metaMessageType == CMIDIMeta_portPrefix
                                                   // metaMessageType == CMIDIMeta_TempoSetting
@property (readonly) NSUInteger MPB;                    // native format (microseconds per beat)
@property (readonly) Float64 BPM;                       // common format (beats per minute)  WARNING: can have floating point errors.
@property (readonly) CMIDISMPTEOffset SMPTEOffset; // metaMessageType == CMIDIMeta_SMPTEOffset
                                                   // metaMessageType == CMIDIMeta_TimeSignature
@property (readonly) UInt8 numerator;                   // native format & common format
@property (readonly) UInt8 denominatorPower;            // native format
@property (readonly) NSUInteger denominator;            // common format
@property (readonly) UInt8 beatsPerBar;                 // useful format
@property (readonly) UInt8 eighthsPerBeat;              // useful format
                                                   // metaMessageType == CMIDIMeta_KeySignature
@property (readonly) SInt8 keyNumberOfSharps;           // native format (negatives are number of flats)
@property (readonly) BOOL  keyIsMinor;                  // native format
@property (readonly) UInt8 keyPitchClass;               // common format
//@property NSData * sequencerEventManufacturerId; // metaMessageType == CMIDIMeta_SequencerEvent
//@property NSData * sequencerEventData;

// -----------------------------------------------------------------------------
#pragma mark            Constructors
// -----------------------------------------------------------------------------

+ (CMIDIMessage *) messageWithSequenceNumber: (NSUInteger) sequenceNumber;
+ (CMIDIMessage *) messageWithText: (NSString *) text andType: (Byte) t;
+ (CMIDIMessage *) messageWithChannelPrefix: (UInt8) channel;
+ (CMIDIMessage *) messageWithPortPrefix: (UInt8) port;
+ (CMIDIMessage *) messageEndOfTrack;
+ (CMIDIMessage *) messageWithTempoInMicrosecondsPerBeat: (NSUInteger) MPB;
+ (CMIDIMessage *) messageWithTempoInBeatsPerMinute: (double) BPM;
+ (CMIDIMessage *) messageWithSMPTEOffset: (CMIDISMPTEOffset) offset;
+ (CMIDIMessage *) messageWithTimeSignatureNumerator: (UInt8) numerator
                                         denominator: (UInt8) denominator;
+ (CMIDIMessage *) messageWithBeatsPerBar: (UInt8) beatsPerBar
                           eighthsPerBeat: (UInt8) eighthsPerBeat;
+ (CMIDIMessage *) messageWithKeySignatureNumberOfSharps: (UInt8) nSharps
                                                 isMinor: (BOOL) isMinor;
+ (CMIDIMessage *) messageWithKeySignaturePitchClass:(UInt8) pitchClass
                                             isMinor:(BOOL) isMinor;
//+ (CMIDIMessage *) messageSequenceEventWithManufacturerId: (NSData *) m andData: (NSData *) data;

// Read a MIDI meta message from a data stream. Called from CMIDIData.m
+ (CMIDIMessage *) readMetaMessage: (Byte *) bytes
                         maxLength: (NSUInteger) maxLength;

// Called externally only when we load Apple's MusicSequence.
// Called internally to create meta text messages.
+ (CMIDIMessage *) metaMessageWithType: (UInt8) type
                                 bytes: (const void *) p
                                length: (NSUInteger) length;
@end





// -----------------------------------------------------------------------------
#pragma mark             Constants: System Messages / Meta Messages
// -----------------------------------------------------------------------------
// values for messages.metaMessageType

// (Based on
// http://253.ccarh.org/handout/smf/
// http://www.omega-art.com/midi/mfiles.html
// This exhausts the Meta event types in these documents.


enum {
    MIDIMeta_Text            =    1,
    MIDIMeta_Copyright       =    2,
    MIDIMeta_SequenceName    =    3,   // Or "track name"
    MIDIMeta_InstrumentName  =    4,
    MIDIMeta_LyricText       =    5,
    MIDIMeta_MarkerText      =    6,
    MIDIMeta_CuePoint        =    7,
    MIDIMeta_UndefinedText1  = 0x08,
    MIDIMeta_UndefinedText2  = 0x09,
    MIDIMeta_UndefinedText3  = 0x0A, // 10
    MIDIMeta_UndefinedText4  = 0x0B, // 11
    MIDIMeta_UndefinedText5  = 0x0C, // 12
    MIDIMeta_UndefinedText6  = 0x0D, // 13
    MIDIMeta_UndefinedText7  = 0x0E, // 14
    MIDIMeta_UndefinedText8  = 0x0F  // 15
};

enum {
    MIDIMeta_FirstText       = MIDIMeta_Text,
    MIDIMeta_LastText        = MIDIMeta_UndefinedText8
};

enum {
    MIDIMeta_SequenceNumber  = 0x00,
    MIDIMeta_ChannelPrefix   = 0x20,
    MIDIMeta_PortPrefix      = 0x21,
    MIDIMeta_EndOfTrack      = 0x2F,
    MIDIMeta_TempoSetting    = 0x51,
    MIDIMeta_SMPTEOffset     = 0x54,
    MIDIMeta_TimeSignature   = 0x58,
    MIDIMeta_KeySignature    = 0x59,
    MIDIMeta_SequencerEvent  = 0x7F
};


// Returned by message.metaMessageType if this is not a meta message.
enum {
    MIDIMeta_None            = 0xFF
};


// -----------------------------------------------------------------------------
#pragma mark             Constants: System Messages / Meta Messages / Key Signature
// -----------------------------------------------------------------------------

enum {
    CMIDIPitchClass_C  = 0,
    CMIDIPitchClass_Db = 1,
    CMIDIPitchClass_D  = 2,
    CMIDIPitchClass_Eb = 3,
    CMIDIPitchClass_E  = 4,
    CMIDIPitchClass_F  = 5,
    CMIDIPitchClass_Gb = 6,
    CMIDIPitchClass_G  = 7,
    CMIDIPitchClass_Ab = 8,
    CMIDIPitchClass_A  = 9,
    CMIDIPitchClass_Bb = 10,
    CMIDIPitchClass_B  = 11
};




