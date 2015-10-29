//
//  CNonModelAUGraph.h
//  CAudioUnits
//
//  Created by CHARLES GILLINGHAM on 10/7/13.
//  Copyright (c) 2013 CHARLES GILLINGHAM. All rights reserved.
//


#import <AudioToolBox/AudioToolBox.h> 

OSStatus NonModalAUGraphNew(AUGraph * auGraph);
OSStatus NonModalAUGraphDispose(AUGraph auGraph);

OSStatus NonModalAUGraphAddNode(AUGraph auGraph,
                                AudioComponentDescription * description, // Input and output.
                                AUNode * node,
                                AudioUnit * unit);

OSStatus NonModalAUGraphRemoveNode(AUGraph auGraph,
                                   AUNode node);

OSStatus NonModalAUGraphConnectNodes(AUGraph inGraph,
                                     AUNode inSourceNode, UInt32 inSourceOutputNumber,
                                     AUNode inDestNode,   UInt32 inDestInputNumber);

OSStatus NonModalAUGraphDisconnectNodeOutput(AUGraph inGraph,
                                             AUNode inSourceNode, UInt32 inSourceOutputNumber);


// Additional getters -- used mostly for testing.
OSStatus AUGraphGetInputConnection(AUGraph graph,
                                   AUNode node, UInt32 inputBus,
                                   AUNode * inputNode, UInt32 * outputBus);

OSStatus AUGraphGetOutputConnection(AUGraph graph,
                                    AUNode node, UInt32 outputBus,
                                    AUNode * outputNode, UInt32 * inputBus);

OSStatus AUGraphGetOutputNode ( AUGraph auGraph, AUNode * outputNode );
