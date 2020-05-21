#import "AppDelegate+FCMPlugin.h"
#import "FCMPlugin.h"
#import "FCMPluginIOS9Support.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

@import UserNotifications;
@import Firebase;

// Implement UNUserNotificationCenterDelegate to receive display notification via APNS for devices
// running iOS 10 and above. Implement FIRMessagingDelegate to receive data message via FCM for
// devices running iOS 10 and above.
@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate>
@end

@implementation AppDelegate (MCPlugin)

static NSData *lastPush;
static NSString *fcmToken;
static NSString *apnsToken;
NSString *const kGCMMessageIDKey = @"gcm.message_id";

//Method swizzling
+ (void)load {
    Method original =  class_getInstanceMethod(self, @selector(application:didFinishLaunchingWithOptions:));
    Method custom =    class_getInstanceMethod(self, @selector(application:customDidFinishLaunchingWithOptions:));
    method_exchangeImplementations(original, custom);
}

- (BOOL)application:(UIApplication *)application customDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self application:application customDidFinishLaunchingWithOptions:launchOptions];

    NSLog(@"DidFinishLaunchingWithOptions");
    [self performSelector:@selector(configureForNotifications) withObject:self afterDelay:0.3f];

    return YES;
}

- (void)configureForNotifications {
    if([FIRApp defaultApp] == nil) {
        [FIRApp configure];
    }
    if ([UNUserNotificationCenter class] != nil) {
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    }
    // For iOS message (sent via FCM)
    [FIRMessaging messaging].delegate = self;
}

+ (void)requestPushPermission:(void (^)(BOOL yesOrNo, NSError* _Nullable error))block withOptions:(NSDictionary*)options {
    if ([UNUserNotificationCenter class] == nil) {
        return [FCMPluginIOS9Support requestPushPermission:block withOptions:options];
    }
    UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError* _Nullable error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
            block(YES, error);
            return;
        }
        NSLog(@"User Notification permission denied: %@", error.localizedDescription);
        block(NO, error);
    }];
}

// [BEGIN message_handling]
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    // Print message ID.
    NSDictionary *userInfo = notification.request.content.userInfo;
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID 1: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    NSError *error;
    NSDictionary *userInfoMutable = [userInfo mutableCopy];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfoMutable
                                                       options:0
                                                         error:&error];
    [FCMPlugin.fcmPlugin notifyOfMessage:jsonData];
    
    // Change this to your preferred presentation option
    completionHandler(UNNotificationPresentationOptionNone);
}

// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID 2: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    NSError *error;
    NSDictionary *userInfoMutable = [userInfo mutableCopy];
    
    NSLog(@"New method with push callback: %@", userInfo);
    
    [userInfoMutable setValue:@(YES) forKey:@"wasTapped"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfoMutable options:0 error:&error];
    NSLog(@"APP WAS CLOSED DURING PUSH RECEPTION Saved data: %@", jsonData);
    lastPush = jsonData;
    
    completionHandler();
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceTokenData {
    [FIRMessaging messaging].APNSToken = deviceTokenData;
    NSString *deviceToken;
    if (@available(iOS 13, *)) {
        deviceToken = [self hexadecimalStringFromData:deviceTokenData];
    } else {
        deviceToken = [[[[deviceTokenData description]
            stringByReplacingOccurrencesOfString:@"<"withString:@""]
            stringByReplacingOccurrencesOfString:@">" withString:@""]
            stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    apnsToken = deviceToken;
    NSLog(@"Device APNS Token: %@", deviceToken);
    if (@available(iOS 10, *)) {
        return;
    }
    [FCMPluginIOS9Support application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceTokenData];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotifications:(NSError *)error {
    NSLog(@"Failed to register for remote notifications: %@", error);
    if (@available(iOS 10, *)) {
        return;
    }
    [FCMPluginIOS9Support application:application didFailToRegisterForRemoteNotifications:error];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (@available(iOS 10, *)) {
        return;
    }
    [FCMPluginIOS9Support application:application didReceiveRemoteNotification:userInfo];
}
#pragma clang diagnostic pop

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[FIRMessaging messaging] appDidReceiveMessage:userInfo];

    if (@available(iOS 10, *)) {
        // Print message ID.
        NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);

        // Pring full message.
        NSLog(@"%@", userInfo);

        // If the app is in the background, keep it for later, in case it's not tapped.
        if(application.applicationState == UIApplicationStateBackground) {
            NSError *error;
            NSDictionary *userInfoMutable = [userInfo mutableCopy];
            [userInfoMutable setValue:@(NO) forKey:@"wasTapped"];
            NSLog(@"app active");
            lastPush = [NSJSONSerialization dataWithJSONObject:userInfoMutable options:0 error:&error];
        } else if(application.applicationState == UIApplicationStateInactive) {
            NSError *error;
            NSDictionary *userInfoMutable = [userInfo mutableCopy];
            [userInfoMutable setValue:@(YES) forKey:@"wasTapped"];
            NSLog(@"app opened by user tap");
            lastPush = [NSJSONSerialization dataWithJSONObject:userInfoMutable options:0 error:&error];
        }

        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }

    [FCMPluginIOS9Support application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}
// [END message_handling]

- (void)messaging:(nonnull FIRMessaging *)messaging didReceiveRegistrationToken:(nonnull NSString *)deviceToken {
    NSLog(@"Device FCM Token: %@", deviceToken);
    // Notify about received token.
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:deviceToken forKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FCMToken" object:nil userInfo:dataDict];
    fcmToken = deviceToken;
    [FCMPlugin.fcmPlugin notifyFCMTokenRefresh:deviceToken];
    [self connectToFcm];
}

// [BEGIN connect_to_fcm]
- (void)connectToFcm {
    // Won't connect since there is no token
    if (!fcmToken) {
        return;
    }
    [[FIRMessaging messaging] subscribeToTopic:@"ios"];
    [[FIRMessaging messaging] subscribeToTopic:@"all"];
}
// [END connect_to_fcm]

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"app become active");
    [FCMPlugin.fcmPlugin appEnterForeground];
    [self connectToFcm];
}

// [BEGIN disconnect_from_fcm]
- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"app entered background");
    [FCMPlugin.fcmPlugin appEnterBackground];
    NSLog(@"Disconnected from FCM");
}
// [END disconnect_from_fcm]

+ (void)setLastPush:(NSData*)push {
    lastPush = push;
}

+ (NSData*)getLastPush {
    NSData* returnValue = lastPush;
    lastPush = nil;
    return returnValue;
}

+ (NSString*)getFCMToken {
    return fcmToken;
}

+ (NSString*)getAPNSToken {
    return apnsToken;
}

+ (void)hasPushPermission:(void (^)(NSNumber* yesNoOrNil))block {
    if ([UNUserNotificationCenter class] == nil) {
        [FCMPluginIOS9Support hasPushPermission:block];
        return;
    }
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings){
        switch (settings.authorizationStatus) {
            case UNAuthorizationStatusAuthorized: {
                block([NSNumber numberWithBool:YES]);
            }
            case UNAuthorizationStatusDenied: {
                block([NSNumber numberWithBool:NO]);
            }
            default: {
                block(nil);
            }
        }
    }];
}

- (NSString *)hexadecimalStringFromData:(NSData *)data {
    NSUInteger dataLength = data.length;
    if (dataLength == 0) {
        return nil;
    }

    const unsigned char *dataBuffer = data.bytes;
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for (int i = 0; i < dataLength; ++i) {
        [hexString appendFormat:@"%02x", dataBuffer[i]];
    }
    return [hexString copy];
}

@end
