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

@import FirebaseInstanceID;
@import FirebaseMessaging;

// Implement UNUserNotificationCenterDelegate to receive display notification via APNS for devices
// running iOS 10 and above. Implement FIRMessagingDelegate to receive data message via FCM for
// devices running iOS 10 and above.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate>
@end
#endif

// Copied from Apple's header in case it is missing in some cases (e.g. pre-Xcode 8 builds).
#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

@implementation AppDelegate (MCPlugin)

static NSData *lastPush;
NSString *const kGCMMessageIDKey = @"gcm.message_id";

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


    // Register for remote notifications. This shows a permission dialog on first run, to
    // show the dialog at a more appropriate time move this registration accordingly.
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        // iOS 7.1 or earlier. Disable the deprecation warnings.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIRemoteNotificationType allNotificationTypes =
        (UIRemoteNotificationTypeSound |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeBadge);
        [application registerForRemoteNotificationTypes:allNotificationTypes];
#pragma clang diagnostic pop
    } else {
        // iOS 8 or later
        // [START register_for_notifications]
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
            // For iOS 10 data message (sent via FCM)
            [FIRMessaging messaging].delegate = self;
#endif
        }

        [[UIApplication sharedApplication] registerForRemoteNotifications];
        // [END register_for_notifications]
    }

    // [START configure_firebase]
    [FIRApp configure];
    // [END configure_firebase]
    // Add observer for InstanceID token refresh callback.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:)
                                                 name:kFIRInstanceIDTokenRefreshNotification object:nil];
    return YES;
}


//////////////////////////////////////////////////////
/////////////////////////IOS 10///////////////////////
//////////////////////////////////////////////////////

// Receive displayed notifications for iOS 10 devices.
// Note on the pragma: When compiling with iOS 10 SDK, include methods that
//                     handle notifications using notification center.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

// [START: FOREGROUND => NOTIFICATION || iOS = 10]
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSLog(@"userNotificationCenter:willPresentNotification:withCompletionHandler()");
    // Print message ID.
    NSDictionary *userInfo = notification.request.content.userInfo;
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"FOREGROUND => NOTIFICATION || iOS = 10: %@", userInfo[kGCMMessageIDKey]);
    }

    // Print full message.
    NSLog(@"%@", userInfo);

    NSError *error;
    NSDictionary *userInfoMutable = [userInfo mutableCopy];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfoMutable
                                                       options:0
                                                         error:&error];
    //JAVASCRIPT onNotification()
    [FCMPlugin.fcmPlugin notifyOfMessage:jsonData];

    // Change this to your preferred presentation option
    completionHandler(UNNotificationPresentationOptionNone); //When we are in the foreground, don't display the notification
}
// [END: FOREGROUND => NOTIFICATION || iOS = 10]

// [START: TAPPED => NOTIFICATION || iOS = 10]
// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler {
    NSLog(@"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler()");
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"TAPPED => NOTIFICATION || iOS = 10: %@", userInfo[kGCMMessageIDKey]);
    }

    // Print full message.
    NSLog(@"aaa%@", userInfo);

    NSError *error;
    NSDictionary *userInfoMutable = [userInfo mutableCopy];

    NSLog(@"New method with push callback: %@", userInfo);
    [userInfoMutable setValue:@(YES) forKey:@"wasTapped"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfoMutable
                                                       options:0
                                                         error:&error];
    
    //Save the data so that when the app loads it can read the variable lastPush and call the onNotification() handler
    NSLog(@"APP WAS CLOSED DURING PUSH RECEPTION Saved data: %@", jsonData);
    lastPush = jsonData;

    completionHandler();
}
// [END: TAPPED => NOTIFICATION || iOS = 10]

// [START: FOREGROUND,TAPPED => DATA || iOS = 10]
- (void)messaging:(nonnull FIRMessaging *)messaging
didReceiveMessage:(nonnull FIRMessagingRemoteMessage *)remoteMessage
{
    NSLog(@"messaging:didReceiveMessage:remoteMessage()");
    // Print message ID.
    NSDictionary *userInfo = remoteData.appData;
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"FOREGROUND,TAPPED => DATA || iOS = 10: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    NSError *error;
    NSDictionary *userInfoMutable = [userInfo mutableCopy];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfoMutable
                                                       options:0
                                                         error:&error];
    //JAVASCRIPT onNotification()
    [FCMPlugin.fcmPlugin notifyOfMessage:jsonData];
}
// [END: FOREGROUND,TAPPED => DATA || iOS = 10]

#endif



//////////////////////////////////////////////////////
///////////////////////IOS < 10///////////////////////
//////////////////////////////////////////////////////

// Include the iOS < 10 methods for handling notifications for when running on iOS < 10.
// As in, even if you compile with iOS 10 SDK, when running on iOS 9 the only way to get
// notifications is the didReceiveRemoteNotification.

// [START: FOREGROUND,TAPPED,BACKGROUND => NOTIFICATION + DATA || iOS < 10]
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"application:didReceiveRemoteNotification:fetchCompletionHandler()");
    // Short-circuit when actually running iOS 10+, let notification centre methods handle the notification.
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_9_x_Max) {
        // check if message is a silent message
        NSString* JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        
        if ([JSONString rangeOfString:@"FCM_PLUGIN_ACTIVITY"].location != NSNotFound)
            return;
    }
    
    NSError *error;
    NSDictionary *userInfoMutable = [userInfo mutableCopy];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfoMutable
                                                       options:0
                                                         error:&error];

    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.

    // Print message ID.
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);

    // Pring full message.
    NSLog(@"%@", userInfo);


    // Has user tapped the notificaiton?
    // UIApplicationStateActive   - app is currently active
    // UIApplicationStateInactive - app is transitioning from background to
    //                              foreground (user taps notification)

    UIApplicationState state = application.applicationState;
    if (application.applicationState == UIApplicationStateActive || application.applicationState == UIApplicationStateInactive) {
        
        if(appliation.applicationState == UIApplicationStateInactive) {
            NSLog(@"app becoming active");
            [userInfoMutable setValue:@(YES) forKey:@"wasTapped"];
        }

        [FCMPlugin.fcmPlugin notifyOfMessage:jsonData];
    }

    completionHandler(UIBackgroundFetchResultNoData);
}
// [END: FOREGROUND,TAPPED => NOTIFICATION + DATA || iOS < 10]

//REMOVED THE METHOD: - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo [DEPRECIATED]
//https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623117-application?changes=latest_minor&language=objc


//////////////////////////////////////////////////////
////////////////////REFRESH TOKENS////////////////////
//////////////////////////////////////////////////////

// [START: REFRESH TOKEN || iOS = 10]
- (void)messaging:(nonnull FIRMessaging *)messaging
didRefreshRegistrationToken:(nonnull NSString *)fcmToken
{
    NSLog(@"iOS = 10: messaging:didRefreshRegistrationToken: InstanceID token: %@", fcmToken);
    [FCMPlugin.fcmPlugin notifyOfTokenRefresh:refreshedToken];
    
    // Connect to FCM since connection may have failed when attempted before having a token.
    [self connectToFcm];
}
// [END: REFRESH TOKEN || iOS = 10]

// [START: REFRESH TOKEN || iOS < 10]
- (void)tokenRefreshNotification:(NSNotification *)notification
{
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    NSString *fcmToken = [[FIRInstanceID instanceID] token];
    NSLog(@"iOS < 10: tokenRefreshNotification: InstanceID token: %@", fcmToken);
    [FCMPlugin.fcmPlugin notifyOfTokenRefresh:refreshedToken];
    // Connect to FCM since connection may have failed when attempted before having a token.
    [self connectToFcm];

    // TODO: If necessary send token to appliation server.
}
// [END: REFRESH TOKEN || iOS < 10]

//////////////////////////////////////////////////////
////////////////////CONNECT TO FCM////////////////////
//////////////////////////////////////////////////////

// [START connect_to_fcm]
- (void)connectToFcm
{

    // Won't connect since there is no token
    if (![[FIRInstanceID instanceID] token]) {
        return;
    }

    // Disconnect previous FCM connection if it exists.
    [[FIRMessaging messaging] shouldEstablishDirectChannel];

    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
            [[FIRMessaging messaging] subscribeToTopic:@"/topics/ios"];
            [[FIRMessaging messaging] subscribeToTopic:@"/topics/all"];
        }
    }];
}
// [END connect_to_fcm]


//////////////////////////////////////////////////////
////////////////FOREGROUND/BACKGROUND/////////////////
//////////////////////////////////////////////////////

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"app become active");
    [FCMPlugin.fcmPlugin appEnterForeground];
    [self connectToFcm];
}

// [START disconnect_from_fcm]
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"app entered background");
    [[FIRMessaging messaging] shouldEstablishDirectChannel];
    [FCMPlugin.fcmPlugin appEnterBackground];
    NSLog(@"Disconnected from FCM");
}
// [END disconnect_from_fcm]

+(NSData*)getLastPush
{
    NSData* returnValue = lastPush;
    lastPush = nil;
    return returnValue;
}


@end
