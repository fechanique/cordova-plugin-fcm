@interface FCMPluginIOS9Support : NSObject {}

+ (void)requestPushPermission:(void (^)(BOOL yesOrNo, NSError* error))block withOptions:(NSDictionary*)options;
+ (void)hasPushPermission:(void (^)(NSNumber* yesNoOrNil))block;
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceTokenData;
+ (void)application:(UIApplication *)application didFailToRegisterForRemoteNotifications:(NSError *)error;

@end
