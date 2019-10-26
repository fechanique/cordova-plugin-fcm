#include <sys/types.h>
#include <sys/sysctl.h>
#import "AppDelegate+FCMPlugin.h"
#import <UserNotifications/UserNotifications.h>
#import <Cordova/CDV.h>
#import "FCMPlugin.h"
#import "Firebase.h"

@interface FCMPlugin () {}
@end

@implementation FCMPlugin

static BOOL notificatorReceptorReady = NO;
static BOOL appInForeground = YES;

static NSString *notificationCallback = @"FCMPlugin.onNotificationReceived";
static NSString *tokenRefreshCallback = @"FCMPlugin.onTokenRefreshReceived";
static NSString *apnsToken = nil;
static NSString *fcmToken = nil;
static FCMPlugin *fcmPluginInstance;

+ (FCMPlugin *) fcmPlugin {
    return fcmPluginInstance;
}

+ (void) setInitialAPNSToken:(NSString *)token
{
    NSLog(@"setInitialAPNSToken token: %@", token);
    apnsToken = token;
}

+ (void) setInitialFCMToken:(NSString *)token
{
    NSLog(@"setInitialFCMToken token: %@", token);
    fcmToken = token;
}

- (void) ready:(CDVInvokedUrlCommand *)command
{
    NSLog(@"Cordova view ready");
    fcmPluginInstance = self;
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

// HAS PERMISSION //
- (void) hasPermission:(CDVInvokedUrlCommand *)command
{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    __block CDVPluginResult *commandResult;
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings){
        switch (settings.authorizationStatus) {
            case UNAuthorizationStatusAuthorized: {
                NSLog(@"has push permission: true");
                commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
                break;
            }
            case UNAuthorizationStatusDenied: {
                NSLog(@"has push permission: false");
                commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:NO];
                break;
            }
            default: {
                NSLog(@"has push permission: unknown");
                commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                break;
            }
        }
        [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
    }];
}

// GET TOKEN //
- (void) getToken:(CDVInvokedUrlCommand *)command 
{
    NSLog(@"get Token");
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:fcmToken];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

// GET APNS TOKEN //
- (void) getAPNSToken:(CDVInvokedUrlCommand *)command 
{
    NSLog(@"get APNS Token");
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:apnsToken];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

// CLEAR ALL NOTIFICATONS //
- (void)clearAllNotifications:(CDVInvokedUrlCommand *)command
{
  [self.commandDelegate runInBackground:^{
    NSLog(@"clear all notifications");
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }];
}

// UN/SUBSCRIBE TOPIC //
- (void) subscribeToTopic:(CDVInvokedUrlCommand *)command 
{
    NSString* topic = [command.arguments objectAtIndex:0];
    NSLog(@"subscribe To Topic %@", topic);
    [self.commandDelegate runInBackground:^{
        if(topic != nil)[[FIRMessaging messaging] subscribeToTopic:topic];
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:topic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) unsubscribeFromTopic:(CDVInvokedUrlCommand *)command 
{
    NSString* topic = [command.arguments objectAtIndex:0];
    NSLog(@"unsubscribe From Topic %@", topic);
    [self.commandDelegate runInBackground:^{
        if(topic != nil)[[FIRMessaging messaging] unsubscribeFromTopic:topic];
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:topic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) registerNotification:(CDVInvokedUrlCommand *)command
{
    NSLog(@"view registered for notifications");
    
    notificatorReceptorReady = YES;
    NSData* lastPush = [AppDelegate getLastPush];
    if (lastPush != nil) {
        [FCMPlugin.fcmPlugin notifyOfMessage:lastPush];
    }
    
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void) notifyOfMessage:(NSData *)payload
{
    NSString *JSONString = [[NSString alloc] initWithBytes:[payload bytes] length:[payload length] encoding:NSUTF8StringEncoding];
    NSString * notifyJS = [NSString stringWithFormat:@"%@(%@);", notificationCallback, JSONString];
    NSLog(@"stringByEvaluatingJavaScriptFromString %@", notifyJS);
    
    if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
        [(UIWebView *)self.webView stringByEvaluatingJavaScriptFromString:notifyJS];
    } else {
        [self.webViewEngine evaluateJavaScript:notifyJS completionHandler:nil];
    }
}

-(void) notifyFCMTokenRefresh:(NSString *)token
{
    NSLog(@"notifyFCMTokenRefresh token: %@", token);
    fcmToken = token;
    NSString * notifyJS = [NSString stringWithFormat:@"%@('%@');", tokenRefreshCallback, token];
    NSLog(@"stringByEvaluatingJavaScriptFromString %@", notifyJS);
    
    if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
        [(UIWebView *)self.webView stringByEvaluatingJavaScriptFromString:notifyJS];
    } else {
        [self.webViewEngine evaluateJavaScript:notifyJS completionHandler:nil];
    }
}

-(void) appEnterBackground
{
    NSLog(@"Set state background");
    appInForeground = NO;
}

-(void) appEnterForeground
{
    NSLog(@"Set state foreground");
    NSData* lastPush = [AppDelegate getLastPush];
    if (lastPush != nil) {
        [FCMPlugin.fcmPlugin notifyOfMessage:lastPush];
    }
    appInForeground = YES;
}

@end
