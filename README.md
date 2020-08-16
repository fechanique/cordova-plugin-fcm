# Google Firebase Cloud Messaging Cordova Push Plugin
> Extremely easy plug&play push notification plugin for Cordova applications with Google Firebase FCM.

[![Donate](https://img.shields.io/badge/Donate-Paypal-0a83fc.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=B33LA4QVUGVBW&source=url)
[![npm downloads](https://img.shields.io/npm/dt/cordova-plugin-fcm-with-dependecy-updated.svg)](https://www.npmjs.com/package/cordova-plugin-fcm-with-dependecy-updated)
[![npm per month](https://img.shields.io/npm/dm/cordova-plugin-fcm-with-dependecy-updated.svg)](https://www.npmjs.com/package/cordova-plugin-fcm-with-dependecy-updated)
[![npm version](https://img.shields.io/npm/v/cordova-plugin-fcm-with-dependecy-updated.svg)](https://www.npmjs.com/package/cordova-plugin-fcm-with-dependecy-updated)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues](https://img.shields.io/github/issues/andrehtissot/cordova-plugin-fcm-with-dependecy-updated.svg)](https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated/issues)
[![GitHub forks](https://img.shields.io/github/forks/andrehtissot/cordova-plugin-fcm-with-dependecy-updated.svg)](https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated/network)
[![GitHub stars](https://img.shields.io/github/stars/andrehtissot/cordova-plugin-fcm-with-dependecy-updated.svg)](https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated/stargazers)
[![Known Vulnerabilities](https://snyk.io/test/github/andrehtissot/cordova-plugin-fcm-with-dependecy-updated/badge.svg?targetFile=package.json)](https://snyk.io/test/github/andrehtissot/cordova-plugin-fcm-with-dependecy-updated?targetFile=package.json)
[![DeepScan grade](https://deepscan.io/api/teams/3417/projects/5068/branches/39495/badge/grade.svg)](https://deepscan.io/dashboard#view=project&tid=3417&pid=5068&bid=39495)

[How it works](#how-it-works) | [Installation](#installation) | [Push Payload Configuration](#push-payload-configuration) |  [Features](#features) | [Example Apps](#example-apps) | [Companion Plugins](#companion-plugins) | [Changelog](#changelog) | [Authorship](#authorship)

## How it works
Send a push notification to a single device or topic.

- Application is in foreground:

  - The notification data is received in the JavaScript callback without notification bar message (this is the normal behavior of mobile push notifications).
  - For Android, to show the notification received on the foreground, it's recommended to use [cordova-plugin-local-notification](https://github.com/katzer/cordova-plugin-local-notifications#readme) as it provides many presentation and interaction features.

- Application is in background or closed:

  - The device displays the notification message in the device notification bar.
  - If the user taps the notification, the application comes to foreground and the notification data is received in the JavaScript callback.
  - If the user does not tap the notification but opens the application, nothing happens until the notification is tapped.

## Installation

Make sure you have ‘google-services.json’ for Android or ‘GoogleService-Info.plist’ for iOS in your Cordova project root folder.

#### Preferences

|Preference|Default Value|Description|
|---|---|---|
|ANDROID_FCM_VERSION|19.0.0|Android's native Firebase Message SDK version.|
|ANDROID_GRADLE_TOOLS_VERSION|3.5.3|Android's Gradle tools version.|
|ANDROID_GOOGLE_SERVICES_VERSION|4.3.3|Android's native Google Services SDK version.|
|ANDROID_DEFAULT_NOTIFICATION_ICON|@mipmap/ic_launcher|Android's default notification icon.|

#### Cordova

Default preferences:

```
npm install -g cordova@latest # Minimal version 9 or higher required
cordova plugin add cordova-plugin-fcm-with-dependecy-updated
```

Complete:

```
npm install -g cordova@latest # Minimal version 9 or higher required 
cordova plugin add cordova-plugin-fcm-with-dependecy-updated \
  --variable ANDROID_FCM_VERSION="19.0.0" \
  --variable ANDROID_GRADLE_TOOLS_VERSION="3.5.3" \
  --variable ANDROID_GOOGLE_SERVICES_VERSION="4.3.3" \
  --variable ANDROID_DEFAULT_NOTIFICATION_ICON="@mipmap/notification_icon"
```

#### Ionic

Default preferences:

```
npm install -g cordova@latest # Minimal version 9 or higher required
ionic cordova plugin add cordova-plugin-fcm-with-dependecy-updated
```

Complete:

```
npm install -g cordova@latest # Minimal version 9 or higher required
ionic cordova plugin add cordova-plugin-fcm-with-dependecy-updated \
  --variable ANDROID_FCM_VERSION="19.0.0" \
  --variable ANDROID_GRADLE_TOOLS_VERSION="3.5.3" \
  --variable ANDROID_GOOGLE_SERVICES_VERSION="4.3.3" \
  --variable ANDROID_DEFAULT_NOTIFICATION_ICON="@mipmap/notification_icon"
```

## Push Payload Configuration

Besides common FCM configuration (https://firebase.google.com/docs/cloud-messaging/ios/certs), the Push payload should contain "notification" and "data" keys and "click_action" equals to "FCM_PLUGIN_ACTIVITY" within "notification".

Structure expected:
```js
{
  ...,
  "notification": {
    ...
  },
  "data": {
    ...
  },
  "android": {
    "notification": {
      "click_action": "FCM_PLUGIN_ACTIVITY"
    }
  },
  ...,
}
```

Example:
```json
{
  "token": "[FCM token]",
  "notification":{
    "title":"Notification title",
    "body":"Notification body",
    "sound":"default",
  },
  "data":{
    "param1":"value1",
    "param2":"value2"
  },
  "android": {
    "notification": {
      "icon":"fcm_push_icon",
      "click_action": "FCM_PLUGIN_ACTIVITY"
    }
  }
}
```


## Features

- [As its own](#as-its-own)
  - [FCM.clearAllNotifications()](#fcmclearallnotifications)
  - [FCM.createNotificationChannel()](#fcmcreatenotificationchannel)
  - [FCM.getAPNSToken()](#fcmgetapnstoken)
  - [FCM.getInitialPushPayload()](#fcmgetinitialpushpayload)
  - [FCM.getToken()](#fcmgettoken)
  - [FCM.hasPermission()](#fcmhaspermission)
  - [FCM.onNotification()](#fcmonnotification)
  - [FCM.onTokenRefresh()](#fcmontokenrefresh)
  - [**FCM.requestPushPermission()**](#fcmrequestpushpermission)
  - [FCM.subscribeToTopic()](#fcmsubscribetotopic)
  - [FCM.unsubscribeFromTopic()](#fcmunsubscribefromtopic)
  - [FCM.eventTarget](#fcmeventtarget)
- [**With Ionic**](#with-ionic)
  - [FCM.onNotification()](#fcmonnotification-1)
  - [FCM.onTokenRefresh()](#fcmontokenrefresh-1)

#### As its own

The JS functions are now as written bellow and do require Promise support. Which, for Android API 19 support, it can be fulfilled by a polyfill.

##### FCM.clearAllNotifications()

Removes existing push notifications from the notifications center.
```typescript
await FCM.clearAllNotifications();
```

##### FCM.createNotificationChannel()

For Android, some notification properties are only defined programmatically.
Channel can define the default behavior for notifications on Android 8.0+.
Once a channel is created, it stays unchangeable until the user uninstalls the app.
```typescript
await FCM.createNotificationChannel({
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

##### FCM.getAPNSToken()

Gets iOS device's current APNS token.
```typescript
const apnsToken: string = await FCM.getAPNSToken();
```

##### FCM.getInitialPushPayload()

Retrieves the message that, on tap, opened the app.
```typescript
const pushPayload: object = await FCM.getInitialPushPayload()
```

##### FCM.getToken()

Gets device's current registration id.
```typescript
const fcmToken: string = await FCM.getToken()
```

##### FCM.hasPermission()

Checking for permissions on iOS. On android, it always returns `true`.
```typescript
const doesIt: boolean = await FCM.hasPermission()
```

##### FCM.onNotification()

Callback firing when receiving new notifications. It serves as a shortcut to listen to eventTarget's "notification" event.
```typescript
const disposable = FCM.onNotification((payload: object) => {
  // ...
})
// ...
disposable.dispose() // To remove listener
```

:warning: If the subscription to notification events happens after the notification has been fired, it'll be lost. As it is expected that you'd not always be able to catch the notification payload that the opened the app, the `FCM.getInitialPushPayload()` method was introduced.

##### FCM.onTokenRefresh()

Callback firing when receiving a new Firebase token. It serves as a shortcut to listen to eventTarget's "tokenRefresh" event.
```typescript
const disposable = FCM.onTokenRefresh((fcmToken: string) => {
  // ...
})
// ...
disposable.dispose() // To remove listener
```

##### FCM.requestPushPermission()

Request push notification permission on iOS, alerting the user if he/she/they have not yet accepted or denied.
For Android, it'll always return true.
```typescript
const wasPermissionGiven: boolean = await FCM.requestPushPermission({
  ios9Support: {
    timeout: 10,  // How long it will wait for a decision from the user before returning `false`
    interval: 0.3 // How long between each permission verification
  }
})
```

:warning: Without this request, the Application won't receive any notification on iOS!
:warning: The user will only have its permition required once, after that time, this call will only return if the permission was given that time.

##### FCM.subscribeToTopic()

Subscribes you to a [topic](https://firebase.google.com/docs/notifications/android/console-topics).
```typescript
const topic: string
// ...
await FCM.subscribeToTopic(topic)
```

##### FCM.unsubscribeFromTopic()

Unsubscribes you from a [topic](https://firebase.google.com/docs/notifications/android/console-topics).
```typescript
const topic: string
// ...
await FCM.unsubscribeFromTopic(topic)
```

##### FCM.eventTarget

EventTarget object for native-sourced custom events. Useful for more advanced listening handling.
```typescript
const listener = (data) => {
  const payload = data.detail
  // ...
}
FCM.eventTarget.addEventListener("notification", listener, false);
// ...
FCM.eventTarget.removeEventListener("notification", listener, false);
```

#### With Ionic

Ionic support was implemented as part of this plugin to allow users to have access to newer features with the type support. It is available in 3 flavors:
- Ionic v5:
```typescript
import { FCM } from "cordova-plugin-fcm-with-dependecy-updated/ionic";
```
- Ionic ngx:
```typescript
import { FCM } from "cordova-plugin-fcm-with-dependecy-updated/ionic/ngx";
```
- Ionic v4 (also works for Ionic v3):
```typescript
import { FCM } from "cordova-plugin-fcm-with-dependecy-updated/ionic/v4";
```

It brings the same behavior as the native implementation, except for `FCM.onNotification()` and `FCM.onTokenRefresh()`, which gain rxjs' Observable support.

To avoid confusion, it's suggested to also remove the redundant @ionic-native/fcm package.

##### FCM.onNotification()

Event firing when receiving new notifications.
```typescript
this.fcm.onNotification().subscribe((payload: object) => {
  // ...
});
```

##### FCM.onTokenRefresh()

Event firing when receiving a new Firebase token.
```typescript
this.fcm.onTokenRefresh().subscribe((token: string) => {
  // ...
});
```

## Example Apps

### Cordova

https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated-app-example

### Ionic v3

https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated-ionic-v3-example

### Ionic v5

https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated-ionic-v5-example

## Companion Plugins

### Optional standalone FCM Image Support for Cordova iOS

After a lot of work, the first release of the plugin is out. Which should enable the support, just by installing it.

Link: https://github.com/andrehtissot/cordova-plugin-fcm-image-support 

### Optional standalone Cocoapods CDN source switcher

When the environment supports, the cocoapods source is automatically set to the official CDN instead of the slow Github repository.

Link: https://github.com/andrehtissot/cordova-plugin-cocoapods-cdn

## Changelog
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

### Version 6

Version 6 changelogs will be only reported in its specific support branch [v6 branch](https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated/tree/v6).

## Authorship
This started as a fork from https://github.com/fechanique/cordova-plugin-fcm and, gradually, had most of its implementation rewritten and improved, for newer dependency versions support, jitpack and cocoapods support, and new useful features.
