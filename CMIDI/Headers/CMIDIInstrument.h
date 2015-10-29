//
//  CMIDIInstrument.h
//  CMIDI 0.0.0
//
//  Created by CHARLES GILLINGHAM on 10/11/15.
//  Copyright (c) 2015 Charles Gillingham. All rights reserved.
//

//  CMIDIInstrument keeps track of the current state of the controllers, and can restore them if required to.

#import "CMIDIReceiver CMIDISender.h"
#import "CMIDIClock.h"

@interface CMIDIInstrument : NSObject <CMIDIReceiver, CMIDITimeReceiver>
@property NSString * displayName;
@property NSObject <CMIDIReceiver> * outputUnit;

// Called from subclasses.
- (id) initWithReceiver: (NSObject <CMIDIReceiver> *) receiver NS_DESIGNATED_INITIALIZER;

// An instrument will need mute the signal chain under several circumstances: (1) The user mutes it (using the property below). (2) The application or window closes. (3) The clock stops (if this is attached to a clock's receiver list).
// An instrument stores the current state of control messages (such as volume, pitch bend, etc.) and will restore these when (1) the user unmutes it (2) the application window re-opens after being hidden (3) The clock starts (4) the object is initialized from afile.
@property BOOL mute;        // Can be set by the user.
@property BOOL isVisible;   // Can be set by the application or document when it is closed.
@end


// "outputUnit" is a CMIDIEndpoint
@interface CMIDIInstrument (ExternalInstrument)
- (id) initWithEndpointName: (NSString *) endpointName;
+ (NSArray *) endpointNames;
@end


// "outputUnit" is a CAudioInstrument
@interface CMIDIInstrument (InternalInstrument)
- (id) initWithInstrumentName: (NSString *) instrumentName;
+ (NSArray *) instrumentNames;
@end
