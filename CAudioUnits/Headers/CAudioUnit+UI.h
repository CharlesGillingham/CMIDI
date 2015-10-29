//
//  CAudioUnit+UI.h
//  CAudioUnits
//
//  Created by CHARLES GILLINGHAM on 2/25/15.
//  Copyright (c) 2015 CHARLES GILLINGHAM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CAudioUnit.h"

@interface CAudioUnit (UI)
- (NSView *) cocoaView;
- (NSView *) genericView;
- (NSViewController *) viewController;
@end


