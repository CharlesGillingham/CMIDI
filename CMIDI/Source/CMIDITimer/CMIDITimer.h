//
//  CMIDITimer.h
//  CMIDI
//
//  Created by CHARLES GILLINGHAM on 2/3/14.
//

#import <Foundation/Foundation.h>
#import "CMIDI Time.h"

@protocol CMIDITimerReceiver
- (void) timerDone: (CMIDINanoseconds) hostTime;
@end

@interface CMIDITimer : NSObject

// Timer does not retain the receiver; caller is responsible for seeing to it that the object is not deallocated before the timer returns.
+ (instancetype) timerWithReceiver: (id<CMIDITimerReceiver>) receiver;

- (void) sendMessageAtHostTime: (CMIDINanoseconds) hostTime;

- (void) deleteMessagesInProgress;

@end


