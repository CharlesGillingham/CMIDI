//
//  CMIDITimer.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 2/3/14.
//  Copyright (c) 2014 CHARLES GILLINGHAM. All rights reserved.
//

#import "CMIDITimer.h"
#import <CoreMIDI/CoreMIDI.h>
#import <CoreAudio/CoreAudio.h>
//#import "CDebugMessages.h"

#define MIDIStatus_TimingClock (0xF8)

#define CNOERR(expr)   (assert(expr == 0))



@implementation CMIDITimer {
    MIDIEndpointRef             _MIDIEndpoint;
    MIDIPortRef                 _MIDIOutputPort;
    MIDITimeStamp               _hostTimePerTick;
}
static MIDIClientRef SimpleMIDITimer_MIDIClient = 0;
static NSInteger     SimpleMIDITimer_Count = 0;
static UInt8         MIDIMessageTimingClock[3] = {MIDIStatus_TimingClock, 0, 0};


- (id) initWithReceiver: (id<CMIDITimerReceiver>) receiver
{
    if (self = [super init]) {
        [self initMIDI: receiver];
    }
    return self;
}


+ (instancetype) timerWithReceiver: (id<CMIDITimerReceiver>) receiver
{
    return [[self alloc] initWithReceiver:receiver];
}


- (id) init { assert(NO); }


- (void) dealloc
{
    [self cleanUpMIDI];
    printf("TIMER DEALLOCATED\n");
}

// -----------------------------------------------------------------------------
#pragma mark                 MIDI Read Procedure
// -----------------------------------------------------------------------------


static void SimpleMIDITimer_MIDIReadProc (const MIDIPacketList *pktlist,
                                          void *refCon,
                                          void *connRefCon)
{
    MIDIPacket *packet;
    int i, j;
    for (i = 0, packet = (MIDIPacket *)pktlist->packet;
         i < pktlist->numPackets;
         i++, packet = MIDIPacketNext(packet))
    {
        for (j = 0; j < packet->length; j++) {
            if (packet->data[j] == MIDIStatus_TimingClock) {
                id <CMIDITimerReceiver> receiver; // Retain until this message returns.
                receiver = (__bridge NSObject <CMIDITimerReceiver> *) refCon;
                [receiver timerDone: packet->timeStamp];
                // If the receiver queued up a new message in "timerDone",
                // hopefully we will remove it in dealloc. 
            }
        }
    }
}



- (void) initMIDI: (id<CMIDITimerReceiver>) receiver
{
    if (!SimpleMIDITimer_MIDIClient) {
        CNOERR( MIDIClientCreate(CFSTR("Simple MIDI Timer MIDIClient"),
                                 NULL, NULL,
                                 &SimpleMIDITimer_MIDIClient) );
    }
    
    NSString *name = [NSString stringWithFormat:
                      @"Simple MIDI Timer MIDIEndpointRef (%lu)",
                      SimpleMIDITimer_Count];
    
//    printf("CMIDI/CMIDITimer.m: Enpoint -- %s\n", name.UTF8String);
    
    CNOERR( MIDIDestinationCreate(SimpleMIDITimer_MIDIClient,
                                  (__bridge CFStringRef)(name),
                                  SimpleMIDITimer_MIDIReadProc,
                                  (__bridge void *) receiver,
                                  &_MIDIEndpoint) );
    name = [NSString stringWithFormat:
            @"Simple Clock MIDI output port (%lu)",
            SimpleMIDITimer_Count];
    CNOERR( MIDIOutputPortCreate(SimpleMIDITimer_MIDIClient,
                                 (__bridge CFStringRef)(name),
                                 &_MIDIOutputPort) );
    SimpleMIDITimer_Count++;
    printf("CMIDI/CMIDITimer.m: Count = %ld\n", (long)SimpleMIDITimer_Count);
}



- (void) cleanUpMIDI
{
    if (_MIDIEndpoint) {
        CNOERR( MIDIFlushOutput(_MIDIEndpoint) );
        CNOERR( MIDIEndpointDispose(_MIDIEndpoint) );
        CNOERR( MIDIPortDispose(_MIDIOutputPort) );
        _MIDIEndpoint = 0;
        _MIDIOutputPort = 0;
    }
}


// -----------------------------------------------------------------------------
#pragma mark                    Public
// -----------------------------------------------------------------------------


- (void) deleteMessagesInProgress
{
    CNOERR( MIDIFlushOutput(_MIDIEndpoint));
}



- (void) sendMessageAtHostTime: (CMIDINanoseconds) hostTime
{
    Byte packetBuffer[100];
    MIDIPacketList *packetList = (MIDIPacketList*)packetBuffer;
    MIDIPacket     *packet     = MIDIPacketListInit(packetList);
    MIDIPacketListAdd(packetList,
                      sizeof(packetBuffer),
                      packet,
                      AudioConvertNanosToHostTime(hostTime),
                      3,
                      MIDIMessageTimingClock);
    CNOERR( MIDISend( _MIDIOutputPort, _MIDIEndpoint, packetList) );

}

@end

