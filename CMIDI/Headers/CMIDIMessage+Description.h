//
//  CMIDIMessage+Description.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 6/9/15.
//

#import "CMIDIMessage.h"

// Useful for formatting column displays.
#define CMIDITimeStringMaxLength          (15)
#define CMIDIMessageNameMaxLength         (30)
#define CMIDITrackNameMaxLength           (15) // Must be wide enough to accomadate 'track' and 'tempo'
#define CMIDIChannelNameMaxLength         (15) // Must be wide enough to accomodate the strings 'drums' and 'channel"
#define CMIDINoteNameMaxLength            (30) // Must be wide enough to accomodate the names of drum instruments
#define CMIDIValueStringMaxLength        (100)
#define CMIDIMessageDescriptionMaxLength (210) // Sum+5


@interface CMIDIMessage (Description)

// Names for values
+ (NSString *) controllerName:           (UInt8) controlNumber;
+ (NSString *) programName:              (UInt8) programNumber;
+ (NSString *) systemMessageName:        (Byte)  systemMessageType;
+ (NSString *) metaMessageName:          (Byte)  metaMessageType;
+ (NSString *) percussionInstrumentName: (Byte)  instrumentNumber;
+ (NSString *) manufacturerName:         (NSData *) manufacturerName;

// Lists of values
+ (NSArray *)  programNames;

// Individual fields of this message
- (NSString *) timeString;
- (NSString *) messageName;
- (NSString *) trackName;
- (NSString *) channelName;
- (NSString *) noteName;
- (NSString *) valueString;

// Description
- (NSString *) description;
+ (NSString *) tableHeader;
- (NSString *) tableRowString;

@end
