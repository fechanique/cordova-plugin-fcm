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

### Optional FCM Image Support for Cordova iOS

After a lot of work, the first release of the plugin https://github.com/andrehtissot/cordova-plugin-fcm-image-support is out. Which should enable the support, just by installing it.

### Version 6.4.0 (21/05/2020)

The `FCMPlugin.requestPushPermissionIOS` function now, not only triggers the request alert, but also returns, as boolean, if the permission was given.

```javascript
FCMPlugin.requestPushPermissionIOS(
  function(wasPermissionGiven) {
    console.info("Was permission given: "+wasPermissionGiven);
  },
  function(error) {
    console.error(error);
  },
  ios9Support: {
    timeout: 10,  // How long it will wait for a decision from the user before returning `false`
    interval: 0.3 // How long between each permission verification
  }
);
```

Note:
On iOS 9, there is no way to know if the user has denied the permissions or he has not yet decided.
For this reason, specifically for iOS 9, after presenting the alert, a timed loop waits until it knows that the user has either given the permissions or that the time has expired.
On iOS 10+, the return is given as soon as the user has selected, ignoring these options.

### Version 6.3.0 (27/04/2020)

FCMPlugin.createNotificationChannelAndroid improved, now accepting three other options: "sound", "lights" and "vibration", like in:
```javascript
FCMPlugin.createNotificationChannelAndroid({
  id: "urgent_alert", // required
  name: "Urgent Alert", // required
  description: "Very urgent message alert",
  importance: "high", // https://developer.android.com/guide/topics/ui/notifiers/notifications#importance
  visibility: "public", // https://developer.android.com/training/notify-user/build-notification#lockscreenNotification
  sound: "alert_sound", // In the "alert_sound" example, the file should located as resources/raw/alert_sound.mp3
  lights: true, // enable lights for notifications
  vibration: true // enable vibration for notifications
});
```

### Version 6.2.0 (26/04/2020)

IOS 9 support reintroduced.

### Version 6.1.0 (24/04/2020)

For Android, some notification properties are only defined programmatically, one of those is channel.
Channel can define the default behavior for notifications on Android 8.0+.
This feature was meant to bring the channel-only configurations importance and visibility:

```javascript
FCMPlugin.createNotificationChannelAndroid({
  id: "urgent_alert", // required
  name: "Urgent Alert", // required
  description: "Very urgent message alert",
  importance: "high", // https://developer.android.com/guide/topics/ui/notifiers/notifications#importance
  visibility: "public", // https://developer.android.com/training/notify-user/build-notification#lockscreenNotification 
});
```

:warning: Once a channel is created, it stays unchangeable until the user uninstalls the app.

To have a notification to use the channel, you have to add to the push notification payload the key `android_channel_id` with the id given to `createNotificationChannelAndroid` (https://firebase.google.com/docs/cloud-messaging/http-server-ref#notification-payload-support)

### Version 6.0.1 (20/04/2020)

As a hotfix to avoid incompatibility with cordova-plugin-ionic-webview, the the changes requested for cordova support (https://cordova.apache.org/howto/2020/03/18/wkwebviewonly) will not be automatic applied.

### Version 6.0.0 (18/04/2020)

On iOS, first run doesn't automatically request Push permission.

The permission, as it is still required, may now be requested from javascript at any moment by executing:
```javascript
//FCMPlugin.requestPushPermissionIOS( successCallback(), errorCallback(err) );
FCMPlugin.requestPushPermissionIOS();
```

### Version 5.1.0 (18/04/2020)

Replaced `UIWebView` with `WKWebView`, as required by Apple (https://developer.apple.com/documentation/uikit/uiwebview).

For a smooth upgrade, the changes requested for cordova support (https://cordova.apache.org/howto/2020/03/18/wkwebviewonly) are applied automatically.

### Version 5.0.0 (16/04/2020)

For both platforms:
- Not only copies, from application root, the Google Services configuration files on build, but also on install;
- `onFirebaseDataNotificationIOS` removed, as relied on upstream socket connection, which will is deprecated and will be removed in Firebase 7 (https://firebase.google.com/support/release-notes/ios#fcm, announced in February 25, 2020).

For iOS:
- On install "Remote Notification" is set as a "Background Mode" capacity automatically;
- Firebase now is handled manually, due to complications of auto-swizzling;
- Firebase dependencies are now set to 6.21.0;
- Delayed Firebase registration, by 300ms, to avoid deadlock issue with Watchdog;
- Removed support for iOS 9.

For Android:
- Demonstrative code, for custom notifications, was removed and its imports of androidx classes to improve compatibility with older cordova plugins.

### Version 4.6.0 (04/04/2020)

For the IOS, if app is on the foreground and the app receives a `data` push notification, the data can be retrieved by setting the callback to the new method: `FCMPlugin.onFirebaseDataNotificationIOS` [Deprecated].

```javascript
FCMPlugin.onFirebaseDataNotificationIOS(
  function(payload) {
    console.info("Message id: "+payload.messageID)
    console.info("Data parameters: "+payload.appData)
  }
);
```

This method is specifically implemented on IOS due to specific payload format ([src/FCMPlugin.d.ts](https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated/blob/master/src/FCMPlugin.d.ts)).


### Version 4.5.1 (30/03/2020)

Due to a bug introduced in v4.4.3, the file `platforms/android/app/src/main/res/values/strings.xml` had two tags included on install, tags which, on build, are also included by cordova-android@8.x.x. Hence failing the build process.

To apply the fix, install the new version and remove these two tags from your values/strings.xml:
* `<string name="google_app_id">...</string>`
* `<string name="google_api_key">...</string>`

### Version 4.2.0 (24/02/2020)

`ANDROID_DEFAULT_NOTIFICATION_ICON` included as a variable.

To define the default icon for notifications (`com.google.firebase.messaging.default_notification_icon`), install this plugin like:
```bash
cordova plugin add cordova-plugin-fcm-with-dependecy-updated --variable ANDROID_DEFAULT_NOTIFICATION_ICON="@mipmap/notification_icon"
```

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

+ Application is in foreground:

   The notification data is received in the JavaScript callback without notification bar message (this is the normal behaviour of mobile push notifications).
   
+ Application is in background or closed:

  1. The device displays the notification message in the device notification bar.
  2. If the user taps the notification, the application comes to foreground and the notification data is received in the JavaScript callback.
  3. If the user does not tap the notification but opens the applicacion, nothing happens until the notification is tapped.


## Authorship
This is a fork from https://github.com/fechanique/cordova-plugin-fcm, which has dependencies versions upgraded, jitpack and cocoapods support, and newer features.
