#import "AppDelegate.h"
#import <UIKit/UIKit.h>
#import <Cordova/CDVViewController.h>

@interface AppDelegate (FCMPlugin)

+ (NSData*)getLastPush;
+ (NSData*)getInitialPushPayload;
+ (NSString*)getFCMToken;
+ (NSString*)getAPNSToken;
+ (void)deleteInstanceId:(void (^)(NSError *error))handler;
+ (void)setLastPush:(NSData*)push;
+ (void)setInitialPushPayload:(NSData*)payload;
+ (void)requestPushPermission:(void (^)(BOOL yesOrNo, NSError* error))block withOptions:(NSDictionary*)options;
+ (void)hasPushPermission:(void (^)(NSNumber* yesNoOrNil))block;

@end
