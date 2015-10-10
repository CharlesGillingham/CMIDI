//
//  CSliderTable.h
//
//  Created by CHARLES GILLINGHAM on 12/2/13.
//  Copyright (c) 2013 CHARLES GILLINGHAM. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum {
    CSliderTable_Transposed      = 0x01,
    CSliderTable_Disconnectable  = 0x02
};


@interface CSliderTable : NSViewController

// Must be set before the view is loaded, and not changed later.
@property NSString * nameLabel;
@property Float64    minValue; // Defaults to 0.0
@property Float64    maxValue; // Defaults to 1.0

// True by default. Setting this to false temporarily disconnects all the bindings. When it is set to true again, the values in the objects are set to match the sliders in the UI.
@property BOOL connected;

// Horizontal matrix where the slider in column j is bound to object.key[j]
- (id) initWithObject: (NSObject *) obj andArrayKey: (NSString *) key;

// Horizontal matrix where the slider in column j is bound to array[j].key
- (id) initWithArray: (NSArray *) array andValueKey: (NSString *) key;

// Two dimensional matrix where the slider on row i, column j is bound to array[i].key[j]
- (id) initWithArrayOfObjects: (NSArray *) array andArrayKey: (NSString *) akey;

// Two dimensional matrix where the slider on row i, column j is bound to array[i][j].key
- (id) initWithArrayOfArrays: (NSArray *) array andValueKey: (NSString *) vKey;

// Two dimensional matrix where the slider on row i, column j is bound to source[i].rKey[j].vKey
- (id) initWithSourceArray: (NSArray *) source
                  arrayKey: (NSString *) rKey
                  valueKey: (NSString *) vKey;

// Primitive entry point
- (id) initWithSourceArray: (NSArray *) source
                  arrayKey: (NSString *) rKey
                  valueKey: (NSString *) vKey
                     flags: (NSUInteger) flags;


@end



//@interface CTransposedSliderTable : CSliderTable
//@end

// Appears without a nameLabel or "connected" button. 
//@interface CPlainSliderTable : CSliderTable
//@end
