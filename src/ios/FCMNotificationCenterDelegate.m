#import "AppDelegate+FCMPlugin.h"
#import "FCMPlugin.h"
#import "FCMNotificationCenterDelegate.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

@import UserNotifications;

// Implement UNUserNotificationCenterDelegate to receive display notification via APNS for devices
// running iOS 10 and above.
@interface FCMNotificationCenterDelegate () <UNUserNotificationCenterDelegate>
@end

@implementation FCMNotificationCenterDelegate

NSMutableArray<NSObject<UNUserNotificationCenterDelegate>*> *subNotificationCenterDelegates;

- (void) forceNotificationCenterDelegate:(float)timeout {
    [self setNotificationCenterDelegate];
    if(timeout < 0) {
        // The job should be done.
        return;
    }
    SEL thisMethodSelector = NSSelectorFromString(@"forceNotificationCenterDelegate:");
    if([self respondsToSelector:thisMethodSelector]) {
//        NSLog(@"FCMNotificationCenterDelegate found: %@", [UNUserNotificationCenter currentNotificationCenter].delegate);
        float remainingTimeout = timeout - 0.1f;
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:thisMethodSelector]];
        [invocation setSelector:thisMethodSelector];
        [invocation setTarget:self];
        [invocation setArgument:&(remainingTimeout) atIndex:2];
        [NSTimer scheduledTimerWithTimeInterval:0.1f invocation:invocation repeats:NO];
        return;
    }
    NSLog(@"forceNotificationCenterDelegate selector not found in FCMNotificationCenterDelegate");
}

- (void)configureForNotifications {
    subNotificationCenterDelegates = [[NSMutableArray alloc]initWithCapacity:0];
    [self setNotificationCenterDelegate];
    [self forceNotificationCenterDelegate:10];
}

- (void) setNotificationCenterDelegate {
    if([UNUserNotificationCenter currentNotificationCenter].delegate == self) {
        return;
    }
    if([UNUserNotificationCenter currentNotificationCenter].delegate != nil) {
        [subNotificationCenterDelegates addObject:[UNUserNotificationCenter currentNotificationCenter].delegate];
//        NSLog(@"subNotificationCenterDelegates: %@", subNotificationCenterDelegates);
    }
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
}


// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;

    // Print full message.
    NSLog(@"willPresentNotification: %@", userInfo);

    NSError *error;
    NSDictionary *userInfoMutable = [userInfo mutableCopy];
    [userInfoMutable setValue:@(NO) forKey:@"wasTapped"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfoMutable
                                                       options:0
                                                         error:&error];
    [FCMPlugin.fcmPlugin notifyOfMessage:jsonData];

    if(subNotificationCenterDelegates.count == 0){
        // No subNotificationCenterDelegates to work with
        // Change this to your preferred presentation option
        completionHandler(UNNotificationPresentationOptionNone);
    }

    // Change this to your preferred presentation option
    __block UNNotificationPresentationOptions notificationPresentationOptions = UNNotificationPresentationOptionNone;
    void (^subDelegateCompletionHandler)(UNNotificationPresentationOptions) = ^(UNNotificationPresentationOptions possibleNotificationPresentationOptions)
    {
        if(notificationPresentationOptions < possibleNotificationPresentationOptions) {
            notificationPresentationOptions = possibleNotificationPresentationOptions;
        }
    };
    SEL thisMethodSelector = NSSelectorFromString(@"userNotificationCenter:willPresentNotification:withCompletionHandler:");
    for (NSObject<UNUserNotificationCenterDelegate>* subNotificationCenterDelegate in subNotificationCenterDelegates) {
        if([subNotificationCenterDelegate respondsToSelector:thisMethodSelector]) {
            [subNotificationCenterDelegate userNotificationCenter:center willPresentNotification:notification withCompletionHandler:subDelegateCompletionHandler];
        // } else {
        //     NSLog(@"subNotificationCenterDelegates[i] not found willPresentNotification: %@", subNotificationCenterDelegate );
        }
    }

    completionHandler(notificationPresentationOptions);
}

// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;

    // Print full message.
    NSLog(@"didReceiveNotificationResponse: %@", userInfo);

    NSError *error;
    NSDictionary *userInfoMutable = [userInfo mutableCopy];
    [userInfoMutable setValue:@(YES) forKey:@"wasTapped"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfoMutable options:0 error:&error];
    [AppDelegate setInitialPushPayload:jsonData];
    [FCMPlugin.fcmPlugin notifyOfMessage:jsonData];

    if(subNotificationCenterDelegates.count == 0){
        // No subNotificationCenterDelegates to work with
        completionHandler();
    }

    void (^noopCompletionHandler)(void) = ^(){};
    SEL thisMethodSelector = NSSelectorFromString(@"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:");
    for (NSObject<UNUserNotificationCenterDelegate>* subNotificationCenterDelegate in subNotificationCenterDelegates) {
        if([subNotificationCenterDelegate respondsToSelector:thisMethodSelector]) {
            [subNotificationCenterDelegate userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:noopCompletionHandler];
        }
    }
    completionHandler();
}

@end
