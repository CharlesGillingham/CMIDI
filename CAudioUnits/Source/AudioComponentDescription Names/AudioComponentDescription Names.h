//
//  CAudioComponent Names.h
//  CAudioUnits
//
//  Created by CHARLES GILLINGHAM on 2/25/15.
//  Copyright (c) 2015 CHARLES GILLINGHAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolBox/AudioToolBox.h> // AudioComponentDescription


NSArray * ACDSubtypeNames( OSType type );
OSStatus  ACDFromOSTypeAndSubtypeName(OSType componentType,
                                     NSString * subtypeName,
                                     AudioComponentDescription * acd);
NSString * ACDSubtypeName( AudioComponentDescription acd );
