//
//  AppDelegate+FCMPlugin.h
//  TestApp
//
//  Created by felipe on 12/06/16.
//
//

#import "AppDelegate.h"
#import <UIKit/UIKit.h>
#import <Cordova/CDVViewController.h>

#import "Firebase.h"

// Copied from Apple's header in case it is missing in some cases (e.g. pre-Xcode 8 builds).
#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;
@interface AppDelegate (FCMPlugin) <UNUserNotificationCenterDelegate, FIRMessagingDelegate>

#else
@interface AppDelegate (FCMPlugin) <FIRMessagingDelegate>

#endif

- (BOOL)application:(UIApplication *_Nonnull)application customDidFinishLaunchingWithOptions:(NSDictionary *_Nonnull)launchOptions;
- (void)application:(UIApplication *_Nonnull)application didReceiveRemoteNotification:(NSDictionary *_Nonnull)userInfo fetchCompletionHandler:(void (^_Nonnull)(UIBackgroundFetchResult))completionHandler;
- (void)userNotificationCenter:(UNUserNotificationCenter *_Nonnull)center willPresentNotification:(UNNotification *_Nonnull)notification withCompletionHandler:(void (^_Nonnull)(UNNotificationPresentationOptions))completionHandler;
- (void)userNotificationCenter:(UNUserNotificationCenter *_Nonnull)center didReceiveNotificationResponse:(UNNotificationResponse *_Nonnull)response withCompletionHandler:(void (^_Nonnull)())completionHandler;
- (void)messaging:(nonnull FIRMessaging *)messaging didReceiveMessage:(nonnull FIRMessagingRemoteMessage *)remoteMessage;
- (void)messaging:(nonnull FIRMessaging *)messaging didRefreshRegistrationToken:(nonnull NSString *)fcmToken;
- (void)applicationDidBecomeActive:(UIApplication *_Nonnull)application;
- (void)applicationDidEnterBackground:(UIApplication *_Nonnull)application;

@end


