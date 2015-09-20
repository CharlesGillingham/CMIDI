//
//  CMIDISequence+Debug.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 8/22/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDISequence+Debug.h"
#import "CMIDISequence+FileIO.h"
#import "CMIDIMessageCollector.h"
#import "CMIDIMessage+Debug.h"
#import "CMIDIFile+Debug.h"
#import "CDebugMessages.h"
#import "CMIDIFakeClock.h"
#import "CMIDIMessage+MetaMessage.h"


@interface CMIDIDebugPrinter : NSObject <CMIDIReceiver, CMIDISender>
@property NSObject <CMIDIReceiver> * outputUnit;
@end


@implementation CMIDIDebugPrinter
@synthesize outputUnit;
- (void) respondToMIDI:(CMIDIMessage *)message
{
    [message show];
    [outputUnit respondToMIDI:message];
}
@end





@implementation CMIDISequence (Debug)

- (BOOL) check
{
    if (!CASSERT(self.events != nil)) return NO;
    if (self.events.count == 0) return YES;
    
    for (CMIDIMessage * msg in self.events) {
        if (!CCHECK_CLASS(msg, CMIDIMessage)) return NO;
    }
    
    for (CMIDIMessage * msg in self.events) {
        CASSERT_RET(self.maxLength >= msg.time);
    }
    
    // Check that the messages are in order.
    CMIDIClockTicks t = [self.events[0] time];
    for (CMIDIMessage * msg in self.events) {
        if (!CASSERT(msg.time >= t)) return NO;
        t = msg.time;
    }
    
    if (self.outputUnit && !CASSERT([self.outputUnit conformsToProtocol:@protocol(CMIDIReceiver)])) return NO;
    return YES;
}



- (BOOL) checkSend: (NSArray *) msgList
{
    if (![self check]) return NO;
    
    CMIDIMessageCollector * mc = [CMIDIMessageCollector new];
    CMIDIClock * cl = [CMIDIFakeClock fakeClock];
  
    [cl.receivers addObject:self];
    self.outputUnit = mc;
    mc.clock = cl;  // Give the message collector the clock, so it can track the time the messages arrive.
    
    [cl start];
    
    if (!CASSERTEQUAL(msgList.count, self.events.count)) return NO;
    if (!CASSERTEQUAL(msgList.count, mc.msgsReceived.count)) return NO;
    if (!CASSERTEQUAL(msgList.count, mc.clockTicksReceived.count)) return NO;
   
    for (NSUInteger i = 0; i < mc.msgsReceived.count; i++) {
        CMIDIClockTicks t = [mc.clockTicksReceived[i] longLongValue];
        CMIDIMessage * msgR = mc.msgsReceived[i];
        CMIDIMessage * msgE = self.events[i];
        CMIDIMessage * msg = msgList[i];
        CASSERT_RET(msgR.time == t);
        CASSERT_RET(msgE == msgR);
        if (!CASSERTEQUAL(msg, msgE)) return NO;
    }
    
    return YES;
}


+ (BOOL) testWithMessageList: (NSArray *) msgs
{
    CMIDISequence * ms = [CMIDISequence new];
    ms.events = msgs;
    if (![ms checkSend:msgs]) return NO;
    
    ms = [CMIDISequence new];
    
    msgs = [CMIDIMessage sortedMessageList:msgs];
    
    NSUInteger split1 = msgs.count/3;
    NSUInteger split2 = msgs.count*2/3;
    
    // Adding messages at the end
    for (NSInteger i = split2; i < msgs.count; i++) {
        [ms addEvent:msgs[i]];
    }
    // Adding events at the beginning
    for (NSInteger i = split1; i >= 0; i--) {
        [ms addEvent:msgs[i]];
    }
    // Adding events in the middle
    for (NSInteger i = split1+1; i < split2; i++) {
        [ms addEvent:msgs[i]];
    }
    // This is really a test of the code above.
    CASSERT_RET(ms.events.count == msgs.count);
    for (NSUInteger i = 0; i < msgs.count; i++) {
        if (!CASSERTEQUAL(ms.events[i],msgs[i])) return NO;
    }
    
    if (![ms checkSend:msgs]) return NO;
    
    
    // Remve an event in the middle.
    [ms removeEventEqualTo:msgs[split1]];
    CASSERT_RET(ms.events.count == msgs.count-1);
    [ms addEvent:msgs[split1]];
    if (![ms checkSend:msgs]) return NO;
    
    // Remove the event at the start
    [ms removeEventEqualTo:msgs[0]];
    CASSERT_RET(ms.events.count == msgs.count-1);
    [ms addEvent:msgs[0]];
    if (![ms checkSend:msgs]) return NO;
    
    [ms removeEventEqualTo:[msgs lastObject]];
    CASSERT_RET(ms.events.count == msgs.count-1);
    [ms addEvent:[msgs lastObject]];
    if (![ms checkSend:msgs]) return NO;
    
    // Attempt to remove a something that isn't there
    [ms removeEventEqualTo:[CMIDIMessage messageWithText:@"Not in the list" andType:MIDIMeta_Text]];
    
    // Remove all the messages (crash test)
    for (CMIDIMessage * msg in msgs) {
        [ms removeEventEqualTo:msg];
    }
    CASSERT_RET(ms.events.count == 0);
    
    // Remove from an empty list (crash test)
    [ms removeEventEqualTo:msgs[0]];
    CASSERT_RET(ms.events.count == 0);

    
    return YES;
}


+ (BOOL) testWithMIDIFile: (NSURL *) fileName
{
    CMIDISequence * ms = [CMIDISequence new];
    NSError * error;
    if (![ms readFile:fileName error:&error]) return NO;
    return [ms checkSend: ms.events];
}



+ (BOOL) test
{
    if (![self testWithMessageList:[CMIDIMessage oneOfEachMessage]]) return NO;
    if (![self testWithMIDIFile:[CMIDIFile exampleMIDIFiles][0]]) return NO;
    return YES;
}

@end
