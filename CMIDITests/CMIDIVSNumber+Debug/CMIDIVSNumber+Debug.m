//
//  CMIDVSNumber+Debug.m
//  CMIDI
//  Variable sized numbers tests
//
//  Created by CHARLES GILLINGHAM on 6/20/15.

#import "CMIDIVSNumber+Debug.h"
#import "CDebugMessages.h"
#import "CMIDI Time.h"

#ifdef DEBUG

@implementation CMIDIVSNumber (Debug)
- (BOOL) check { return YES; }

+ (BOOL) test
{
 //   Byte buf[4] = {0x80, 0x00, 0x00, 0x00};
 //   CMIDIVSNumber * vs = [CMIDIVSNumber numberWithBytes:buf maxLength:4];
    
    return ([self testValidNumbers] &&
            [self testInvalidNumbers]// &&
        //    [self testAllByteLists] &&
        //    [self testAllNumbers]
            );
    // Skip "testAll" because it takes several minutes on this machine.
}


+ (BOOL) testValidValue: (NSUInteger) intValue
                  bytes: (Byte) b0 : (Byte) b1 : (Byte) b2 : (Byte) b3
         expectedLength: (NSUInteger) expectedLength
              maxLength: (NSUInteger) maxLength

{
    Byte buf[5] = {b0, b1, b2, b3, 0xFF};
    
    CMIDIVSNumber * vs1 = [CMIDIVSNumber numberWithInteger:intValue];
    CMIDIVSNumber * vs2 = [CMIDIVSNumber numberWithBytes:buf maxLength:maxLength];
    CASSERT_RET(vs1 != nil);
    CASSERT_RET(vs2 != nil);
    CASSERT_RET(vs1.integerValue == intValue);
    CASSERT_RET(vs2.integerValue == intValue);
    CASSERT_RET(vs1.dataLength == expectedLength);
    CASSERT_RET(vs2.dataLength == expectedLength);
    for (int i = 0; i < expectedLength; i++) {
        CASSERT_RET(vs1.data[i] == buf[i]);
        CASSERT_RET(vs2.data[i] == buf[i]);
    }
    return YES;
}




+ (BOOL) testValidNumbers
{
    // Maxlength is set to 6, so that it will crash if it reads too much..
    
    // Most significant digit: 7 with 1 digit
    CASSERT_RET([self testValidValue:0x00000001 bytes:0x01 :0x00 :0x00 :0x00 expectedLength:1 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00000002 bytes:0x02 :0x00 :0x00 :0x00 expectedLength:1 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00000004 bytes:0x04 :0x00 :0x00 :0x00 expectedLength:1 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00000008 bytes:0x08 :0x00 :0x00 :0x00 expectedLength:1 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00000010 bytes:0x10 :0x00 :0x00 :0x00 expectedLength:1 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00000020 bytes:0x20 :0x00 :0x00 :0x00 expectedLength:1 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00000040 bytes:0x40 :0x00 :0x00 :0x00 expectedLength:1 maxLength:6]);
  
    // 7 with 2 digits
    CASSERT_RET([self testValidValue:0x00000080 bytes:0x81 :0x00 :0x00 :0x00 expectedLength:2 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00000100 bytes:0x82 :0x00 :0x00 :0x00 expectedLength:2 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00000200 bytes:0x84 :0x00 :0x00 :0x00 expectedLength:2 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00000400 bytes:0x88 :0x00 :0x00 :0x00 expectedLength:2 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00000800 bytes:0x90 :0x00 :0x00 :0x00 expectedLength:2 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00001000 bytes:0xA0 :0x00 :0x00 :0x00 expectedLength:2 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00002000 bytes:0xC0 :0x00 :0x00 :0x00 expectedLength:2 maxLength:6]);
   
    // 7 with 3 digitns
    CASSERT_RET([self testValidValue:0x00004000 bytes:0x81 :0x80 :0x00 :0x00 expectedLength:3 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00008000 bytes:0x82 :0x80 :0x00 :0x00 expectedLength:3 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00010000 bytes:0x84 :0x80 :0x00 :0x00 expectedLength:3 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00020000 bytes:0x88 :0x80 :0x00 :0x00 expectedLength:3 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00040000 bytes:0x90 :0x80 :0x00 :0x00 expectedLength:3 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00080000 bytes:0xA0 :0x80 :0x00 :0x00 expectedLength:3 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00100000 bytes:0xC0 :0x80 :0x00 :0x00 expectedLength:3 maxLength:6]);
   
    // 7 with 4 digits
    CASSERT_RET([self testValidValue:0x00200000 bytes:0x81 :0x80 :0x80 :0x00 expectedLength:4 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00400000 bytes:0x82 :0x80 :0x80 :0x00 expectedLength:4 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00800000 bytes:0x84 :0x80 :0x80 :0x00 expectedLength:4 maxLength:6]);
    CASSERT_RET([self testValidValue:0x01000000 bytes:0x88 :0x80 :0x80 :0x00 expectedLength:4 maxLength:6]);
    CASSERT_RET([self testValidValue:0x02000000 bytes:0x90 :0x80 :0x80 :0x00 expectedLength:4 maxLength:6]);
    CASSERT_RET([self testValidValue:0x04000000 bytes:0xA0 :0x80 :0x80 :0x00 expectedLength:4 maxLength:6]);
    CASSERT_RET([self testValidValue:0x08000000 bytes:0xC0 :0x80 :0x80 :0x00 expectedLength:4 maxLength:6]);
    
    // All digits: 7 with 1 byte
    CASSERT_RET([self testValidValue:0x00000001 bytes:0x01 :0x00 :0x00 :0x00 expectedLength:1 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00000003 bytes:0x03 :0x00 :0x00 :0x00 expectedLength:1 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00000007 bytes:0x07 :0x00 :0x00 :0x00 expectedLength:1 maxLength:6]);
    CASSERT_RET([self testValidValue:0x0000000F bytes:0x0F :0x00 :0x00 :0x00 expectedLength:1 maxLength:6]);
    CASSERT_RET([self testValidValue:0x0000001F bytes:0x1F :0x00 :0x00 :0x00 expectedLength:1 maxLength:6]);
    CASSERT_RET([self testValidValue:0x0000003F bytes:0x3F :0x00 :0x00 :0x00 expectedLength:1 maxLength:6]);
    CASSERT_RET([self testValidValue:0x0000007F bytes:0x7F :0x00 :0x00 :0x00 expectedLength:1 maxLength:6]);
    
    // 7 with 2 byte
    CASSERT_RET([self testValidValue:0x000000FF bytes:0x81 :0x7F :0x00 :0x00 expectedLength:2 maxLength:6]);
    CASSERT_RET([self testValidValue:0x000001FF bytes:0x83 :0x7F :0x00 :0x00 expectedLength:2 maxLength:6]);
    CASSERT_RET([self testValidValue:0x000003FF bytes:0x87 :0x7F :0x00 :0x00 expectedLength:2 maxLength:6]);
    CASSERT_RET([self testValidValue:0x000007FF bytes:0x8F :0x7F :0x00 :0x00 expectedLength:2 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00000FFF bytes:0x9F :0x7F :0x00 :0x00 expectedLength:2 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00001FFF bytes:0xBF :0x7F :0x00 :0x00 expectedLength:2 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00003FFF bytes:0xFF :0x7F :0x00 :0x00 expectedLength:2 maxLength:6]);
    
    // 7 with 3 byte
    CASSERT_RET([self testValidValue:0x00007FFF bytes:0x81 :0xFF :0x7F :0x00 expectedLength:3 maxLength:6]);
    CASSERT_RET([self testValidValue:0x0000FFFF bytes:0x83 :0xFF :0x7F :0x00 expectedLength:3 maxLength:6]);
    CASSERT_RET([self testValidValue:0x0001FFFF bytes:0x87 :0xFF :0x7F :0x00 expectedLength:3 maxLength:6]);
    CASSERT_RET([self testValidValue:0x0003FFFF bytes:0x8F :0xFF :0x7F :0x00 expectedLength:3 maxLength:6]);
    CASSERT_RET([self testValidValue:0x0007FFFF bytes:0x9F :0xFF :0x7F :0x00 expectedLength:3 maxLength:6]);
    CASSERT_RET([self testValidValue:0x000FFFFF bytes:0xBF :0xFF :0x7F :0x00 expectedLength:3 maxLength:6]);
    CASSERT_RET([self testValidValue:0x001FFFFF bytes:0xFF :0xFF :0x7F :0x00 expectedLength:3 maxLength:6]);
    
    // 7 with 4 byte
    CASSERT_RET([self testValidValue:0x003FFFFF bytes:0x81 :0xFF :0xFF :0x7F expectedLength:4 maxLength:6]);
    CASSERT_RET([self testValidValue:0x007FFFFF bytes:0x83 :0xFF :0xFF :0x7F expectedLength:4 maxLength:6]);
    CASSERT_RET([self testValidValue:0x00FFFFFF bytes:0x87 :0xFF :0xFF :0x7F expectedLength:4 maxLength:6]);
    CASSERT_RET([self testValidValue:0x01FFFFFF bytes:0x8F :0xFF :0xFF :0x7F expectedLength:4 maxLength:6]);
    CASSERT_RET([self testValidValue:0x03FFFFFF bytes:0x9F :0xFF :0xFF :0x7F expectedLength:4 maxLength:6]);
    CASSERT_RET([self testValidValue:0x07FFFFFF bytes:0xBF :0xFF :0xFF :0x7F expectedLength:4 maxLength:6]);
    CASSERT_RET([self testValidValue:0x0FFFFFFF bytes:0xFF :0xFF :0xFF :0x7F expectedLength:4 maxLength:6]);

    return YES;
}



+ (BOOL) badDataByteCheck: (Byte) b0 : (Byte) b1 : (Byte) b2 : (Byte) b3
                maxLength: (NSUInteger) maxLength
{
    Byte buf[5] = {b0, b1, b2, b3, 0xFF};
    CMIDIVSNumber * vs = [CMIDIVSNumber numberWithBytes:buf maxLength:maxLength];
    CASSERT_RET(vs == nil);
    
    return YES;
}



+ (BOOL) testInvalidNumbers
{
    // This number is too large to represent in four bytes.
    CMIDIVSNumber * vs;
    vs = [CMIDIVSNumber numberWithInteger:0x0FFFFFFF+1];
    CASSERT_RET(vs == nil);
    
    // These values are both too large.
    Byte buf1[5] = { 0xFF, 0xFF, 0xFF, 0xFF, 0x01 };
    vs = [CMIDIVSNumber numberWithBytes: buf1 maxLength: 5];
    CASSERT_RET(vs == nil);
    Byte buf2[5] = { 0x80, 0x80, 0x80, 0x80, 0x0E };
    vs = [CMIDIVSNumber numberWithBytes: buf2 maxLength: 5];
    CASSERT_RET(vs == nil);
    
    // Maxlength is too short.
    CASSERT_RET([self badDataByteCheck:0x81 :0x00 :0x00 :0x00 maxLength:1]);
    CASSERT_RET([self badDataByteCheck:0xC0 :0x00 :0x00 :0x00 maxLength:1]);
    CASSERT_RET([self badDataByteCheck:0xFF :0x7F :0x00 :0x00 maxLength:1]);
    CASSERT_RET([self badDataByteCheck:0x81 :0x80 :0x00 :0x00 maxLength:1]);
    CASSERT_RET([self badDataByteCheck:0xC0 :0x80 :0x00 :0x00 maxLength:1]);
    CASSERT_RET([self badDataByteCheck:0xFF :0xFF :0x7F :0x00 maxLength:1]);
    CASSERT_RET([self badDataByteCheck:0x81 :0x80 :0x80 :0x00 maxLength:1]);
    CASSERT_RET([self badDataByteCheck:0xC0 :0x80 :0x80 :0x00 maxLength:1]);
    CASSERT_RET([self badDataByteCheck:0xFF :0xFF :0xFF :0x7F maxLength:1]);
    CASSERT_RET([self badDataByteCheck:0x81 :0x80 :0x00 :0x00 maxLength:2]);
    CASSERT_RET([self badDataByteCheck:0xC0 :0x80 :0x00 :0x00 maxLength:2]);
    CASSERT_RET([self badDataByteCheck:0xFF :0xFF :0x7F :0x00 maxLength:2]);
    CASSERT_RET([self badDataByteCheck:0x81 :0x80 :0x80 :0x00 maxLength:2]);
    CASSERT_RET([self badDataByteCheck:0xC0 :0x80 :0x80 :0x00 maxLength:2]);
    CASSERT_RET([self badDataByteCheck:0xFF :0xFF :0xFF :0x7F maxLength:2]);
    CASSERT_RET([self badDataByteCheck:0x81 :0x80 :0x80 :0x00 maxLength:3]);
    CASSERT_RET([self badDataByteCheck:0xC0 :0x80 :0x80 :0x00 maxLength:3]);
    CASSERT_RET([self badDataByteCheck:0xFF :0xFF :0xFF :0x7F maxLength:3]);
    
    return YES;
}


// This test takes several minutes to complete.
+ (BOOL) testAllNumbers
{
    printf("TEST ALL NUMBERS (Take approx. 30 minutes)\n");
    BOOL fMax =  NO;
    CMIDINanoseconds t = CMIDINow();
    for (UInt64 i = 0; i < 0xFFFFFFFF; i++) {
        if (i % 0x01000000 == 0) printf("  %llu\n", i);
        CMIDIVSNumber * vs = [CMIDIVSNumber numberWithInteger:i];
        if (vs != nil) {
            CASSERT_RET([self testValidValue:i
                                       bytes:vs.data[0]
                                            :vs.data[1]
                                            :vs.data[2]
                                            :vs.data[3]
                              expectedLength:vs.dataLength
                                   maxLength:6]);
        } else if (!fMax) {
            fMax = YES;
            printf("MAX: %llu", i);
        }
    }
    printf("TIME FOR TEST WAS: %lld ns\n", CMIDINow()-t);
    return YES;
}



+ (BOOL) testAllByteLists
{
    printf("TEST ALL BYTE LISTS (Take approx. 30 minutes)\n");
    CMIDINanoseconds t = CMIDINow();
    for (int b1 = 0; b1 <= 0xFF; b1++) {
        printf("    %d\n", b1);
        for (int b2 = 0; b2 <= 0xFF; b2++) {
            for (int b3 = 0; b3 <= 0xFF; b3++) {
                for (int b4 = 0; b4 <= 0xFF; b4++) {
                    Byte buf[4] = {b1,b2,b3,b4};
                    CMIDIVSNumber * vs = [CMIDIVSNumber numberWithBytes:buf maxLength:4];
                    if (vs != nil) {
                        CASSERT_RET([self testValidValue:vs.integerValue
                                                   bytes:b1:b2:b3:b4
                                          expectedLength:vs.dataLength
                                               maxLength:4]);
                    }
                }
            }
        }
    }
    printf("TIME FOR TEST WAS: %lld ns\n", CMIDINow()-t);
    return YES;
}

@end

#endif
