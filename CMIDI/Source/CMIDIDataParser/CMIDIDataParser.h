//
//  CMIDIMessageStream.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 6/20/15.
//
#import <Foundation/Foundation.h>

@interface CMIDIDataParser : NSObject

// Error is at "firstError". Set "firstError" to nil when the message is retrieved
@property NSError * firstError;

// Expects to be called repeatedly with successive data packets.
// Returns a list of messages
// Returns nil if this was a fatal error. Error is at "firstError".
- (NSArray *) parseMessageData: (const Byte *) data
                        length: (NSUInteger) length;

@end