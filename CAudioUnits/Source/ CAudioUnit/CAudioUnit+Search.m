//
//  CAudioUnit+Search.m
//  CAudioUnits
//
//  Created by CHARLES GILLINGHAM on 6/26/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CAudioUnit+Search.h"
#import "CAudioUnit_Internal.h"
#import "CAUErrors.h"
#import "CAUError_Internal.h"
#import "CAudioEffect.h"
#import "CAudioInstrument.h"
#import "CAudioOutput.h"
#import "CAudioGenerator.h"
#import "AudioComponentDescription Names.h"


NSString * kCAudioUnitTypeName_Instrument        = @"Music device";
NSString * kCAudioUnitTypeName_Output            = @"Output";
NSString * kCAudioUnitTypeName_Effect            = @"Effect";
NSString * kCAudioUnitTypeName_Generator         = @"Generator";
NSString * kCAudioUnitTypeName_Error             = @"ERROR: Unknown audio unit type";

// -----------------------------------------------------------------------------
#pragma mark                   AudioUnit type name
// -----------------------------------------------------------------------------

NSDictionary * ACDStaticOSTypeNameDictionary = nil;

NSDictionary * ACDOSTypeNameDictionary()
{
    if (!ACDStaticOSTypeNameDictionary) {
        ACDStaticOSTypeNameDictionary =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithInt:kAudioUnitType_MusicDevice], kCAudioUnitTypeName_Instrument,
         [NSNumber numberWithInt:kAudioUnitType_Effect],      kCAudioUnitTypeName_Effect,
         [NSNumber numberWithInt:kAudioUnitType_Generator],   kCAudioUnitTypeName_Generator,
         [NSNumber numberWithInt:kAudioUnitType_Output],      kCAudioUnitTypeName_Output,
         nil
         ];
    }
    return ACDStaticOSTypeNameDictionary;
}



NSArray * AudioComponentTypeNames()
{
    return [ACDOSTypeNameDictionary() allKeys];
}


NSArray * AudioComponentSubtypeNamesFromTypeName( NSString * typeName )
{
    NSNumber * data = [ACDOSTypeNameDictionary() objectForKey:typeName];
    if (!data) {
        return @[];
    } else {
        return ACDSubtypeNames((OSType) data.integerValue);
    }
}


OSStatus AudioComponentTypeFromName(NSString * typeName,
                                    OSType * componentType)
{
    NSNumber * data = [ACDOSTypeNameDictionary() objectForKey:typeName];
    if (!data) {
        return kCAudioUnitsErr_unknownType;
    }
    * componentType = (OSType) data.integerValue;
    return noErr;
}



NSString * AudioComponentTypeName( OSType componentType )
{
    switch (componentType) {
        case kAudioUnitType_MusicDevice: return kCAudioUnitTypeName_Instrument;
        case kAudioUnitType_Generator:   return kCAudioUnitTypeName_Generator;
        case kAudioUnitType_Effect:      return kCAudioUnitTypeName_Effect;
        case kAudioUnitType_Output:      return kCAudioUnitTypeName_Output;
        default:                         return kCAudioUnitTypeName_Error;
    }
}



// -----------------------------------------------------------------------------
#pragma mark                   CAudioUnit (Search)
// -----------------------------------------------------------------------------


@implementation CAudioUnit (Search)
@dynamic typeName;

- (NSString *) typeName
{
    return AudioComponentTypeName(self.auDescription.componentType);
}


+ (NSArray *) typeNames {
    return AudioComponentTypeNames();
}


+ (NSArray *) subtypeNames: (NSString *) typeName
{
    return AudioComponentSubtypeNamesFromTypeName(typeName);
}


+ (CAudioUnit *) unitWithType: (NSString *) typeName
                      subtype: (NSString *) subtypeName
                        graph: (CAUGraph *) graph;
{
    OSType componentType;
    OSStatus err = AudioComponentTypeFromName(typeName, &componentType);
    if (err) {
        CAudioUnitRegisterConstructionError(err, subtypeName);
        return nil;
    }
    
    CAudioUnit * au;
    switch (componentType) {
        case kAudioUnitType_Generator:   {  au = [CAudioGenerator alloc]; break; }
        case kAudioUnitType_MusicDevice: {  au = [CAudioInstrument alloc]; break; }
        case kAudioUnitType_Effect:      {  au = [CAudioEffect alloc]; break; }
        case kAudioUnitType_Output:      {  au = [CAudioOutput alloc]; break; }
        default: // Impossible
            return nil;
    }
    
    return [au initWithOSType:componentType
                      subtype:subtypeName
                        graph:graph];
}


+ (CAudioUnit *) unitWithType: (NSString *) typeName
                      subtype: (NSString *) subTypeName
{
    return [self unitWithType:typeName subtype:subTypeName graph:[CAUGraph currentGraph]];
}


@end