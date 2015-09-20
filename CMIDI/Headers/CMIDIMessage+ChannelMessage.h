//
//  CMIDIMessage+ChannelMessage.h
//  Convenience properties for CMIDIMessages.
//
//  Created by CHARLES GILLINGHAM on 6/10/15.


#import "CMIDIMessage.h"


@interface CMIDIMessage (ChannelMessages)
// -----------------------------------------------------------------------------
#pragma mark            Message access
// -----------------------------------------------------------------------------
@property (readonly) UInt8 channel;                     // type != CMIDIMessage_System
@property (readonly) UInt8 noteNumber;                  // any of the three note messages
@property (readonly) UInt8 velocity;                    // type == CMIDIMessage_NoteOn
@property (readonly) UInt8 releaseVelocity;             // type == CMIDIMessage_NoteOff
@property (readonly) UInt8 notePressure;                // type == CMIDIMessage_NotePressure
@property (readonly) BOOL isNoteMessage;
@property (readonly) BOOL isNoteOff;                    // True if message is Note Off or Note On with velocity = 0.
@property (readonly) UInt8 percussionInstrument;        // note message where channel == MIDIChannel_Percussion
@property (readonly) UInt8 controlNumber;               // type == CMIDIMessage_Controller
@property (readonly) Byte controlType;                  // type == CMIDIMessage_Controller
@property (readonly) UInt8 byteValue;                   //      controlType == CMIDIControlType_Continuous || _Fine
@property (readonly) BOOL boolValue;                    //      controlType == CMIDIControlType_Binary
@property (readonly) UInt8 programNumber;               // type == CMIDIMessage_ProgramChange
@property (readonly) UInt8 channelPressure;             // type == CMIDIMessage_ChannelPressure
@property (readonly) UInt16 pitchWheelValue;            // type == CMIDIMessage_PitchWheel

+ (Byte) controlTypeFromControlNumber: (UInt8) controlNumber;


// -----------------------------------------------------------------------------
#pragma mark            Constructors
// -----------------------------------------------------------------------------
+ (CMIDIMessage *) messageWithNoteOn:  (UInt8) n velocity: (UInt8) v channel: (UInt8) c;
+ (CMIDIMessage *) messageWithNoteOff: (UInt8) n releaseVelocity: (UInt8) v channel: (UInt8) c;
+ (CMIDIMessage *) messageWithNotePressure: (UInt8) n pressure: (UInt8) p channel: (UInt8) c;
+ (CMIDIMessage *) messageWithController: (Byte) control value: (UInt8) v channel: (UInt8) c;
+ (CMIDIMessage *) messageWithController: (Byte) control boolValue: (BOOL) b channel: (UInt8) c;
+ (NSArray *)      messageListWithRPNController: (UInt16) rpn value: (UInt16) v channel: (UInt8) c;
//+ (NSArray *)    messageListToIncrementRPNController: (UInt16) rpn channel: (UInt8) c; (TODO)
//+ (NSArray *)    messageListToDecrementRPNController: (UInt16) rpn channel: (UInt8) c; (TODO)

// Mode messages
+ (CMIDIMessage *) messageAllSoundOff: (UInt8) c;
+ (CMIDIMessage *) messageAllControllersOff: (UInt8) c;
+ (CMIDIMessage *) messageLocalKeyboardOff: (UInt8) c;
+ (CMIDIMessage *) messageAllNotesOff: (UInt8) c;
+ (CMIDIMessage *) messageOmniModeOff: (UInt8) c;
+ (CMIDIMessage *) messageOmniModeOn:  (UInt8) c;
+ (CMIDIMessage *) messageMonoMode:    (UInt8) c;
+ (CMIDIMessage *) messagePolyMode:    (UInt8) c;

+ (CMIDIMessage *) messageWithProgramChange: (UInt8) programNumber channel: (UInt8) c;
+ (CMIDIMessage *) messageWithChannelPressure: (UInt8) pressure channel: (UInt8) c;
+ (CMIDIMessage *) messageWithPitchWheelValue: (UInt16) v channel: (UInt8) c;
@end


// -----------------------------------------------------------------------------
#pragma mark            Constants: Channel messages
// -----------------------------------------------------------------------------
// Values for message.channel

enum {
    MIDIChannel_Min = 1,
    MIDIChannel_Max = 16,
    MIDIChannel_Count = 16
};

// Some special channels
enum {
    MIDIChannel_None            =  0, // The "channel" of a system message.
    MIDIChannel_Percussion      =  10
};


// -----------------------------------------------------------------------------
#pragma mark            Constants: Channel messages / Note Messages / Percussion messages
// -----------------------------------------------------------------------------
// Values for message.note

enum {
    MIDINote_Min = 0,
    MIDINote_Max = 127,
    MIDINote_Count = 128
};

// Some notes
enum {
    MIDINote_MiddleC = 60,
    MIDINote_A440 = 57
};

// Values for message.percussionInstrument
enum {
    MIDIPercussionInstrument_AcousticBassDrum =  35,
    MIDIPercussionInstrument_BassDrum1        =  36,
    MIDIPercussionInstrument_AcousticSnare    =  38,
    MIDIPercussionInstrument_ClosedHiHat      =  42
    
    // ETC -- THERE ARE A LOT MORE.
};


// -----------------------------------------------------------------------------
#pragma mark            Constants: Channel messages / Control Message
// -----------------------------------------------------------------------------
// Value for message.controlType
// These are split up by their function and the type of data they provide

enum {
    CMIDIControllerType_Continuous,  // value = 0..127
    CMIDIControllerType_Fine,        // value = 0..127
    CMIDIControllerType_Binary,      // value = 0 or 127, representing True or False
    CMIDIControllerType_RPN,         // used to define more controllers (see below)
    CMIDIControllerType_Mode,        // value is ignored
    CMIDIControllerType_Undefined    // probably represents an error
};

// The type is defined by the control number:
// 00-19 continuous controllers
// 20-31 undefined
// 32-51 continuous controllers (fine control)
// 52-63 undefined
// 64-69 binary controllers
// 70-83 continuous controllers (sound)
// 85-90 undefined
// 91-95 continuous controllers (effects)
// 96-101 RPN controller messages
// 102-119 undefined
// 120-127 mode messages


// -----------------------------------------------------------------------------
#pragma mark            Constants: Channel messages / Control Message / Continuous controllers
// -----------------------------------------------------------------------------
// values for message.controllerNumber

enum {
    MIDIController_BankSelect       = 0,
    MIDIController_ModulationWheel  = 1,
    MIDIController_BreathControl    = 2,
    MIDIController_Undefined1       = 3,
    MIDIController_FootController   = 4,
    MIDIController_PortamentoTime   = 5, // See also 5,37 and 84
    MIDIController_DataEntry        = 6, // When used with RPN, this controls the last registered parameter.
    MIDIController_ChannelVolume    = 7,
    MIDIController_Balance          = 8,
    MIDIController_Undefined2       = 9,
    MIDIController_Pan              = 10,
    MIDIController_Expression       = 11,
    MIDIController_Effect1          = 12,
    MIDIController_Effect2          = 13,
    MIDIController_Undefined3       = 14,
    MIDIController_Undefined4       = 15,
    MIDIController_GeneralPurpose1  = 16,
    MIDIController_GeneralPurpose2  = 17,
    MIDIController_GeneralPurpose3  = 18,
    MIDIController_GeneralPurpose4  = 19
};


// fine control
// These are numbered strictly in parallel with the main value.
enum {
    MIDIController_FineBankSelect       = 32, // (MIDIController_BankSelect | 0x20)
    MIDIController_FineModulationWheel  = 33, // (MIDIController_ModulationWheel | 0x20)
    MIDIController_FineBreathControl    = 34, // etc.
    MIDIController_FineUndefined1       = 35,
    MIDIController_FineFootController   = 36,
    MIDIController_FinePortamentoTime   = 37,
    MIDIController_FineDataEntry        = 38,
    MIDIController_FineChannelVolume    = 39,
    MIDIController_FineBalance          = 40,
    MIDIController_FineUndefined2       = 41,
    MIDIController_FinePan              = 42,
    MIDIController_FineExpression       = 43,
    MIDIController_FineEffect1          = 44,
    MIDIController_FineEffect2          = 45,
    MIDIController_FineUndefined3       = 46,
    MIDIController_FineUndefined4       = 47,
    MIDIController_FineGeneralPurpose1  = 48,
    MIDIController_FineGeneralPurpose2  = 49,
    MIDIController_FineGeneralPurpose3  = 50,
    MIDIController_FineGeneralPurpose4  = 51
};


// SOUND CONTROLLERS
// sound control
enum {
    MIDIController_SoundVariation       = 70,
    MIDIController_SoundTimbre          = 71,  // AKA "FilterResonance"
    MIDIController_SoundReleaseTime     = 72,
    MIDIController_SoundAttackTime      = 73,
    MIDIController_SoundBrightness      = 74,
    MIDIController_SoundDecayTime       = 75,  // Not sure if 75-79 are GM standard or if they are Apple-specific
    MIDIController_SoundVibratoRate     = 76,  // (they are from AUMIDIDefs.h)
    MIDIController_SoundVibratoDepth    = 77,
    MIDIController_SoundVibratoDelay    = 78,
    MIDIController_SoundController79    = 79,

    // GENERAL PURPOSE (assume continuous)
    MIDIController_GeneralPurpose5      = 80,
    MIDIController_GeneralPurpose6      = 81,
    MIDIController_GeneralPurpose7      = 82,
    MIDIController_GeneralPurpose8      = 83,

    // PORTAMENTO CONTROL
    MIDIController_PortamentoSource     = 84,  // Value is "source note" WHAT DOES THAT MEAN??
    
    // EFFECTS
    MIDIController_ReverbSend           = 91,  // AKA ReverbLevel
    MIDIController_Tremolo              = 92,
    MIDIController_ChorusSend           = 93, // AKA ChorusLevel
    MIDIController_Detune               = 94,
    MIDIController_Celeste              = 95
};


// -----------------------------------------------------------------------------
#pragma mark            Constants: Channel messages / Control Message / Binary Controller
// -----------------------------------------------------------------------------
// Values for message.controllerNumber

enum {
    MIDIController_Sustain          = 64, // AKA "Hold1"
    MIDIController_PortamentoOnOff  = 65, // (see also 5,37 and 84)
    MIDIController_Sostenato        = 66,
    MIDIController_Soft             = 67,
    MIDIController_Legato           = 68,
    MIDIController_Hold2            = 69
};



// -----------------------------------------------------------------------------
#pragma mark            Constants: Channel messages / Control Message / Registered Parameters
// -----------------------------------------------------------------------------
// The "registered parameter" system allows up to 16,384 more virtual controllers.
enum {
    MIDIRPN_PitchBendSensitivity	= 0x0000,
    MIDIRPN_MasterFineTuning		= 0x0001,
    MIDIRPN_MasterCoarseTuning		= 0x0002,
    MIDIRPN_ModDepthRange           = 0x0005
};
// ... there are many, many more ...

enum {
    MIDIRPN_Null					= 0x3fff	//! 0x7f/0x7f (from AUMIDIDefs.h: may be Apple-specific)
};


// Values for message.controllerNumber (These controller numbers should not be needed to send messages normal RPN controllers. The constructors above combine four messages to set an RPN parameter. However, this interface does not currently provide an interface to parse a set of messages and determine the current value of an RPN parameter.
enum {
    MIDIController_RPN_DataEntry_MSB                = 6,
    MIDIController_RPN_DataEntry_LSB                = 38,
    MIDIController_RPN_DataButtonIncrement          = 96,
    MIDIController_RPN_DataButtonDecrement          = 97,
    MIDIController_RPN_NonRegisteredParameter_LSB   = 98,
    MIDIController_RPN_NonRegisteredParameter_MSB   = 99,
    MIDIController_RPN_RegisteredParameter_LSB      = 100,
    MIDIController_RPN_RegisteredParameter_MSB      = 101
};


// -----------------------------------------------------------------------------
#pragma mark            Channel messages / Control Message / Global Control
// -----------------------------------------------------------------------------
// Values for message.controllerNumber; see also the constructors above.
enum {
    MIDIController_Mode_AllSoundOff         = 120,
    MIDIController_Mode_AllControllersOff   = 121,
    MIDIController_Mode_LocalKeyboardOff    = 122,
    MIDIController_Mode_AllNotesOff         = 123
};



// -----------------------------------------------------------------------------
#pragma mark            Constants: Channel messages / Control Message / Channel Mode
// -----------------------------------------------------------------------------
// Values for message.controllerNumber
enum {
    MIDIController_Mode_OmniModeOff	  = 124,
    MIDIController_Mode_OmniModeOn    = 125,
    MIDIController_Mode_MonoOperation = 126,
    MIDIController_Mode_PolyOperation = 127
};



// -----------------------------------------------------------------------------
#pragma mark            Constants: Channel messages / Program Change
// -----------------------------------------------------------------------------

// message.programNumber
enum {
    MIDIProgramNumber_AcousticGrandPiano	= 0,
    MIDIProgramNumber_BrightAcousticPiano	= 1,
    MIDIProgramNumber_ElectricGrandPiano	= 2,
    MIDIProgramNumber_HonkyTonkPiano		= 3,
    MIDIProgramNumber_ElectricPiano1		= 4,
    MIDIProgramNumber_ElectricPiano2		= 5,
    MIDIProgramNumber_Harpsichord           = 6,
    MIDIProgramNumber_Clavinet              = 7,
    
    MIDIProgramNumber_Celesta               = 8,
    MIDIProgramNumber_Glockenspiel          = 9,
    MIDIProgramNumber_MusicBox              = 10,
    MIDIProgramNumber_Vibraphone            = 11,
    MIDIProgramNumber_Marimba               = 12,
    MIDIProgramNumber_Xylophone             = 13,
    MIDIProgramNumber_TubularBells          = 14,
    MIDIProgramNumber_Dulcimer              = 15,
    
    MIDIProgramNumber_DrawbarOrgan          = 16,
    MIDIProgramNumber_PercussiveOrgan		= 17,
    MIDIProgramNumber_RockOrgan             = 18,
    MIDIProgramNumber_ChurchOrgan           = 19,
    MIDIProgramNumber_ReedOrgan             = 20,
    MIDIProgramNumber_Accordion             = 21,
    MIDIProgramNumber_Harmonica             = 22,
    MIDIProgramNumber_TangoAccordion		= 23,
    
    MIDIProgramNumber_AcousticGuitarNylon	= 24,
    MIDIProgramNumber_AcousticGuitarSteel	= 25,
    MIDIProgramNumber_ElectricGuitarJazz	= 26,
    MIDIProgramNumber_ElectricGuitarClean   = 27,
    MIDIProgramNumber_ElectricGuitarMuted   = 28,
    MIDIProgramNumber_OverdrivenGuitar      = 29,
    MIDIProgramNumber_DistortionGuitar      = 30,
    MIDIProgramNumber_GuitarHarmonics       = 31,
    
    MIDIProgramNumber_AcousticBass          = 32,
    MIDIProgramNumber_ElectricBassFinger    = 33,
    MIDIProgramNumber_ElectricBassPick      = 34,
    MIDIProgramNumber_FretlessBass          = 35,
    MIDIProgramNumber_SlapBass1             = 36,
    MIDIProgramNumber_SlapBass2             = 37,
    MIDIProgramNumber_SynthBass1            = 38,
    MIDIProgramNumber_SynthBass2            = 39,
    
    MIDIProgramNumber_Violin                = 40,
    MIDIProgramNumber_Viola                 = 41,
    MIDIProgramNumber_Cello                 = 42,
    MIDIProgramNumber_Contrabass            = 43,
    MIDIProgramNumber_TremoloStrings		= 44,
    MIDIProgramNumber_PizzicatoStrings		= 45,
    MIDIProgramNumber_OrchestralHarp		= 46,
    MIDIProgramNumber_Timpani               = 47,
    MIDIProgramNumber_StringEnsemble1		= 48,
    MIDIProgramNumber_StringEnsemble2		= 49,
    MIDIProgramNumber_SynthStrings1         = 50,
    MIDIProgramNumber_SynthStrings2         = 51,
    MIDIProgramNumber_ChoirAahs             =52,
    MIDIProgramNumber_VoiceOohs             = 53,
    MIDIProgramNumber_SynthChoir            = 54,
    MIDIProgramNumber_OrchestraHit          = 55,
    
    MIDIProgramNumber_Trumpet               = 56,
    MIDIProgramNumber_Trombone              = 57,
    MIDIProgramNumber_Tuba                  = 58,
    MIDIProgramNumber_MutedTrumpet          = 59,
    MIDIProgramNumber_FrenchHorn            = 60,
    MIDIProgramNumber_BrassSection          = 61,
    MIDIProgramNumber_SynthBrass1           = 62,
    MIDIProgramNumber_SynthBrass2           = 63,
    
    MIDIProgramNumber_SopranoSax            = 64,
    MIDIProgramNumber_AltoSax               = 65,
    MIDIProgramNumber_TenorSax              = 66,
    MIDIProgramNumber_BaritoneSax           = 67,
    MIDIProgramNumber_Oboe                  = 68,
    MIDIProgramNumber_EnglishHorn           = 69,
    MIDIProgramNumber_Bassoon               = 70,
    MIDIProgramNumber_Clarinet              = 71,
    MIDIProgramNumber_Piccolo               = 72,
    MIDIProgramNumber_Flute                 = 73,
    MIDIProgramNumber_Recorder              = 74,
    MIDIProgramNumber_PanFlute              = 75,
    MIDIProgramNumber_BlownBottle           = 76,
    MIDIProgramNumber_Shakuhachi            = 77,
    MIDIProgramNumber_Whistle               = 78,
    MIDIProgramNumber_Ocarina               = 79,
    
    MIDIProgramNumber_Lead_1_Square         = 80,
    MIDIProgramNumber_Lead_2_Sawtooth       = 81,
    MIDIProgramNumber_Lead_3_Calliope       = 82,
    MIDIProgramNumber_Lead_4_Chiff          = 83,
    MIDIProgramNumber_Lead_5_Charang        = 84,
    MIDIProgramNumber_Lead_6_Voice          = 85,
    MIDIProgramNumber_Lead_7_Fifths         = 86,
    MIDIProgramNumber_Lead_8_BassAndLead    = 87,
    
    MIDIProgramNumber_Pad_1_Newage          = 88,
    MIDIProgramNumber_Pad_2_Warm            = 89,
    MIDIProgramNumber_Pad_3_Polysynth       = 90,
    MIDIProgramNumber_Pad_4_Choir           = 91,
    MIDIProgramNumber_Pad_5_Bowed           = 92,
    MIDIProgramNumber_Pad_6_Metallic        = 93,
    MIDIProgramNumber_Pad_7_Halo            = 94,
    MIDIProgramNumber_Pad_8_Sweep           = 95,
    
    MIDIProgramNumber_FX_1_Rain             = 96,
    MIDIProgramNumber_FX_2_Soundtrack       = 97,
    MIDIProgramNumber_FX_3_Crystal          = 98,
    MIDIProgramNumber_FX_4_Atmosphere       = 99,
    MIDIProgramNumber_FX_5_Brightness       = 100,
    MIDIProgramNumber_FX_6_Goblins          = 101,
    MIDIProgramNumber_FX_7_Echoes           = 102,
    
    MIDIProgramNumber_FX_8_SciFi            = 103,
    MIDIProgramNumber_Sitar                 = 104,
    MIDIProgramNumber_Banjo                 = 105,
    MIDIProgramNumber_Shamisen              = 106,
    MIDIProgramNumber_Koto                  = 107,
    MIDIProgramNumber_Kalimba               = 108,
    MIDIProgramNumber_Bagpipe               = 109,
    MIDIProgramNumber_Fiddle                = 110,
    MIDIProgramNumber_Shanai                = 111,
    
    MIDIProgramNumber_TinkleBell            = 112,
    MIDIProgramNumber_Agogo                 = 113,
    MIDIProgramNumber_SteelDrums            = 114,
    MIDIProgramNumber_Woodblock             = 115,
    MIDIProgramNumber_TaikoDrum             = 116,
    MIDIProgramNumber_MelodicTom            = 117,
    MIDIProgramNumber_SynthDrum             = 118,
    MIDIProgramNumber_ReverseCymbal         = 119,
    
    MIDIProgramNumber_GuitarFretNoise		= 120,
    MIDIProgramNumber_BreathNoise           = 121,
    MIDIProgramNumber_Seashore              = 122,
    MIDIProgramNumber_BirdTweet             = 123,
    MIDIProgramNumber_TelephoneRing         = 124,
    MIDIProgramNumber_Helicopter            = 125,
    MIDIProgramNumber_Applause              = 126,
    MIDIProgramNumber_Gunshot               = 127
};

enum {
    MIDIProgramNumber_Count                 = 128,
    MIDIProgramNumber_Max                   = 127
};


// -----------------------------------------------------------------------------
#pragma mark            Constants: Channel messages / Pitch wheel
// -----------------------------------------------------------------------------
// See http://home.roadrunner.com/~jgglatt/tech/midispec/wheel.htm

enum {
    MIDIPitchWheel_Min  = 0x0000,
    MIDIPitchWheel_Zero = 0x2000,
    MIDIPitchWheel_Max  = 0x3FFF
};


