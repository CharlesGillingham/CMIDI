//
//  CMIDI Time.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 7/15/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//
//  Basic definitions, and convenience properties for CTime objects used with music and MIDI.

#import <Foundation/Foundation.h>
// -----------------------------------------------------------------------------
#pragma mark                    Time Units
// -----------------------------------------------------------------------------
// These formats have the advantage that they are integers -- they do no suffer from floating point errors and thus can represent musical events precisely. Other units (such as "beats" or "seconds") have to represented with floating point numbers.

// A particular time in a sequence or composition, or the current time as reported by the machine.
typedef SInt64 CMIDINanoseconds;

// A "clock tick". From this, using the hierarchy, ou can calculate beats (given a value for "ticksPerBeat"), bars, etc.
typedef SInt64 CMIDIClockTicks;

// -----------------------------------------------------------------------------
#pragma mark                    Utilities
// -----------------------------------------------------------------------------

CMIDINanoseconds CMIDINow();

