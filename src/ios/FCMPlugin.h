#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>
#import "Firebase.h"



@interface FCMPlugin : CDVPlugin
{
    //NSString *notificationCallBack;
}
@property (nonatomic, strong) FIRRemoteConfig *config;

+ (FCMPlugin *) fcmPlugin;
- (void)initializeRemoteConfig:(CDVInvokedUrlCommand *)command;
- (void)getStringValueForKey:(CDVInvokedUrlCommand *)command;
- (void)ready:(CDVInvokedUrlCommand*)command;
- (void)getToken:(CDVInvokedUrlCommand*)command;
- (void)subscribeToTopic:(CDVInvokedUrlCommand*)command;
- (void)unsubscribeFromTopic:(CDVInvokedUrlCommand*)command;
- (void)registerNotification:(CDVInvokedUrlCommand*)command;
- (void)notifyOfMessage:(NSData*) payload;
- (void)appEnterBackground;
- (void)appEnterForeground;
- (void)logEvent:(CDVInvokedUrlCommand*)command;
- (void)setUserId:(CDVInvokedUrlCommand *)command;
- (void)setUserProperty:(CDVInvokedUrlCommand *)command;

@end
