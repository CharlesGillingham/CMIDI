//
//  CMIDIMessage+DescriptionWithTimeMap.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 9/11/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#import "CMIDIMessage+Description.h"
#import "CMIDITempoMeter.h"


@interface CMIDIMessage (DescriptionWithTime)
- (NSString *) timeString: (CMIDITempoMeter *) map;

// Description with time
- (NSString *) descriptionWithTimeMap: (CMIDITempoMeter *) map;
- (NSString *) tableRowStringWithTimeMap: (CMIDITempoMeter *) map;
+ (NSString *) tableHeaderWithTimeMap: (CMIDITempoMeter *) map;

@end
