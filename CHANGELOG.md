# Changelog

## Version 7

### Version 7.8.0 (03/02/2020)

- IOS_FIREBASE_MESSAGING_VERSION upgraded to 7.4.0;
- FCM.hasPermission now supports Android;
- On iOS, getToken will now wait until fcm token is defined to return it;
- FCM.getInitialPushPayload now uses UTF8 instead of ISOLatin;

### Version 7.7.0 (11/12/2020)

Downgraded Cordova and Cordova-Android minimal required versions.

### Version 7.6.1 (11/12/2020)

Fixed auto install of ionic-specific dependencies on Windows

### Version 7.6.0 (08/11/2020)

Added IOS_FIREBASE_MESSAGING_VERSION plugin variable to force a fixed Firebase/Messaging pod version.

### Version 7.5.0 (08/11/2020)

For pure Cordova projects, ionic dependencies are skipped for "ionic", "ionic/ngx" and "ionic/v4".

### Version 7.4.0 (01/11/2020)

Upgraded Android and Node depenencies.

### Version 7.3.1 (06/09/2020)

Android: Avoided setting initialPushPayload from a non-tapped notification.

### Version 7.3.0 (30/08/2020)

Removed optional Firebase/Analytics iOS dependency.

### Version 7.2.0 (23/08/2020)

Added deleteInstanceId to allow user's "resetting" Firebase session (https://firebase.google.com/support/privacy/manage-iids#delete_an_instance_id).

### Version 7.1.1 (16/08/2020)

iOS: Values sent as notification on push payload should never overwrite values sent as data.

Android: tapping action small refactor.

Ionic: Removed tslib dependency due to reported incompatibility.

### Version 7.1.0 (16/08/2020)

For iOS: Added `title`, `subtitle`, `body` and `badge` to the data given to JS.

This data is coming from notification part of the push payload, instead of only from data.

Android has been responding this way for a long time with `title` and `body`.

### Version 7.0.10 (16/08/2020)

Defined minimal version of "cordova" package supported as version 9. Due to issues of supporting lower versions and "cordova-ios@5+" without deprecated configuration.

Removed explicit definition of "Firebase/Analytics" and "Firebase/Messaging" due to lack of matching “>=” definitions between plugins.

### Version 7.0.9 (21/07/2020)

getInitialPushPayload: Conversion of NSData* into NSDictonary* fix -- Thanks to @medeirosrafael for debugging and fixing it!

### Version 7.0.8 (20/07/2020)

Avoided execution of install_ionic_dependencies.bat after the app is installed;

Removed old framework dependencies -- Thanks for @QuentinFarizon, for pointing it out!

### Version 7.0.7 (17/07/2020)

Removed auto-cdnfy due to service issues;

Set AndroidXEnabled for cordova-android-9.0.0 (https://cordova.apache.org/announcements/2020/06/29/cordova-android-9.0.0.html).

### Version 7.0.6 (14/07/2020)

Simplified ionic/ngx/FCM.d.ts imports

### Version 7.0.5 (13/07/2020)

Renamed extension scripts/install_ionic_dependencies.sh to .bat, to have it running on windows.

### Version 7.0.4 (13/07/2020)

Simplified ionic/FCM.js and ionic/ngx/FCM.js files to ease building with them.

Improved scripts/install_ionic_dependencies.sh windows support.

### Version 7.0.3 (07/07/2020)

Simplified ionic/v4/FCM.js file by setting the FCM function in the global context.

### Version 7.0.2 (01/07/2020)

Simplified .d.ts files by removing the new "type" from imports and exports.

### Version 7.0.1 (28/06/2020)

Replaced native to JS context messaging, from JS injection to event subscription.

### Version 7.0.0 (27/06/2020)

Breaking update released. Please pay atention to the changes in plugin preferences and API methods.

## Version 6

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

## Version 5
Minor changes omitted.

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

## Version 4
Minor changes omitted.

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

## Version 3
Minor changes omitted.

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

## Version 2
Minor changes omitted.

### Version 2.1.2 (03/06/2017)
- Tested on Android and iOS using Cordova cli 6.4.0, Cordova android 6.0.0 and Cordova ios 4.3.1
- Available sdk functions: onTokenRefresh, getToken, subscribeToTopic, unsubscribeFromTopic and onNotification
- 'google-services.json' and 'GoogleService-Info.plist' are added automatically from Cordova project root to platform folders
- Added data payload parameter to check whether the user tapped on the notification or was received while in foreground.
- **Free testing server available for free! https://cordova-plugin-fcm.appspot.com**
