#include <sys/types.h>
#include <sys/sysctl.h>
#import "AppDelegate+FCMPlugin.h"
#import <UserNotifications/UserNotifications.h>
#import <Cordova/CDV.h>
#import <WebKit/WebKit.h>
#import "FCMPlugin.h"
#import "Firebase.h"

@interface FCMPlugin () {}
@end

@implementation FCMPlugin

static BOOL notificatorReceptorReady = NO;
static BOOL appInForeground = YES;

static NSString *notificationCallback = @"FCMPlugin.onNotificationReceived";
static NSString *tokenRefreshCallback = @"FCMPlugin.onTokenRefreshReceived";
static FCMPlugin *fcmPluginInstance;

+ (FCMPlugin *)fcmPlugin {
    return fcmPluginInstance;
}

- (void)ready:(CDVInvokedUrlCommand *)command {
    NSLog(@"Cordova view ready");
    fcmPluginInstance = self;
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

// HAS PERMISSION //
- (void)hasPermission:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        [AppDelegate hasPushPermission:^(NSNumber* pushPermission){
            __block CDVPluginResult *commandResult;
            if (pushPermission == nil) {
                NSLog(@"has push permission: unknown");
                commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            } else if ([pushPermission boolValue] == YES) {
                NSLog(@"has push permission: true");
                commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
            } else if ([pushPermission boolValue] == NO) {
                NSLog(@"has push permission: false");
                commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:NO];
            }
            [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
        }];
    }];
}

// GET TOKEN //
- (void)getToken:(CDVInvokedUrlCommand *)command {
    NSLog(@"get Token");
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        NSString* fcmToken = [AppDelegate getFCMToken];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:fcmToken];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

// GET APNS TOKEN //
- (void)getAPNSToken:(CDVInvokedUrlCommand *)command  {
    NSLog(@"get APNS Token");
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        NSString* apnsToken = [AppDelegate getAPNSToken];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:apnsToken];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

// CLEAR ALL NOTIFICATONS //
- (void)clearAllNotifications:(CDVInvokedUrlCommand *)command {
  [self.commandDelegate runInBackground:^{
    NSLog(@"clear all notifications");
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }];
}

// UN/SUBSCRIBE TOPIC //
- (void)subscribeToTopic:(CDVInvokedUrlCommand *)command {
    NSString* topic = [command.arguments objectAtIndex:0];
    NSLog(@"subscribe To Topic %@", topic);
    [self.commandDelegate runInBackground:^{
        if(topic != nil)[[FIRMessaging messaging] subscribeToTopic:topic];
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:topic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)unsubscribeFromTopic:(CDVInvokedUrlCommand *)command {
    NSString* topic = [command.arguments objectAtIndex:0];
    NSLog(@"unsubscribe From Topic %@", topic);
    [self.commandDelegate runInBackground:^{
        if(topic != nil)[[FIRMessaging messaging] unsubscribeFromTopic:topic];
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:topic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)requestPushPermission:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSNumber* ios9SupportTimeout = [command argumentAtIndex:0 withDefault:[NSNumber numberWithFloat:10]];
        NSNumber* ios9SupportInterval = [command argumentAtIndex:1 withDefault:[NSNumber numberWithFloat:0.3]];
        NSLog(@"requestPushPermission { ios9SupportTimeout:%@ ios9SupportInterval:%@ }", ios9SupportTimeout, ios9SupportInterval);
        id objects[] = { ios9SupportTimeout, ios9SupportInterval };
        id keys[] = { @"ios9SupportTimeout", @"ios9SupportInterval" };
        NSDictionary* options = [NSDictionary dictionaryWithObjects:objects forKeys:keys count:2];
        [AppDelegate requestPushPermission:^(BOOL pushPermission, NSError* _Nullable error) {
            if(error != nil){
                NSLog(@"push permission request error: %@", error);
                __block CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error description]];
                [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
                return;
            }
            NSLog(@"push permission request result: %@", pushPermission ? @"Yes" : @"No");
            __block CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:pushPermission];
            [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
        } withOptions:options];
    }];
}

- (void)registerNotification:(CDVInvokedUrlCommand *)command {
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

- (void)notifyOfMessage:(NSData *)payload {
    NSString* JSONString = [[NSString alloc] initWithBytes:[payload bytes] length:[payload length] encoding:NSUTF8StringEncoding];
    NSString* notifyJS = [NSString stringWithFormat:@"%@(%@);", notificationCallback, JSONString];
    NSLog(@"stringByEvaluatingJavaScriptFromString %@", notifyJS);
    [self runJS:notifyJS];
}

- (void)notifyFCMTokenRefresh:(NSString *)token {
    NSLog(@"notifyFCMTokenRefresh token: %@", token);
    NSString* notifyJS = [NSString stringWithFormat:@"%@('%@');", tokenRefreshCallback, token];
    NSLog(@"stringByEvaluatingJavaScriptFromString %@", notifyJS);
    [self runJS:notifyJS];
}

- (void)runJS:(NSString *)jsCode {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.webView respondsToSelector:@selector(evaluateJavaScript:completionHandler:)]) {
            [(WKWebView *)self.webView evaluateJavaScript:jsCode completionHandler:nil];
        } else {
            [self.webViewEngine evaluateJavaScript:jsCode completionHandler:nil];
        }
    });
}

- (void)appEnterBackground {
    NSLog(@"Set state background");
    appInForeground = NO;
}

- (void)appEnterForeground {
    NSLog(@"Set state foreground");
    NSData* lastPush = [AppDelegate getLastPush];
    if (lastPush != nil) {
        [FCMPlugin.fcmPlugin notifyOfMessage:lastPush];
    }
    appInForeground = YES;
}

@end
