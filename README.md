# Google Firebase Cloud Messaging Cordova Push Plugin
> Extremely easy plug&play push notification plugin for Cordova applications with Google Firebase FCM.

[![npm downloads](https://img.shields.io/npm/dt/cordova-plugin-fcm-with-dependecy-updated.svg)](https://www.npmjs.com/package/cordova-plugin-fcm-with-dependecy-updated)
[![npm per month](https://img.shields.io/npm/dm/cordova-plugin-fcm-with-dependecy-updated.svg)](https://www.npmjs.com/package/cordova-plugin-fcm-with-dependecy-updated)
[![npm version](https://img.shields.io/npm/v/cordova-plugin-fcm-with-dependecy-updated.svg)](https://www.npmjs.com/package/cordova-plugin-fcm-with-dependecy-updated)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues](https://img.shields.io/github/issues/andrehtissot/cordova-plugin-fcm-with-dependecy-updated.svg)](https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated/issues)
[![GitHub forks](https://img.shields.io/github/forks/andrehtissot/cordova-plugin-fcm-with-dependecy-updated.svg)](https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated/network)
[![GitHub stars](https://img.shields.io/github/stars/andrehtissot/cordova-plugin-fcm-with-dependecy-updated.svg)](https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated/stargazers)
[![Known Vulnerabilities](https://snyk.io/test/github/andrehtissot/cordova-plugin-fcm-with-dependecy-updated/badge.svg?targetFile=package.json)](https://snyk.io/test/github/andrehtissot/cordova-plugin-fcm-with-dependecy-updated?targetFile=package.json)
[![DeepScan grade](https://deepscan.io/api/teams/3417/projects/5068/branches/39495/badge/grade.svg)](https://deepscan.io/dashboard#view=project&tid=3417&pid=5068&bid=39495)

## Authorship
This is a fork from https://github.com/fechanique/cordova-plugin-fcm, which has dependencies versions upgraded, jitpack and cocoapods support, and newer features.

### Version 4.1.0 (26/10/2019)

Older notifications can be cleared from notification center.
Works on both IOS and Android.

```javascript
//FCMPlugin.clearAllNotifications( successCallback(msg), errorCallback(err) );
FCMPlugin.clearAllNotifications();
```

### Version 4.0.0 (12/10/2019)
The old `FCMPlugin.getToken` is focused on retrieving the FCM Token.
For the IOS, APNS token can now be retrieved by the new method:

```javascript
FCMPlugin.getAPNSToken(
  function(token) {
    console.info("Retrieved token: "+token)
  },
  function(error) {
    console.error(error);
  }
);
```

On android, it will always return `null`.

The APNS token, once given, should not change for the same user (as commented on in https://stackoverflow.com/questions/6652242/does-the-apns-device-token-ever-change-once-created).

Although, contrary to APNS, the FCM tokens do expire, and for this reason, `FCMPlugin.onTokenRefresh` will be called with the new one FCM token.

### Version 3.2.0 (16/09/2019)
#### Checking for permissions
Useful for IOS. On android, it will always return `true`.

```javascript
FCMPlugin.hasPermission(function(doesIt){
    // doesIt === true => yes, push was allowed
    // doesIt === false => nope, push will not be available
    // doesIt === null => still not answered, recommended checking again later
    if(doesIt) {
        haveFun();
    }
});
```

### Version 2.1.2 (03/06/2017)
- Tested on Android and iOS using Cordova cli 6.4.0, Cordova android 6.0.0 and Cordova ios 4.3.1
- Available sdk functions: onTokenRefresh, getToken, subscribeToTopic, unsubscribeFromTopic and onNotification
- 'google-services.json' and 'GoogleService-Info.plist' are added automatically from Cordova project root to platform folders
- Added data payload parameter to check whether the user tapped on the notification or was received while in foreground.
- **Free testing server available for free! https://cordova-plugin-fcm.appspot.com**

## Installation
Make sure you have ‘google-services.json’ for Android or  ‘GoogleService-Info.plist’ for iOS in your Cordova project root folder. You don´t need to configure anything else in order to have push notification working for both platforms, everything is magic.
```Bash
cordova plugin add cordova-plugin-fcm-with-dependecy-updated
```

### Firebase configuration files
Get the needed configuration files for Android or iOS from the Firebase Console (see docs: https://firebase.google.com/docs/).

### Android compilation details
Put the downloaded file 'google-services.json' in the Cordova project root folder.

You will need to ensure that you have installed the appropiate Android SDK libraries.

:warning: For Android >5.0 status bar icon, you must include transparent solid color icon with name 'fcm_push_icon.png' in the 'res' folder in the same way you add the other application icons.
If you do not set this resource, then the SDK will use the default icon for your app which may not meet the standards for Android >5.0.

### iOS compilation details
Put the downloaded file 'GoogleService-Info.plist' in the Cordova project root folder.

## Usage

:warning: It's highly recommended to use REST API to send push notifications because Firebase console does not have all the functionalities. **Pay attention to the payload example in order to use the plugin properly**.  
You can also test your notifications with the free testing server: https://cordova-plugin-fcm.appspot.com

### Receiving Token Refresh

```javascript
//FCMPlugin.onTokenRefresh( onTokenRefreshCallback(token) );
//Note that this callback will be fired everytime a new token is generated, including the first time.
FCMPlugin.onTokenRefresh(function(token){
    alert( token );
});
```

### Get token

```javascript
//FCMPlugin.getToken( successCallback(token), errorCallback(err) );
//Keep in mind the function will return null if the token has not been established yet.
FCMPlugin.getToken(function(token){
    alert(token);
});
```

### Subscribe to topic

```javascript
//FCMPlugin.subscribeToTopic( topic, successCallback(msg), errorCallback(err) );
//All devices are subscribed automatically to 'all' and 'ios' or 'android' topic respectively.
//Must match the following regular expression: "[a-zA-Z0-9-_.~%]{1,900}".
FCMPlugin.subscribeToTopic('topicExample');
```

### Unsubscribe from topic

```javascript
//FCMPlugin.unsubscribeFromTopic( topic, successCallback(msg), errorCallback(err) );
FCMPlugin.unsubscribeFromTopic('topicExample');
```

### Receiving push notification data

```javascript
//FCMPlugin.onNotification( onNotificationCallback(data), successCallback(msg), errorCallback(err) )
//Here you define your application behaviour based on the notification data.
FCMPlugin.onNotification(function(data){
    if(data.wasTapped){
      //Notification was received on device tray and tapped by the user.
      alert( JSON.stringify(data) );
    }else{
      //Notification was received in foreground. Maybe the user needs to be notified.
      alert( JSON.stringify(data) );
    }
});
```

### Send notification. Payload example (REST API)
Full documentation: https://firebase.google.com/docs/cloud-messaging/http-server-ref  
Free testing server: https://cordova-plugin-fcm.appspot.com
```javascript
//POST: https://fcm.googleapis.com/fcm/send
//HEADER: Content-Type: application/json
//HEADER: Authorization: key=AIzaSy*******************
{
  "notification":{
    "title":"Notification title",
    "body":"Notification body",
    "sound":"default",
    "click_action":"FCM_PLUGIN_ACTIVITY",
    "icon":"fcm_push_icon"
  },
  "data":{
    "param1":"value1",
    "param2":"value2"
  },
    "to":"/topics/topicExample",
    "priority":"high",
    "restricted_package_name":""
}
//sound: optional field if you want sound with the notification
//click_action: must be present with the specified value for Android
//icon: white icon resource name for Android >5.0
//data: put any "param":"value" and retreive them in the JavaScript notification callback
//to: device token or /topic/topicExample
//priority: must be set to "high" for delivering notifications on closed iOS apps
//restricted_package_name: optional field if you want to send only to a restricted app package (i.e: com.myapp.test)
```

## How it works
Send a push notification to a single device or topic.
- 1.a Application is in foreground:
 - The notification data is received in the JavaScript callback without notification bar message (this is the normal behaviour of mobile push notifications).
- 1.b Application is in background or closed:
 - The device displays the notification message in the device notification bar.
 - If the user taps the notification, the application comes to foreground and the notification data is received in the JavaScript callback.
 - If the user does not tap the notification but opens the applicacion, nothing happens until the notification is tapped.
