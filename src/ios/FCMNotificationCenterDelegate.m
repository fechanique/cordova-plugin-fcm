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
    NSLog(@"FCMNotificationCenterDelegate.willPresentNotification!");
    NSData *jsonData = [self extractJSONData:notification withWasTapped:NO];
    [FCMPlugin.fcmPlugin notifyOfMessage:jsonData];
    __block UNNotificationPresentationOptions notificationPresentationOptions = UNNotificationPresentationOptionNone;
    void (^subDelegateCompletionHandler)(UNNotificationPresentationOptions) = ^(UNNotificationPresentationOptions possibleNotificationPresentationOptions) {
        if(notificationPresentationOptions < possibleNotificationPresentationOptions) {
            notificationPresentationOptions |= possibleNotificationPresentationOptions;
        }
    };
    SEL thisMethodSelector = NSSelectorFromString(@"userNotificationCenter:willPresentNotification:withCompletionHandler:");
    for (NSObject<UNUserNotificationCenterDelegate>* subNotificationCenterDelegate in subNotificationCenterDelegates) {
        if([subNotificationCenterDelegate respondsToSelector:thisMethodSelector]) {
            [subNotificationCenterDelegate userNotificationCenter:center willPresentNotification:notification withCompletionHandler:subDelegateCompletionHandler];
        }
    }
    completionHandler(notificationPresentationOptions);
}

// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    NSLog(@"FCMNotificationCenterDelegate.didReceiveNotificationResponse!");
    NSData *jsonData = [self extractJSONData:response.notification withWasTapped:YES];
    [AppDelegate setInitialPushPayload:jsonData];
    [FCMPlugin.fcmPlugin notifyOfMessage:jsonData];
    void (^noopCompletionHandler)(void) = ^(){};
    SEL thisMethodSelector = NSSelectorFromString(@"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:");
    for (NSObject<UNUserNotificationCenterDelegate>* subNotificationCenterDelegate in subNotificationCenterDelegates) {
        if([subNotificationCenterDelegate respondsToSelector:thisMethodSelector]) {
            [subNotificationCenterDelegate userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:noopCompletionHandler];
        }
    }
    completionHandler();
}

- (NSData*)extractJSONData:(UNNotification*)notification
             withWasTapped:(BOOL)wasTapped {
    UNNotificationContent *content = notification.request.content;
    NSLog(@"Push notification received: title=\"%@\" subtitle=\"%@\" body=\"%@\" badge=\"%@\"",
          content.title, content.subtitle, content.body, content.badge);
    NSLog(@"Push data received: %@", content.userInfo);
    NSDictionary *notificationData = [content.userInfo mutableCopy];
    if([notificationData objectForKey:@"wasTapped"] == nil) { [notificationData setValue:@(wasTapped) forKey:@"wasTapped"]; }
    if([notificationData objectForKey:@"title"] == nil) { [notificationData setValue:content.title forKey:@"title"]; }
    if([notificationData objectForKey:@"subtitle"] == nil) { [notificationData setValue:content.subtitle forKey:@"subtitle"]; }
    if([notificationData objectForKey:@"body"] == nil) { [notificationData setValue:content.body forKey:@"body"]; }
    if([notificationData objectForKey:@"badge"] == nil) { [notificationData setValue:content.badge forKey:@"badge"]; }
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:notificationData options:0 error:&error];
    if(error != NULL) {
        NSLog(@"Error on converting to JSON: %@", notificationData);
        return NULL;
    }
    return jsonData;
}

@end
