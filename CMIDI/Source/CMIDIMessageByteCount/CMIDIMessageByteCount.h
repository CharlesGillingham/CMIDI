//
//  CMIDIMessageByteCount.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 8/22/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    CMIDIMessageDataErr_corrupt = 1,
    CMIDIMessageDataErr_undefinedMessage = 2,
    CMIDIMessageDataErr_badVariableSizedNumber = 3,
    CMIDIMessageDataErr_badMetaMessageLength = 4
};

NSUInteger CMIDIMessageByteCount (UInt8 status,
                                      const Byte * data, // data AFTER the status byte
                                      NSUInteger maxLength,
                                      BOOL isFromFile,
                                      OSStatus * errCode);
