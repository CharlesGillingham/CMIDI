//
//  CSliderTableView.h
//
//  Created by CHARLES GILLINGHAM on 11/5/13.
//

#import <Cocoa/Cocoa.h>

@interface CSliderTableView : NSView

// These all  nee
@property NSUInteger rowCount;
@property NSUInteger columnCount;
@property BOOL       isTransposed;
@property Float64    minValue;
@property Float64    maxValue;

// To be called after the view is loaded.
- (void) setDimensions: (NSUInteger) rows
                      : (NSUInteger) columns
                      : (BOOL) isTransposed;

// This can be used to set the values in the matrix.
- (NSSlider *) sliderOnRow: (NSUInteger) row
                    column: (NSUInteger) column;

- (void) positionOfSlider: (NSSlider *) slider
                      row: (NSInteger *) row
                   column: (NSInteger *) col;

// All of the sliders will use this target
- (void) setTarget: (id) target andSelector: (SEL) selector;

@end



