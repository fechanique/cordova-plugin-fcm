# Firebase Cloud Messaging Cordova Push Plugin
> Extremely easy plug&play push notification plugin for Cordova applications and FCM.

#### Version 1.0.7
- Android and iOS compatible.
- Available sdk functions: subscribeToTopic, unsubscribeFromTopic and JavaScript notification data reception.

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


##Usage

####Subscribe to topic

```javascript
//All devices are subscribed automatically to 'all' and 'ios' or 'android' topic respectively.
//Must match the following regular expression: "[a-zA-Z0-9-_.~%]{1,900}".
FCMPlugin.subscribeToTopic('topicExample', successCallback, errorCallback);
```

####Unsubscribe from topic

```javascript
FCMPlugin.unsubscribeFromTopic('topicExample', successCallback, errorCallback);
```

####Receiving push notification data

```javascript
//Here you define your application behaviour based on the notification data.
FCMPlugin.onNotification(
  function(data){
    alert(data.key);
  },
  successCallback,
  errorCallback
);
```

####Send payload example

```javascript
//https://fcm.googleapis.com/fcm/send
//Content-Type: application/json
//Authorization: key=AIzaSy*******************
{
  "notification":{
    "title":"Notification title",  //Any value
    "body":"Notification body",  //Any value
    "sound":"default", //If you want notification sound
    "click_action":"FCM_PLUGIN_ACTIVITY",  //Must be present for Android
    "icon":"fcm_push_icon"  //White icon Android resource
  },
  "data":{
    "param1":"value1",  //Any data to be retrieved in the notification callback
    "param2":"value2"
  },
    "to":"/topics/topicExample", //Topic or single device
    "restricted_package_name":"" //Set for application filtering
}
```
##How it works
Send a push notification to a single device or topic.
- 1.a Application is in foreground:
 - The user receives the notification data in the JavaScript callback without notification alert message (this is the normal behaviour of mobile push notifications).
- 1.b Application is in background:
 - The user receives the notification message in its device notification bar.
 - The user taps the notification and the application is opened.
 - The user receives the notification data in the JavaScript callback.

##License
```
The MIT License

Copyright (c) 2016 Felipe Echanique Torres (felipe.echanique in the gmail.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
