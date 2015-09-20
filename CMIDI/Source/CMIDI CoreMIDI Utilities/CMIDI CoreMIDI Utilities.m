//
//  CMIDIApplicationClient.c
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 5/23/14.
//

#include "CMIDI CoreMIDI Utilities.h"


MIDIClientRef CApplicationMIDIClient = 0;


MIDIClientRef CMIDIClient()
{
    if (!CApplicationMIDIClient) {
        MIDIClientCreate(CFSTR("CMIDIApplication client"), NULL, 0, &CApplicationMIDIClient);
    }
    return CApplicationMIDIClient;
}



NSString * CMIDIEndpointName( MIDIEndpointRef endpointRef )
{
    NSString * string;
    if (!endpointRef) {
        string = @"Uninitialize MIDI endpoint";
    } else {
        MIDIEntityRef entity = 0;
        MIDIEndpointGetEntity(endpointRef, &entity);
        
        
        CFPropertyListRef properties = nil;
        OSStatus err = MIDIObjectGetProperties(entity, &properties, true);
        if (err) {
            err = MIDIObjectGetProperties(endpointRef, &properties, true);
        }
        
        if (err) {
            string = @"MIDI endpoint with no name";
        } else {
            NSDictionary *dictionary = (__bridge NSDictionary *)(properties);
            string = [NSString stringWithFormat:@"%@", [dictionary valueForKey:@"name"]];
            CFRelease(properties);
        }
        
    }
    return string;
    
}
