//
//  CAUGraph.h
//  CAudioUnits
//
//  Created by CHARLES GILLINGHAM on 9/3/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

// If you need multiple signal chains in the same application, you need to use a separate CAUGraph for each signal chain. Create the graph first, and then create each unit with it. Units may only be connected to other units from the same graph.

@interface CAUGraph : NSObject

// Singleton, for applications with only one graph (i.e., the normal case)
+ (CAUGraph * ) currentGraph;

@end


@protocol CAudioUnitRequiredMethods2 <NSObject>
- (id) initWithSubtype: (NSString *) subtypeName
                 graph: (CAUGraph *) graph;

@end



