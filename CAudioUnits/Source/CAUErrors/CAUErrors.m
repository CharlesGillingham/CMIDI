//
//  CAudioUnit+Errors.m
//  CAudioUnits
//
//  Created by CHARLES GILLINGHAM on 2/4/14.
//  Copyright (c) 2014 CHARLES GILLINGHAM. All rights reserved.
//

#import "CAUErrors.h"
#import "AudioComponentDescription Names.h"

NSError * CAudioUnit_currentError = nil;
NSString * const CAudioUnit_ErrorDomain = @"com.CAudioUnit";

NSString * CAudioUnitNameForObject(NSObject *object)
{
    NSString * objName;
    if (!object) {
        objName = @"CAudioUnit.framework";
    } else if ([object isKindOfClass:[CAudioUnit class]]) {
        objName = ((CAudioUnit *) object).displayName;
    } else {
        objName = [object description];
    }
    return objName;

}


void CAudioUnitRegisterError(OSStatus err,
                             NSString * message)
{
    if (err && !CAudioUnit_currentError) {
        NSDictionary * errorDict = @{ NSLocalizedDescriptionKey : message };
       
        NSString * errorDomain;
        if (err == kCAudioUnitsErr_unknownSubtype || err == kCAudioUnitsErr_unknownType) {
            errorDomain = CAudioUnit_ErrorDomain;
        } else {
            errorDomain = NSOSStatusErrorDomain;
        }
        
        CAudioUnit_currentError = [NSError errorWithDomain:errorDomain
                                                      code:err
                                                  userInfo:errorDict];
    }
}



void CAudioUnitRegisterConstructionError( OSStatus err, NSString * typeName)
{
    NSString * description = [NSString stringWithFormat:@"Could not create a unit of type \'%@\'", typeName];
    CAudioUnitRegisterError(err, description);
}



void CAudioUnitRegisterConnectionError(OSStatus err,
                                       CAudioUnit * unit1,
                                       CAudioUnit * unit2)
{
    NSString * description = [NSString stringWithFormat: @"Can not connect the %@ to the %@",
                              CAudioUnitNameForObject(unit1),
                              CAudioUnitNameForObject(unit2)];
    CAudioUnitRegisterError(err, description);
}




#ifdef DEBUG
const char * CAudioUnitErrorString(OSStatus errCode)
{
    switch (errCode) {
        case noErr:                                     return "No error";
            
        case kCAudioUnitsErr_unknownSubtype:             return "CAU error: unknown subtype";
        case kCAudioUnitsErr_unknownType:                return "CAU error: unknown type";
            
        case kAudioUnitErr_InvalidProperty:             return "AU error: invalid property";
        case kAudioUnitErr_InvalidParameter:            return "AU error: invalid parameter";
        case kAudioUnitErr_InvalidElement:              return "AU error: invalid element";
        case kAudioUnitErr_NoConnection:                return "AU error: no connection";
        case kAudioUnitErr_FailedInitialization:        return "AU error: failed initialization";
        case kAudioUnitErr_TooManyFramesToProcess:      return "AU error: To many frames to process";
        case kAudioUnitErr_InvalidFile:                 return "AU error: Invalid file";
        case kAudioUnitErr_FormatNotSupported:          return "AU error: Format not supported";
        case kAudioUnitErr_Uninitialized:               return "AU error: Uninitialized";
        case kAudioUnitErr_InvalidScope:                return "AU error: Invalid scope";
        case kAudioUnitErr_PropertyNotWritable:         return "AU error: Property not writeable";
        case kAudioUnitErr_CannotDoInCurrentContext:    return "AU error: Cannot do in current context";
        case kAudioUnitErr_InvalidPropertyValue:        return "AU error: Invalid property value";
        case kAudioUnitErr_PropertyNotInUse:            return "AU error: Property not in use";
        case kAudioUnitErr_Initialized:			        return "AU error: Initialized";
        case kAudioUnitErr_InvalidOfflineRender:        return "AU error: Invalid offline render";
        case kAudioUnitErr_Unauthorized:                return "AU error: Unauthorized";
            
            // AUGraph errors
        case kAUGraphErr_NodeNotFound:                  return "AU graph error: node not found";
        case kAUGraphErr_InvalidConnection:             return "AU graph error: invalid connection";
        case kAUGraphErr_OutputNodeErr:                 return "AU graph error: output node error";
        case kAUGraphErr_InvalidAudioUnit:              return "AU graph error: invalid audio unit";
            
        default:
            printf("UNKNOWN OS ERROR CODE # %ld\n", (long)errCode);
            return "AU error: TODO";
    };
}



Boolean CAUNoErr(OSStatus err, char * code)
{
    if (err) {
        printf("\n\nFAILING EXCEPTION in CAudioUnits -----------------------------------------------\n");
        printf("%d\n",err);
        printf("%s\n", CAudioUnitErrorString(err));
        printf("SOURCE CODE: ---------------------------------------------------------------------\n");
        printf("%s\n",code);
        printf("----------------------------------------------------------------------------------\n\n");
        return NO;
    } else {
        return YES;
    }
}


#endif


