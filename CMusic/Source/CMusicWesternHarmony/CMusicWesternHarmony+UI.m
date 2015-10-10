//
//  MHarmony+UI.m
//  SqueezeBox
//
//  Created by CHARLES GILLINGHAM on 6/16/14.
//  Copyright (c) 2014 CHARLES GILLINGHAM. All rights reserved.
//

#import "CMusicWesternHarmony+UI.h"
#import "CMusicWesternHarmonyViewController.h"


@implementation CMusicWesternHarmony (UI)
- (NSViewController *) viewController
{
    return [[CMusicWesternHarmonyViewController alloc] initWithHarmony: self];
}
@end

