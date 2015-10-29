//
//  CAudioUnit+Examples.m
//  CMIDIFilePlayerAndEffect
//
//  Created by CHARLES GILLINGHAM on 9/13/15.
//  Copyright (c) 2015 CHARLES GILLINGHAM. All rights reserved.
//

#import "CAudioUnit+Examples.h"
#import "CAudioUnit_Internal.h"
#import "CAUGraph.h"

NSString * kCAudioGeneratorName_filePlayer = @"Apple: AUAudioFilePlayer";
NSString * kCAudioInstrumentName_DLSSynth  = @"Apple: DLSMusicDevice";
NSString * kCAudioInstrumentName_sampler   = @"Apple: AUSampler";
NSString * kCAudioEffectName_pitch         = @"Apple: AUPitch";
NSString * kCAudioEffectName_delay         = @"Apple: AUDelay";
NSString * kCAudioOutputName_defaultOutput = @"Apple: DefaultOutputUnit";

@implementation CAudioUnit (Examples)

+ (CAudioGenerator *) filePlayer: (CAUGraph *) graph
{
    return [[CAudioGenerator alloc] initWithOSType:kAudioUnitType_Generator
                                           subtype:kCAudioGeneratorName_filePlayer
                                             graph:graph];
}

+ (CAudioInstrument *) DLSSynth: (CAUGraph *) graph
{
    return [[CAudioInstrument alloc] initWithOSType:kAudioUnitType_MusicDevice
                                           subtype:kCAudioInstrumentName_DLSSynth
                                             graph:graph];
}

+ (CAudioInstrument *) sampler: (CAUGraph *) graph
{
    return [[CAudioInstrument alloc] initWithOSType:kAudioUnitType_MusicDevice
                                            subtype:kCAudioInstrumentName_sampler
                                              graph:graph];
}

+ (CAudioEffect *) delay: (CAUGraph *) graph
{
    return [[CAudioEffect alloc] initWithOSType:kAudioUnitType_Effect
                                        subtype:kCAudioEffectName_delay
                                          graph:graph];
}

+ (CAudioEffect *) pitch: (CAUGraph *) graph
{
    return [[CAudioEffect alloc] initWithOSType:kAudioUnitType_Effect
                                        subtype:kCAudioEffectName_pitch
                                          graph:graph];
}

+ (CAudioOutput *) defaultOutput: (CAUGraph *) graph
{
    return [[CAudioOutput alloc] initWithOSType:kAudioUnitType_Output
                                        subtype:kCAudioOutputName_defaultOutput
                                          graph:graph];
}


+ (CAudioInstrument *) sampler   { return [self sampler:[CAUGraph currentGraph]]; }
+ (CAudioInstrument *) DLSSynth  { return [self DLSSynth:[CAUGraph currentGraph]]; }
+ (CAudioGenerator *) filePlayer { return [self filePlayer:[CAUGraph currentGraph]]; }
+ (CAudioEffect *) delay         { return [self delay:[CAUGraph currentGraph]]; }
+ (CAudioEffect *) pitch         { return [self pitch:[CAUGraph currentGraph]]; }
+ (CAudioOutput *) defaultOutput { return [self defaultOutput:[CAUGraph currentGraph]]; }

@end
