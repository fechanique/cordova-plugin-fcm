//
//  AppDelegate+FCMPlugin.m
//  TestApp
//
//  Created by felipe on 12/06/16.
//
//
#import "AppDelegate+FCMPlugin.h"
#import "FCMPlugin.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

#import "Firebase.h"

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;
#endif

// Implement UNUserNotificationCenterDelegate to receive display notification via APNS for devices
// running iOS 10 and above. Implement FIRMessagingDelegate to receive data message via FCM for
// devices running iOS 10 and above.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate>

@end
#endif

static NSData* lastNotification;

// Copied from Apple's header in case it is missing in some cases (e.g. pre-Xcode 8 builds).
#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

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
        //For iOS 10 data message (sent direct from FCM)
        [FIRMessaging messaging].delegate = self;
#endif
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [FIRMessaging messaging].shouldEstablishDirectChannel = YES;
    
    return YES;
}

//////////////////////////////////////////////////////
/////////////////////////IOS 9////////////////////////
//////////////////////////////////////////////////////

// COMMENT: Its hard to tell from the FCM documentation whether didReceiveRemoteNotification will be fired on iOS 10 
// as well as willPresentNotification
// If it does then we need to put the 'short circuit' code back in didReceiveRemoteNotification
// to stop the notification being recognized twice by the plugin

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"application:didReceiveRemoteNotification:fetchCompletionHandler:");
    //FORGROUND => NOTIF + DATA                         [ios 9]
    //BACKGROUND.content_available=1 => NOTIF + DATA    [ios 9]
    //BACKGROUND.TAPPED => NOTIF + DATA                 [ios 9]
    //FOREGROUND => DATA                                [ios 9]
    
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

// COMMENT: It would seem that in iOS 10, content-available=1 messages don't work anymore. 
// It is hard to know whether this is true

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
  NSLog(@"userNotificationCenter:willPresentNotification:withCompletionHandler:");
  //FOREGROUND => NOTIF + DATA                        [ios 10]
  //BACKGROUND.content_available=1 => NOTIF + DATA    [ios 10] [DOESN'T WORK] https://forums.developer.apple.com/thread/64943
  [self notifyOfMessage:notification.request.content.userInfo withTapInfo:false];

  completionHandler(UNNotificationPresentationOptionNone);
}

// COMMENT: Might be a problem here if applicationDidBecomeActive is called before didReceiveNotificationResponse
// This would result in the notification not being recognised by the plugin because of the newly implemented
// [self notifyOfMessage] function which stores the data instead of sending it to javascript IF wasTapped = true
// Just not sure if iOS calls it before the app goes into the foreground OR when it goes into the foreground

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSLog(@"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:");
    //BACKGROUND.TAPPED => NOTIF + DATA                [ios 10]
    [self notifyOfMessage:response.notification.request.content.userInfo withTapInfo:true];
}

- (void)messaging:(nonnull FIRMessaging *)messaging didReceiveMessage:(nonnull FIRMessagingRemoteMessage *)remoteMessage {
    NSLog(@"messaging:didReceiveMessage:remoteMessage:");
    //FOREGROUND => DATA                               [ios 10]
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
    NSLog(@"applicationDidBecomeActive:");
    if(lastNotification) {
        [FCMPlugin.fcmPlugin notifyOfMessage:lastNotification];
        lastNotification = NULL;
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"applicationDidEnterBackground:");
}

//////////////////////////////////////////////////////
///////////////////MESSAGE HANDLING///////////////////
//////////////////////////////////////////////////////

-(void) notifyOfMessage: (NSDictionary*) notification withTapInfo:(BOOL)wasTapped {
    NSData *jsonData = [self packageMessage:notification withTapInfo:wasTapped];
    [self logMessage:jsonData];
    
    if(wasTapped) {
        NSLog(@"notifyOfMessage:withTapInfo: => wasTapped = true... therefore going to store the data and send when app returns to the foreground");
        lastNotification = jsonData;
        return;
    }
    [FCMPlugin.fcmPlugin notifyOfMessage:jsonData];
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
