//
//  CMIDIVSNumber.m
//  SqueezeBox 0.2.1
//
//  Created by CHARLES GILLINGHAM on 1/7/14.
//  Copyright (c) 2014 CHARLES GILLINGHAM. All rights reserved.
//

#import "CMIDIVSNumber.h"

@implementation CMIDIVSNumber {
    Byte       _data[4];
    NSUInteger _length;
    NSUInteger _integerValue;
}
@dynamic    data;
@synthesize dataLength = _length;
@dynamic    integerValue;

+ (instancetype) numberWithInteger: (NSUInteger) i
{
    CMIDIVSNumber * n = [CMIDIVSNumber new];
    if ([n setIntegerValue: i]) {
        return n;
    } else {
        return nil;
    }
}


+ (instancetype) numberWithBytes:(const Byte *)p
                       maxLength:(NSUInteger) length
{
    CMIDIVSNumber * n = [CMIDIVSNumber new];
    if ([n setDataWithBytes:p maxLength:length]) {
        return n;
    } else {
        return nil;
    }
}


- (unsigned long) integerValue
{
    return _integerValue;
}


- (Byte *) data
{
    return _data;
}



- (BOOL) setIntegerValue: (NSUInteger) value
{
    _integerValue = value;
    
    register unsigned long buffer;
    buffer = value & 0x7F;
    _length = 1;
    
    while (value >>= 7)
    {
        buffer <<= 8;
        _length++;
        if (_length > 4)  {
            return NO;
        }
        buffer |= ((value & 0x7F) | 0x80);
    }
    
    for (int i = 0; i < _length; i++) {
        _data[i] = (buffer & 0x000000FF);
        buffer >>= 8;
    }
    
    return YES;
}


- (BOOL) setDataWithBytes: (const Byte *) p
                maxLength: (NSUInteger) maxLength
{
    register Byte * pd = _data;
    register unsigned long value = 0;
    register unsigned char c;
    
    if (maxLength == 0) { // Shouldn't happen, but just in case, call it 0.
        _integerValue = 0;
        _length = 0;
        return YES;
    }
    
    _length = 1;
    *pd++ = *p;
    c = *p++;
    
    if (c == 0x80) return NO; // We need a most significant digit to shift.
    
    value = c & 0x7F;
    
    while (c & 0x80) {
        _length++;
        if (_length > 4 || _length > maxLength) {
            return NO;
        }
        *pd++ = *p;
        c = *p++;
        
        value = (value << 7) + (c & 0x7F);
    }
    
    _integerValue = value;
    return YES;
}


@end


// -----------------------------------------------------------------------------
#pragma mark                        Two Byte values
// -----------------------------------------------------------------------------

UInt8 CMIDILSBFromUInt16(UInt16 v)
{
    return (0x007F & v);
}

UInt8 CMIDIMSBFromUInt16(UInt16 v)
{
    return ((0x3F80 & (v)) >> 7);
}


UInt16 CMIDIUInt16FromMSBandLSB(Byte MSB, Byte LSB)
{
    UInt16 _14bit;
    _14bit = (UInt16) MSB;
    _14bit <<= 7;
    _14bit |= (UInt16) LSB;
    return(_14bit);
}



