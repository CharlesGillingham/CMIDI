//
//  CMIDIMessageCollector.h
//  CAudioMIDIMusic
//
//  Created by CHARLES GILLINGHAM on 9/15/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDIReceiver CMIDISender.h"
#import "CMIDIClock.h"


@interface CMIDIMessageCollector : NSObject <CMIDIReceiver, CMIDITimeReceiver>
@property CMIDIClock * clock;
@property NSMutableArray * msgsReceived;
@property NSMutableArray * hostTimesReceived;
@property NSMutableArray * clockTicksReceived;
@property NSMutableArray * hostTimesExpected;
- (void) reset;
@end
