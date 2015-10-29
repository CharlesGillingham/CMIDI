//
//  CMIDIInstrument+Internal.m
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 10/28/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDIInstrument.h"
#import "CAudioInstrument.h"
#import "CAUGraph.h"

@interface CAudioInstrument (CMIDI) <CMIDIReceiver>
@end

@implementation CAudioInstrument (CMIDI)
- (void) respondToMIDI:(CMIDIMessage *)message
{
    [self respondToMIDI:(Byte *)(message.data.bytes) ofSize:message.data.length];
}
@end


@implementation CMIDIInstrument (Internal)


- (id) initWithInstrumentName: (NSString *) instrumentName
{
    CAUGraph * g = [CAUGraph new];
    CAudioInstrument * inst = [[CAudioInstrument alloc] initWithSubtype:instrumentName graph:g];
    CAudioOutput * outp = [[CAudioOutput alloc] initWithSubtype:@"Apple: AUDefaultOutput" graph:g];
    inst.outputUnit = outp;
   
    return [self initWithReceiver:inst];
}


+ (NSArray *) instrumentNames
{
    return [CAudioInstrument subtypeNames];
}


@end
