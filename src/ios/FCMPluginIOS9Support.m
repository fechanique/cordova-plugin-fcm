#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "FCMPlugin.h"
#import "FCMPluginIOS9Support.h"
#import "AppDelegate+FCMPlugin.h"

@interface FCMPluginIOS9Support () {}
@end

@implementation FCMPluginIOS9Support

NSString *const hasRequestedPushPermissionPersistenceKey = @"FCMPlugin.iOS9.hasRequestedPushPermission";
static void (^requestPushPermissionCallback)(BOOL yesOrNo, NSError* _Nullable error);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (void)requestPushPermission:(void (^)(BOOL yesOrNo, NSError* _Nullable error))block withOptions:(NSDictionary*)options {
    requestPushPermissionCallback = block;
    UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    NSNumber* ios9SupportTimeout = options[@"ios9SupportTimeout"];
    float timeout = [ios9SupportTimeout floatValue];
    NSNumber* ios9SupportInterval = options[@"ios9SupportInterval"];
    float interval = [ios9SupportInterval floatValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [self waitForUserDecision:timeout withInterval:interval];
    });
}
#pragma clang diagnostic pop

+ (void)callbackRequestPushPermission:(BOOL)yesOrNo {
    [self callbackRequestPushPermission:yesOrNo withError:nil];
}

+ (void)callbackRequestPushPermission:(BOOL)yesOrNo withError:(NSError* _Nullable)error {
    [self setHasRequestedPushPermission:YES];
    if(requestPushPermissionCallback != nil) {
        requestPushPermissionCallback(yesOrNo, error);
        requestPushPermissionCallback = nil;
    }
}

+ (void)waitForUserDecision:(float)timeout withInterval:(float)interval {
    [self hasPushPermission:^(NSNumber* pushPermission){
        if(pushPermission != nil) {
            // User has chosen.
            [self callbackRequestPushPermission:[pushPermission boolValue]];
            return;
        }
        if(timeout < 0) {
            // We have to speculate that the request was not accepted
            [self callbackRequestPushPermission:NO];
            return;
        }
        SEL thisMethodSelector = NSSelectorFromString(@"waitForUserDecision:withInterval:");
        if(![self respondsToSelector:thisMethodSelector]) {
            NSLog(@"waitForUserDecision:withInterval: selector not found in FCMPluginIOS9Support");
            return;
        }
        float remainingTimeout = timeout - interval;
        float givenInterval = interval;
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:thisMethodSelector]];
        [invocation setSelector:thisMethodSelector];
        [invocation setTarget:self];
        [invocation setArgument:&(remainingTimeout) atIndex:2]; //arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocationion
        [invocation setArgument:&(givenInterval) atIndex:3];
        [NSTimer scheduledTimerWithTimeInterval:interval invocation:invocation repeats:NO];
    }];
}

+ (void)setHasRequestedPushPermission:(BOOL)pushPermission {
    [[NSUserDefaults standardUserDefaults]
        setObject:[NSNumber numberWithBool:pushPermission] forKey:hasRequestedPushPermissionPersistenceKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)getHasRequestedPushPermission {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:hasRequestedPushPermissionPersistenceKey]) {
        bool hasRequestedPushPermission = [[[NSUserDefaults standardUserDefaults]
                                                objectForKey:hasRequestedPushPermissionPersistenceKey] boolValue];
        return hasRequestedPushPermission;
    }
    return NO;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (void)hasPushPermission:(void (^)(NSNumber* yesNoOrNil))block {
    NSString* apnsToken = [AppDelegate getAPNSToken];
    if(apnsToken != nil) {
        block([NSNumber numberWithBool:YES]);
        return;
    }
    if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        block([NSNumber numberWithBool:YES]);
        return;
    }
    UIUserNotificationSettings *notificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    BOOL itDoesHaveNotificationSettings = ((int) notificationSettings.types) != 0;
    if(itDoesHaveNotificationSettings) {
        block([NSNumber numberWithBool:YES]);
    }
    BOOL alreadyRequested = [self getHasRequestedPushPermission];
    block(alreadyRequested ? [NSNumber numberWithBool:NO] : nil);
}
#pragma clang diagnostic pop

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    NSError *error;
    NSDictionary *userInfoMutable = [userInfo mutableCopy];
    if (application.applicationState != UIApplicationStateActive) {
        NSLog(@"New method with push callback: %@", userInfo);
        [userInfoMutable setValue:@(YES) forKey:@"wasTapped"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfoMutable options:0 error:&error];
        NSLog(@"APP WAS CLOSED DURING PUSH RECEPTION Saved data: %@", jsonData);
        [AppDelegate setInitialPushPayload:jsonData];
        [AppDelegate setLastPush:jsonData];
    }
}

+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceTokenData {
    [self callbackRequestPushPermission:YES];
}

+ (void)application:(UIApplication *)application didFailToRegisterForRemoteNotifications:(NSError *)error {
    [self callbackRequestPushPermission:NO withError:error];
}

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    NSLog(@"%@", userInfo);
    NSError *error;
    NSDictionary *userInfoMutable = [userInfo mutableCopy];

    // Has user tapped the notificaiton?
    // UIApplicationStateActive   - app is currently active
    // UIApplicationStateInactive - app is transitioning from background to
    //                              foreground (user taps notification)
    if (application.applicationState == UIApplicationStateActive
        || application.applicationState == UIApplicationStateInactive) {
        [userInfoMutable setValue:@(NO) forKey:@"wasTapped"];
        NSLog(@"app active");
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfoMutable
                                                           options:0
                                                             error:&error];
        [FCMPlugin.fcmPlugin notifyOfMessage:jsonData];
    }
    completionHandler(UIBackgroundFetchResultNoData);
}

@end
