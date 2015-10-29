//
//  CAUError_Internal.h
//  CAudioUnits
//
//  Created by CHARLES GILLINGHAM on 9/16/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CAudioUnit.h"

void CAudioUnitRegisterConstructionError(OSStatus err,
                                         NSString * typeName);
void CAudioUnitRegisterConnectionError(OSStatus err,
                                       CAudioUnit * unit1,
                                       CAudioUnit * unit2);

