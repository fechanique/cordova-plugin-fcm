#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>

@interface FCMPlugin : CDVPlugin
{
    //NSString *notificationCallBack;
}

+ (FCMPlugin *) fcmPlugin;
+ (void)setInitialAPNSToken:(NSString*) token;
+ (void)setInitialFCMToken:(NSString*) token;
- (void)notifyFCMTokenRefresh:(NSString*) token;
- (void)ready:(CDVInvokedUrlCommand*)command;
- (void)hasPermission:(CDVInvokedUrlCommand*)command;
- (void)getToken:(CDVInvokedUrlCommand*)command;
- (void)getAPNSToken:(CDVInvokedUrlCommand*)command;
- (void)clearAllNotifications:(CDVInvokedUrlCommand *)command;
- (void)subscribeToTopic:(CDVInvokedUrlCommand*)command;
- (void)unsubscribeFromTopic:(CDVInvokedUrlCommand*)command;
- (void)registerNotification:(CDVInvokedUrlCommand*)command;
- (void)notifyOfMessage:(NSData*) payload;
- (void)appEnterBackground;
- (void)appEnterForeground;

@end
