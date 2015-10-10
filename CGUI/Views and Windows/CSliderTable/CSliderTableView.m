//
//  CSliderTableView.m
//  SqueezeBox 0.2.1
//
//  Created by CHARLES GILLINGHAM on 11/5/13.
//  Copyright (c) 2013 CHARLES GILLINGHAM. All rights reserved.
//

#import "CSliderTableView.h"

@interface CSliderTableView  ()
@property NSArray * sliders;
@end


@implementation CSliderTableView {
    NSUInteger _rowCount;
    NSUInteger _columnCount;
    BOOL       _isTransposed;
}
@synthesize rowCount = _rowCount;
@synthesize columnCount = _columnCount;
@synthesize isTransposed = _isTransposed;
@synthesize sliders;
@synthesize minValue;
@synthesize maxValue;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isTransposed = NO;
    }
    return self;
}



- (NSSlider *) makeSliderWithFrame: (NSRect) frame
{
    NSSlider * slider = [[NSSlider new] initWithFrame: frame];
    
    // Configure slider
    [slider.cell setControlSize:NSMiniControlSize];
    slider.maxValue = self.maxValue;
    slider.minValue = self.minValue;
    
    return slider;
}


- (void) makeSliderRows: (NSUInteger) rows columns: (NSUInteger) columns
{
    NSSize newSize;
    newSize.height = self.frame.size.height/rows;
    newSize.width  = self.frame.size.width/columns;
    NSMutableArray * rowArray = [NSMutableArray arrayWithCapacity: rows];
    for (NSUInteger row = 0; row < rows; row++) {
        NSMutableArray * columnArray = [NSMutableArray arrayWithCapacity: columns];
        for (NSUInteger column = 0; column < columns; column ++ ) {
            NSRect newFrame;
            newFrame.size = newSize;
            newFrame.origin.x = (column * newSize.width);
            newFrame.origin.y = (row * newSize.height);
            NSSlider * slider = [self makeSliderWithFrame: newFrame];
            [columnArray addObject: slider];
        }
        [rowArray addObject: columnArray];
    }
    
    _rowCount = rows;
    _columnCount = columns;
    sliders = rowArray;
    
    // Add them after they've all been created. Not sure if this is absolutely necessary, but I'm not sure what events are kicked off by "addSubview". Also, there might be another place to do this that is smarter.
    for (NSArray * rowArray in sliders) {
        for (NSSlider * slider in rowArray) {
            [self addSubview: slider];
        }
    }
}


- (void) resizeSlidersToFitFrame
{
    NSSize contentSize = self.frame.size;
    
    NSSize newSize;
    newSize.width = (contentSize.width/self.columnCount);
    newSize.height = (contentSize.height/self.rowCount);
    for (NSUInteger row = 0; row < self.rowCount; row++) {
        for (NSUInteger column = 0; column < self.columnCount; column ++ ) {
            NSRect newFrame;
            newFrame.size = newSize;
            newFrame.origin.x = (column * newSize.width);
            newFrame.origin.y = (row * newSize.height);
            NSSlider * slider = [[sliders objectAtIndex: row] objectAtIndex: column];
            slider.frame = newFrame;
        }
    }
}


// Called whenever the window is resized.
- (void) resizeSubviewsWithOldSize:(NSSize)oldSize
{
    [super resizeSubviewsWithOldSize:oldSize];
    [self resizeSlidersToFitFrame];
}

// ------------------------------------------------------------------------------
#pragma mark                setDimensions (PUBLIC)
// ------------------------------------------------------------------------------


- (void) setDimensions: (NSUInteger) row : (NSUInteger) column : (BOOL) isTransposed
{
    // Can't change dimensions after the sliders have been built.
    assert(sliders == nil);
    _isTransposed = isTransposed;
    [self checkTransposition: &row : &column];
    [self makeSliderRows:row columns:column];
}


// ------------------------------------------------------------------------------
#pragma mark                Locating sub-views (PUBLIC)
// ------------------------------------------------------------------------------



- (void) positionOfSlider: (NSSlider *) slider row: (NSInteger *) row column: (NSInteger *) col
{
    // [sliders objectAtIndex:0] is the BOTTOM row, i.e. rowCount - 1
    NSUInteger r, c;
    r = self.rowCount - 1;
    for (NSArray * rowArray in sliders) {
        c = 0;
        for (NSSlider * sl in rowArray) {
            if (sl == slider) {
                [self checkTransposition:&r:&c];
                *row = r;
                *col = c;
                return;
            }
            c++;
        }
        r--;
    }
    
    *row = NSNotFound;
    *col = NSNotFound;
}


// [sliders objectAtIndex:0] is the BOTTOM row, i.e. rowCount - 1
- (NSSlider *) sliderOnRow: (NSUInteger) row column: (NSUInteger) column
{
    [self checkTransposition: &row : &column];
    return [[sliders objectAtIndex: self.rowCount-row-1] objectAtIndex: column];
}


// ------------------------------------------------------------------------------
#pragma mark                Target-Action (PUBLIC)
// ------------------------------------------------------------------------------


- (void) setTarget: (id) target andSelector: (SEL) selector
{
    for (NSArray * rowArray in sliders) {
        for (NSSlider * slider in rowArray) {
            [slider setTarget: target];
            [slider setAction: selector];
        }
    }
}

// ------------------------------------------------------------------------------
#pragma mark                Transpose
// ------------------------------------------------------------------------------



- (void) checkTransposition: (NSUInteger *) row : (NSUInteger *) col
{
    if (_isTransposed) {
        NSInteger temp = *row;
        *row = *col;
        *col = temp;
    }
}

@end
