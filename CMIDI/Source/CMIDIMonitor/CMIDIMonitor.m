//
//  CMIDIMonitor.m
//  CMIDIFilePlayerDemo
//
//  Created by CHARLES GILLINGHAM on 9/13/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//
#import "CMIDIMonitor.h"
#import "CMIDIMessage+ChannelMessage.h"
#import "CMIDITempoMeter.h"
#import "CMIDIMessage+DescriptionWithTime.h"
#import "CMIDIMessage+Description.h"


@interface CMIDIMonitor ()
@property CMIDITempoMeter           * timeMap;

@property (readonly) NSString       * header;
@property NSDictionary              * strAttributes;

@property IBOutlet NSTextView       * messagesTextField;
@property IBOutlet NSScroller       * verticalScroller;
@end

NSString *const CMIDIMonitorNibFileName = @"CMIDIMonitor.nib";

@implementation CMIDIMonitor {
    // Using "weak" is not strictly necessary, but I'm having some difficulty getting all of these units to deallocate, and I think the synchronization locks will keep anyone from changing the outputUnit while we're using it.
    NSObject <CMIDIReceiver> * __weak _outputUnit;
    
}

@dynamic    outputUnit;
@dynamic    header;
@synthesize timeMap;
@synthesize hideNoteOff;
@synthesize strAttributes;
@synthesize messagesTextField;
@synthesize verticalScroller;

// -------------------------------------------------------------------------------------
//      INITIALIZATION
// -------------------------------------------------------------------------------------

- (id) init
{
    self = [super initWithNibName:CMIDIMonitorNibFileName bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        self.timeMap = [[CMIDITempoMeter alloc] initWithTicksPerBeat:480];
        hideNoteOff = NO;
        _outputUnit = nil;
    
        // init string attributes
        NSFont *font = [NSFont fontWithName:@"Andale Mono" size:10.0];
        strAttributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [verticalScroller setFloatValue:1.0];
}

// -------------------------------------------------------------------------------------
//                              HEADER
// -------------------------------------------------------------------------------------
// KVC Compliant

- (NSAttributedString *) header
{
    NSString * hdr = [CMIDIMessage tableHeaderWithTimeMap: self.timeMap];
    return [[NSAttributedString new] initWithString: hdr attributes: strAttributes];
}


+ (NSSet *) keyPathsForValuesAffectingHeader
{
    return [NSSet setWithObjects:@"timeMap.timeStringFormat", nil];
}


// -------------------------------------------------------------------------------------
// IBActions
// -------------------------------------------------------------------------------------


- (IBAction) clearPressed: (id) sender
{
    NSAttributedString * astr = [[NSAttributedString new] initWithString: @"" attributes: strAttributes];
    [[messagesTextField textStorage] setAttributedString: astr];
}


// -------------------------------------------------------------------------------------
// SHOW MESSAGE
// -------------------------------------------------------------------------------------

- (void) showMessage: (CMIDIMessage *) mm
{
    if (mm.isNoteOff && hideNoteOff) return;

    [timeMap respondToMIDI:mm];
    NSString * str = [mm tableRowStringWithTimeMap:timeMap];
    
    BOOL scrollForNewMessages;
    NSInteger pos = [verticalScroller floatValue];
    if (pos >= 0.99999) { // Allow for floating point errors
        scrollForNewMessages = YES;
    } else {
        scrollForNewMessages = NO;
    }
    
    str = [NSString stringWithFormat:@"\n%@", str];
    NSAttributedString *astr = [[NSAttributedString new] initWithString: str attributes: strAttributes];
    [[messagesTextField textStorage] appendAttributedString:astr];
    
    if (scrollForNewMessages) {
        [messagesTextField scrollRangeToVisible:NSMakeRange([[messagesTextField string] length], 0)];
        [verticalScroller setFloatValue: 1.0];
    }
}



//--------------------------------------------------------------------------------------
//      MIDI SENDER
//--------------------------------------------------------------------------------------

- (NSObject <CMIDIReceiver> *) outputUnit { return _outputUnit; }
- (void) setOutputUnit: (NSObject <CMIDIReceiver> *) obj
{
    if (!obj || [obj respondsToSelector:@selector(respondToMIDI:)]) {
        @synchronized(self) {
            _outputUnit = obj;
        }
    }
}



//------------------------------------------------------------------------------
//      MIDI RECEIVER
//------------------------------------------------------------------------------

- (void) respondToMIDI: (CMIDIMessage	*) mm
{
    // Use ARC to make sure no one changes or deallocates the receiver before we finish sending the message.
    NSObject <CMIDIReceiver> * receiver;
    CMIDIMonitor * mon; // Why does this need to be weak???
    @synchronized(self) {
        receiver = _outputUnit;
        mon = self;
    }
 
    // Pass through
    if (receiver) {
        [receiver respondToMIDI: mm];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [mon showMessage:mm];
    });
    
}

@end
