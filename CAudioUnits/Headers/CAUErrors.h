//
//  CAudioUnitErrors.h
//  CAudioUnits
//
//  Created by CHARLES GILLINGHAM on 2/25/15.
//  Copyright (c) 2015 CHARLES GILLINGHAM. All rights reserved.

#import "CAudioUnit.h"

// TODO: fix these error codes
enum {
    kCAudioUnitsErr_unknownType    = 1000,
    kCAudioUnitsErr_unknownSubtype = 1001
};

// CAudioUnits won't change this error until it is retreived and set to nil.
extern NSError  * CAudioUnit_currentError;

extern NSString * const CAudioUnit_ErrorDomain;
