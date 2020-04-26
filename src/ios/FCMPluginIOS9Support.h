@interface FCMPluginIOS9Support : NSObject
{
}

+ (void)requestPushPermission;
+ (void)hasPushPermission:(void (^)(NSNumber* yesNoOrNil))block;

@end
