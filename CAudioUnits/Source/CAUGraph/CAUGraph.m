//
//  CAUGraph.m
//  CAudioUnits
//
//  Created by CHARLES GILLINGHAM on 8/31/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CAudioUnit_Internal.h"
#import "CAUGraph_Internal.h"
#import "CAUError_Internal.h"
#import "CAUNoErr.h"
#import "AudioComponentDescription Names.h"
#import "CAudioNonModalAUGraph.h"




@implementation CAUGraph {
    AUGraph auGraph;
}

- (id) init
{
    if (self = [super init]) {
        if (NonModalAUGraphNew(&auGraph) != 0) {
            return nil;
        }
    }
    return self;
}


- (BOOL) initializeUnit: (CAudioUnit *) unit
        withDescription: (AudioComponentDescription) acd
{
    OSStatus err = noErr;
    AUNode aun;
    AudioUnit au;
    err = NonModalAUGraphAddNode(auGraph, &acd, &aun, &au);
    if (err) {
        CAudioUnitRegisterConstructionError(err, ACDSubtypeName(acd));
        return NO;
    }
    unit.cauGraph      = self;
    unit.auNode        = aun;
    unit.audioUnit     = au;
    unit.auDescription = acd;
    unit.subtypeName   = ACDSubtypeName( acd );
    unit.displayName   = unit.subtypeName;
    return YES;
}


- (void) dealloc
{
    CAUNOERR( NonModalAUGraphDispose(auGraph) );
}


- (void) cleanUpUnit: (CAudioUnit *) unit
{
    if (unit.auDescription.componentType != kAudioUnitType_Output) {
        CAUNOERR( NonModalAUGraphRemoveNode(auGraph, unit.auNode) );
    }
}


- (BOOL) checkConnectionPreconditions: (CAudioUnit *) source : (CAudioUnit *) destination
{
    // These (should have) already been handled by CAudioUnit.
    NSParameterAssert(destination != nil);
    NSParameterAssert(source != nil);
  
    if (![source isKindOfClass:[CAudioUnit class]] || ![destination isKindOfClass:[CAudioUnit class]]) {
        CAudioUnitRegisterConnectionError(kAUGraphErr_InvalidAudioUnit,source,destination);
        return NO;
    }
    
    // Make sure that these units are not related any way.
    if (source == destination || destination.outputUnit == source || source.inputUnit == destination) {
        CAudioUnitRegisterConnectionError(kAUGraphErr_InvalidConnection,source,destination);
        return NO;
    }
    
    if (source.cauGraph != destination.cauGraph) {
        CAudioUnitRegisterConnectionError(kAUGraphErr_InvalidConnection, source, destination);
        return NO;
    }
    
    if (source.auDescription.componentType == kAudioUnitType_Output) {
        CAudioUnitRegisterConnectionError(kAUGraphErr_InvalidConnection, source, destination);
        return NO;
    }
    
    // These (should have) already been handled by CAudioUnit.
    NSParameterAssert(destination.inputUnit == nil);
    NSParameterAssert(destination.cauGraph == self);
    NSParameterAssert(source.outputUnit == nil);
    NSParameterAssert(source.cauGraph == self);

    return YES;
}



- (BOOL) connectBus: (UInt32) sourceBus ofUnit: (CAudioUnit *) source
              toBus: (UInt32) destBus   ofUnit: (CAudioUnit *) destination
{
    if (![self checkConnectionPreconditions:source :destination]) return NO;
    
    OSStatus err;
    @synchronized(self) {
        err = NonModalAUGraphConnectNodes(auGraph,
                                          source.auNode, sourceBus,
                                          destination.auNode, destBus);
       if (err == 0) {
           // Take care of connections inside the sync lock.
           source._outputUnit = destination;
           destination._inputUnit = source;
           return YES;
        }
    }
    
    // Report errors outside the sync lock.
    CAudioUnitRegisterConnectionError(err, source, destination);
    return NO;
}




- (BOOL) disconnectOutputBus: (UInt32) busNumber
                      ofUnit: (CAudioUnit *) unit
{
 
    // Allow them to disconnect twice, if they wish.
    if (unit.outputUnit == nil) return YES;
    
    NSParameterAssert(unit.outputUnit != nil);
    NSParameterAssert(unit.cauGraph == self);
    NSParameterAssert(unit.outputUnit.inputUnit == unit);
    
    // Other busses not currently supported
    UInt32 outputBus = 0;
    OSStatus err;
    @synchronized(self) {
        err = NonModalAUGraphDisconnectNodeOutput(auGraph,
                                                  unit.auNode, outputBus);
        if (err == 0) {
            unit._outputUnit._inputUnit = nil;
            unit._outputUnit = nil;
            return YES;
        }
    }
    
    CAudioUnitRegisterConnectionError(err, unit, nil);
    return NO;
}


- (BOOL) connectUnits:(CAudioUnit *)source :(CAudioUnit *)destination
{
    return [self connectBus:0 ofUnit:source toBus:0 ofUnit:destination];
}


- (BOOL) disconnectOutput: (CAudioUnit *) unit
{
    return [self disconnectOutputBus:0 ofUnit:unit];
}

// -----------------------------------------------------------------------------
#pragma mark                    Singleton
// -----------------------------------------------------------------------------

// Singleton, for applications with only one signal chain (i.e., the normal case)
CAUGraph * CAUGraph_currentGraph;

+ (CAUGraph *) currentGraph
{
    if (!CAUGraph_currentGraph) {
        CAUGraph_currentGraph = [CAUGraph new];
    }
    return CAUGraph_currentGraph;
}




#ifdef DEBUG
- (AUGraph) graph
{
    return auGraph;
}
#endif

@end
