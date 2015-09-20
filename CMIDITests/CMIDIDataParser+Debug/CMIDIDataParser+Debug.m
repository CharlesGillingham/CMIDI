//
//  CMIDIDataParser+Debug.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 8/12/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDIDataParser+Debug.h"
#import "CMIDIMessage+Debug.h"
#import "CMIDIMessage+ChannelMessage.h"
#import "CMIDIMessage+SystemMessage.h"
#import "CMIDIMessage+MetaMessage.h"
#import "CMIDIMessage+Description.h"
#import "CDebugMessages.h"


@implementation CMIDIDataParser (Debug)

NSMutableArray * CMIDIDataParser_exampleData = nil;
NSMutableArray * CMIDIDataParser_exampleMessages = nil;

+ (void) initExampleData
{
//    CMIDIDataParser * parser = [CMIDIDataParser new];
    CMIDIDataParser_exampleData = [NSMutableArray new];
    CMIDIDataParser_exampleMessages = [NSMutableArray new];
    
    Byte dummySysExManufacturer = 1;
    Byte dummySysExData[5] = {10,11,12,13,14};
    CMIDIMessage * sysExMsg = [CMIDIMessage messageWithSystemExclusiveManufacturer:[NSData dataWithBytes:&dummySysExManufacturer length:1]
                                                                           andData:[NSData dataWithBytes:&dummySysExData length:5]];
    
    {
        UInt32 exampleDataBlock_length = 157;
        UInt8 exampleDataBlock[157] = {
            // Set of note on messages
            MIDIMessage_NoteOn, 10, 64,
            MIDIMessage_NoteOn, 11, 65,
            MIDIMessage_NoteOn, 12, 66,
            MIDIMessage_NoteOn, 13, 67,
            MIDIMessage_NoteOn, 14, 68,
            MIDIMessage_ProgramChange, 10,
            MIDIMessage_ProgramChange, 11,
            MIDISystemMsg_TuneRequest,
            
            MIDISystemMsg_SystemExclusive, 01, 10, 11, 12, 13, 14, MIDISystemMsg_EndofSysEx,
            
            // Same thing with running status
            MIDIMessage_NoteOff, 10, 64,
            11, 65,
            12, 66,
            13, 67,
            14, 68,
            MIDIMessage_ProgramChange, 10,
            11,
            MIDISystemMsg_TuneRequest,
            
            
            // Realtime status byte interrupting at each point.
            MIDIMessage_NoteOn, 10, 64, MIDISystemMsg_TimingClock,
            MIDIMessage_NoteOn, 11, 65,
            MIDIMessage_NoteOn, MIDISystemMsg_Start, 12, 66,
            MIDIMessage_NoteOn, 13, MIDISystemMsg_SystemReset, 67, // Shouldn't be read as meta
            MIDIMessage_NoteOn, 14, 68, MIDISystemMsg_ActiveSensing,
            
            MIDIMessage_ProgramChange, MIDISystemMsg_TimingClock, 10, MIDISystemMsg_TimingClock,
            MIDIMessage_ProgramChange, 11, MIDISystemMsg_TimingClock,
            
            MIDISystemMsg_TuneRequest, MIDISystemMsg_TimingClock,
            
            MIDISystemMsg_SystemExclusive, MIDISystemMsg_TimingClock, 01, 10, 11, 12, 13, 14, MIDISystemMsg_EndofSysEx,
            MIDISystemMsg_SystemExclusive, 01, MIDISystemMsg_TimingClock, 10, 11, 12, 13, 14, MIDISystemMsg_EndofSysEx,
            MIDISystemMsg_SystemExclusive, 01, 10, MIDISystemMsg_TimingClock, 11, 12, 13, 14, MIDISystemMsg_EndofSysEx,
            MIDISystemMsg_SystemExclusive, 01, 10, 11, MIDISystemMsg_TimingClock, 12, 13, 14, MIDISystemMsg_EndofSysEx,
            MIDISystemMsg_SystemExclusive, 01, 10, 11, 12, MIDISystemMsg_TimingClock, 13, 14, MIDISystemMsg_EndofSysEx,
            
            MIDISystemMsg_SystemExclusive, 01, 10, 11, 12, 13, 14, MIDISystemMsg_TimingClock, MIDISystemMsg_EndofSysEx,
            MIDISystemMsg_SystemExclusive, 01, 10, 11, 12, 13, 14, MIDISystemMsg_EndofSysEx, MIDISystemMsg_TimingClock,
            
            // Same thing with running status
            MIDIMessage_NoteOff, 10, 64, MIDISystemMsg_TimingClock,
            11, 65,
            MIDISystemMsg_Start, 12, 66,
            13, MIDISystemMsg_Stop, 67,
            14, 68, MIDISystemMsg_ActiveSensing,
            
            MIDIMessage_ProgramChange, MIDISystemMsg_TimingClock, 10, MIDISystemMsg_TimingClock,
            11, MIDISystemMsg_TimingClock,
            
            MIDISystemMsg_TuneRequest, MIDISystemMsg_TimingClock // Data block ends with real-time byte; tricky case.
        };
        
        
        NSArray * exampleMessages = @[
                                      [CMIDIMessage messageWithNoteOn:10 velocity:64 channel:1],
                                      [CMIDIMessage messageWithNoteOn:11 velocity:65 channel:1],
                                      [CMIDIMessage messageWithNoteOn:12 velocity:66 channel:1],
                                      [CMIDIMessage messageWithNoteOn:13 velocity:67 channel:1],
                                      [CMIDIMessage messageWithNoteOn:14 velocity:68 channel:1],
                                      [CMIDIMessage messageWithProgramChange:10 channel:1],
                                      [CMIDIMessage messageWithProgramChange:11 channel:1],
                                      [CMIDIMessage messageTuneRequest], // 1 byte message
                                      
                                      sysExMsg,
                                      
                                      // Same thing with running status
                                      [CMIDIMessage messageWithNoteOff:10 releaseVelocity:64 channel:1],
                                      [CMIDIMessage messageWithNoteOff:11 releaseVelocity:65 channel:1],
                                      [CMIDIMessage messageWithNoteOff:12 releaseVelocity:66 channel:1],
                                      [CMIDIMessage messageWithNoteOff:13 releaseVelocity:67 channel:1],
                                      [CMIDIMessage messageWithNoteOff:14 releaseVelocity:68 channel:1],
                                      [CMIDIMessage messageWithProgramChange:10 channel:1],
                                      [CMIDIMessage messageWithProgramChange:11 channel:1],
                                      [CMIDIMessage messageTuneRequest], // 1 byte message
                                      
                                      
                                      // Same thing with real time message interruptions.
                                      [CMIDIMessage messageTimingClock],
                                      [CMIDIMessage messageWithNoteOn:10 velocity:64 channel:1],
                                      [CMIDIMessage messageWithNoteOn:11 velocity:65 channel:1],
                                      [CMIDIMessage messageStart],
                                      [CMIDIMessage messageWithNoteOn:12 velocity:66 channel:1],
                                      [CMIDIMessage messageSystemReset],
                                      [CMIDIMessage messageWithNoteOn:13 velocity:67 channel:1],
                                      [CMIDIMessage messageActiveSensing],
                                      [CMIDIMessage messageWithNoteOn:14 velocity:68 channel:1],
                                      [CMIDIMessage messageTimingClock],
                                      [CMIDIMessage messageTimingClock],
                                      [CMIDIMessage messageWithProgramChange:10 channel:1],
                                      [CMIDIMessage messageTimingClock],
                                      [CMIDIMessage messageWithProgramChange:11 channel:1],
                                      [CMIDIMessage messageTimingClock],
                                      [CMIDIMessage messageTuneRequest], // 1 byte message
                                      
                                      
                                      [CMIDIMessage messageTimingClock],
                                      sysExMsg,
                                      [CMIDIMessage messageTimingClock],
                                      sysExMsg,
                                      [CMIDIMessage messageTimingClock],
                                      sysExMsg,
                                      [CMIDIMessage messageTimingClock],
                                      sysExMsg,
                                      [CMIDIMessage messageTimingClock],
                                      sysExMsg,
                                      [CMIDIMessage messageTimingClock],
                                      sysExMsg,
                                      [CMIDIMessage messageTimingClock],
                                      sysExMsg,
                                      
                                      [CMIDIMessage messageTimingClock],
                                      [CMIDIMessage messageWithNoteOff:10 releaseVelocity:64 channel:1],
                                      [CMIDIMessage messageStart],
                                      [CMIDIMessage messageWithNoteOff:11 releaseVelocity:65 channel:1],
                                      [CMIDIMessage messageWithNoteOff:12 releaseVelocity:66 channel:1],
                                      [CMIDIMessage messageStop],
                                      [CMIDIMessage messageWithNoteOff:13 releaseVelocity:67 channel:1],
                                      [CMIDIMessage messageActiveSensing],
                                      [CMIDIMessage messageWithNoteOff:14 releaseVelocity:68 channel:1],
                                      [CMIDIMessage messageTimingClock],
                                      [CMIDIMessage messageTimingClock],
                                      [CMIDIMessage messageWithProgramChange:10 channel:1],
                                      [CMIDIMessage messageTimingClock],
                                      [CMIDIMessage messageWithProgramChange:11 channel:1],
                                      [CMIDIMessage messageTimingClock],
                                      [CMIDIMessage messageTuneRequest] // 1 byte message
                                      ];
        
        [CMIDIDataParser_exampleMessages addObject:exampleMessages];
        [CMIDIDataParser_exampleData addObject:[NSData dataWithBytes:exampleDataBlock length:exampleDataBlock_length]];
    }
    
    // ONE OF EVERY MIDI MESSAGE
    {
        NSMutableArray * exampleMessages = [NSMutableArray new];
        NSMutableData * d = [NSMutableData new];
        for (CMIDIMessage * msg in [CMIDIMessage oneOfEachMessage]) {
            // Meta only appear in files, and system real times appear out of order ..
            if (!msg.isMeta && !msg.isSystemRealTime) {
                [d appendData:msg.data];
                
                // Don't copy the time
                [exampleMessages addObject:[CMIDIMessage messageWithData:msg.data]];
            }
        }
        [CMIDIDataParser_exampleMessages addObject:exampleMessages];
        [CMIDIDataParser_exampleData addObject:d];
    }
    
    
    // SHORT MESSAGE ERRORS

    {
        UInt32 exampleDataBlock_length = 73;
        UInt8 exampleDataBlock[73] = {
            // Set of note on messages
            MIDIMessage_NoteOn, 10, 64,
            MIDIMessage_NoteOn, 11,           // SHORT MESSAGE
            MIDIMessage_NoteOn, 12, 66,
            MIDIMessage_NoteOn,               // SHORT MESSAGE
            MIDIMessage_NoteOn, 14, 68,
            MIDIMessage_ProgramChange, 10,
            MIDIMessage_ProgramChange,        // SHORT MESSAGE
            MIDISystemMsg_TuneRequest,
            
            // Same thing with running status
            MIDIMessage_NoteOff, 10, 64,
            11, 65,
            12, 66,
            13, 67,
            14,  // SHORT
            MIDIMessage_ProgramChange, 10,
            11,
            MIDISystemMsg_TuneRequest,
            
            
            // Realtime status byte interrupting at each point.
            MIDIMessage_NoteOn, 10, MIDISystemMsg_TimingClock,
            MIDIMessage_NoteOn, 11,
            MIDIMessage_NoteOn, MIDISystemMsg_Start, 12,
            MIDIMessage_NoteOn, 13, MIDISystemMsg_SystemReset,
            MIDIMessage_NoteOn, 14,  MIDISystemMsg_ActiveSensing,
            
            MIDIMessage_ProgramChange, MIDISystemMsg_TimingClock,  MIDISystemMsg_TimingClock,
            MIDIMessage_ProgramChange, MIDISystemMsg_TimingClock,
            
            MIDISystemMsg_TuneRequest, MIDISystemMsg_TimingClock,
            
            // Same thing with running status
            MIDIMessage_NoteOff, 10, 64, MIDISystemMsg_TimingClock,
            11, 65,
            MIDISystemMsg_Start, 12, 66,
            13, MIDISystemMsg_Stop, 67,
            14,  MIDISystemMsg_ActiveSensing,
            
            MIDIMessage_ProgramChange, MIDISystemMsg_TimingClock, 10, MIDISystemMsg_TimingClock,
            11, MIDISystemMsg_TimingClock,
            
            MIDISystemMsg_TuneRequest, MIDISystemMsg_TimingClock // Data block ends with real-time byte; tricky case.
        };
        
        
        NSArray * exampleMessages = @[
                                      [CMIDIMessage messageWithNoteOn:10 velocity:64 channel:1],
                    // SHORT          [CMIDIMessage messageWithNoteOn:11 velocity:65 channel:1],
                                      [CMIDIMessage messageWithNoteOn:12 velocity:66 channel:1],
                    // SHORT          [CMIDIMessage messageWithNoteOn:13 velocity:67 channel:1],
                                      [CMIDIMessage messageWithNoteOn:14 velocity:68 channel:1],
                                      [CMIDIMessage messageWithProgramChange:10 channel:1],
                    // SHORT          [CMIDIMessage messageWithProgramChange:11 channel:1],
                                      [CMIDIMessage messageTuneRequest], // 1 byte message
                                      
                                      // Same thing with running status
                                      [CMIDIMessage messageWithNoteOff:10 releaseVelocity:64 channel:1],
                                      [CMIDIMessage messageWithNoteOff:11 releaseVelocity:65 channel:1],
                                      [CMIDIMessage messageWithNoteOff:12 releaseVelocity:66 channel:1],
                                      [CMIDIMessage messageWithNoteOff:13 releaseVelocity:67 channel:1],
                       // SHORT       [CMIDIMessage messageWithNoteOff:14 releaseVelocity:68 channel:1],
                                      [CMIDIMessage messageWithProgramChange:10 channel:1],
                                      [CMIDIMessage messageWithProgramChange:11 channel:1],
                                      [CMIDIMessage messageTuneRequest], // 1 byte message
                                      
                                      
                                      // Same thing with real time message interruptions.
                                      [CMIDIMessage messageTimingClock],
                                      [CMIDIMessage messageStart],
                                      [CMIDIMessage messageSystemReset],
                                      [CMIDIMessage messageActiveSensing],
                                     [CMIDIMessage messageTimingClock],
                                      [CMIDIMessage messageTimingClock],
                                      [CMIDIMessage messageTimingClock],
                                     [CMIDIMessage messageTimingClock],
                               
                                      [CMIDIMessage messageTuneRequest], // 1 byte message
                                      
                                        
                                      [CMIDIMessage messageTimingClock],
                                      [CMIDIMessage messageWithNoteOff:10 releaseVelocity:64 channel:1],
                                      [CMIDIMessage messageStart],
                                      [CMIDIMessage messageWithNoteOff:11 releaseVelocity:65 channel:1],
                                      [CMIDIMessage messageWithNoteOff:12 releaseVelocity:66 channel:1],
                                      [CMIDIMessage messageStop],
                                      [CMIDIMessage messageWithNoteOff:13 releaseVelocity:67 channel:1],
                                      [CMIDIMessage messageActiveSensing],
                                      [CMIDIMessage messageTimingClock],
                                      [CMIDIMessage messageTimingClock],
                                      [CMIDIMessage messageWithProgramChange:10 channel:1],
                                      [CMIDIMessage messageTimingClock],
                                      [CMIDIMessage messageWithProgramChange:11 channel:1],
                                      [CMIDIMessage messageTimingClock],
                                      [CMIDIMessage messageTuneRequest] // 1 byte message
                                      ];
        
    //    NSData * d = [NSData dataWithBytes:exampleDataBlock length:exampleDataBlock_length];
    //    [parser parseMessageData:d.bytes length:d.length];
        
        [CMIDIDataParser_exampleMessages addObject:exampleMessages];
        [CMIDIDataParser_exampleData addObject:[NSData dataWithBytes:exampleDataBlock length:exampleDataBlock_length]];
    }

  
    
    
    // SYSEX IN TWO PACKETS
    {
        NSUInteger exampleDataBlock_length = 4;
        Byte exampleDataBlock[4] = {
            MIDISystemMsg_SystemExclusive,  01, 10, 11  // Not terminaated
        };
        NSArray * exampleMessages = @[];
        
        [CMIDIDataParser_exampleMessages addObject:exampleMessages];
        [CMIDIDataParser_exampleData addObject:[NSData dataWithBytes:exampleDataBlock length:exampleDataBlock_length]];
    }
    
    {
        NSUInteger exampleDataBlock_length = 5;
        Byte exampleDataBlock[5] = {
            MIDISystemMsg_SysExContinued, 12, 13, 14, MIDISystemMsg_EndofSysEx  // Terminated
        };
        NSArray * exampleMessages = @[sysExMsg];
        
        
        [CMIDIDataParser_exampleMessages addObject:exampleMessages];
        [CMIDIDataParser_exampleData addObject:[NSData dataWithBytes:exampleDataBlock length:exampleDataBlock_length]];
       
    }
    
    // SYSEX IN TWO PACKETS
    // with inconveniently intervening real time messages
    {
        NSUInteger exampleDataBlock_length = 5;
        Byte exampleDataBlock[5] = {
            MIDISystemMsg_SystemExclusive,  01, 10, 11, MIDISystemMsg_TimingClock  // Apparently terminated by real-time message.
        };
        NSArray * exampleMessages = @[[CMIDIMessage messageTimingClock]];
        
        
        [CMIDIDataParser_exampleMessages addObject:exampleMessages];
        [CMIDIDataParser_exampleData addObject:[NSData dataWithBytes:exampleDataBlock length:exampleDataBlock_length]];
    }
    
    {
        NSUInteger exampleDataBlock_length = 7;
        Byte exampleDataBlock[7] = {
            MIDISystemMsg_TimingClock, MIDISystemMsg_SysExContinued, 12, 13, 14, MIDISystemMsg_TimingClock, MIDISystemMsg_EndofSysEx  // Terminated
        };
        NSArray * exampleMessages = @[[CMIDIMessage messageTimingClock],[CMIDIMessage messageTimingClock],sysExMsg];
        
        
        [CMIDIDataParser_exampleMessages addObject:exampleMessages];
        [CMIDIDataParser_exampleData addObject:[NSData dataWithBytes:exampleDataBlock length:exampleDataBlock_length]];
        
    }
    
    // SYSEX IN TWO PACKETS
    // where client forgot MIDISystemMsg_SysExContinued. Sysex returned in next packet.
    {
        NSUInteger exampleDataBlock_length = 4;
        Byte exampleDataBlock[4] = {
            MIDISystemMsg_SystemExclusive,  01, 10, 11  // Not terminaated
        };
        NSArray * exampleMessages = @[];
        
        
        [CMIDIDataParser_exampleMessages addObject:exampleMessages];
        [CMIDIDataParser_exampleData addObject:[NSData dataWithBytes:exampleDataBlock length:exampleDataBlock_length]];
    }
    
    {
        NSUInteger exampleDataBlock_length = 4;
        Byte exampleDataBlock[4] = {
            12, 13, 14, MIDISystemMsg_EndofSysEx
        };
        NSArray * exampleMessages = @[sysExMsg];
        
        [CMIDIDataParser_exampleMessages addObject:exampleMessages];
        [CMIDIDataParser_exampleData addObject:[NSData dataWithBytes:exampleDataBlock length:exampleDataBlock_length]];
        
    }

    // SYSEX TERMINATED BY END OF DATA
    // System exclusive where the caller forgot to terminate it; sysex is returned on the next packet.
    {
        NSUInteger exampleDataBlock_length = 7;
        Byte exampleDataBlock[7] = {
            MIDISystemMsg_SystemExclusive,  01, 10, 11, 12, 13, 14  // Not terminaated
        };
        NSArray * exampleMessages = @[];
        
        [CMIDIDataParser_exampleMessages addObject:exampleMessages];
        [CMIDIDataParser_exampleData addObject:[NSData dataWithBytes:exampleDataBlock length:exampleDataBlock_length]];
    }
    
    {
        NSUInteger exampleDataBlock_length = 3;
        Byte exampleDataBlock[3] = {
            MIDIMessage_NoteOn, 10, 64
        };
        NSArray * exampleMessages = @[sysExMsg, [CMIDIMessage messageWithNoteOn:10 velocity:64 channel:1]];
        
        [CMIDIDataParser_exampleMessages addObject:exampleMessages];
        [CMIDIDataParser_exampleData addObject:[NSData dataWithBytes:exampleDataBlock length:exampleDataBlock_length]];
        
    }
    
    // SYSEX TERMINATED BY ANOTHER MESSAGE
    // No problem
    {
        NSUInteger exampleDataBlock_length = 9;
        Byte exampleDataBlock[9] = {
            MIDISystemMsg_SystemExclusive,  01, 10, 11, 12, 13, 14, MIDIMessage_ProgramChange, 10  // Not terminaated
        };
        NSArray * exampleMessages = @[sysExMsg, [CMIDIMessage messageWithProgramChange:10 channel:1]];
        
        [CMIDIDataParser_exampleMessages addObject:exampleMessages];
        [CMIDIDataParser_exampleData addObject:[NSData dataWithBytes:exampleDataBlock length:exampleDataBlock_length]];
    }
    
    
    // ONE-BYTE MESSAGE FOLLOWED BY MEANINGLESS DATA BYTES
    // Simplest to ignore them; return the valid messages.
    // Note that messages with length > 1 followed by meaningless bytes must be parsed as "running status"
    {
        NSUInteger exampleDataBlock_length = 9;
        Byte exampleDataBlock[9] = {
            MIDISystemMsg_TuneRequest, 10, 60, 64, 21, 8, MIDIMessage_ProgramChange, 10, 11
        };
        NSArray * exampleMessages = @[[CMIDIMessage messageTuneRequest],
                                      [CMIDIMessage messageWithProgramChange:10 channel:1],
                                      [CMIDIMessage messageWithProgramChange:11 channel:1]
                                      ];
        
        [CMIDIDataParser_exampleMessages addObject:exampleMessages];
        [CMIDIDataParser_exampleData addObject:[NSData dataWithBytes:exampleDataBlock length:exampleDataBlock_length]];
    }
    
    
    
    // ONE-BYTE MESSAGE FOLLOWED BY MEANINGLESS DATA BYTES, WITH REAL-TIME BYTES
    // Simplest to ignore them; return the valid messages.
    // Note that messages with length > 1 followed by meaningless bytes must be parsed as "running status"
    {
        NSUInteger exampleDataBlock_length = 9;
        Byte exampleDataBlock[9] = {
            MIDISystemMsg_TuneRequest, MIDISystemMsg_TimingClock, 60, MIDISystemMsg_TimingClock, 21, 8, MIDIMessage_ProgramChange, 10, 11
        };
        NSArray * exampleMessages = @[[CMIDIMessage messageTimingClock],
                                      [CMIDIMessage messageTuneRequest],
                                      [CMIDIMessage messageTimingClock],
                                      [CMIDIMessage messageWithProgramChange:10 channel:1],
                                      [CMIDIMessage messageWithProgramChange:11 channel:1]
                                      ];
        
        
        [CMIDIDataParser_exampleMessages addObject:exampleMessages];
        [CMIDIDataParser_exampleData addObject:[NSData dataWithBytes:exampleDataBlock length:exampleDataBlock_length]];
    }


    // FAILS WITH NO OPENING STATUS BYTE; CORRUPT DATA TEST.
    {
        NSUInteger exampleDataBlock_length = 3;
        Byte exampleDataBlock[3] = {
            3, 10, 64
        };
        NSNull * exampleMessages = [NSNull null];
        [CMIDIDataParser_exampleMessages addObject:exampleMessages];
        [CMIDIDataParser_exampleData addObject:[NSData dataWithBytes:exampleDataBlock length:exampleDataBlock_length]];
        
    }
    
    
    // FAILS WITH OPENING REAL TIME STATUS BYTE THEN GARBAGE
    {
        NSUInteger exampleDataBlock_length = 3;
        Byte exampleDataBlock[3] = {
            MIDISystemMsg_TimingClock, 10, 64
        };
        NSNull * exampleMessages = [NSNull null];
        [CMIDIDataParser_exampleMessages addObject:exampleMessages];
        [CMIDIDataParser_exampleData addObject:[NSData dataWithBytes:exampleDataBlock length:exampleDataBlock_length]];
        
    }


}


+ (NSArray *) exampleData
{
    if (!CMIDIDataParser_exampleData) {
        [self initExampleData];
    }
    return CMIDIDataParser_exampleData;
}


+ (NSArray *) exampleMessages
{
    if (!CMIDIDataParser_exampleMessages) {
        [self initExampleData];
    }
    return CMIDIDataParser_exampleMessages;
}



+ (BOOL) test
{
    CMIDIDataParser * parser = [CMIDIDataParser new];
    if (!CMIDIDataParser_exampleMessages) {
        [self initExampleData];
    }
    
    for (NSUInteger i = 0; i < CMIDIDataParser_exampleMessages.count; i++) {
        NSArray * asExpected = CMIDIDataParser_exampleMessages[i];
        
        if ([asExpected isKindOfClass:[NSNull class]]) {
            asExpected = nil;
        }
        
        NSData * d = CMIDIDataParser_exampleData[i];
        printf("IGNORE ANY ERROR >>>>>>>>>>>>>>>>>>>>>>>>>>\n");
        NSArray * asParsed = [parser parseMessageData:d.bytes length:d.length];
        printf("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n");
        
        if (!CASSERTEQUAL(asParsed, asExpected)) return NO;
    }
    
    return YES;
    
}


@end
