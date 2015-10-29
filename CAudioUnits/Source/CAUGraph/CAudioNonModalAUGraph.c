//
//  CAudioNonModalAUGraph.c
//  CAudioUnits
//
//  Created by CHARLES GILLINGHAM on 10/7/13.
//  Copyright (c) 2013 CHARLES GILLINGHAM. All rights reserved.
//

#import "CAudioNonModalAUGraph.h"
#import "CAUNoErr.h"

// -----------------------------------------------------------------------------
#pragma mark           Additional getters for graph
// -----------------------------------------------------------------------------


OSStatus AUGraphGetInputConnection(AUGraph auGraph,
                                   AUNode destNode, UInt32 inputBus,
                                   AUNode * sourceNode, UInt32 * outputBus)
{
    UInt32 ioNuminteractions;
    AUGraphGetNumberOfInteractions(auGraph, &ioNuminteractions);
    AUNodeInteraction outInteractions[ioNuminteractions];
    AUGraphGetNodeInteractions(auGraph, destNode, &ioNuminteractions, outInteractions);
    for (UInt32 i = 0; i < ioNuminteractions; i++) {
        if (outInteractions[i].nodeInteractionType == kAUNodeInteraction_Connection) {
            AUNodeConnection conn = outInteractions[i].nodeInteraction.connection;
            if (conn.destNode == destNode && conn.destInputNumber == inputBus) {
                *sourceNode = conn.sourceNode;
                *outputBus = conn.sourceOutputNumber;
                return noErr;
            }
        }
    }
    *sourceNode = 0;
    *outputBus = 0;
    return noErr; // All errors are fatal
}



OSStatus AUGraphGetOutputConnection(AUGraph auGraph,
                                    AUNode sourceNode, UInt32 outputBus,
                                    AUNode * destNode, UInt32 * inputBus)
{
    UInt32 ioNuminteractions;
    AUGraphGetNumberOfInteractions(auGraph, &ioNuminteractions);
    AUNodeInteraction outInteractions[ioNuminteractions];
    AUGraphGetNodeInteractions(auGraph, sourceNode, &ioNuminteractions, outInteractions);
    for (UInt32 i = 0; i < ioNuminteractions; i++) {
        if (outInteractions[i].nodeInteractionType == kAUNodeInteraction_Connection) {
            AUNodeConnection conn = outInteractions[i].nodeInteraction.connection;
            if (conn.sourceNode == sourceNode && conn.sourceOutputNumber == outputBus) {
                *destNode = conn.destNode;
                *inputBus = conn.destInputNumber;
                return noErr;
            }
        }
    }
    *destNode = 0;
    *inputBus = 0;
    return noErr; // All errors are fatal
}



OSStatus AUGraphGetFirstNodeOfType(AUGraph auGraph, OSType type, AUNode * node)
{
    UInt32 nodeCount;
    CAUNOERR (AUGraphGetNodeCount (auGraph, &nodeCount));
    
    for (UInt32 i = 0; i < nodeCount; ++i)
    {
        CAUNOERR (AUGraphGetIndNode(auGraph, i, node) );
        
        AudioComponentDescription desc;
        CAUNOERR (AUGraphNodeInfo(auGraph, *node, &desc, 0) );
        if (desc.componentType == type)
        {
            return noErr;
        }
    }
    
    // didn't find the audio unit
    return kAUGraphErr_NodeNotFound;
}




OSStatus AUGraphGetOutputNode ( AUGraph auGraph, AUNode * outputNode )
{
    return (AUGraphGetFirstNodeOfType(auGraph, kAudioUnitType_Output, outputNode));
}


// -----------------------------------------------------------------------------
#pragma mark           Hidden Output Node Kludge
// -----------------------------------------------------------------------------
// Apple's AUGraph will not run if there is no output node. To keep this interface non-modal, we have to create a hidden output node when the graph is first created. When the client creates an output unit, we remove the hidden node and add a new one, as specificied by the client. This interface gives the client no means to connect to the hidden node or effect it in any way, so we can remove it safely.
// Possible issue: if the client creates a second output node in the same graph, we will not be able to report the error. The first output node will behave unpredictably. May be able to fix this at the AUGraph level. May be able to fix this by putting some kind of mark (userInfo?) on the node, so I know it's the hidden one.

const AudioComponentDescription AppleDefaultOuputACD = {
    kAudioUnitType_Output,
    kAudioUnitSubType_DefaultOutput,
    kAudioUnitManufacturer_Apple,
    0,0
};



OSStatus AddHiddenOuputNode(AUGraph auGraph)
{
    AUNode hiddenNode;
    CAUNOERR( AUGraphAddNode(auGraph, &AppleDefaultOuputACD, &hiddenNode) );
    return noErr; // Any error is fatal
}



OSStatus ReplaceHiddenOutputNode(AUGraph auGraph,
                                 AudioComponentDescription * description,
                                 AUNode * node,
                                 AudioUnit * unit)
{
    AUNode hiddenNode;
    CAUNOERR( AUGraphGetOutputNode(auGraph, &hiddenNode));
    
    CAUNOERR( AUGraphStop(auGraph) ); // Graph won't run without an output node.
    
    CAUNOERR( AUGraphRemoveNode(auGraph, hiddenNode) );
    
    OSStatus err = AUGraphAddNode(auGraph, description, node);
    
    if (err) {
        CAUNOERR( AUGraphAddNode(auGraph, &AppleDefaultOuputACD, &hiddenNode) );
    } else {
        CAUNOERR( AUGraphNodeInfo(auGraph, *node, description, unit));
        CAUNOERR( AudioUnitInitialize(*unit));
        CAUNOERR( AUGraphUpdate(auGraph, NULL) ); // Is this necessary?
    }

    CAUNOERR( AUGraphStart(auGraph));

    return err;
}



// -----------------------------------------------------------------------------
#pragma mark           Constructors
// -----------------------------------------------------------------------------



OSStatus NonModalAUGraphNew(AUGraph * auGraph)
{
    CAUNOERR( NewAUGraph(auGraph));
    CAUNOERR( AUGraphOpen(*auGraph)); // Is this necessary?
    
    AddHiddenOuputNode(*auGraph);
    
    CAUNOERR( AUGraphInitialize(*auGraph));
    CAUNOERR( AUGraphUpdate(*auGraph, NULL)); // Is this necessary?
    
    // Start Audio rendering
    CAUNOERR( AUGraphStart(*auGraph));
    
    // Test
    Boolean isRunning;
    CAUNOERR( AUGraphIsRunning(*auGraph, &isRunning) );
    assert(isRunning);
    
    return noErr; // All errors are fatal.
}




OSStatus NonModalAUGraphDispose( AUGraph auGraph )
{
    Boolean wasRunning = false;
    CAUNOERR (AUGraphIsRunning(auGraph, &wasRunning));
    if (wasRunning) {
        CAUNOERR( AUGraphStop(auGraph));
    }
    
    // Dispose of root node (is this necessary?)
    AUNode outputNode;
    CAUNOERR (AUGraphGetOutputNode(auGraph, &outputNode));
    CAUNOERR (AUGraphRemoveNode(auGraph, outputNode));
    
    CAUNOERR (AUGraphUninitialize(auGraph));
    CAUNOERR (AUGraphClose(auGraph));
    CAUNOERR (DisposeAUGraph(auGraph));
    return noErr; // All errors are fatal
}


// -----------------------------------------------------------------------------
#pragma mark           Managing nodes
// -----------------------------------------------------------------------------

// This didn't work ...
/*
OSStatus NonModalAUGraphUpdate ( AUGraph auGraph )
{
    Boolean success;
    if (AUGraphUpdate(auGraph, &success) == kAUGraphErr_CannotDoInCurrentContext) {
        CAUNOERR( AUGraphStop(auGraph));
        CAUNOERR (AUGraphUpdate(auGraph,NULL));
        CAUNOERR( AUGraphStart(auGraph) );
    }
    return noErr; // All errors are fatal.
}
*/


OSStatus NonModalAUGraphAddNode(AUGraph auGraph, AudioComponentDescription * description,
                                AUNode * node, AudioUnit * unit )
{
    if (description->componentType == kAudioUnitType_Output) {
       return ReplaceHiddenOutputNode(auGraph, description, node, unit);
    }
    
    OSStatus err = AUGraphAddNode(auGraph, description, node);
    if (err) return err;
    
    CAUNOERR( AUGraphNodeInfo(auGraph, *node, description, unit));
    CAUNOERR( AudioUnitInitialize(*unit));
    CAUNOERR( AUGraphUpdate(auGraph, NULL) );
    
    return noErr; // All other errors are fatal
}




OSStatus NonModalAUGraphRemoveNode(AUGraph auGraph,
                                   AUNode node)
{
    // We need to stop the graph to avoid receiving the occasional random "cannot do in current context" messages.
    // I would love to take advantage of AUGraph's AUGraphUpdate functionality, but unfortunately I can't wait till the next render cycle to try updating again if it fails. The UI needs to know if this is going to succeed or not, and we can't wait.
    // Also, if the graph is running it is not easy to AUUpdate to restore the graph back the same state - pending changes are hard to remove, errors are difficult to recover from. I'm not sure if there is a way to fix this without basically duplicating AUGraph myself, which is beyond the scope of my current project. I've already done too much here. See "BugReport()" in CAudioUnitTests.
    CAUNOERR( AUGraphStop(auGraph) );
    CAUNOERR( AUGraphRemoveNode(auGraph, node) );
    CAUNOERR( AUGraphStart(auGraph) );
    return noErr; // All errors are fatal
}



// All of these are checked in CAudioUnit.m ... but just for debugging, here's all these assertions
// Show that everything exists and that there is no connection on either bus.
#ifdef DEBUG
void AssertPreconditionsForConnect(AUGraph auGraph,
                                   AUNode inSourceNode, UInt32 inSourceOutputNumber,
                                   AUNode inDestNode,   UInt32 inDestInputNumber)
{
    assert(inSourceNode != inDestNode);
    assert(auGraph != 0);
    assert(inSourceNode != 0);
    assert(inDestNode != 0);
    AUNode currentDestNode;
    UInt32 currentDestInputNumber;
    AUNode currentSourceNode;
    UInt32 currentSourceOutputNumber;
    CAUNOERR( AUGraphGetOutputConnection(auGraph,
                                        inSourceNode, inSourceOutputNumber,
                                        &currentDestNode, &currentDestInputNumber) );
    CAUNOERR( AUGraphGetInputConnection(auGraph,
                                       inDestNode, inDestInputNumber,
                                       &currentSourceNode, &currentSourceOutputNumber) );
    assert(currentDestNode == 0);
    assert(currentSourceNode == 0);
}
#endif




OSStatus NonModalAUGraphConnectNodes(AUGraph auGraph,
                                     AUNode inSourceNode, UInt32 inSourceOutputNumber,
                                     AUNode inDestNode,   UInt32 inDestInputNumber)
{
#ifdef DEBUG
    AssertPreconditionsForConnect(auGraph, inSourceNode, inSourceOutputNumber, inDestNode, inDestInputNumber);
#endif
    
    // See note above about stopping the graph.
    CAUNOERR (AUGraphStop(auGraph));
    
    // From here on out, we are making destructive changes.
    OSStatus connectErr = AUGraphConnectNodeInput(auGraph,
                                                  inSourceNode, inSourceOutputNumber,
                                                  inDestNode, inDestInputNumber);
    
    // Sometimes AUGraph doesn't clean up after itself. In tests, this disconnect is necessary, otherwise their is a partial connection left behing. This will cause a second error to print in stderr.
    if (connectErr) {
        AUGraphDisconnectNodeInput(auGraph, inDestNode, inDestInputNumber);
    }
    
    CAUNOERR (AUGraphStart(auGraph));
    return connectErr;
}




OSStatus NonModalAUGraphDisconnectNodeOutput(AUGraph auGraph,
                                             AUNode inSourceNode, UInt32 inSourceOutputNumber)
{
    assert(auGraph != 0);
    assert(inSourceNode != 0);
    
    // Find out how they are currently connected
    AUNode currentDestNode;
    UInt32 currentDestInputNumber;
    CAUNOERR( AUGraphGetOutputConnection(auGraph,
                                        inSourceNode, inSourceOutputNumber,
                                        &currentDestNode, &currentDestInputNumber) );
    
    // Nothing to disconnect.
    if (currentDestNode == 0) return noErr;
    
    CAUNOERR (AUGraphStop(auGraph));
    
    // Break any previous output connection.
    OSStatus disconnectErr = AUGraphDisconnectNodeInput(auGraph, currentDestNode, currentDestInputNumber);
    if (disconnectErr) {
        AUGraphConnectNodeInput(auGraph,
                                inSourceNode, inSourceOutputNumber,
                                currentDestNode, currentDestInputNumber);
    }
    
    CAUNOERR (AUGraphStart(auGraph));
    
    // Report only the first error.
    return disconnectErr;
}

