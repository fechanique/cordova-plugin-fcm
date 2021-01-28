# Changelog

### Version 8.3.0 (28/01/2021)
- Fix Dynamic Link on iOS (when app is closed)
- Refactor on Dynamic Link handler
- Add FCM tag to identify logs
- Code indent


### Version 8.2.0 (10/12/2020)
- Fixed Dynamic Link. New function getDynamicLink. Fixed open link on
  background, foreground and non-installed app
- Big code refactor

### Version 8.1.5 (24/11/2020)
- Fixed Dynamic link callback on Android (2)

### Version 8.1.2 (23/11/2020)
- Fixed Dynamic link callback on Android

### Version 8.1.1 (23/11/2020)
- Fixed Objective-C function

### Version 8.1.0 (19/11/2020)
- Adds getDynamicLink function

### Version 8.0.1 (14/08/2020)
- Refactor on Dynamic Links
- Bug fixes on ClearAllNotifications

### Version 8.0.0 (10/08/2020)
- New Dynamic Links support for iOS
- New Dynamic Links support for Android
- Requires `cordova` >= 9.0.0 and `cordova-android` >= 9.0.0
- Latest version of Firebase using Cocoapods

### Version 7.0.1 (07/06/2020)
- Fix build `cordova-android` 8.1.0.

### Version 7.0.0 (07/06/2020)
- Requires `cordova-android` >= 8.1.0.

### Version 6.0.3 (07/03/2020)
- Allow receiving push notifications from Firebase Console (without `click_action` param).

### Version 5.1.1 (11/14/2019)
- Make it compatible with `cordova-android` v7.1.4.

### Version 5.1.0 (10/24/2019)
- Adds new functionality to clear badge of notifications.

### Version 5.0.1 (09/19/2019)
- Fix google-services (downgrade version) to make it compatible with cordova-android 8.1.0.

### Version 5.0.0 (09/17/2019)
- Updates google-services to make it compatible with cordova-android 8.1.0.

### Version 4.1.3 (09/02/2019)
- Fix Analytic issues on Android devices.

### Version 4.1.2 (08/19/2019)
- Adds Google Analytics Events Tracking support (Android API level 27+).
- Fix builder on development mode for Android.

### Version 4.0.0 (06/28/2019)
- Adds support for Google Analytics Events Tracking (`logEvent`, `setUserId` and `setUserProperty`) (only iOS).
- This wrapper `@ionic-native/fcm` is not required any more. You need to install a new one [FCMNG](https://github.com/cmgustavo/fcm-ng)

### Version 3.0.4 (06/23/2019)
- Upgrade Android plugin for Gradle, revision 1.1.3 (March 2015)

### Version 3.0.2 (05/09/2019)
- Support for new Firebase SDK. [Deprecated function](https://firebase.google.com/docs/reference/android/com/google/firebase/iid/FirebaseInstanceIdService)
- Available in NPMjs.com

### Version 2.1.2 (03/06/2017)
- Tested on Android and iOS using Cordova cli 6.4.0, Cordova android 6.0.0 and Cordova ios 4.3.1
- Available sdk functions: onTokenRefresh, getToken, subscribeToTopic, unsubscribeFromTopic and onNotification
- 'google-services.json' and 'GoogleService-Info.plist' are added automatically from Cordova project root to platform folders
- Added data payload parameter to check whether the user tapped on the notification or was received while in foreground.
