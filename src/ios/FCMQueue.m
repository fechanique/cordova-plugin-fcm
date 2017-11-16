//
//  FCMQueue.m
//  Cordova Plugin Test
//
//  Created by Chris Palmer on 16/11/17.
//

#import "FCMQueue.h"
#import "FCMPlugin.h"


//THREAD SAFE QUEUE
@implementation FCMQueue

#pragma mark Singleton Methods

+ (id)sharedFCMQueue {
    static FCMQueue *sharedQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedQueue = [[self alloc] init];
    });
    return sharedQueue;
}

- (id)init {
    if (self = [super init]) {
        isInForeground = YES;
        notificationCallbackRegistered = NO;
        queueLock = [[NSLock alloc] init];
        queue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}


- (void)setIsInForground:(BOOL)value {
    isInForeground = value;
    [self triggerOffloadQueue];
}

- (void)setNotificationCallbackRegistered:(BOOL)value {
    notificationCallbackRegistered = value;
    [self triggerOffloadQueue];
}

-(void) pushNotificationToQueue: (NSData*) jsonData {
    [queueLock lock];
    [queue addObject:jsonData];
    [queueLock unlock];
    
    //trigger the queue to be offloaded anyway, see if we can...
    [self triggerOffloadQueue];
}

-(void) triggerOffloadQueue {
    BOOL canOffloadQueue = isInForeground && notificationCallbackRegistered;
    //Need to be in the foreground AND have a notification callback
    if(canOffloadQueue) {
        //Conditions met, lets offload the queue
        [self offloadQueue];
    } else {
        [self countQueue];
    }
}

-(void) offloadQueue {
    [queueLock lock];
    
    for(NSData* jsonData in queue) {
        [FCMPlugin.fcmPlugin notifyOfMessage:jsonData];
    }
    
    [queue removeAllObjects];
    
    [queueLock unlock];
}

-(void) countQueue {
    [queueLock lock];
    
    int count = (int) [queue count];
    if (count > 0) {
        NSLog(@"Cannot offload notification queue, objects waiting %d", count);
    }
    
    [queueLock unlock];
}

@end
