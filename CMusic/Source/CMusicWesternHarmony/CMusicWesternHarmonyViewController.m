//
//  MHarmonyViewController.m
//  SqueezeBox 0.2.2
//
//  Created by CHARLES GILLINGHAM on 2/17/14.
//  Copyright (c) 2014 CHARLES GILLINGHAM. All rights reserved.
//

#import "CMusicWesternHarmonyViewController.h"
#import "CSliderTable.h"


@interface CMusicWesternHarmonyViewController ()
@property IBOutlet NSBox * harmonicStrengthsBox;
@property CSliderTable * harmonicStrengthsTable;
@end

NSString * MHarmonyViewControllerNibName = @"CMusicWesternHarmonyViewController.nib";

@implementation CMusicWesternHarmonyViewController
@synthesize harmony;
@synthesize harmonicStrengthsBox;
@synthesize harmonicStrengthsTable;

- (id)initWithHarmony: (CMusicWesternHarmony *) h
{
    self = [super initWithNibName:MHarmonyViewControllerNibName
                           bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        harmony = h;
    }
    return self;
}

- (void) loadView
{
    [super loadView];

    harmonicStrengthsTable = [[CSliderTable alloc] initWithSourceArray:@[harmony]
                                                              arrayKey:@"harmonicStrengths"
                                                              valueKey:nil];
    harmonicStrengthsTable.minValue = 0;
    harmonicStrengthsTable.maxValue = 3;
    [harmonicStrengthsBox setContentView:harmonicStrengthsTable.view];
}

@end
