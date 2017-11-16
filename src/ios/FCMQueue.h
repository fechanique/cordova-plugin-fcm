//
//  FCMQueue.h
//  Cordova Plugin Test
//
//  Created by Chris Palmer on 16/11/17.
//

#import <Foundation/Foundation.h>

//THREADSAFE QUEUE
@interface FCMQueue : NSObject {
    NSLock *queueLock;
    NSMutableArray *queue;
    
    
    BOOL isInForeground;
    BOOL notificationCallbackRegistered;
}

- (void)setIsInForground:(BOOL)value;
- (void)setNotificationCallbackRegistered:(BOOL)value;
- (void) pushNotificationToQueue: (NSData*_Nonnull) jsonData;

+ (id _Nonnull )sharedFCMQueue;

@end
