//###########################################
//  AppDelegate+FCMPlugin.h
//
//  Created by felipe on 12/06/16.
//
//  Modified by Gustavo Cortez (01/28/2021)
//
//###########################################

#import "AppDelegate.h"
#import <UIKit/UIKit.h>
#import <Cordova/CDVViewController.h>

@interface AppDelegate (FCMPlugin)

+ (NSData*)getLastPush;
+ getLastLink;
+ getLastUniversalLink;
@end
