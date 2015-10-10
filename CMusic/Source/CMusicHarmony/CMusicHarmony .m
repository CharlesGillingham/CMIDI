//
//  CMusicHarmony.m
//  CMusic
//
//  Created by CHARLES GILLINGHAM on 10/1/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMusicHarmony.h"
#import "CMusicHarmony+Scales.h"

enum {
    CMusicHarmony_UndefinedKey = -1
};

@implementation CMusicHarmony {
    CMusicHarmonicStrength _harmonicStrengths[CMusicPitchClass_Count];
    CMusicPitchClass _key;
}


- (id) initWithHarmonicStrengths: (NSArray *) hs
                             key: (CMusicPitchClass) key
{
    if (self = [super init]) {
        _key = key;
        [self setHarmonicStrengths:hs];
        if (![self checkParameters]) return nil;
    }
    return self;
}


+ (instancetype) CMajorI
{
    return [[self alloc] initWithHarmonicStrengths:@[@3,@0,@1,@0,@2,@1,@0,@2,@0,@1,@0,@1]
                                               key:CMusicPitchClass_C];
}



- (BOOL) checkParameters
{
    BOOL fOk = NO;
    for (NSUInteger i = 0; i < 12; i++) {
        SInt16 hs = _harmonicStrengths[i];
        
        // Must be a valid harmonic strength.
        NSAssert(hs >= 0 && hs <= CMusicHarmonicStrength_Max,
                 ([NSString stringWithFormat:@"Invalid harmonic strength %d of pitch class %s",
                   hs, CMusicPitchClassName(i)]));
        
        // Must have at least one member of the scale.
        if (hs > 0) fOk = YES;
    }
    
    NSAssert(fOk,@"Empty harmony");
    
    // Key must be in the scale.
    if (_harmonicStrengths[_key] == kCMusic_outOfKey) {
        printf("OOPS\n");
    }
    
    NSAssert(_harmonicStrengths[_key] > kCMusic_outOfKey,@"Key is not in the scale");
    
    return fOk;
}




// -----------------------------------------------------------------------------
#pragma mark              Harmonic strength
// -----------------------------------------------------------------------------

- (CMusicHarmonicStrength) harmonicStrength:(CMusicPitchClass)pc
{
    return _harmonicStrengths[pc];
}

- (void) setHarmonicStrength:(CMusicHarmonicStrength)hs ofPitchClass:(CMusicPitchClass)pc
{
    [self willChangeValueForKey:@"harmonicStrengths"];
    @synchronized(self) {
        _harmonicStrengths[pc] = hs;
    }
    [self checkParameters];
    [self didChangeValueForKey:@"harmonicStrengths"];
}


- (void)setHarmonicStrengths:(NSArray *)strengths
{
    NSAssert(strengths.count == CMusicPitchClass_Count, @"Invalid harmonic strengths");
    
    [self willChangeValueForKey:@"harmonicStrengths"];
    @synchronized(self) {
        NSUInteger i = 0;
        for (NSNumber * n in strengths) {
            _harmonicStrengths[i++] = n.integerValue;
        }
    }
    [self checkParameters];
    [self didChangeValueForKey:@"harmonicStrengths"];
}


// Called internally from transpose, setKey:scaleForm:root:chordForm
- (void) setHarmonicStrengthWithData: (SInt16 *) strengths andKey: (SInt16) key
{
    [self willChangeValueForKey:@"harmonicStrengths"];
    @synchronized(self) {
        _key = key;
        for (NSUInteger i = 0; i < CMusicPitchClass_Count; i++) {
            _harmonicStrengths[i] = strengths[i];
        }
    }
    [self checkParameters];
    [self didChangeValueForKey:@"harmonicStrengths"];

    
}


// -----------------------------------------------------------------------------
#pragma mark                Key &  Transpose
// -----------------------------------------------------------------------------
@dynamic key;

- (CMusicPitchClass) key
{
    return _key;
}


- (void) setKey: (CMusicPitchClass) key
{
    [self transpose:_key - key];
}


- (void) transpose: (CMusicPitchClass) nPCs
{
    if (nPCs == 0) return;
    
    CMusicHarmonicStrength hs[CMusicPitchClass_Count];
    for (NSUInteger newpc, pc = 0; pc < CMusicPitchClass_Count; pc++) {
        newpc = SInt16Mod(pc+nPCs, CMusicPitchClass_Count);
        hs[pc] = _harmonicStrengths[newpc];
    }
    
    [self setHarmonicStrengthWithData:hs
                               andKey:SInt16Mod(_key-nPCs,CMusicPitchClass_Count)];
}


// -----------------------------------------------------------------------------
#pragma mark                Set scale and chord
// -----------------------------------------------------------------------------

- (void) setKey: (CMusicPitchClass) newKey
      scaleForm: (NSArray *) scaleForm
      chordRoot: (CMusicScaleDegree) chordRootScaleDegree
      chordForm: (NSArray *) chordForm
{
    CMusicHarmonicStrength hs[CMusicPitchClass_Count];
    
    for (CMusicPitchClass pc = 0; pc < CMusicPitchClass_Count; pc++) {
        hs[pc] = kCMusic_outOfKey;
    }
    
    CMusicPitchClass pcFromSD[CMusicPitchClass_Count];
    CMusicScaleDegree sd = 0;
    for (NSNumber * n in scaleForm) {
        CMusicPitchClass pc = SInt16Mod(n.integerValue + newKey,CMusicPitchClass_Count);
        pcFromSD[sd++] = pc;
        NSAssert(sd <= CMusicPitchClass_Count, @"CMusic doesn't support scales with more than 12 notes");
        
        hs[pc] = kCMusic_scaleTone;
    }
    SInt16 scaleToneCount = sd;
    
    if (chordRootScaleDegree != ((CMusicScaleDegree)NSNotFound)) {
        
        for (NSNumber * n in chordForm) {
            SInt16 ctsd = SInt16Mod(n.integerValue + chordRootScaleDegree, scaleToneCount);
            SInt16 pc = pcFromSD[ctsd];
            
            hs[pc] = kCMusic_chordTone;
        }
        
        SInt16 pc = pcFromSD[chordRootScaleDegree];
        hs[pc] = kCMusic_chordRoot;
        
    }
    
    [self setHarmonicStrengthWithData:hs andKey:newKey];
}





- (void) setKey: (CMusicPitchClass) newKey
      scaleForm: (NSArray *) scaleForm
           mode: (SInt16) mode
      chordRoot: (CMusicScaleDegree) chordRootScaleDegree
      chordForm: (NSArray *) chordForm
      inversion: (SInt16) inversion
{
    NSAssert(mode < scaleForm.count,@"Bad mode");
    NSAssert(inversion < chordForm.count,@"Bad inversion");
    
    SInt16 nScaleTones = scaleForm.count;
    SInt16 nChordTones = chordForm.count;

    if (mode != 0) {
        NSMutableArray * sf = [NSMutableArray arrayWithCapacity:scaleForm.count];
    
        CMusicPitchClass i, j, modeOffset = [scaleForm[mode] integerValue], pc;
        for (i = 0; i < nScaleTones; i++) {
            j = SInt16Mod(mode+i, nScaleTones);
            pc = SInt16Mod([scaleForm[j] integerValue] - modeOffset, CMusicPitchClass_Count);
            [sf addObject:[NSNumber numberWithInteger:pc]];
        }

        scaleForm = sf;
    }
    
    if (inversion != 0) {
        NSMutableArray * cf = [NSMutableArray arrayWithCapacity:scaleForm.count];
        
        CMusicScaleDegree i, j, invOffset = [chordForm[inversion] integerValue], sd;
        for (i = 0; i < nChordTones; i++) {
            j = SInt16Mod(inversion+i, nChordTones);
            sd = SInt16Mod([chordForm[j] integerValue] - invOffset, nScaleTones);
            [cf addObject:[NSNumber numberWithInteger:sd]];
        }

        chordForm = cf;
    }
    
    [self setKey:newKey scaleForm:scaleForm chordRoot:chordRootScaleDegree chordForm:chordForm];
}


@end
