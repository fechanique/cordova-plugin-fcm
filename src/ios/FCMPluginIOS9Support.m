#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "FCMPluginIOS9Support.h"
#import "AppDelegate+FCMPlugin.h"

@interface FCMPluginIOS9Support () {}
@end

@implementation FCMPluginIOS9Support

NSString *const hasRequestedPushPermissionPersistenceKey = @"FCMPlugin.iOS9.hasRequestedPushPermission";

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

@end
