//
//  CAudioUnit+Examples.h
//  CMIDIFilePlayerAndEffect
//
//  Created by CHARLES GILLINGHAM on 9/13/15.
//  Copyright (c) 2015 CHARLES GILLINGHAM. All rights reserved.
//

// Convenience generators for several common items

#import "CAudioUnit.h"
#import "CAudioGenerator.h"
#import "CAudioInstrument.h"
#import "CAudioEffect.h"
#import "CAudioOutput.h"

extern NSString * kCAudioGeneratorName_filePlayer;
extern NSString * kCAudioInstrumentName_DLSSynth;
extern NSString * kCAudioInstrumentName_sampler;
extern NSString * kCAudioEffectName_pitch;
extern NSString * kCAudioEffectName_delay;
extern NSString * kCAudioOutpuetName_defaultOutput;


@interface CAudioUnit (Examples)

// Generators
+ (CAudioGenerator *) filePlayer;

// Instruments
+ (CAudioInstrument *) DLSSynth;
+ (CAudioInstrument *) sampler;

// Effects
+ (CAudioEffect *) delay;
+ (CAudioEffect *) pitch;

// Output
+ (CAudioOutput *) defaultOutput;

// Same thing, for applications that need multiple graphs.
+ (CAudioGenerator *) filePlayer: (CAUGraph *) graph;
+ (CAudioInstrument *) DLSSynth: (CAUGraph *) graph;
+ (CAudioInstrument *) sampler: (CAUGraph *) graph;
+ (CAudioEffect *) delay: (CAUGraph *) graph;
+ (CAudioEffect *) pitch: (CAUGraph *) graph;
+ (CAudioOutput *) defaultOutput: (CAUGraph *) graph;

@end

