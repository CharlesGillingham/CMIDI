//
//  CApplicationMIDIClient.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 5/23/14.


#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

MIDIClientRef CMIDIClient();

NSString * CMIDIEndpointName(MIDIEndpointRef endpointRef);

#define CNOERR(err) (NSAssert((err) == 0, @"Fatal error"))
