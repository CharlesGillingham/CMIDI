//
//  CMIDITests.m
//  SqueezeBox 0.0.1
//
//  Created by CHARLES GILLINGHAM on 6/17/15.
//  Copyright (c) 2015 SqueezeBox. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "CMIDI.h"
#import "CMIDITimer+Debug.h"
#import "CMIDIClock+Debug.h"
#import "CMIDITempoMeter+Debug.h"
#import "CMIDIMessage+Debug.h"
#import "CMIDIDataParser+Debug.h"
#import "CMIDIVSNumber+Debug.h"
#import "CMIDIFile+Debug.h"
#import "CMIDIEndpoint+Debug.h"
#import "CMIDISequence+Debug.h"

@interface CMIDIInspectionTests : XCTestCase
@end
@implementation CMIDIInspectionTests
- (void) testInspectCMIDIMessage           { [CMIDIMessage inspectionTest]; }
- (void) testInspectAppleMIDIFile          { XCTAssert([CMIDIFile appleMIDIFileInspectionTest]); }
- (void) testInspectCMIDIFile              { XCTAssert([CMIDIFile inspectionTest]);  }
- (void) testInspectCMIDIClock             { [CMIDIClock timingInspectionTest]; }
- (void) testInspectCMIDIEndpoints         { [CMIDIInternalEndpoint inspectionTest]; }

// Requires CMusic+Debug; easy to fix if I want.
//- (void) testInspectCMIDITempoMeterNanos   { [CMIDITempoMeter inspectNanos]; }
//- (void) testInspectCMIDITempoMeterTicks   { [CMIDITempoMeter inspectTicks]; }
//- (void) testInspectCMIDITempoMeterBeats   { [CMIDITempoMeter inspectBeats]; }
@end


@interface CMIDITests : XCTestCase
@end
@implementation CMIDITests
- (void) testMIDIMessage          { XCTAssert([CMIDIMessage test]); }
- (void) testMIDIDataParser       { XCTAssert([CMIDIDataParser test]); }
- (void) testCMIDIVSNumbers       { XCTAssert([CMIDIVSNumber test]); }
- (void) testCMIDIEndpoint1       { XCTAssert([CMIDIInternalEndpoint test1]); }
- (void) testCMIDIEndpoint2       { XCTAssert([CMIDIInternalEndpoint test2]); }
- (void) testReadWriteRead        { XCTAssert([CMIDIFile readWriteReadTest]); }
- (void) testWriteRead            { XCTAssert([CMIDIFile writeReadTest]); }
- (void) testCMIDIClockBPM        { XCTAssert([CMIDIClock testBPM]); }
- (void) testCMIDISequenceLists   { XCTAssert([CMIDISequence testWithMessageList:[CMIDIMessage oneOfEachMessage]]); }
- (void) testCMIDISequenceFiles   { XCTAssert([CMIDISequence testWithMIDIFile:[CMIDIFile exampleMIDIFiles][0]]); }
- (void) testCMIDITempoMeter      { XCTAssert([CMIDITempoMeter testTicksPerBeat]); }
@end


@interface CMIDITimingTests : XCTestCase
@end
@implementation CMIDITimingTests
- (void) testCMIDITimer             { XCTAssert([CMIDITimer testTiming]);  } // Currently failing; stubbed out.
- (void) testCMIDIClock             { XCTAssert([CMIDIClock basicTest:CMIDIClock_100_BPM_at_24_TPB]); }
- (void) testCMIDIClockTickOrder1   { XCTAssert([CMIDIClock testTickOrderTempoChange]);  }
- (void) testCMIDIClockTickOrder2   { XCTAssert([CMIDIClock testTickOrderStartStop]); }
@end

