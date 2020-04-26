@interface FCMPluginIOS9Support : NSObject
{
}

+ (void)requestPushPermission;
+ (void)hasPushPermission:(void (^)(NSNumber* yesNoOrNil))block;
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end
