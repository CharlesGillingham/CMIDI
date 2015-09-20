//
//  CMIDIMessage+Description.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 1/9/14.
//

#import "CMIDIMessage.h"
#import "CMIDIMessage+ChannelMessage.h"
#import "CMIDIMessage+SystemMessage.h"
#import "CMIDIMessage+MetaMessage.h"
#import "CMIDIMessage+Description.h"
#include "string.h"


#define CMIDIMessageNameStringMaxLength  (40)
#define CMIDIMessageDetailOffset         (16)

//--------------------------------------------------------------------------------------
// MESSAGE NAME
//--------------------------------------------------------------------------------------

const char MIDIControllerNames[128][CMIDIMessageNameStringMaxLength+4] = {
    "Controller: 000 Bank select",
    "Controller: 001 Modulation wheel",
    "Controller: 002 Breath Control",
    "Controller: 003 Undefined",
    "Controller: 004 Foot controller",
    "Controller: 005 Portamento time",
    "Controller: 006 Data Entry",
    "Controller: 007 Volume",
    "Controller: 008 Balance",
    "Controller: 009 Undefined",
    "Controller: 010 Pan",
    "Controller: 011 Expression",
    "Controller: 012 Effect control 1",
    "Controller: 013 Effect control 2",
    "Controller: 014 Undefined",
    "Controller: 015 Undefined",
    "Controller: 016 General Purpose Controller",
    "Controller: 017 General Purpose Controller",
    "Controller: 018 General Purpose Controller",
    "Controller: 019 General Purpose Controller",
    "Controller: 020 Undefined",
    "Controller: 021 Undefined",
    "Controller: 022 Undefined",
    "Controller: 023 Undefined",
    "Controller: 024 Undefined",
    "Controller: 025 Undefined",
    "Controller: 026 Undefined",
    "Controller: 027 Undefined",
    "Controller: 028 Undefined",
    "Controller: 029 Undefined",
    "Controller: 030 Undefined",
    "Controller: 031 Undefined",
    "Controller: 000|0x20 Fine Bank select",
    "Controller: 001|0x20 Fine Modulation wheel",
    "Controller: 002|0x20 Fine Breath Control",
    "Controller: 003|0x20 Fine Undefined",
    "Controller: 004|0x20 Fine Foot controller",
    "Controller: 005|0x20 Fine Portamento time",
    "Controller: 006|0x20 Fine Data Entry",
    "Controller: 007|0x20 Fine Volume",
    "Controller: 008|0x20 Fine Balance",
    "Controller: 009|0x20 Fine Undefined",
    "Controller: 010|0x20 Fine Pan",
    "Controller: 011|0x20 Fine Expression",
    "Controller: 012|0x20 Fine Effect control 1",
    "Controller: 013|0x20 Fine Effect control 2",
    "Controller: 014|0x20 Fine Undefined",
    "Controller: 015|0x20 Fine Undefined",
    "Controller: 016|0x20 Fine General Purpose",
    "Controller: 017|0x20 Fine General Purpose",
    "Controller: 018|0x20 Fine General Purpose", // 50
    "Controller: 019|0x20 Fine General Purpose",
    "Controller: 020|0x20 Fine Undefined",
    "Controller: 021|0x20 Fine Undefined",
    "Controller: 022|0x20 Fine Undefined",
    "Controller: 023|0x20 Fine Undefined",
    "Controller: 024|0x20 Fine Undefined",
    "Controller: 025|0x20 Fine Undefined",
    "Controller: 026|0x20 Fine Undefined",
    "Controller: 027|0x20 Fine Undefined",
    "Controller: 028|0x20 Fine Undefined", // 60
    "Controller: 029|0x20 Fine Undefined",
    "Controller: 030|0x20 Fine Undefined",
    "Controller: 031|0x20 Fine Undefined",
    "Controller: 064 Sustain",
    "Controller: 065 Portamento",
    "Controller: 066 Sostenato",
    "Controller: 067 Soft Pedal",
    "Controller: 068 Legato",
    "Controller: 069 Hold 2",
    "Controller: 070 Sound variation", // 70
    "Controller: 071 Sound timbre",
    "Controller: 072 Sound release time",
    "Controller: 073 Sound attack time",
    "Controller: 074 Sound brightness",
    "Controller: 075 Sound decay time",
    "Controller: 076 Sound vibrato rate",
    "Controller: 077 Sound vibrato depth",
    "Controller: 078 Sound vibrato delay",
    "Controller: 079 Sound (undefined)",
    "Controller: 080 Sound: General purpose",
    "Controller: 081 Sound: General purpose",
    "Controller: 082 Sound: General purpose",
    "Controller: 083 Sound: General purpose",
    "Controller: 084 Sound: General purpose",
    "Controller: 085 Portamento source",
    "Controller: 086 Undefined",
    "Controller: 087 Undefined",
    "Controller: 088 Undefined",
    "Controller: 089 Undefined",
    "Controller: 090 Undefined",
    "Controller: 091 Reverb send",
    "Controller: 092 Termolo",
    "Controller: 093 Chorus send",
    "Controller: 094 Detune",
    "Controller: 095 Celeste",
    "Controller: 096 Data button increment",
    "Controller: 097 Data button decrement",
    "Controller: 098 RPN NonRegisteredParam LSB",
    "Controller: 099 RPN NonRegisteredParam MSB",
    "Controller: 100 RPN RegisteredParameter LSB",
    "Controller: 101 RPN RegisteredParameter MSB",
    "Controller: 102 Undefined",
    "Controller: 103 Undefined",
    "Controller: 104 Undefined",
    "Controller: 105 Undefined",
    "Controller: 106 Undefined",
    "Controller: 107 Undefined",
    "Controller: 108 Undefined",
    "Controller: 109 Undefined",
    "Controller: 110 Undefined",
    "Controller: 111 Undefined",
    "Controller: 112 Undefined",
    "Controller: 113 Undefined",
    "Controller: 114 Undefined",
    "Controller: 115 Undefined",
    "Controller: 116 Undefined",
    "Controller: 117 Undefined",
    "Controller: 118 Undefined",
    "Controller: 119 Undefined",
    "Mode:       120 All sound off",
    "Mode:       121 All controllers off",
    "Mode:       122 Local keyboard on/off",
    "Mode:       123 All notes off",
    "Mode:       124 Omni off",
    "Mode:       125 Omni",
    "Mode:       126 Mono",
    "Mode:       127 Poly"  // 127
};

// These are the names given for the General MIDI Level 1 Sound Set
// See http://www.midi.org/techspecs/gm1sound.php

const char MIDIProgramNames[128][CMIDIMessageNameStringMaxLength] = {
    "Program:    000 Acoustic Grand Piano",    // Piano
    "Program:    001 Bright Acoustic Piano",
    "Program:    002 Electric Grand Piano",
    "Program:    003 Honky-tonk Piano",
    "Program:    004 Electric Piano 1",
    "Program:    005 Electric Piano 2",
    "Program:    006 Harpsichord",
    "Program:    007 Clavinet",
    "Program:    008 Celesta",                // Chromatic percussion
    "Program:    009 Glockenspiel",
    "Program:    010 Music Box",
    "Program:    011 Vibraphone",
    "Program:    012 Marimba",
    "Program:    013 Xylophone",
    "Program:    014 Tubular Bells",
    "Program:    015 Dulcimer",
    "Program:    016 Drawbar Organ",          // Organ
    "Program:    017 Percussive Organ",
    "Program:    018 Rock Organ",
    "Program:    019 Church Organ",
    "Program:    020 Reed Organ",
    "Program:    021 Accordion",
    "Program:    022 Harmonica",
    "Program:    023 Tango Accordion",
    "Program:    024 Acoustic Guitar (nylon)", // Guitar
    "Program:    025 Acoustic Guitar (steel)",
    "Program:    026 Electric Guitar (jazz)",
    "Program:    027 Electric Guitar (clean)",
    "Program:    028 Electric Guitar (muted)",
    "Program:    029 Overdriven Guitar",
    "Program:    030 Distortion Guitar",
    "Program:    031 Guitar Harmonics",
    "Program:    032 Acoustic Bass",           // Bass
    "Program:    033 Electric Bass (finger)",
    "Program:    034 Electric Bass (pick)",
    "Program:    035 Fretless Bass",
    "Program:    036 Slap Bass 1",
    "Program:    037 Slap Bass 2",
    "Program:    038 Synth Bass 1",
    "Program:    039 Synth Bass 2",
    "Program:    040 Violin",                  // Strings
    "Program:    041 Viola",
    "Program:    042 Cello",
    "Program:    043 Contrabass",
    "Program:    044 Tremolo Strings",
    "Program:    045 Pizzicato Strings",
    "Program:    046 Orchestral Harp",
    "Program:    047 Timpani",
    "Program:    048 String Ensemble 1",       // Ensemble
    "Program:    049 String Ensemble 2",
    "Program:    050 Synth Strings 1",
    "Program:    051 Synth Strings 2",
    "Program:    052 Choir Aahs",
    "Program:    053 Voice Oohs",
    "Program:    054 Synth Choir",
    "Program:    055 Orchestra Hit",
    "Program:    056 Trumpet",                 // Brass
    "Program:    057 Trombone",
    "Program:    058 Tuba",
    "Program:    059 Muted Trumpet",
    "Program:    060 French Horn",
    "Program:    061 Brass Section",
    "Program:    062 Synth Brass 1",
    "Program:    063 Synth Brass 2",
    "Program:    064 Soprano Sax",             // Reeds
    "Program:    065 Alto Sax",
    "Program:    066 Tenor Sax",
    "Program:    067 Baritone Sax",
    "Program:    068 Oboe",
    "Program:    069 English Horn",
    "Program:    070 Bassoon",
    "Program:    071 Clarinet",
    "Program:    072 Piccolo",                 // Pipe
    "Program:    073 Flute",
    "Program:    074 Recorder",
    "Program:    075 Pan Flute",
    "Program:    076 Blown Bottle",
    "Program:    077 Shakuhachi",
    "Program:    078 Whistle",
    "Program:    079 Ocarina",
    "Program:    080 Lead 1 (square)",         // Synth lead
    "Program:    081 Lead 2 (sawtooth)",
    "Program:    082 Lead 3 (calliope)",
    "Program:    083 Lead 4 (chiff)",
    "Program:    084 Lead 5 (charang)",
    "Program:    085 Lead 6 (voice)",
    "Program:    086 Lead 7 (fifths)",
    "Program:    087 Lead 8 (bass + lead)",
    "Program:    088 Pad 1 (new age)",         // Synth Pads
    "Program:    089 Pad 2 (warm)",
    "Program:    090 Pad 3 (polysynth)",
    "Program:    091 Pad 4 (choir)",
    "Program:    092 Pad 5 (bowed)",
    "Program:    093 Pad 6 (metallic)",
    "Program:    094 Pad 7 (halo)",
    "Program:    095 Pad 8 (sweep)",
    "Program:    096 FX 1 (rain)",             // Synth Effects
    "Program:    097 FX 2 (soundtrack)",
    "Program:    098 FX 3 (crystal)",
    "Program:    099 FX 4 (atmosphere)",
    "Program:    100 FX 5 (brightness)",
    "Program:    101 FX 6 (goblins)",
    "Program:    102 FX 7 (echoes)",
    "Program:    103 FX 8 (sci-fi)",
    "Program:    104 Sitar",                   // Ethnic
    "Program:    105 Banjo",
    "Program:    106 Shamisen",
    "Program:    107 Koto",
    "Program:    108 Kalimba",
    "Program:    109 Bagpipe",
    "Program:    110 Fiddle",
    "Program:    111 Shanai",
    "Program:    112 Tinkle Bell",             // Percussive
    "Program:    113 Agogo",
    "Program:    114 Steel Drums",
    "Program:    115 Woodblock",
    "Program:    116 Taiko Drum",
    "Program:    117 Melodic Tom",
    "Program:    118 Synth Drum",
    "Program:    119 Reverse Cymbal",          // Sound effects
    "Program:    120 Guitar Fret Noise",
    "Program:    121 Breath Noise",
    "Program:    122 Seashore",
    "Program:    123 Bird Tweet",
    "Program:    124 Telephone Ring",
    "Program:    125 Helicopter",
    "Program:    126 Applause",
    "Program:    127 Gunshot"
};



const char MIDISystemMessageNames[16][CMIDIMessageNameStringMaxLength+1] = {
    "System:     000 System Exclusive",
    "System:     001 MIDI Time Code Qtr Frame",
    "System:     002 Song Position Pointer",
    "System:     003 Song Select",
    "System:     004 Undefined1",
    "System:     005 Undefined2",
    "System:     006 Tune Request",
    "System:     007 End of System Exclusive",
    "System:     008 Timing Clock",
    "System:     009 Timing Tick",
    "System:     010 Start",
    "System:     011 Continue",
    "System:     012 Stop",
    "System:     013 Undefined4",
    "System:     014 Active Sensing",
    "System:     015 Reset"
};



const char MIDIMetaMessageNames[128][CMIDIMessageNameStringMaxLength] = {
    "Meta:       x00 Sequence number",
    "Meta:       x01 Text",
    "Meta:       x02 Copyright",
    "Meta:       x03 Sequence or track name",
    "Meta:       x04 Instrument name",
    "Meta:       x05 Lyric",
    "Meta:       x06 Marker text",
    "Meta:       x07 Cue point text",
    "Meta:       x08 Undefined text",
    "Meta:       x09 Undefined text",
    "Meta:       x0A Undefined text (10)",
    "Meta:       x0B Undefined text (11)",
    "Meta:       x0C Undefined text (12)",
    "Meta:       x0D Undefined text (13)",
    "Meta:       x0E Undefined text (14)",
    "Meta:       x0F Undefined text (15)",
    "Meta:       x10 Undefined",
    "Meta:       x11 Undefined",
    "Meta:       x12 Undefined",
    "Meta:       x13 Undefined",
    "Meta:       x14 Undefined",
    "Meta:       x15 Undefined",
    "Meta:       x16 Undefined",
    "Meta:       x17 Undefined",
    "Meta:       x18 Undefined",
    "Meta:       Undefined (0x19)",
    "Meta:       Undefined (0x1A)",
    "Meta:       Undefined (0x1B)",
    "Meta:       Undefined (0x1C)",
    "Meta:       Undefined (0x1D)",
    "Meta:       Undefined (0x1E)",
    "Meta:       Undefined (0x1F)",
    "Meta:       x20 Channel prefix",     // 0x20
    "Meta:       x21 Port prefix",        // 0x21
    "Meta:       Undefined (0x22)",
    "Meta:       Undefined (0x23)",
    "Meta:       Undefined (0x24)",
    "Meta:       Undefined (0x25)",
    "Meta:       Undefined (0x26)",
    "Meta:       Undefined (0x27)",
    "Meta:       Undefined (0x28)",
    "Meta:       Undefined (0x29)",
    "Meta:       Undefined (0x2A)",
    "Meta:       Undefined (0x2B)",
    "Meta:       Undefined (0x2C)",
    "Meta:       Undefined (0x2D)",
    "Meta:       Undefined (0x2E)",
    "Meta:       x2F End of track",        // 0x2F
    "Meta:       Undefined (0x30)",
    "Meta:       Undefined (0x31)",
    "Meta:       Undefined (0x32)",
    "Meta:       Undefined (0x33)",
    "Meta:       Undefined (0x34)",
    "Meta:       Undefined (0x35)",
    "Meta:       Undefined (0x36)",
    "Meta:       Undefined (0x37)",
    "Meta:       Undefined (0x38)",
    "Meta:       Undefined (0x39)",
    "Meta:       Undefined (0x3A)",
    "Meta:       Undefined (0x3B)",
    "Meta:       Undefined (0x3C)",
    "Meta:       Undefined (0x3D)",
    "Meta:       Undefined (0x3E)",
    "Meta:       Undefined (0x3F)",
    "Meta:       Undefined (0x40)",
    "Meta:       Undefined (0x41)",
    "Meta:       Undefined (0x42)",
    "Meta:       Undefined (0x43)",
    "Meta:       Undefined (0x44)",
    "Meta:       Undefined (0x45)",
    "Meta:       Undefined (0x46)",
    "Meta:       Undefined (0x47)",
    "Meta:       Undefined (0x48)",
    "Meta:       Undefined (0x49)",
    "Meta:       Undefined (0x4A)",
    "Meta:       Undefined (0x4B)",
    "Meta:       Undefined (0x4C)",
    "Meta:       Undefined (0x4D)",
    "Meta:       Undefined (0x4E)",
    "Meta:       Undefined (0x4F)",
    "Meta:       Undefined (0x50)",
    "Meta:       x51 Tempo setting",   // 0x51
    "Meta:       x52 Undefined",
    "Meta:       x53 Undefined",
    "Meta:       x54 SMPTE offset",    // 0x54
    "Meta:       x55 Undefined",
    "Meta:       x56 Undefined",
    "Meta:       x57 Undefined",
    "Meta:       x58 Time signature",  // 0x58
    "Meta:       x59 Key signature",   // 0x59
    "Meta:       Undefined (0x5A)",
    "Meta:       Undefined (0x5B)",
    "Meta:       Undefined (0x5C)",
    "Meta:       Undefined (0x5D)",
    "Meta:       Undefined (0x5E)",
    "Meta:       Undefined (0x5F)",
    "Meta:       Undefined (0x60)",
    "Meta:       Undefined (0x61)",
    "Meta:       Undefined (0x62)",
    "Meta:       Undefined (0x63)",
    "Meta:       Undefined (0x64)",
    "Meta:       Undefined (0x65)",
    "Meta:       Undefined (0x66)",
    "Meta:       Undefined (0x67)",
    "Meta:       Undefined (0x68)",
    "Meta:       Undefined (0x69)",
    "Meta:       Undefined (0x6A)",
    "Meta:       Undefined (0x6B)",
    "Meta:       Undefined (0x6C)",
    "Meta:       Undefined (0x6D)",
    "Meta:       Undefined (0x6E)",
    "Meta:       Undefined (0x6F)",
    "Meta:       Undefined (0x70)",
    "Meta:       Undefined (0x71)",
    "Meta:       Undefined (0x72)",
    "Meta:       Undefined (0x73)",
    "Meta:       Undefined (0x74)",
    "Meta:       Undefined (0x75)",
    "Meta:       Undefined (0x76)",
    "Meta:       Undefined (0x77)",
    "Meta:       Undefined (0x78)",
    "Meta:       Undefined (0x79)",
    "Meta:       Undefined (0x7A)",
    "Meta:       Undefined (0x7B)",
    "Meta:       Undefined (0x7C)",
    "Meta:       Undefined (0x7D)",
    "Meta:       Undefined (0x7E)",
    "Meta:       x7F Sequencer Event"     // 0x7F
};



// Just in case there is some corrupt value passed to this routine
const char *sError                  = "ERROR: Unknown MIDI message";
const char *sStatusError            = "ERROR: Status byte is corrupt";
const char *sByte1Error             = "ERROR: First data byte is corrupt";

//--------------------------------------------------------------------------------------
// NOTE, KEY, PERCUSSION INSTRUMENT
//--------------------------------------------------------------------------------------

const char * MIDIPitchClassNames[12] = {
    "C",  "C#", "D",  "Eb", "E", "F", "F#", "G", "G#/Ab", "A", "Bb", "B"
};



// These names are from http://computermusicresource.com/GM.Percussion.KeyMap.html
// Percussion instrument are stored as note numbers,
const char MIDIPercussionNoteNames[128][CMIDIMessageNameStringMaxLength] = {
    "00   Undefined drum",
    "01   Undefined drum",
    "02   Undefined drum",
    "03   Undefined drum",
    "04   Undefined drum",
    "05   Undefined drum",
    "06   Undefined drum",
    "07   Undefined drum",
    "08   Undefined drum",
    "09   Undefined drum",
    "10   Undefined drum",
    "11   Undefined drum",
    "12   Undefined drum",
    "13   Undefined drum",
    "14   Undefined drum",
    "15   Undefined drum",
    "16   Undefined drum",
    "17   Undefined drum",
    "18   Undefined drum",
    "19   Undefined drum",
    "20   Undefined drum",
    "21   Undefined drum",
    "22   Undefined drum",
    "23   Undefined drum",
    "24   Undefined drum",
    "25   Undefined drum",
    "26   Undefined drum",
    "27   Undefined drum",
    "28   Undefined drum",
    "29   Undefined drum",
    "30   Undefined drum",
    "31   Undefined drum",
    "32   Undefined drum",
    "33   Undefined drum",
    "34   Undefined drum",
    
    "35   Acoustic Bass Drum",
    "36   Bass Drum 1",
    "37   Side Stick",
    "38   Acoustic Snare",
    "39   Hand Clap	",
    "40   Electric Snare",
    "41   Low Floor Tom",
    "42   Closed Hi Hat",
    "43   High Floor Tom",
    "44   Pedal Hi-Hat",
    "45   Low Tom",
    "46   Open Hi-Hat",
    "47   Low-Mid Tom",
    "48   Hi Mid Tom",
    "49   Crash Cymbal 1",
    "50   High Tom",
    "51   Ride Cymbal 1",
    "52   Chinese Cymbal",
    "53   Ride Bell",
    "54   Tambourine",
    "55   Splash Cymbal",
    "56   Cowbell",
    "57   Crash Cymbal 2",
    "58   Vibraslap",
    "59   Ride Cymbal 2",
    "60   Hi Bongo",
    "61   Low Bongo",
    "62   Mute Hi Conga",
    "63   Open Hi Conga",
    "64   Low Conga",
    "65   High Timbale",
    "66   Low Timbale",
    "67   High Agogo",
    "68   Low Agogo",
    "69   Cabasa",
    "70   Maracas",
    "71   Short Whistle",
    "72   Long Whistle",
    "73   Short Guiro",
    "74   Long Guiro",
    "75   Claves",
    "76   Hi Wood Block",
    "77   Low Wood Block",
    "78   Mute Cuica",
    "79   Open Cuica",
    "80   Mute Triangle",
    "81   Open Triangle",
    
    "82   Undefined drum",
    "83   Undefined drum",
    "84   Undefined drum",
    "85   Undefined drum",
    "86   Undefined drum",
    "87   Undefined drum",
    "88   Undefined drum",
    "89   Undefined drum",
    "90   Undefined drum",
    "91   Undefined drum",
    "92   Undefined drum",
    "93   Undefined drum",
    "94   Undefined drum",
    "95   Undefined drum",
    "96   Undefined drum",
    "97   Undefined drum",
    "98   Undefined drum",
    "99   Undefined drum",
    "100  Undefined drum",
    "101  Undefined drum",
    "102  Undefined drum",
    "103  Undefined drum",
    "104  Undefined drum",
    "105  Undefined drum",
    "106  Undefined drum",
    "107  Undefined drum",
    "108  Undefined drum",
    "109  Undefined drum",
    "110  Undefined drum",
    "111  Undefined drum",
    "112  Undefined drum",
    "113  Undefined drum",
    "114  Undefined drum",
    "115  Undefined drum",
    "116  Undefined drum",
    "117  Undefined drum",
    "118  Undefined drum",
    "119  Undefined drum",
    "120  Undefined drum",
    "121  Undefined drum",
    "122  Undefined drum",
    "123  Undefined drum",
    "124  Undefined drum",
    "125  Undefined drum",
    "126  Undefined drum",
    "127  Undefined drum"
};



//--------------------------------------------------------------------------------------
// CMIDI
//
//--------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------
#pragma mark                        UTILITIES
//--------------------------------------------------------------------------------------

NSString * CMIDIMessageDataString( NSData * d )
{
    NSMutableString * s = [NSMutableString stringWithCapacity:d.length * 3 + ceil(d.length/8)];
    UInt8 bytesPerLine = 8;
    
    Byte * p = ((Byte *)d.bytes);
    Byte * stop = p + d.length;
    Byte * stopRow = p + bytesPerLine;
    while (p < stop && p < stopRow) {
        [s appendString:[NSString stringWithFormat:@"%02X ", (UInt8) (*p++)]];
    }
    while (p < stop) {
        [s appendString:@"\n"];
        stopRow = p + bytesPerLine;
        while (p < stop && p < stopRow) {
            [s appendString:[NSString stringWithFormat:@"%02X ", (UInt8) (*p++)]];
        }
    }
    return s;
}



NSString * CMIDIMessageIndentAndSplitInnerLines(NSString * s, int indent, NSUInteger maxLineWidth)
{
    return [s stringByReplacingOccurrencesOfString:@"\n"
                                        withString:[NSString stringWithFormat:@"\n%-*s", indent, ""]];
}



@implementation CMIDIMessage (Description)

//--------------------------------------------------------------------------------------
#pragma mark                  ACCESS STORED STRINGS
//--------------------------------------------------------------------------------------

+ (NSString *) controllerName: (UInt8) controlNumber {
    return [NSString stringWithCString:MIDIControllerNames[controlNumber]+CMIDIMessageDetailOffset encoding:NSUTF8StringEncoding];
}


+ (NSString *) programName: (UInt8) programNumber {
    return [NSString stringWithCString:MIDIProgramNames[programNumber]+CMIDIMessageDetailOffset encoding:NSUTF8StringEncoding];
}


+ (NSArray *) programNames
{
    NSMutableArray * a = [NSMutableArray arrayWithCapacity:MIDIProgramNumber_Count];
    for (UInt8 i = 0; i < MIDIProgramNumber_Count; i++) {
        [a addObject:[CMIDIMessage programName:i]];
    }
    return a;
}


+ (NSString *) systemMessageName: (Byte) systemMessageType {
    return [NSString stringWithCString:MIDISystemMessageNames[systemMessageType - MIDISystemMsg_First]+CMIDIMessageDetailOffset encoding:NSUTF8StringEncoding];
}


+ (NSString *) metaMessageName: (Byte) metaMessageType {
    return [NSString stringWithCString:MIDIMetaMessageNames[metaMessageType]+CMIDIMessageDetailOffset encoding:NSUTF8StringEncoding];
}


+ (NSString *) percussionInstrumentName: (Byte) instrumentNumber
{
    return [NSString stringWithCString:MIDIPercussionNoteNames[instrumentNumber]+5 encoding:NSUTF8StringEncoding];
}


+ (NSString *) manufacturerName: (NSData *) manufacturerName
{
    return [NSString stringWithFormat:@"(TODO) bytes:%@", CMIDIMessageDataString(manufacturerName)];
}


// Keep track of a key signature message, if you find one. Use it to format note names going forward.
SInt8 CMIDIMessage_Description_nSharps = 0;


//--------------------------------------------------------------------------------------
//                                  MESSAGE NAMES, PROGRAM NAME, CONTROL NAME.
//--------------------------------------------------------------------------------------

- (NSString *) messageName
{
    switch (self.type) {
        case MIDIMessage_NoteOn:
            if (self.velocity == 0) {
                return @"Note On (OFF)";
            } else {
                return @"Note On";
            }
        
        case MIDIMessage_NoteOff:
            return @"Note Off";
        
        case MIDIMessage_NotePressure:
            return @"Note Pressure";
        
        case MIDIMessage_ControlChange:
            return [CMIDIMessage controllerName:self.controlNumber];
        
        case MIDIMessage_ProgramChange:
            return @"Program";
        
        case MIDIMessage_ChannelPressure:
            return @"Pressure";
        
        case MIDIMessage_PitchWheel:
            return @"Pitch Wheel";
   
        case MIDIMessage_System:
            if (self.isMeta) {
                return [CMIDIMessage metaMessageName:self.metaMessageType];
            } else {
                return [CMIDIMessage systemMessageName:self.systemMessageType];
            }
        default:
            return @"Corrupt (data byte in status position)";
    }
}




- (NSString *) channelName
{
    UInt8 channel;
    if (self.type == MIDIMessage_System) {
        if (self.systemMessageType == MIDISystemMsg_Meta && self.metaMessageType == MIDIMeta_ChannelPrefix) {
            channel = self.channelPrefix;
        } else {
            return @"-";
        }
    } else {
        channel = self.channel;
    }
    
    if (channel == MIDIChannel_Percussion) {
        return @"drums";
    } else {
        return [NSString stringWithFormat:@"%hhu", channel];
    }
}



- (NSString *) trackName
{
    if (self.track == CMIDIMessage_NoTrack) {
        return @"-";
    } else if (self.track == 0) {
        return @"tempo";
    } else {
        return [NSString stringWithFormat:@"%lu", self.track];
    }
}


- (NSString *) noteName
{
    if (self.isNoteMessage) {
        switch (self.channel) {
            case MIDIChannel_Percussion:
                return [CMIDIMessage percussionInstrumentName: self.percussionInstrument];
            default: {
                // Returns the same value as CMNoteName in the key of C major.
                const char * pitchClassName = MIDIPitchClassNames[self.noteNumber % 12];
                int octave = floor(self.noteNumber/12)-1;
                return [NSString stringWithFormat:@"%s%d", pitchClassName, octave];
            }
        }
    } else {
        return @"-";
    }
}


//--------------------------------------------------------------------------------------
#pragma mark                             VALUE
//--------------------------------------------------------------------------------------


- (NSString *) valueString: (BOOL *) containsMessageName;
{
    * containsMessageName = YES;
    switch (self.type) {
            
        case MIDIMessage_NoteOn: {
            *containsMessageName = NO;
            UInt16 velocity = self.velocity;
            if (velocity == 0) {
                return @"Velocity=0 (OFF)";
            } else {
                return [NSString stringWithFormat:@"Velocity=%hu", velocity];
            }
        }
        
        case MIDIMessage_NoteOff:
            *containsMessageName = NO;
            return [NSString stringWithFormat:@"Release velocity=%hhu", self.releaseVelocity];
            
        case MIDIMessage_NotePressure:
            *containsMessageName = NO;
            return [NSString stringWithFormat:@"Pressure=%hhu", self.notePressure];
            
        case MIDIMessage_ControlChange:
            switch (self.controlType) {
                    
                case CMIDIControllerType_Mode:
                    *containsMessageName = NO;
                    return @"";
                    
                case CMIDIControllerType_Continuous:
                case CMIDIControllerType_Fine:
                    return [NSString stringWithFormat:@"%@=%hhu", self.messageName, self.byteValue];
                    
                case CMIDIControllerType_Binary:
                    return [NSString stringWithFormat:@"%@=%s", self.messageName, (self.boolValue? "ON" : "OFF")];
                    
                case CMIDIControllerType_Undefined:
                    return [NSString stringWithFormat:@"Corrupt message (undefined controller)"];
                    
                case CMIDIControllerType_RPN:
                    *containsMessageName = NO;
                    return [NSString stringWithFormat:@"value=0x%X", self.byteValue];
                    
                default: // Can't happen
                    assert(NO);
            }
            
        case MIDIMessage_ProgramChange:
            return [NSString stringWithFormat:@"Program=%hhu", self.programNumber];
            
        case MIDIMessage_ChannelPressure:
            return [NSString stringWithFormat:@"Channel Pressure=%hhu", self.channelPressure];
            
        case MIDIMessage_PitchWheel:
            return [NSString stringWithFormat:@"Pitch Wheel=%hu", self.pitchWheelValue];
            
        case MIDIMessage_System:
            switch (self.systemMessageType) {
                case MIDISystemMsg_SystemExclusive:
                    *containsMessageName = NO;
                    return [NSString stringWithFormat:@"Manufacturer=%@\nData:\n%@",
                            [CMIDIMessage manufacturerName:self.sysExManufacturerId],
                            CMIDIMessageDataString(self.sysExData)];
                    
                case MIDISystemMsg_SongSelection:
                    return [NSString stringWithFormat:@"%@=%d", self.messageName, self.songSelection];
                
                case MIDISystemMsg_SongPosition:
                    return [NSString stringWithFormat:@"%@=%lld clock ticks", self.messageName, self.songPosition];
                    
                case MIDISystemMsg_MIDITimeCodeQtrFrame:
                    return [NSString stringWithFormat:@"%@=%hhu", self.messageName, self.MTCQuarterframe];
        
                case MIDISystemMsg_SystemReset:
                    if (!self.isMeta) {
                        *containsMessageName = NO;
                        return @"";
                    } // Fall through
                    
                //case MIDISystemMsg_Meta:
                    
                    switch (self.metaMessageType) {
                            
                        case MIDIMeta_FirstText ... MIDIMeta_LastText:
                            return [NSString stringWithFormat:@"%@=\"%@\"",self.messageName, self.text];
                            
                        case MIDIMeta_SequenceNumber:
                            return [NSString stringWithFormat:@"%@=%lu (Warning: not supported by CMIDI)",
                                    self.messageName, (unsigned long)self.sequenceNumber];
                            
                        case MIDIMeta_ChannelPrefix:
                            return [NSString stringWithFormat:@"%@=%hhu", self.messageName, self.channelPrefix];
        
                        case MIDIMeta_PortPrefix:
                            return [NSString stringWithFormat:@"%@=%hhu", self.messageName, self.portPrefix];
                            
                        case MIDIMeta_TempoSetting:
                            * containsMessageName = NO;
                            return [NSString stringWithFormat:@"BPM=%10f  MPB=%lu", self.BPM, (unsigned long)self.MPB];
                            
                        case MIDIMeta_TimeSignature:
                            return [NSString stringWithFormat:@"Time signature=%lu/%lu (2^%hhu)",
                                    (unsigned long)self.numerator,
                                    (unsigned long)self.denominator,
                                    self.denominatorPower];
                            
                        case MIDIMeta_SMPTEOffset: {
                            CMIDISMPTEOffset s = self.SMPTEOffset;
                            return [NSString stringWithFormat:@"SMPTE Offset=%hhu:%hhu:%hhu:%hhu:%hhu",
                                    s.hours,
                                    s.minutes,
                                    s.seconds,
                                    s.frames,
                                    s.fractionalFrames];
                        }
                            
                        case MIDIMeta_KeySignature: {
                            SInt8 nSharps = self.keyNumberOfSharps;
                            BOOL isMinor  = self.keyIsMinor;
                            
                            // Set this, to use in future note messages
                            CMIDIMessage_Description_nSharps = nSharps;
                            
                            return [NSString stringWithFormat:@"Key signature=%s%s (%s:%d Minor:%s)",
                                    MIDIPitchClassNames[self.keyPitchClass],
                                    (isMinor ? " Minor" : " Major"),
                                    (nSharps >= 0 ? "Sharps" : "Flats"),
                                    (nSharps >= 0 ? nSharps : -nSharps),
                                    (isMinor ? "YES" : "NO")
                                    ];
                        }
                            
                        case MIDIMeta_SequencerEvent:
                            *containsMessageName = NO;
                            return @"(Not supported by CMIDI)";
                            // return [NSString stringWithFormat:@"Manufacturer: %@\nData:\n%@",
                            //        [CMIDIMessage manufacturerName:self.sequencerEventManufacturerId],
                            //        CMIDIMessageDataString(self.sequencerEventData)];

                        case MIDIMeta_EndOfTrack:
                            *containsMessageName = NO;
                            return @"";
                            
                        default:
                            return @"Could not retreive value: meta message number is corrupt.";
                    }
                default: {
                    *containsMessageName = NO;
                    return @""; // One-byte system messsages.
                }
            }
        default:
            return @"Corrupt (data byte in status position)";
    }
}


- (NSString *) valueString
{
    BOOL unused;
    return [self valueString: &unused];
}

                

- (NSString *) timeString
{
    return [NSString stringWithFormat:@"%lld", self.time];
}



//--------------------------------------------------------------------------------------
#pragma mark                        Description
//--------------------------------------------------------------------------------------
// This is temporary; in all these tables, we only need the text at position 16

- (NSString *) description
{
    NSMutableString * s = [NSMutableString stringWithCapacity:200];
    [s appendFormat:@"<CMIDIMessage:"];
    
    BOOL containsMessageName;
    NSString * sValue = [self  valueString:&containsMessageName];
    if (containsMessageName) {
        [s appendString:sValue];
    } else {
        [s appendString:self.messageName];
    }

    [s appendFormat:@", Time=%lld", self.time];
 
    if (self.track != CMIDIMessage_NoTrack) {
        [s appendFormat:@", Track=%@", [self trackName]];
    }
    
    if (self.type != MIDIMessage_System) {
        [s appendFormat:@", Channel=%@", self.channelName];
    }
    
    if (self.isNoteMessage) {
        [s appendFormat:@", Note=%@", self.noteName];
    }
    
    if (!containsMessageName && sValue.length > 0) {
        sValue = CMIDIMessageIndentAndSplitInnerLines(sValue,(int)(s.length+2),80);
        [s appendFormat:@", %@", sValue];
    }
    
    [s appendFormat:@">"];
    
    return s;
}

//--------------------------------------------------------------------------------------
#pragma mark                         Description of a list
//--------------------------------------------------------------------------------------
// MIDI Monitor needs these lines one at time


- (NSString *) tableRowString
{
    NSString * sValue = [self valueString];
    sValue = CMIDIMessageIndentAndSplitInnerLines(sValue,
                                                  CMIDIMessageDescriptionMaxLength - CMIDIValueStringMaxLength,
                                                  CMIDIMessageDescriptionMaxLength);
    
    // Use the UTF8String, not NSString, because the width doesn't seem to work with '@'.
    return [NSString stringWithFormat:@"%-*s %-*s %-*s %-*s %-*s %-*s",
            CMIDITimeStringMaxLength,             self.timeString.UTF8String,
            CMIDIMessageNameMaxLength,            self.messageName.UTF8String,
            CMIDITrackNameMaxLength,              self.trackName.UTF8String,
            CMIDIChannelNameMaxLength,            self.channelName.UTF8String,
            CMIDINoteNameMaxLength,               self.noteName.UTF8String,
            CMIDIValueStringMaxLength,            sValue.UTF8String];
}


+ (NSString *) tableHeader
{
    return [NSString stringWithFormat:@"%-*s %-*s %-*s %-*s %-*s %-*s",
            CMIDITimeStringMaxLength,  "Time",
            CMIDIMessageNameMaxLength, "Message",
            CMIDITrackNameMaxLength,   "Track",
            CMIDIChannelNameMaxLength, "Channel",
            CMIDINoteNameMaxLength,     "Note",
            CMIDIValueStringMaxLength,  "Value"];
    
}


@end

