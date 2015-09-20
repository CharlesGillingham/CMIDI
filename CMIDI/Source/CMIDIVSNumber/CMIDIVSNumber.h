//
//  CMIDIVSNumber.h
//  SqueezeBox 0.2.1
//
//  Created by CHARLES GILLINGHAM on 1/7/14.
//

#import <Foundation/Foundation.h>

// Returns nil if the number can't be parsed.

@interface CMIDIVSNumber : NSObject
+ (instancetype) numberWithInteger: (NSUInteger) value;
+ (instancetype) numberWithBytes: (const Byte *) p
                       maxLength: (NSUInteger) length;
@property (readonly) Byte * data;
@property (readonly) NSUInteger dataLength;
@property (readonly) NSUInteger integerValue;
@end

// Other number formats found in MIDI files and MIDI data streams.

UInt8 CMIDILSBFromUInt16(UInt16 v);
UInt8 CMIDIMSBFromUInt16(UInt16 v);
UInt16 CMIDIUInt16FromMSBandLSB(UInt8 MSB, UInt8 LSB);


