#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>

@interface FCMPlugin : CDVPlugin {}

+ (FCMPlugin *) fcmPlugin;
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
- (void)runJS:(NSString *)jsCode;
- (void)appEnterBackground;
- (void)appEnterForeground;

@end
