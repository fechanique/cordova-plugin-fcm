# Firebase Cloud Messaging Cordova Push Plugin

#### Version 1.0.3
- Android and iOS compatible.
- Available sdk functions: subscribeToTopic, unsubscribeFromTopic and notification capture.

##Installation
```Bash
cordova plugin add cordova-plugin-fcm

```

#### Firebase configuration
See docs: https://firebase.google.com/docs/

#### Android compilation details
Put your generated file google-services.json in the project root folder.

You will need to ensure that you have installed the following items through the Android SDK Manager:

- Android Support Library version 23 or greater
- Android Support Repository version 20 or greater
- Google Play Services version 27 or greater
- Google Repository version 22 or greater

:warning: For Android >5.0 status bar icon, you must to include transparent solid color icon with name 'fcm_push_icon.png' in the 'res' folder in the same way you add the other application icons.
If you do not set this resource, then the SDK will use the default icon for your app which may not meet the standards for Android 5.0.

#### iOS compilation details
Put your generated file GoogleService-Info.plist in the project root folder.

:warning: The plugin will throw an xCode error on Cordova-iOS 4.0.0. Install previous cordova version:
```Bash
cordova platform remove ios
cordova platform add ios@3.9.2 
```

##Usage

####Subscribe To Topic

```javascript
//All users are subscribed automatically to 'all' and 'ios' or 'android' topic respectively.
FCMPlugin.subscribeToTopic('topicExample', successCallback, errorCallback);
```

####Unsubscribe From Topic

```javascript
FCMPlugin.unsubscribeFromTopic('topicExample', successCallback, errorCallback);
```

####Capture Push Notification Data

```javascript
FCMPlugin.onNotification(
  function(data){
    alert(data.key);
  },
  successCallback, 
  errorCallback
);
```

###Payload example

```javascript
{
  "notification":{
    "title":"Notification title",  //Any value
    "body":"Notification body",  //Any value
    "click_action":"FCM_PLUGIN_ACTIVITY",
    "icon":"fcm_push_icon"
  },
  "data":{
    "param1":"value1",  //Any data to be retrieved in the notification callback
    "param2":"value2"
  },
    "to":"/topics/topicExample",
    "restricted_package_name":"" //Set for application filtering
}
```
