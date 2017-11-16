//
//  AppDelegate+FCMPlugin.m
//  TestApp
//
//  Created by felipe on 12/06/16.
//
//
#import "AppDelegate+FCMPlugin.h"
#import "FCMPlugin.h"
#import "FCMQueue.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

// Implement UNUserNotificationCenterDelegate to receive display notification via APNS for devices
// running iOS 10 and above. Implement FIRMessagingDelegate to receive data message via FCM for
// devices running iOS 10 and above.


@implementation AppDelegate (FCMPlugin)

//////////////////////////////////////////////////////
///////////////////INITIALIZATION/////////////////////
//////////////////////////////////////////////////////

//Method swizzling
+ (void)load
{
    Method original =  class_getInstanceMethod(self, @selector(application:didFinishLaunchingWithOptions:));
    Method custom =    class_getInstanceMethod(self, @selector(application:customDidFinishLaunchingWithOptions:));
    method_exchangeImplementations(original, custom);
}

- (BOOL)application:(UIApplication *)application customDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self application:application customDidFinishLaunchingWithOptions:launchOptions];
    
    NSLog(@"DidFinishLaunchingWithOptions");
    
    [FIRApp configure];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        UNAuthorizationOptions authOptions =
        UNAuthorizationOptionAlert
        | UNAuthorizationOptionSound
        | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
        }];
        
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
#endif
    }
    
    [FIRMessaging messaging].delegate = self;
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [FIRMessaging messaging].shouldEstablishDirectChannel = YES;
    

    
    return YES;
}

//////////////////////////////////////////////////////
/////////////////////////IOS 9////////////////////////
//////////////////////////////////////////////////////

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"application:didReceiveRemoteNotification:fetchCompletionHandler:");
    //FORGROUND => NOTIF + DATA                             [ios 9]
    //BACKGROUND.content_available=1 => NOTIF + DATA        [ios 9]
    //BACKGROUND.TAPPED => NOTIF + DATA                     [ios 9]
    //FOREGROUND => DATA                                    [ios 9]
    
    // Has user tapped the notification?
    // UIApplicationStateActive   - app is currently active
    // UIApplicationStateInactive - app is transitioning from background to foreground (user taps notification)
    
    UIApplicationState state = application.applicationState;
    if (state == UIApplicationStateInactive) {
        [self notifyOfMessage:userInfo withTapInfo:true];
    } else {
        [self notifyOfMessage:userInfo withTapInfo:false];
    }
    completionHandler(UIBackgroundFetchResultNewData);
}



//////////////////////////////////////////////////////
/////////////////////////IOS 10///////////////////////
//////////////////////////////////////////////////////

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSLog(@"userNotificationCenter:willPresentNotification:withCompletionHandler:");
    //FOREGROUND => NOTIF + DATA                                  [ios 10]
    [self notifyOfMessage:notification.request.content.userInfo withTapInfo:false];
    
    completionHandler(UNNotificationPresentationOptionNone);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSLog(@"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:");
    //BACKGROUND.TAPPED => NOTIF + DATA                         [ios 10]
    //BACKGROUND.content_available=1.TAPPED => NOTIF + DATA     [ios 10] content_available=1 doesn't do anything, notification is treated like a normal bg notification
    [self notifyOfMessage:response.notification.request.content.userInfo withTapInfo:true];
    
    completionHandler();
}

- (void)messaging:(nonnull FIRMessaging *)messaging didReceiveMessage:(nonnull FIRMessagingRemoteMessage *)remoteMessage {
    NSLog(@"messaging:didReceiveMessage:remoteMessage:");
    //FOREGROUND => DATA                                        [ios 10]
    //BACKGROUND.content_available=1 => DATA                    [ios 10] content_available=1 doesn't do anything, notification is treated like normal foreground data notification => https://github.com/ostownsville/cordova-plugin-fcm/pull/4#issuecomment-327722950 && https://forums.developer.apple.com/thread/64943
    [self notifyOfMessage:remoteMessage.appData withTapInfo:false];
}
#endif

//////////////////////////////////////////////////////
////////////////////REFRESH TOKENS////////////////////
//////////////////////////////////////////////////////
- (void)messaging:(nonnull FIRMessaging *)messaging didRefreshRegistrationToken:(nonnull NSString *)fcmToken
{
    NSLog(@"messaging:didRefreshRegistrationToken:");
    [FCMPlugin.fcmPlugin notifyOfTokenRefresh:fcmToken];
}


//////////////////////////////////////////////////////
////////////////FOREGROUND/BACKGROUND/////////////////
//////////////////////////////////////////////////////

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[FCMQueue sharedFCMQueue] setIsInForground:YES];
    NSLog(@"applicationDidBecomeActive:");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[FCMQueue sharedFCMQueue] setIsInForground:NO];
    NSLog(@"applicationDidEnterBackground:");
}

//////////////////////////////////////////////////////
///////////////////MESSAGE HANDLING///////////////////
//////////////////////////////////////////////////////

-(void) notifyOfMessage: (NSDictionary*) notification withTapInfo:(BOOL)wasTapped {
    NSData *jsonData = [self packageMessage:notification withTapInfo:wasTapped];
    [self logMessage:jsonData];

    //Push notification onto a queue...
    [[FCMQueue sharedFCMQueue] pushNotificationToQueue:jsonData];
}

-(void) logMessage: (NSData*) messageData {
    NSLog(@"Notification Data: %@", messageData);
}

-(NSData*) packageMessage: (NSDictionary*) notification withTapInfo:(BOOL)wasTapped {
    NSError *error;
    NSDictionary *notificationMut = [notification mutableCopy];
    [notificationMut setValue:@(wasTapped) forKey:@"wasTapped"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:notificationMut
                                                       options:0
                                                         error:&error];
    return jsonData;
}

@end
