#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "FCMPlugin.h"
#import "FCMPluginIOS9Support.h"
#import "AppDelegate+FCMPlugin.h"

@interface FCMPluginIOS9Support () {}
@end

@implementation FCMPluginIOS9Support

NSString *const hasRequestedPushPermissionPersistenceKey = @"FCMPlugin.iOS9.hasRequestedPushPermission";

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (void)requestPushPermission {
    UIUserNotificationType allNotificationTypes =
    (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings =
    [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [self setHasRequestedPushPermissionWithTimeout:10.0f];
    });
}
#pragma clang diagnostic pop

+ (void)setHasRequestedPushPermissionWithTimeout:(float) timeout {
    [self hasPushPermission:^(NSNumber* pushPermission){
        float tryInterval = 0.3f;
        if (timeout > 0 && (pushPermission == nil || [pushPermission boolValue] == NO)) {
            float remainingTimeout = timeout - tryInterval;
            SEL thisMethodSelector = NSSelectorFromString(@"setHasRequestedPushPermissionWithTimeout:");
            if([self respondsToSelector:thisMethodSelector]) {
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:thisMethodSelector]];
                [invocation setSelector:thisMethodSelector];
                [invocation setTarget:self];
                [invocation setArgument:&(remainingTimeout) atIndex:2]; //arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocationion
                [NSTimer scheduledTimerWithTimeInterval:tryInterval invocation:invocation repeats:NO];
                return;
            }
        }
        [[NSUserDefaults standardUserDefaults]
            setObject:[NSNumber numberWithBool:YES] forKey:hasRequestedPushPermissionPersistenceKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
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
        [AppDelegate setLastPush:jsonData];
    }
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
