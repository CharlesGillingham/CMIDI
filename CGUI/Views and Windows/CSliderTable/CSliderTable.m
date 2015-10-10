//
//  CSliderTable.m
//
//  Created by CHARLES GILLINGHAM on 11/4/13.

//  TODO:
//  1) Do actually need the nib? Can I just "initWithView:[SliderTableView new]"? Doesn't really matter at this point.

//  IMPLEMENTATION NOTES
//  - This is a straight forward

#import "CSliderTable.h"
#import "CSliderTableView.h"

#define KVOTrace1
#define KVOTrace2
#define KVOTrace3
#define SLIDERTRACE
#define SLIDERTRACE2
#define SLIDERTRACE3


@interface CSliderTable ()
@property NSString                  * arrayKey;
@property NSString                  * valueKey;
@property NSArray                   * sourceObjects;
@property NSUInteger                  rowCount;
@property NSUInteger                  colCount;
@property BOOL                        fTransposed;

@property IBOutlet CSliderTableView * tableView;
@property IBOutlet NSButton         * connectButton;
@property IBOutlet NSTextField      * nameLabelField;

@end


@implementation CSliderTable {
    BOOL _connected;
}
@synthesize arrayKey;
@synthesize valueKey;
@synthesize sourceObjects;
@synthesize rowCount;
@synthesize colCount;
@synthesize fTransposed;
@synthesize minValue;
@synthesize maxValue;
@synthesize nameLabel;

@dynamic    connected;

// IBOutlets
@synthesize tableView;
@synthesize connectButton;
@synthesize nameLabelField;

// Horizontal matrix where the slider in column j is bound to object.akey[j]
- (id) initWithObject: (NSObject *) obj andArrayKey: (NSString *) aKey
{
    return [self initWithSourceArray:[NSArray arrayWithObject: obj]
                            arrayKey:aKey valueKey:nil];
}

// Two dimensional matrix where the slider on row i, column j is bound to array[i].akey[j]
- (id) initWithArrayOfObjects: (NSArray *) array andArrayKey: (NSString *) akey
{
    return [self initWithSourceArray: array
                            arrayKey: akey valueKey: nil];
}

// Horizontal matrix where the slider in column j is bound to array[j].vkey
- (id) initWithArray: (NSArray *) array andValueKey: (NSString *) vKey
{
    return [self initWithSourceArray:[NSArray arrayWithObject: array]
                            arrayKey:nil valueKey: vKey];
}


// Two dimensional matrix where the slider on row i, column j is bound to array[i][j].vkey
- (id) initWithArrayOfArrays: (NSArray *) array andValueKey: (NSString *) vKey
{
    return [self initWithSourceArray: array
                            arrayKey: nil valueKey: vKey];
}



- (id) initWithSourceArray: (NSArray *) source
                  arrayKey: (NSString *) rKey
                  valueKey: (NSString *) vKey
{
    return [self initWithSourceArray:source arrayKey:rKey valueKey:vKey flags:0];
}


// Two dimensional matrix where the values are at source[i].arrayKey[j].valueKey
- (id) initWithSourceArray: (NSArray *) source
                  arrayKey: (NSString *) rKey
                  valueKey: (NSString *) vKey
                     flags: (NSUInteger) flags
{
    NSString * nibName;

    if ((flags & CSliderTable_Disconnectable)) {
        nibName = @"CSliderTableViewController2.nib";
    } else {
        nibName = @"CSliderTableViewController.nib";
    }
    
    if (self = [self initWithNibName: nibName bundle: nil])
    {
        self.fTransposed = ((flags & CSliderTable_Transposed) != 0);
        self.sourceObjects = source;
        self.arrayKey = rKey;
        self.valueKey = vKey;
        self.minValue = 0.0; // Default values
        self.maxValue = 1.0;
        self.nameLabel = @"Slider table";
        [self modelGetDimensions: &rowCount : &colCount];
        
        _connected = YES;
    }
    return self;
}



- (void) loadView
{
    [super loadView];
    
    
    if (nameLabelField) {
        if (!nameLabel) nameLabel = @"<DISPLAY NAME NOT SET>";
        [nameLabelField setStringValue:nameLabel];
    }
    
    [self viewConfigureSliders];
    [self loadContent];
    
    // Connect it to the object:
    [self viewSetTarget];
    [self modelObserveChanges];
}


- (void) dealloc
{
    // Note that, because dealloc may be called much later than this window is closed and discarded, this view may still be receiving messages long after the window is closed.
    if (self.view) {
        [self modelRemoveObserver];
    }
}

// ------------------------------------------------------------------------------
#pragma mark            Data flow into and out of the model objects
// ------------------------------------------------------------------------------

- (NSMutableArray *) modelGetRow: (NSUInteger) row
{
    if (arrayKey) {
        return [sourceObjects[row] valueForKeyPath:arrayKey];
    } else {
        return sourceObjects[row];
    }
}


- (void) modelGetDimensions: (NSUInteger *) rows
                           : (NSUInteger *) columns
{
    
    NSMutableArray * rowA = [self modelGetRow:0];
    assert([rowA respondsToSelector:@selector(count)]);

    * rows = sourceObjects.count;
    * columns = rowA.count;
}



- (void) modelSaveValue: (NSNumber *) n onRow: (NSUInteger) row column: (NSUInteger) column
{
    NSMutableArray * rowA = [self modelGetRow:row];
    if (valueKey) {
        if (![[rowA[column] valueForKeyPath: valueKey] isEqualTo:n]) {
            [rowA[column] setValue: n forKeyPath:valueKey] ;
        }
    } else {
        if (![rowA[column] isEqualTo: n]) {
            rowA[column] = n;
        }
    }
 }



- (NSNumber *) modelGetValueOnRow: (NSUInteger) row column: (NSUInteger) column
{
    NSMutableArray * rowA = [self modelGetRow:row];
    if (valueKey) {
        return [rowA[column] valueForKeyPath:valueKey];
    } else {
        return rowA[column];
    }
 }



// We need this additional save routine because of the way that CListFDD maintains normalization; setting the whole distribution has a different effect than setting them one at a time. The "commit" button allows us to avoid setting everything at once.
- (void) modelSaveValues: (NSArray *) rowValues onRow: (NSUInteger) row
{
    if (arrayKey && !valueKey) {
        // Set the whole row; this is the justification for this routine.
        [sourceObjects[row] setValue:rowValues forKeyPath:arrayKey];
    } else {
        NSMutableArray * rowA = [self modelGetRow:row];
        
        NSUInteger column = 0;
        for (NSObject * value in rowValues) {
            if (valueKey) {
                [rowA[column++] setValue:value forKeyPath:valueKey];
            } else {
                rowA[column++] = value; // Not used;
            }
        }
    }
}


// -----------------------------------------------------------------------------
#pragma mark                 Observing the model
// -----------------------------------------------------------------------------

NSUInteger makeRowAndColumn( UInt8 row, UInt8 column )
{
    return (row | column << 8);
}


UInt8 rowFromRowAndColumn ( NSUInteger rowAndColumn)
{
    return (rowAndColumn & 0x000000FF);
}


UInt8 columnFromRowAndColumn ( NSUInteger rowAndColumn)
{
    return ((rowAndColumn & 0x0000FF00) >> 8);
}


- (void) modelObserveChanges
{
    NSAssert(valueKey != nil || arrayKey != nil, @"CSliderTable can't observe changes made to this object.");

    UInt8 row = 0;
    for (NSObject * rowSource in sourceObjects) {
        
        if (arrayKey) {
            NSUInteger rowAndColumn = makeRowAndColumn(row,0);
            [rowSource addObserver:self forKeyPath:arrayKey
                           options:0
                           context:(void *)(rowAndColumn)];
        }
        
        if (valueKey) {
            UInt8 column = 0;
            for (NSObject * object in [self modelGetRow:row]) {
                NSUInteger rowAndColumn = makeRowAndColumn(row,column);
                [object addObserver:self forKeyPath:valueKey
                            options:0
                            context:(void *)(rowAndColumn)];
                column++;
            }
        }
        row++;
    }
}



- (void) modelRemoveObserver
{
    NSUInteger row = 0;
    for (NSObject * rowSource in sourceObjects) {
        if (arrayKey) {
            [rowSource removeObserver:self forKeyPath:arrayKey];
        }
        if (valueKey) {
             for (NSObject * object in [self modelGetRow:row]) {
                [object removeObserver:self forKeyPath:valueKey];
            }
        }
        row++;
    }
}



// Model => View

- (void) observeValueForKeyPath:(NSString *)inKP
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if (_connected) {
        
        NSUInteger rowAndColumn = (NSUInteger) context;
        UInt8 row = rowFromRowAndColumn(rowAndColumn);
        UInt8 column = columnFromRowAndColumn(rowAndColumn);
        
        switch ([[change objectForKey:NSKeyValueChangeKindKey] intValue]) {

            case NSKeyValueChangeSetting: {
                if ([inKP isEqualTo:arrayKey]) {
                    [self loadValuesOnRow: row];
                } else {
                    NSAssert([inKP isEqualTo:valueKey],@"Slider table KVC failure: wrong key.");
                    [self loadValueOnRow: row column:column];
                }
                break;
            }
   
            case NSKeyValueChangeReplacement: {
                NSAssert([inKP isEqualTo:valueKey],@"Slider table KVC failure: wrong key.");
                NSIndexSet * idxSet = [change objectForKey:NSKeyValueChangeIndexesKey];
                [idxSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    KVOTrace2;
                    [self loadValueOnRow: row column: idx];
                }];
                break;
            }
        
            default: {
                // The dimensions have changed.
                // Should reload the whole view for the other cases, but I'm not sure if the view currently supports a complete reload and I don't want to test it.
                NSAssert(NO,@"Slider table KVC failure: can't change dimensions.");
            }
        }
        
    }
}



// ------------------------------------------------------------------------------
#pragma mark            Data flow into and out of the slider matrix
// ------------------------------------------------------------------------------

- (void) viewConfigureSliders
{
    tableView.minValue = self.minValue;
    tableView.maxValue = self.maxValue;
    [tableView setDimensions: self.rowCount : self.colCount: self.fTransposed];

}



- (void) viewLoadValue: (NSNumber *) n
                 onRow: (NSUInteger) row
                column: (NSUInteger) column
{
    NSSlider * slider = [tableView sliderOnRow: row column: column];
    SLIDERTRACE;
    if ([slider doubleValue] == [n doubleValue]) return;
    [slider setDoubleValue:[n doubleValue]];
}


- (NSNumber *) viewGetValueOnRow: (NSUInteger) row
                          column: (NSUInteger) column
{
    NSSlider * slider = [tableView sliderOnRow: row column: column];
    return [NSNumber numberWithDouble:[slider doubleValue]];
}



- (NSArray *) viewGetValuesOnRow: (NSUInteger) row
{
    NSMutableArray * vs = [NSMutableArray arrayWithCapacity:colCount];
    for (NSUInteger col = 0; col < colCount; col++) {
        [vs addObject:[self viewGetValueOnRow:row column:col]];
    }
    return vs;
}


// ------------------------------------------------------------------------------
#pragma mark            Observing the slider matrix
// ------------------------------------------------------------------------------


- (void) viewSetTarget
{
    [tableView setTarget: self andSelector:@selector(sliderMoved:)];
}


- (IBAction) sliderMoved:(id)sender
{
    if (_connected) {
        SLIDERTRACE2;
        NSInteger row, col;
        [tableView positionOfSlider: (NSSlider *)sender row: &row column: &col];
        assert(row != NSNotFound && col != NSNotFound);
        [self saveValueOnRow: row column: col];
        SLIDERTRACE3;
    }
}


// ------------------------------------------------------------------------------
#pragma mark            Data flow between the view and object
// ------------------------------------------------------------------------------

// TODO: Some of this could move into the view ... the view could just give and receive content.

// View => Model
// Save all the rows and columns
- (void) saveContent
{
    for (NSUInteger row = 0; row < rowCount; row++) {
        NSArray * vals = [self viewGetValuesOnRow:row];
        [self modelSaveValues:vals onRow:row];
    }
}


// View[i][j] => Model[i][j]
- (void) saveValueOnRow: (NSUInteger) row column: (NSUInteger) col
{
    NSNumber * value = [self viewGetValueOnRow: row column: col];
    [self modelSaveValue: value onRow: row column: col];
}



// Model => View
// Called when the entire model is changed (e.g., at initialization)
- (void) loadContent
{
    for (NSUInteger row = 0; row < rowCount; row++) {
        for (NSUInteger col = 0; col < colCount; col++) {
            [self loadValueOnRow:row column: col];
        }
    }
}

// Model[i] => View[i]
// Called when the whole array is changed and we receive a notification for "arrayKey"
- (void) loadValuesOnRow: (NSUInteger) row
{
    for (NSUInteger col = 0; col < colCount; col++) {
        [self loadValueOnRow:row column: col];
    }
}


// Model[i][j] => View[i][j]
// Called when one item in the model is changed and we receive a notification for "valueKey"
- (void) loadValueOnRow: (NSUInteger) row column: (NSUInteger) col
{
    NSNumber * value = [self modelGetValueOnRow:row column:col];
    [self viewLoadValue: value onRow: row column: col];
}



// ------------------------------------------------------------------------------
#pragma mark                   Commit support
// ------------------------------------------------------------------------------
// If connected = NO, then the KVO connection is broken.

- (IBAction) connectButtonToggled: (id) sender
{
    self.connected = (connectButton.state == NSOffState);
}

- (void) setConnected: (BOOL) c
{
    if (!_connected && c) {
        _connected = c;
        [self saveContent];
    } else {
        _connected = c;
    }
}

- (BOOL) connected {
    return _connected;
}

@end

