
//###########################################
//  FCMPlugin.h
//
//  Modified by Gustavo Cortez (01/28/2021)
//
//###########################################

#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>

@import Firebase;

@interface FCMPlugin : CDVPlugin
{
    //NSString *notificationCallBack;
}

+ (FCMPlugin *) fcmPlugin;
- (void)ready:(CDVInvokedUrlCommand*)command;
- (void)getToken:(CDVInvokedUrlCommand*)command;
- (void)subscribeToTopic:(CDVInvokedUrlCommand*)command;
- (void)unsubscribeFromTopic:(CDVInvokedUrlCommand*)command;
- (void)registerNotification:(CDVInvokedUrlCommand*)command;
- (void)notifyOfMessage:(NSData*) payload;
- (void)notifyOfTokenRefresh:(NSString*) token;
- (void)appEnterBackground;
- (void)appEnterForeground;
- (void)logEvent:(CDVInvokedUrlCommand*)command;
- (void)setUserId:(CDVInvokedUrlCommand*)command;
- (void)setUserProperty:(CDVInvokedUrlCommand*)command;
- (void)clearAllNotifications:(CDVInvokedUrlCommand*)command;
- (void)getDynamicLink:(CDVInvokedUrlCommand *)command;
- (void)onDynamicLink:(CDVInvokedUrlCommand *)command;
- (void)createDynamicLink:(CDVInvokedUrlCommand *)command;
- (void)postDynamicLink:(FIRDynamicLink*) dynamicLink;
- (void)postUniversalLink:(NSString*) universalLink;

@property (nonatomic, copy) NSString* domainUriPrefix;
@property (nonatomic, copy) NSString* dynamicLinkCallbackId;
@property (nonatomic, retain) NSDictionary* lastDynamicLinkData;
@property (nonatomic, retain) NSString* lastUniversalLinkData;

@end
