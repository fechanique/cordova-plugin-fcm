//
//  AppDelegate+FCMPlugin.h
//  TestApp
//
//  Created by felipe on 12/06/16.
//
//

#import "AppDelegate.h"
#import <UIKit/UIKit.h>
#import <Cordova/CDVViewController.h>

@interface AppDelegate (FCMPlugin)

+ (NSData*)getLastPush;
+ (NSString*)getFCMToken;
+ (NSString*)getAPNSToken;
+ (void)requestPushPermission;
+ (void)hasPushPermission:(void (^)(NSNumber* yesNoOrNil))block;

@end
