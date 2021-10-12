//###########################################
//  AppDelegate+FCMPlugin.m
//
//  Created by felipe on 12/06/16.
//
//  Modified by Gustavo Cortez (01/28/2021)
//
//###########################################

#import "AppDelegate+FCMPlugin.h"
#import "FCMPlugin.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

#import "Firebase.h"

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;
#endif

@import Firebase;

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
static FIRDynamicLink *lastLink;
static NSString *lastUniversalLink;
NSString *const kGCMMessageIDKey = @"gcm.message_id";

//Method swizzling
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(application:openURL:options:)];
        [self swizzleMethod:@selector(application:continueUserActivity:restorationHandler:)];
    });
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // [START configure_firebase]
    [FIRApp configure];
    // [END configure_firebase]

    [super application:application didFinishLaunchingWithOptions:launchOptions];

    NSLog(@"FCM -> DidFinishLaunchingWithOptions");

    return YES;
}

// ------------ DYNAMIC LINKS

+ (void)swizzleMethod:(SEL)originalSelector {
    Class class = [self class];
    NSString *selectorString = NSStringFromSelector(originalSelector);
    SEL newSelector = NSSelectorFromString([@"swizzled_" stringByAppendingString:selectorString]);
    SEL defaultSelector = NSSelectorFromString([@"default_" stringByAppendingString:selectorString]);
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method newMethod = class_getInstanceMethod(class, newSelector);
    Method noopMethod = class_getInstanceMethod(class, defaultSelector);
    if (class_addMethod(class, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(class, newSelector, method_getImplementation(originalMethod ?: noopMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

- (BOOL)default_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options {
    return FALSE;
}

- (BOOL)swizzled_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options {
    // always call original method implementation first
    BOOL handled = [self swizzled_application:app openURL:url options:options];
    // parse firebase dynamic link
    FIRDynamicLink *dynamicLink = [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
    if (dynamicLink) {
        if (dynamicLink.url) {
            NSLog(@"FCM -> Found Dynamic Link (fresh install): %@", dynamicLink.url);
            // Handle the deep link. For example, show the deep-linked content,
            // apply a promotional offer to the user's account or show customized onboarding view.
            // ...
            [FCMPlugin.fcmPlugin postDynamicLink:dynamicLink];
        } else {
            // Dynamic link has empty deep link. This situation will happens if
            // Firebase Dynamic Links iOS SDK tried to retrieve pending dynamic link,
            // but pending link is not available for this device/App combination.
            // At this point you may display default onboarding view.
        }
        handled = TRUE;
    }
    return handled;
}

- (BOOL)default_application:(UIApplication *)app continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {
    return FALSE;
}

- (BOOL)swizzled_application:(UIApplication *)app continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {

    if ([userActivity webpageURL] != nil) {
        NSString *incomingURL = [userActivity webpageURL].absoluteString;
        NSLog(@"FCM -> Incoming URL is %@", incomingURL);

        BOOL handled = [[FIRDynamicLinks dynamicLinks] handleUniversalLink:userActivity.webpageURL
                                                                completion:^(FIRDynamicLink * _Nullable dynamicLink,
                                                                             NSError * _Nullable error) {
            if (error != nil) {
                return NSLog(@"FCM -> Found an error! %@", error.localizedDescription);
            }


               if([incomingURL hasPrefix:@"https"]) {
                    lastUniversalLink = incomingURL;
                    [FCMPlugin.fcmPlugin postUniversalLink:incomingURL];
                    NSLog(@"FCM -> Universal Link %@", incomingURL);
                } else {
                    if (dynamicLink != nil && dynamicLink.url != nil) {
                        NSLog(@"FCM -> Found Dynamic Link: %@", dynamicLink.url);
                        lastLink = dynamicLink; // Store dynamic link (to user when cordova ready)
                        [FCMPlugin.fcmPlugin postDynamicLink:dynamicLink];
                    } else {
                        NSLog(@"FCM -> This's weird. Dynamic link object has no url");
                    }
                }
        }];

        if (handled) {
            return YES;
        } else {
            // may do other things with incoming URL
            return NO;
        }

    } else { return NO; }
}

// ------------ END DYNAMIC LINKS

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM -> Registration token: %@", fcmToken);
    // Notify about received token.
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName:
     @"FCMToken" object:nil userInfo:dataDict];
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
}

// [START refresh_token]
- (void)tokenRefreshNotification:(NSNotification *)notification
{
    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,
                                                        NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"FCM -> Error fetching remote instance ID: %@", error);
        } else {
            NSLog(@"FCM -> Remote instance ID token (refresh): %@", result.token);
            [FCMPlugin.fcmPlugin notifyOfTokenRefresh:result.token];
            // Connect to FCM since connection may have failed when attempted before having a token.
            [self connectToFcm];
        }
    }];
}
// [END refresh_token]

// [START connect_to_fcm]
- (void)connectToFcm
{
    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,
                                                        NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"FCM -> Error fetching remote instance ID: %@", error);
        } else {
            NSLog(@"FCM -> Remote instance ID token: %@", result.token);
            [[FIRMessaging messaging] subscribeToTopic:@"ios"];
            [[FIRMessaging messaging] subscribeToTopic:@"all"];
        }
    }];
}
// [END connect_to_fcm]

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"FCM -> App become active");
    [FCMPlugin.fcmPlugin appEnterForeground];
    [self connectToFcm];
}

// [START disconnect_from_fcm]
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"FCM -> App entered background");
    [FCMPlugin.fcmPlugin appEnterBackground];
    lastLink = nil;
    lastUniversalLink = nil;// Clear active link
    NSLog(@"FCM -> Disconnected from FCM");
}
// [END disconnect_from_fcm]

+(NSData*)getLastPush
{
    NSData* returnValue = lastPush;
    lastPush = nil;
    return returnValue;
}

+getLastLink
{
    FIRDynamicLink *returnLink = lastLink;
    lastLink = nil;
    lastUniversalLink = nil;
    return returnLink;
}

+getLastUniversalLink
{
    NSString *returnLink = lastUniversalLink;
    lastUniversalLink = nil;
    return returnLink;
}

@end
