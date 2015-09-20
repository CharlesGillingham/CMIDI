//
//  CMIDIClock+Debug.m
//  SqueezeBox 0.0.1
//
//  Created by CHARLES GILLINGHAM on 6/16/15.
//  Copyright (c) 2015 SqueezeBox. All rights reserved.
//

#import "CMIDIClock+Debug.h"
#import "CMIDIClockTickTester.h"
#import <AppKit/AppKit.h>
#import "CDebugMessages.h"
#import "CMIDIMessageCollector.h"

#ifdef DEBUG

@interface CMIDIBeepOnClockTick : NSObject <CMIDITimeReceiver>
@end

@implementation CMIDIBeepOnClockTick

- (void) clockTicked:(CMIDIClock *)c
{
    NSBeep();
    printf("BEEP %lld\n", c.currentTick);
}

@end


@implementation CMIDIClock (Debug)

- (BOOL) check { return YES; }

+ (BOOL) timingInspectionTest
{
    CDebugInspectionTestHeader("CMIDIClock inspection test", "Beeps should occur every second; check that this seems reasonable");
    CMIDIClock * cl = [CMIDIClock new];
    cl.nanosecondsPerTick = 1000000000;
    printf("Beats per minute: %f\n", cl.beatsPerMinute);
    printf("Ticks per second: %f\n", (cl.beatsPerMinute * 24) / 60);
    [cl.receivers addObject:[CMIDIBeepOnClockTick new]];
    [cl start];
    sleep(10);
    return YES;
}



+ (BOOL) checkSteadyTiming: (CMIDIMessageCollector *) mc
                     tempo: (CTime) tempo
{
    NSUInteger count = mc.hostTimesExpected.count;
    CASSERT_RET(count == mc.hostTimesReceived.count);
    CASSERT_RET(count == mc.clockTicksReceived.count);
    CASSERT_RET(count > 0);
    
    
    // Check that the expected times are all correct.
    CTime prevTime = [mc.hostTimesExpected[0] longLongValue];
    for (NSUInteger i = 1; i < count; i++) {
        CTime hte = [mc.hostTimesExpected[i] longLongValue];
        CASSERT_RET(hte - prevTime == tempo);
        prevTime = hte;
    }
 
    BOOL fOK = YES;

    // Find out the average difference from time received to time expected
    CTime maxDiff = 0;
    CTime maxDiff2 = 0;
    CTime totalDiffs = 0;
    for (NSUInteger i = 0; i < count; i++) {
        CTime hte = [mc.hostTimesExpected[i] longLongValue];
        CTime htr = [mc.hostTimesReceived[i] longLongValue];
        CTime diff = (hte > htr ? hte - htr : htr - hte);
        if (diff > maxDiff) {
            maxDiff = diff;
        } else if (diff > maxDiff2) {
            maxDiff2 = diff;
        }
        totalDiffs += diff;
    }
    CTime avgDiff = totalDiffs/count;
    
    printf("\nChecking difference from expected time:\n");
    printf("Number of ticks:         %8lu ticks\n", count);
    printf("Host time per tick:      %8lld ns\n", tempo);
    printf("Average nanoseconds off: %8lld ns\n", avgDiff);
    printf("Worst nanoseconds off:   %8lld ns\n", maxDiff);
    printf("2nd to worst:            %8lld ns\n", maxDiff2);
    
    if (!CASSERT_MSG(maxDiff < tempo, @"Clock was more than one tick off")) fOK = NO;
    if (!CASSERT_MSG(maxDiff < 1000000, @"Clock was more than a millisecond off")) fOK = NO;
    
    maxDiff = 0;
    maxDiff2 = 0;
    totalDiffs = 0;
    prevTime = [mc.hostTimesReceived[0] longLongValue];
    for (NSUInteger i = 1; i < count; i++) {
        CTime htr = [mc.hostTimesReceived[i] longLongValue];
        CTime delta = (htr - prevTime);
        prevTime = htr;
        
        CTime diff = (tempo < delta ? delta-tempo : tempo-delta);
        if (diff > maxDiff) {
            maxDiff = diff;
        } else if (diff > maxDiff2) {
            maxDiff2 = diff;
        }
        totalDiffs += diff;
    }
    avgDiff = totalDiffs/count;
    
    printf("\nChecking difference between delta times received and tempo:\n");
    printf("Number of ticks:         %8lu ticks\n", count);
    printf("Host time per tick:      %8lld ns\n", tempo);
    printf("Average nanoseconds off: %8lld ns\n", avgDiff);
    printf("Worst nanoseconds off:   %8lld ns\n", maxDiff);
    printf("2nd to worst:            %8lld ns\n", maxDiff2);
    
    if (!CASSERT_MSG(maxDiff < tempo, @"Clock was more than one tick off")) fOK = NO;
    if (!CASSERT_MSG(maxDiff < 1000000, @"Clock was more than 1 millisecond off")) fOK = NO;
    
    return fOK;
}



+ (BOOL) checkSteadyTicks: (CMIDIMessageCollector *) mc
{
    printf("\nChecking ticks are in order.\n");
    NSUInteger count = mc.hostTimesExpected.count;
    CASSERT_RET(count == mc.hostTimesReceived.count);
    CASSERT_RET(count == mc.clockTicksReceived.count);
    CASSERT_RET(count > 0);

    BOOL fOK = YES;
    CTime prevTick = [mc.clockTicksReceived[0] longLongValue];
    for (NSUInteger i = 1; i < count; i++) {
        CTime tick = [mc.clockTicksReceived[i] longLongValue];
        if(!CASSERTEQUAL(tick,prevTick+1)) fOK = NO;
        prevTick++;
    }
    
    if (fOK == NO) {
        CTime prevTick = [mc.clockTicksReceived[0] longLongValue];
        for (NSUInteger i = 1; i < count; i++) {
            CTime tick = [mc.clockTicksReceived[i] longLongValue];
            printf("%lld %lld\n", tick, prevTick+1);
            prevTick++;
        }
    }
    
    return fOK;
}



+ (BOOL) basicTest: (CMIDINanoseconds) tempo
{
    CMIDIClock * cl = [CMIDIClock new];
    CMIDIMessageCollector * mc = [CMIDIMessageCollector new];
    cl.nanosecondsPerTick = tempo;
    [cl.receivers addObject:mc];
 
    [cl start];
    sleep(5);
    [cl stop];
    sleep(0.01);
    
    return (
            [CMIDIClock checkSteadyTiming:mc tempo:tempo] &&
            [CMIDIClock checkSteadyTicks:mc]
            );
}


+ (BOOL) testTickOrderTempoChange
{
    CMIDIClock * cl = [CMIDIClock new];
    CMIDIMessageCollector * mc = [CMIDIMessageCollector new];
    cl.nanosecondsPerTick = CMIDIClock_100_BPM_at_24_TPB;
    [cl.receivers addObject:mc];
    
    [cl start];
    sleep(1);
    cl.nanosecondsPerTick = CMIDIClock_200_BPM_at_24_TPB;
    sleep(1);
    cl.nanosecondsPerTick = CMIDIClock_80_BPM_at_24_TPB;
    sleep(1);
    [cl stop];
    [cl start];
    sleep(1);
    [cl stop];
    cl.nanosecondsPerTick = CMIDIClock_100_BPM_at_24_TPB;
    [cl start];
    sleep(1);
    cl.nanosecondsPerTick = 10000000000; // 1 tick per second
    sleep(1);
    cl.nanosecondsPerTick = CMIDIClock_200_BPM_at_24_TPB;
    sleep(1);
    [cl stop];
    sleep(0.01);

    return [CMIDIClock checkSteadyTicks:mc];
}


+ (BOOL) testTickOrderStartStop
{
    CDebugInspectionTestHeader("Test tick order", "Time set while running, you should see: \"ztimeset;.\".");
    printf("\nTempo set while running, set back required: you should see \"y.temposet\", but it's also okay if you see \"y.9.temposet\".\n\n");
    printf("If you see \"z0.timeset\", then the tick was incremented, clockTicked for the new tick, and THEN we got timeset followed by clockTicked\n");
 
    CMIDIClockTickTester * tstr = [CMIDIClockTickTester new];
    
    CMIDIClock * testClock = [CMIDIClock new];
    tstr.testClock = testClock;
    
    [testClock.receivers addObject:tstr];
    
    testClock.nanosecondsPerTick = CMIDIClock_200_BPM_at_24_TPB;
    testClock.currentTick = 0;
    
    [testClock start];
    sleep(1);
    [testClock stop];  // Stop/Start back-to-back
    [testClock start];
    [testClock stop];
    sleep(1);
    testClock.currentTick = 27*24; // Set tick while stopped
    [testClock start];
    sleep(1);
    [testClock stop];
    sleep(1);
    [testClock start];
    sleep(1);
    testClock.currentTick = 13.3*24; // Set tick while running
    sleep(1);
    [testClock stop];
    sleep(1);
    testClock.nanosecondsPerTick = CMIDIClock_50_BPM_at_24_TPB; // Set tempo while stopped
    [testClock start];
    sleep(1);
    [testClock stop];   // Stop start back-to-back
    [testClock start];
    sleep(1);
    testClock.nanosecondsPerTick = CMIDIClock_200_BPM_at_24_TPB;  // Set tempo while running; attempted create the "short tick" circumstance.
    sleep(1);
    [testClock stop];
    sleep(0.5);
    
    // Make double sure it deallocates.
    [testClock.receivers removeObject:tstr];
    testClock = nil;
    tstr.testClock = nil;
   
    return tstr.testPassed;
}




+ (BOOL) testBPM
{
    CMIDIClock * cl = [CMIDIClock new];
 
    cl.beatsPerMinute = 50;
    CASSERT_RET(cl.nanosecondsPerTick == CMIDIClock_50_BPM_at_24_TPB);
    cl.nanosecondsPerTick = CMIDIClock_50_BPM_at_24_TPB;
    CASSERT_RET(cl.beatsPerMinute == 50);
    
    cl.beatsPerMinute = 64;
    CASSERT_RET(cl.nanosecondsPerTick == CMIDIClock_64_BPM_at_24_TPB);
    cl.nanosecondsPerTick = CMIDIClock_64_BPM_at_24_TPB;
    CASSERT_RET(cl.beatsPerMinute == 64);

    cl.beatsPerMinute = 80;
    CASSERT_RET(cl.nanosecondsPerTick == CMIDIClock_80_BPM_at_24_TPB);
    cl.nanosecondsPerTick = CMIDIClock_80_BPM_at_24_TPB;
    CASSERT_RET(cl.beatsPerMinute == 80);
    
    cl.beatsPerMinute = 100;
    CASSERT_RET(cl.nanosecondsPerTick == CMIDIClock_100_BPM_at_24_TPB);
    cl.nanosecondsPerTick = CMIDIClock_100_BPM_at_24_TPB;
    CASSERT_RET(cl.beatsPerMinute == 100);
    
    cl.beatsPerMinute = 125;
    CASSERT_RET(cl.nanosecondsPerTick == CMIDIClock_125_BPM_at_24_TPB);
    cl.nanosecondsPerTick = CMIDIClock_125_BPM_at_24_TPB;
    CASSERT_RET(cl.beatsPerMinute == 125);

    cl.beatsPerMinute = 128;
    CASSERT_RET(cl.nanosecondsPerTick == CMIDIClock_128_BPM_at_24_TPB);
    cl.nanosecondsPerTick = CMIDIClock_128_BPM_at_24_TPB;
    CASSERT_RET(cl.beatsPerMinute == 128);
    
    cl.beatsPerMinute = 160;
    CASSERT_RET(cl.nanosecondsPerTick == CMIDIClock_160_BPM_at_24_TPB);
    cl.nanosecondsPerTick = CMIDIClock_160_BPM_at_24_TPB;
    CASSERT_RET(cl.beatsPerMinute == 160);
    
    cl.beatsPerMinute = 200;
    CASSERT_RET(cl.nanosecondsPerTick == CMIDIClock_200_BPM_at_24_TPB);
    cl.nanosecondsPerTick = CMIDIClock_200_BPM_at_24_TPB;
    CASSERT_RET(cl.beatsPerMinute == 200);
    
    cl.beatsPerMinute = 250;
    CASSERT_RET(cl.nanosecondsPerTick == CMIDIClock_250_BPM_at_24_TPB);
    cl.nanosecondsPerTick = CMIDIClock_250_BPM_at_24_TPB;
    CASSERT_RET(cl.beatsPerMinute == 250);
    
    return YES;
}

@end




#endif
