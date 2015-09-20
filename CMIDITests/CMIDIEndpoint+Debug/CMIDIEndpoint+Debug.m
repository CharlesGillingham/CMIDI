//
//  CMIDIEndpoint+Debug.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 6/28/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDIEndpoint+Debug.h"
#import "CDebugMessages.h"
#import "CMIDIMessageCollector.h"
#import "CMIDIMessage+Debug.h"

@implementation CMIDIInternalEndpoint (Debug)

- (BOOL) check { return YES; }

+ (BOOL) test1
{
    CMIDIInternalEndpoint * endp = [CMIDIInternalEndpoint endpointWithName:@"Test Endpoint"];
    if (!CCHECK_CLASS(endp, CMIDIInternalEndpoint)) return NO;
    CMIDIMessageCollector * collector = [CMIDIMessageCollector new];
    endp.outputUnit = collector;
    
    NSArray * messages = [CMIDIMessage oneOfEachMessageForRealTime];
    
    for (CMIDIMessage * msg in messages) {
        [endp respondToMIDI:msg];
    }
    
    // Give it a few seconds to finish.
    sleep(3);
    
    if (!CASSERTEQUAL(messages, collector.msgsReceived)) return NO;
    
    return YES;
}


+ (BOOL) test2
{
    CMIDIInternalEndpoint * endp = [CMIDIInternalEndpoint endpointWithName:@"Test Endpoint"];
    if (!CCHECK_CLASS(endp, CMIDIInternalEndpoint)) return NO;
    CMIDIMessageCollector * collector = [CMIDIMessageCollector new];
    endp.outputUnit = collector;
    
    NSArray * messages = [CMIDIMessage oneOfEachMessageForRealTime];
 
    // Send them all at exactly the same time. Try to see if there are multiple messages in one packet.
    CMIDINanoseconds t = CMIDINow() + 100000;
    for (CMIDIMessage * msg in messages) {
        msg.time = t;
        [endp respondToMIDI:msg atTime: t];
    }
    
    // Give it a few seconds to finish.
    sleep(3);
    
    if (!CASSERTEQUAL(messages, collector.msgsReceived)) return NO;
    
    return YES;
}


+ (void) inspectionTest
{
    CDebugInspectionTestHeader("List sources", "List of the endpoints currently found on this machine.");
    printf("SOURCES:\n");
    printf("%s\n", [[CMIDIExternalSource dictionary] allKeys].description.UTF8String);
    printf("DESTINATIONS:\n");
    printf("%s\n", [[CMIDIExternalDestination dictionary] allKeys].description.UTF8String);
    printf("INTERNAL:\n");
    printf("%s\n", [[CMIDIInternalEndpoint dictionary] allKeys].description.UTF8String);
    printf("ADDING AN ENDPOINT:\n");
    [CMIDIInternalEndpoint endpointWithName:@"NEW ENDPOINT"];
    printf("SOURCES:\n");
    printf("%s\n", [[CMIDIExternalSource dictionary] allKeys].description.UTF8String);
    printf("DESTINATIONS:\n");
    printf("%s\n", [[CMIDIExternalDestination dictionary] allKeys].description.UTF8String);
    printf("INTERNAL:\n");
    printf("%s\n", [[CMIDIInternalEndpoint dictionary] allKeys].description.UTF8String);
    
    CDebugInspectionTestFooter();
    
    
}

@end
