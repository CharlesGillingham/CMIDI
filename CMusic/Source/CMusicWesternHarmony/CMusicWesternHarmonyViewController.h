//
//  MHarmonyViewController.h
//  SqueezeBox 0.2.2
//
//  Created by CHARLES GILLINGHAM on 2/17/14.
//  Copyright (c) 2014 CHARLES GILLINGHAM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CMusicWesternHarmony.h"

@interface CMusicWesternHarmonyViewController : NSViewController
@property CMusicWesternHarmony * harmony;
- (id)  initWithHarmony: (CMusicWesternHarmony *) h;
@end
