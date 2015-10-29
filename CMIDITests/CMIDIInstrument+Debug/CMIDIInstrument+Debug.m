//
//  CMIDInstrument+Debug.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 10/13/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDIInstrument+Debug.h"
#import "CMIDIEndpoint.h"
#import "CDebugMessages.h"
#import "CMIDIMessageCollector.h"
#import "CMIDIMessage+ChannelMessage.h"
#import "CKVCTester.h"

@interface CMIDIInstrument ()
@property NSArray * stateList;
@end



@implementation CMIDIInstrument (Debug)

// Specialized for the two types of instruments, software and external. This is the version for an external instrument.
+ (CMIDIInstrument *) exampleWithCollector: (CMIDIMessageCollector *) collector
{
    NSString * endpN = [CMIDIInstrument endpointNames][0];
    CMIDIInstrument * inst = [[CMIDIInstrument alloc] initWithEndpointName:endpN];
    
    CASSERT(inst != nil);
    
    inst.outputUnit = (CMIDIExternalDestination *) collector;
    
    return inst;
}


+ (BOOL) test
{
    CMIDIMessageCollector * coll = [CMIDIMessageCollector new];
    CMIDIInstrument * inst = [self exampleWithCollector:coll];
    
    CMIDIMessage * messageNoteOn_ch2   = [CMIDIMessage messageWithNoteOn:MIDINote_MiddleC velocity:64 channel:2];
    CMIDIMessage * programChange27_ch2 = [CMIDIMessage messageWithProgramChange:27 channel:2];
    CMIDIMessage * programChange32_ch2 = [CMIDIMessage messageWithProgramChange:32 channel:2];
    CMIDIMessage * programChange25_ch3 = [CMIDIMessage messageWithProgramChange:25 channel:3];
    CMIDIMessage * allNotesOff_ch1 = [CMIDIMessage messageAllNotesOff:1];
    
    CKVCTester * tester = [CKVCTester testerWithObject:inst expectedKeys:@[@"currentState"]];
    
    [inst respondToMIDI:messageNoteOn_ch2];
    if (![tester testCount:0]) return NO;
    if (!CASSERTEQUAL(coll.msgsReceived,@[messageNoteOn_ch2])) return NO;
    if (!CASSERTEQUAL(inst.stateList,@[])) return NO;
    
    [inst respondToMIDI:programChange27_ch2];
    if (![tester testCount:1]) return NO;
    if (!CASSERTEQUAL(coll.msgsReceived,(@[messageNoteOn_ch2, programChange27_ch2]))) return NO;
    if (!CASSERTEQUAL(inst.stateList,@[programChange27_ch2])) return NO;
    
    [inst respondToMIDI:programChange32_ch2];
    if (![tester testCount:1]) return NO;
    if (!CASSERTEQUAL(coll.msgsReceived,(@[messageNoteOn_ch2, programChange27_ch2, programChange32_ch2]))) return NO;
    if (!CASSERTEQUAL(inst.stateList,@[programChange32_ch2])) return NO;
    
 
    [inst respondToMIDI:programChange25_ch3];
    if (![tester testCount:1]) return NO;
    if (!CASSERTEQUAL(coll.msgsReceived,(@[messageNoteOn_ch2, programChange27_ch2, programChange32_ch2, programChange25_ch3]))) return NO;
    if (!CASSERTEQUAL(inst.stateList,(@[programChange32_ch2, programChange25_ch3]))) return NO;

    [inst setMute:YES];
    if (![tester testCount:0]) return NO;
    if (!CASSERTEQUAL(coll.msgsReceived[4],allNotesOff_ch1)) return NO;
    if (!CASSERTEQUAL(inst.stateList,(@[programChange32_ch2, programChange25_ch3]))) return NO;
    
    [coll reset];
    
    [inst setMute:NO];
    if (![tester testCount:0]) return NO;
    if (!CASSERTEQUAL(coll.msgsReceived,(@[programChange32_ch2, programChange25_ch3]))) return NO;
    if (!CASSERTEQUAL(inst.stateList,(@[programChange32_ch2, programChange25_ch3]))) return NO;

    [inst setMute:YES];
    if (![tester testCount:0]) return NO;
    if (!CASSERTEQUAL(coll.msgsReceived[2],allNotesOff_ch1)) return NO;
    if (!CASSERTEQUAL(inst.stateList,(@[programChange32_ch2, programChange25_ch3]))) return NO;

    [coll reset];
    
    [inst clockStopped:nil];
    if (![tester testCount:0]) return NO;
    if (!CASSERTEQUAL(coll.msgsReceived,@[])) return NO;
    if (!CASSERTEQUAL(inst.stateList,(@[programChange32_ch2, programChange25_ch3]))) return NO;
   
    [inst clockStarted:nil];
    if (![tester testCount:0]) return NO;
    if (!CASSERTEQUAL(coll.msgsReceived,@[])) return NO;
    if (!CASSERTEQUAL(inst.stateList,(@[programChange32_ch2, programChange25_ch3]))) return NO;

    [inst setMute:NO];
    if (![tester testCount:0]) return NO;
    if (!CASSERTEQUAL(coll.msgsReceived,(@[programChange32_ch2, programChange25_ch3]))) return NO;
    if (!CASSERTEQUAL(inst.stateList,(@[programChange32_ch2, programChange25_ch3]))) return NO;
    
    return YES;
}
@end
