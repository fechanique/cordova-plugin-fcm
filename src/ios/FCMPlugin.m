#include <sys/types.h>
#include <sys/sysctl.h>

#import "AppDelegate+FCMPlugin.h"

#import <Cordova/CDV.h>
#import "FCMPlugin.h"

@import FirebaseInstanceID;
@import FirebaseMessaging;
@import FirebaseAnalytics;



@interface FCMPlugin () {}
@end

@implementation FCMPlugin

static BOOL notificatorReceptorReady = NO;
static BOOL appInForeground = YES;

static NSString *notificationCallback = @"FCMPlugin.onNotificationReceived";
static FCMPlugin *fcmPluginInstance;

+ (FCMPlugin *) fcmPlugin {
    
    return fcmPluginInstance;
}


- (void)initializeRemoteConfig:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{
        
        self.config = [FIRRemoteConfig remoteConfig];
        
        FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] initWithDeveloperModeEnabled:YES];
        self.config.configSettings = remoteConfigSettings;
        
        [self.config fetchWithExpirationDuration:600 completionHandler:^(FIRRemoteConfigFetchStatus status, NSError * _Nullable error) {
            [self.config activateFetched];
        }];
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void)getStringValueForKey:(CDVInvokedUrlCommand *)command
{
    NSLog(@"Cordova view ready");
    fcmPluginInstance = self;
    [self.commandDelegate runInBackground:^{
        
        NSString* propertyString = [command.arguments objectAtIndex:0];
        
        FIRRemoteConfigValue *value = self.config[propertyString];
        if(value != nil)
        {
            NSString *b = value.stringValue;
            NSLog(@"remote config val = %@",b);
            CDVPluginResult* pluginResult = nil;
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithString:b]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        else
        {
            CDVPluginResult* pluginResult = nil;
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
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

//Analytics
- (void)logEvent:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSString* key = [command.arguments objectAtIndex:0];
        NSString* value = [command.arguments objectAtIndex:1];
        
        [FIRAnalytics logEventWithName:kFIREventSelectContent parameters:@{
                                                                           kFIRParameterContentType:key,
                                                                           kFIRParameterItemID:value
                                                                           }];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void)setUserId:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSString *userId = [command.arguments objectAtIndex:0];
        
        [FIRAnalytics setUserID:userId];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)setUserProperty:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSString* propertyString = [command.arguments objectAtIndex:0];
        NSString* propertyName = [command.arguments objectAtIndex:1];
        
        [FIRAnalytics setUserPropertyString:propertyString forName:propertyName];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}


// GET TOKEN //
- (void) getToken:(CDVInvokedUrlCommand *)command 
{
    NSLog(@"get Token");
    [self.commandDelegate runInBackground:^{
        NSString* token = [[FIRInstanceID instanceID] token];
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:token];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

// UN/SUBSCRIBE TOPIC //
- (void) subscribeToTopic:(CDVInvokedUrlCommand *)command 
{
    NSString* topic = [command.arguments objectAtIndex:0];
    NSLog(@"subscribe To Topic %@", topic);
    [self.commandDelegate runInBackground:^{
        if(topic != nil)[[FIRMessaging messaging] subscribeToTopic:[NSString stringWithFormat:@"/topics/%@", topic]];
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
        if(topic != nil)[[FIRMessaging messaging] unsubscribeFromTopic:[NSString stringWithFormat:@"/topics/%@", topic]];
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
