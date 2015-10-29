//
//  CAudioUnit+Search.h
//  CAudioUnits
//
//  Created by CHARLES GILLINGHAM on 9/5/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

// This category is designed to aid in creating a user interface which allows user to select the type of a unit by name. This is not a very useful feature except for a completely general application that allows the user to create any sort of graph they want. This is also probably not a great idea, because this overlooks the fact that future versions of this interface may want to subclass some of these sub-type.
// For now I am saving this code, but I may remove it future versions.

#import "CAudioUnit.h"
#import "CAUGraph.h"

// AudioUnit type names
extern NSString * kCAudioUnitTypeName_Instrument;
extern NSString * kCAudioUnitTypeName_Output;
extern NSString * kCAudioUnitTypeName_Effect;
extern NSString * kCAudioUnitTypeName_Generator;


@interface CAudioUnit (Search)
@property (readonly) NSString   * typeName;

+ (NSArray *)  typeNames;                            // @[@"Effect", @"Generator" ... ]
+ (NSArray *)  subtypeNames: (NSString *) typeName;  // Subtypes of the type named by this.

+ (CAudioUnit *) unitWithType:(NSString *) typeName
                      subtype:(NSString *) subtypeName;

+ (CAudioUnit *) unitWithType:(NSString *) typeName
                      subtype:(NSString *) subtypeName
                        graph:(CAUGraph *) graph;
@end
