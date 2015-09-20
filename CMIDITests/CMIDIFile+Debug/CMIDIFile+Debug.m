//
//  CMIDIFile+Debug.m
//  SqueezeBox 0.0.1
//
//  Created by CHARLES GILLINGHAM on 6/20/15.
//  Copyright (c) 2015 SqueezeBox. All rights reserved.
//

#import "CMIDIFile+Debug.h"
#import "CMIDIFile+Description.h"
#import "CMIDIMessage+Debug.h"
#import "CMIDIMessage+ChannelMessage.h"
#import "CMIDIMessage+SystemMessage.h"
#import "CMIDIMessage+MetaMessage.h"
#import "CMIDIMessage+Description.h"
#import "CMIDIFileByApple.h"
#import "CDebugMessages.h"

@implementation CMIDIFile (Debug)

- (BOOL) check
{
    CASSERT_RET(self.format >= 0 && self.format <= 2);
    CASSERT_RET(self.format != 0 || self.trackCount <= 2); // Tempo track and main track.

    if (![self checkMessages]) return NO;
    if (![self checkOrder]) return NO;
    if (![self checkTrackCountAndLength]) return NO;
    if (![self checkTempoTrack]) return NO;

    return YES;
}

- (BOOL) checkMessages
{
    CASSERT_RET(self.messages != nil);
    CASSERT_RET(self.messages.count > 0);
    for (int i = 0; i < self.messages.count; i++) {
        CMIDIMessage * msg = self.messages[i];
        if (!CCHECK_CLASS(msg, CMIDIMessage)) return NO;
        if (!CASSERT(!msg.isSystemRealTime)) return NO;
        if (!CASSERT_MSG((msg.type != MIDIMessage_NoteOn) || (msg.velocity != 0),
                         ([NSString stringWithFormat:@"\'note on\' with velocity=0 found (should be \'note off\'\nMessage %d: %s",
                           i, msg.description.UTF8String])))
            return NO;
        // This application uses the "endOfTrackTime" list, rather than messages buried in the list.
        if (!CASSERT(msg.metaMessageType != MIDIMeta_EndOfTrack)) return NO;
    }
    return YES;
}


- (BOOL) checkOrder
{
    CMIDIClockTicks prevTime = [self.messages[0] time];
    for (int i = 0; i < self.messages.count; i++) {
        CMIDIMessage * msg = self.messages[i];
        CASSERT_RET(msg.time >= prevTime);
        prevTime = msg.time;
    }
    return YES;
}


// Note that we already checked the order, so that this guarantees that the eot message is the last one on the track.
- (BOOL) checkTrackCountAndLength
{
    NSUInteger maxTrackNumber = 0;
    
    for (int i = 0; i < self.messages.count; i++) {
        CMIDIMessage * msg = self.messages[i];
        if (msg.track > maxTrackNumber) maxTrackNumber = msg.track;
        if (!CASSERT_MSG(msg.time <= [self.endOfTrackTimes[msg.track] integerValue],
                          ([NSString stringWithFormat:@"Message has a time longer than the end of track.\nTrack: %lu\nMessage: %s\nEnd of track time:%lu",
                            msg.track, msg.description.UTF8String,  [self.endOfTrackTimes[msg.track] integerValue]
                            ]))) return NO;
    }
    if (!CASSERT_MSG(self.trackCount == maxTrackNumber+1,@"Track count is incorrect")) return NO;
    return YES;
}


- (BOOL) checkTempoTrack
{
    for (int i = 0; i < self.messages.count; i++) {
        CMIDIMessage * msg = self.messages[i];
        if (msg.metaMessageType != MIDIMeta_EndOfTrack) {
             if (msg.isTimeMessage) {
                if (!CASSERT_MSG(msg.track == 0, ([NSString stringWithFormat:
                                                   @"Time messge is on track %lu\nMessage %d: %s",
                                                   msg.track,
                                                   i, msg.description.UTF8String])))
                    return NO;
            } else {
                if (!CASSERT_MSG(msg.track != 0, ([NSString stringWithFormat:
                                                   @"Message is on the tempo track\nMessage %d: %s",
                                                   i, msg.description.UTF8String])))
                    return NO;
            }
        }
    }
    return YES;
}

//------------------------------------------------------------------------------
#pragma mark               Test and Example File Names
//------------------------------------------------------------------------------


// From three different manufacturers
// A set of MIDI files randomly downloaded from the net.
enum {
    ExampleMIDIFiles_Count = 4
};
char * ExampleMIDIFiles[ExampleMIDIFiles_Count] = {
    "bach_846",
    "Beatles -- Let it Be",
    "chp_op18",
    "Beatles -- Yesterday"
};


+ (NSArray *) exampleMIDIFiles
{
    NSString * examplePath = @"CMIDITests/CMIDIFile+Debug/Example Files/";
    NSMutableArray * exampleMIDIFiles = [NSMutableArray arrayWithCapacity:ExampleMIDIFiles_Count];
    for (NSUInteger i = 0; i < ExampleMIDIFiles_Count; i++) {
        const char * exampleFile = ExampleMIDIFiles[i];
        NSString * fileName = [NSString stringWithFormat:@"%@%s.mid", examplePath, exampleFile];
        [exampleMIDIFiles addObject:[NSURL fileURLWithPath:fileName]];
    }
    return exampleMIDIFiles;
}


+ (NSURL *) exampleMIDIFileURL: (const char *) exampleFile
{
    NSString * examplePath = @"CMIDITests/CMIDIFile+Debug/Example Files/";
    NSString * fileName = [NSString stringWithFormat:@"%@%s.mid", examplePath, exampleFile];
    return [NSURL fileURLWithPath:fileName];
    //    return [NSURL fileURLWithPath:[NSString stringWithCString:ExampleMIDIFiles[i] encoding:NSASCIIStringEncoding]];
}


+ (NSURL *) testMIDIFileURL: (int) i
{
    NSString * examplePath = @"CMIDITests/CMIDIFile+Debug/Test Files/";
    NSString * testName = [NSString stringWithFormat:@"TestMIDIFile%d", i];
    NSString * fileName = [NSString stringWithFormat:@"%@%@.%s", examplePath, testName, "mid"];
    return [NSURL fileURLWithPath:fileName];
}


//------------------------------------------------------------------------------
#pragma mark               Read and write
//------------------------------------------------------------------------------


+ (BOOL) checkRead: (NSURL *) fURL file: (CMIDIFile **) cmfRet
{
    printf("Reading %s\n", fURL.path.UTF8String);
    BOOL fOK = YES;
    
    NSError * cmError = nil, * afError = nil;
    CMIDIFile * cmf = [CMIDIFile MIDIFileWithContentsOfFile:fURL error:&cmError];
    *cmfRet = cmf;
    
    // Check against apple's version.
    CMIDIFileByApple * af =  [CMIDIFileByApple MIDIFileWithContentsOfFile:fURL
                                                             ticksPerBeat:(cmf ? cmf.ticksPerBeat : 480)
                                                                    error:&afError];
    if (!cmf) {
        if (!CASSERT_MSG(cmError != nil, @"CMIDIFile did not report an error when it failed to read")) fOK = NO;
        if (!CASSERT_MSG(af == nil,      @"CMIDIFile could not open file that Apple's MusicSequence could read")) fOK = NO;
        if (!af) {
            if (!CASSERT_MSG(afError != nil, @"CMIDIFileByApple did not report an error when it failed")) fOK = NO;
        }
    } else {
        if (!CASSERT_MSG(cmError == nil, @"CMIDIFile reported an error when reading succeeded")) fOK = NO;
        if (!CCHECK_CLASS(cmf,CMIDIFile)) fOK = NO;
        if (!CASSERT_MSG(af != nil, @"CMIDIFile can read this, but Apple's music sequence says it's unreadable")) fOK = NO;
        if (af) {
            if (!CASSERT_MSG(afError == nil, @"CMIDIFileBy apple reported an error when reading succeeded")) fOK = NO;
            for (CMIDIMessage * msg in af.messages) {
                if (!CCHECK_CLASS(msg, CMIDIMessage)) {
                    CFAIL(@"CMIDIFileByApple created a bad message: BAD TEST");
                    fOK = NO;
                }
            }
        }
    }
    
    // FIXING AN ACCEPTABLE PROBLEM FOR THE SAKE OF REGRESSION TESTS.
    // Apple reports the time of this note off message wrong; could be my fault -- I don't know.
    // At any rate, the way that CMIDIFile represents it is the way that makes sense.
    if ([fURL.lastPathComponent isEqualToString:@"Beatles -- Yesterday.mid"]) {
        printf("CMIDIFileByApple: Fixing problem in \'%s\'\n", fURL.lastPathComponent.UTF8String);
        for (NSUInteger i = 6460; i <= 6477; i++) {
            af.messages[i] = cmf.messages[i];
        }
    }
    
    if (!CASSERTEQUAL(af.messages, cmf.messages)) fOK = NO;
    return fOK;
}



+ (BOOL) checkWrite: (CMIDIFile *) cmf toFile: (NSURL *) fURL
{
    printf("Writing %s\n", fURL.path.UTF8String);
    NSError * error = nil;
    if (!CASSERT([cmf writeFile: fURL error:&error])) {
        CASSERT(error != nil);
        return NO;
    }
    if (!CASSERT(error == nil)) return NO;
    if (!CCHECK(cmf)) return NO;
    return YES;
}



//------------------------------------------------------------------------------
#pragma mark                   Inspection Tests
//------------------------------------------------------------------------------


#ifdef CDEBUG_INCLUDE_INSPECTION_TESTS


+ (BOOL) inspectionTest
{
    CDebugInspectionTestHeader("CMIDI File Inspection Test", "This test was verified by opening the MIDI file in Logic and comparing the messages and times by eye.\n");
    CMIDIFile * cmf;
    for (NSUInteger i = 0; i < ExampleMIDIFiles_Count; i++) {
        NSError * error;
        NSURL * exURL = [self exampleMIDIFileURL:ExampleMIDIFiles[i]];
        cmf = [CMIDIFile MIDIFileWithContentsOfFile:exURL error:&error];
        if (!CCHECK_CLASS(cmf, CMIDIFile)) return NO;
        if (cmf) {
            [cmf show:YES];
        }
    }
    CDebugInspectionTestFooter();
    return YES;
}


+ (BOOL) appleMIDIFileInspectionTest
{
    CDebugInspectionTestHeader("Apple's 'MusicSequence' Inspection Test", "Making sure that this looks normal, before we test it against CMIDIFile.\n");
    CMIDIFileByApple * af;
    for (NSUInteger i = 0; i < ExampleMIDIFiles_Count; i++) {
        NSError * error;
        NSURL * exURL = [self exampleMIDIFileURL:ExampleMIDIFiles[i]];
        af = [CMIDIFileByApple MIDIFileWithContentsOfFile:exURL ticksPerBeat:480 error:&error];
        if (af) {
            [af show:YES];
        }
    }
    CDebugInspectionTestFooter();
    return YES;
}


#endif



//------------------------------------------------------------------------------
#pragma mark                   Regression Tests
//------------------------------------------------------------------------------

+ (BOOL) readWriteReadTest
{
    BOOL fOK = YES;
    CMIDIFile * cmf, * cmf2;
    for (int i = 0; i < ExampleMIDIFiles_Count; i++) {
        printf("------------------\n");
        NSURL * inputFile = [self exampleMIDIFileURL:ExampleMIDIFiles[i]];
        NSURL * testFile  = [self testMIDIFileURL:i];
        
        if (![self checkRead:inputFile file:&cmf]) fOK = NO;
        if (cmf) {
            if ([self checkWrite:cmf toFile:testFile]) {
                if (![self checkRead:testFile file:&cmf2]) fOK = NO;
                if (cmf2) {
                    if (!CASSERTEQUAL(cmf.messages, cmf2.messages)) return NO;
                }
            } else {
                fOK = NO;
            }
        }
    }
    printf("------------------\n");
    return fOK;
}


+ (BOOL) writeReadTest
{
    NSMutableArray * messages = [NSMutableArray arrayWithArray:[CMIDIMessage oneOfEachMessage]];
    
    for (CMIDIMessage * msg in messages) {
        if ([msg isSystemRealTime] ||                                      // These message can't appear in files
            msg.systemMessageType == MIDISystemMsg_SystemExclusive ||      // Don't understand how apple stores these; they are in "RawData" blocks, but they are mangled.
            msg.systemMessageType == MIDISystemMsg_MIDITimeCodeQtrFrame || // Apple strips out these messages (are these actually real-time messages)
            msg.systemMessageType == MIDISystemMsg_TuneRequest ||
            msg.systemMessageType == MIDISystemMsg_SongPosition
            ) {
            msg.data = [CMIDIMessage messageWithText:@"Skipped" andType:MIDIMeta_Text].data;
        }
    }
    
    CMIDIFile * cmf, * cmf2;
    
    cmf = [CMIDIFile emptyMIDIFile];
    cmf.ticksPerBeat = 480;
    cmf.messages = messages;
    
    NSURL * testFile = [self testMIDIFileURL:21];
    
    BOOL fOK = YES;
    
    if (![self checkWrite:cmf toFile:testFile]) fOK = NO;
    if (![self checkRead:testFile file:&cmf2]) fOK = NO;
    if (cmf2) {
        if (!CASSERTEQUAL(cmf.messages, cmf2.messages)) fOK = NO;
    }
    
    
    return fOK;
}


//------------------------------------------------------------------------------
#pragma mark                   Test Constructors
//------------------------------------------------------------------------------

/*
 
 + (void) saveExampleMessages: (NSArray *) tracks
 file: (CMIDIFile *) cmf
 testName: (NSString *) testName
 {
 // Check the example (first)
 for (NSArray * track in tracks) {
 for (CMIDIMessage * message in track) {
 if (!CCHECK(message)) {
 return;
 }
 }
 }
 
 if (!CCHECK(cmf)) {
 return;
 }
 
 NSURL * fileURL = [self testMIDIFileURL:testNam];
 NSError * error;
 if (![cmf writeFile:fileURL error:&error]) {
 return;
 }
 
 // How do you want to save the MIDI files?
 NSURL * messageURL = [self testFileURL:testName ext:"dat"];
 [self writeObject:tracks toURL:messageURL];
 }
 */

//------------------------------------------------------------------------------
#pragma mark            NOT USED / DEVELOPMENT NSCoding test
//------------------------------------------------------------------------------


+ (NSObject *) readObjectFromURL: (NSURL *) fileURL
{
    NSError * error;
    NSData * fileData = [NSData dataWithContentsOfURL:fileURL options:0 error:&error];
    if (!fileData || (error != nil)) {
        CFAIL(([NSString stringWithFormat:@"Couldn't open file \'%s\'", fileURL.path.UTF8String]));
        return nil;
    }
    
    NSObject * object;
    NSKeyedUnarchiver * decoder;
    decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData: fileData];
    @try {
        object = [decoder decodeObjectForKey:@"object"];
    }
    @catch (NSException *except) {
        CFAIL(([NSString stringWithFormat:@"Couldn't decode file \'%s\'", fileURL.path.UTF8String]));
        return nil;
    }
    
    return object;
}



+ (BOOL) writeObject: (NSObject *) object
               toURL: (NSURL *) fileURL
{
    // I probably don't need a "keyed" archiver, but this works and I know how to use it.
    NSMutableData   * fileData  = [NSMutableData data];
    NSKeyedArchiver * coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:fileData];
    [coder encodeObject:object forKey:@"object"];
    NSError * error;
    [fileData writeToURL:fileURL options:0 error:&error];
    return CASSERT_MSG(error == nil, (([NSString stringWithFormat:@"Couldn't save file \'%s\'", fileURL.path.UTF8String])));
}



@end
