//
//  AudioComponent Names.c
//  CAudioUnits
//
//  Created by CHARLES GILLINGHAM on 2/25/15.
//  Copyright (c) 2015 CHARLES GILLINGHAM. All rights reserved.
//

#import "AudioComponentDescription Names.h"
#import "CAUErrors.h"


// Utility
NSString * ACSubtypeName( AudioComponent comp )
{
    CFStringRef compName = nil;
    OSStatus err = 0;
    err = AudioComponentCopyName (comp, &compName);
    if (!err && compName && CFStringGetLength(compName) > 0) {
        return [NSString stringWithString: (__bridge NSString *) compName];
    } else {
        assert(NO);
        return nil;
    }
}


// -----------------------------------------------------------------------------
#pragma mark                   Name List
// -----------------------------------------------------------------------------

NSArray * ACDSubtypeNames( OSType componentType )
{
    AudioComponentDescription desc = {};
    desc.componentType = componentType;
    UInt32 count = AudioComponentCount(&desc);
    NSMutableArray *list = [NSMutableArray arrayWithCapacity: count];
    AudioComponent comp = NULL;
    for (int i = 0; i < count; i++) {
        comp = AudioComponentFindNext(comp, &desc);
        [list addObject:ACSubtypeName(comp)];
    }
    return list;
}




// -----------------------------------------------------------------------------
#pragma mark                   Getter
// -----------------------------------------------------------------------------


NSString * ACDSubtypeName( AudioComponentDescription acd )
{
    AudioComponentDescription desc = acd;
    UInt32 count = AudioComponentCount(&desc);
    if (count == 0) {
        return @"invalid audio unit type or subtype";
    }
    AudioComponent comp = NULL;
    comp = AudioComponentFindNext(comp, &desc);
    return ACSubtypeName(comp);
}


// -----------------------------------------------------------------------------
#pragma mark                   Setters
// -----------------------------------------------------------------------------


OSStatus ACDFromOSTypeAndSubtypeName( OSType componentType,
                                      NSString * subtypeName,
                                      AudioComponentDescription * acd)
{
    AudioComponentDescription desc = {};
    desc.componentType = componentType;
    
    UInt32 count = AudioComponentCount(&desc);
    AudioComponent comp = NULL;
    for (int i = 0; i < count; i++) {
        comp = AudioComponentFindNext(comp, &desc);
        if ([ACSubtypeName(comp) isEqualToString:subtypeName]) {
            AudioComponentGetDescription(comp, &desc);
            (*acd) = desc;
            return noErr;
        }
    }
    return kCAudioUnitsErr_unknownSubtype;
}




