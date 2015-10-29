//
//  CAudioUnit.m
//  CAudioUnits
//
//  Created by Charles Gillingham on 7/6/12.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CAudioUnit_Internal.h"
#import "CAUGraph_Internal.h"
#import "CAUError_Internal.h"
#import "AudioComponentDescription Names.h"

// -----------------------------------------------------------------------------
#pragma mark                    CAudioUnit
// -----------------------------------------------------------------------------

@implementation CAudioUnit
@synthesize _inputUnit;
@synthesize _outputUnit;
@synthesize cauGraph;
@synthesize audioUnit;
@synthesize auNode;
@synthesize auDescription;
@synthesize displayName;
@synthesize subtypeName;
@dynamic inputUnit;
@dynamic outputUnit;

#ifdef DEBUG
NSInteger CAudioUnit_count = 0;
#endif


- (instancetype) initWithOSType: (OSType) type
                        subtype: (NSString *) subtype
                          graph: (CAUGraph *) graph
{
    NSParameterAssert(graph != nil);

    AudioComponentDescription acd;
    OSStatus err = ACDFromOSTypeAndSubtypeName(type, subtype, &acd);
    if (err) {
        CAudioUnitRegisterConstructionError(err, subtype);
        return nil;
    }
    
    if (self = [super init]) {
        [graph initializeUnit:self withDescription:acd];
 #ifdef DEBUG
        CAudioUnit_count++;
#endif
    }
    
    return self;
}


// Enforce desingated initializer
- (id) init {  assert(NO);  return [self init]; }


- (void) dealloc
{
    // This can only happen during [initWithCoder]. Objective-C disposes the dummy "CAudioUnit" that it created when we set "self". Because it's uninitialized, it has no auGraph.
    if (!cauGraph) return;
    
    // Note that there is no upstream connection, because otherwise this would be retained and dealloc would not be called.
    // KLUDGE (1) In my tests, self->_outputUnit->_inputUnit is inexplicably set nil while deallocation is happening. Don't understand why.
    if (self._outputUnit) {
        if (self._outputUnit._inputUnit) {
            [cauGraph disconnectOutput:self];
        }
    }
    
    [cauGraph cleanUpUnit:self];
    
#ifdef DEBUG
    CAudioUnit_count--;
#endif
}


// -----------------------------------------------------------------------------
#pragma mark                    Create from subclass
// -----------------------------------------------------------------------------
// Called from subclasses

+ (NSArray *) subtypesOfOSType:(OSType)type
{
    return ACDSubtypeNames(type);
}


// -----------------------------------------------------------------------------
#pragma mark                    Connection
// -----------------------------------------------------------------------------



- (void) setOutputUnit: (CAudioUnit *) newUnit
{
    if (self._outputUnit == newUnit) {
        return;
    }
    
    // Make sure newUnit is valid before starting the code below.
    if (!newUnit) {
        [cauGraph disconnectOutput:self];
        return;
    }
    if (![newUnit isKindOfClass:[CAudioUnit class]]) {
        CAudioUnitRegisterConnectionError(kAUGraphErr_InvalidAudioUnit, self, newUnit);
        return;
    }
    
    // Code is easier to read if rename things like this.
    // We want to remove all connections and connect in1 to out2.
    CAudioUnit * in1  = self;
    CAudioUnit * out1 = self._outputUnit;
    CAudioUnit * in2  = newUnit._inputUnit;
    CAudioUnit * out2 = newUnit;
    
    if (!in1 || !out1 || [in1.cauGraph disconnectOutput:in1]) {
        if (!in2 || !out2 || [in2.cauGraph disconnectOutput:in2]) {
            if (!in1 || !out2 || [in1.cauGraph connectUnits:in1:out2]) {
                return;
            }
            
            // Reconnect on failure
            if (in2 && out2) {
                [in2.cauGraph connectUnits:in2:out2];
            }
        }
        
        // Reconnect on failure
        if (in1 && out1) {
            [in1.cauGraph connectUnits:in1:out1];
        }
    }
}


- (CAudioUnit *) outputUnit {
    return _outputUnit;
}


- (CAudioUnit *) inputUnit {
    return _inputUnit;
}


@end

