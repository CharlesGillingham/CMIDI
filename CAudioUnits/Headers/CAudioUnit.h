//
//  CAudioUnit.h
//  CAudioUnits
//
//  Created by CHARLES GILLINGHAM on 6/25/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CAudioUnit : NSObject 
@property (readonly) NSString   * subtypeName;
@property NSString              * displayName;

//To create a signal processing chain, assign the outputUnit.
@property CAudioUnit            * outputUnit;
@property (readonly) CAudioUnit * inputUnit;
@end

// Implemented by every subclasses CAudioEffect, CAudioOutput, CAudioGenerator, CAudioInstrument
@protocol CAudioUnitRequiredMethods <NSObject>

// A list of the available subtypes for this class.
+ (NSArray *) subtypeNames;

// Create a unit of the given subtype.
- (id) initWithSubtype: (NSString *) subtypeName;

@end
