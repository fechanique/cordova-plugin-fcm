# Google Firebase Cloud Messaging Cordova Push Plugin
> Extremely easy plug&play push notification plugin for Cordova applications with Google Firebase FCM.

## Installation
Make sure you have ‘google-services.json’ for Android or  ‘GoogleService-Info.plist’ for iOS in your Cordova project root folder. You don´t need to configure anything else in order to have push notification working for both platforms, everything is magic.
```Bash
cordova plugin add cordova-plugin-fcm-ng

```

#### Firebase configuration files
Get the needed configuration files for Android or iOS from the Firebase Console (see docs: https://firebase.google.com/docs/).

#### Android compilation details
Put the downloaded file 'google-services.json' in the Cordova project root folder.

You will need to ensure that you have installed the appropiate Android SDK libraries.

For Android >5.0 status bar icon, you must include transparent solid color icon with name `fcm_push_icon.png` in the 'res' folder in the same way you add the other application icons.
If you do not set this resource, then the SDK will use the default icon for your app which may not meet the standards for Android >5.0.

#### iOS compilation details
Put the downloaded file 'GoogleService-Info.plist' in the Cordova project root folder.

## Usage

It's highly recommended to use REST API to send push notifications because Firebase console does not have all the functionalities. **Pay attention to the payload example in order to use the plugin properly**.

#### Receiving Token Refresh

```javascript
//FCMPluginNG.onTokenRefresh( onTokenRefreshCallback(token) );
//Note that this callback will be fired everytime a new token is generated, including the first time.
FCMPluginNG.onTokenRefresh(function(token){
    alert( token );
});
```

#### Get token

```javascript
//FCMPluginNG.getToken( successCallback(token), errorCallback(err) );
//Keep in mind the function will return null if the token has not been established yet.
FCMPluginNG.getToken(function(token){
    alert(token);
});
```

#### Subscribe to topic

```javascript
//FCMPluginNG.subscribeToTopic( topic, successCallback(msg), errorCallback(err) );
//All devices are subscribed automatically to 'all' and 'ios' or 'android' topic respectively.
//Must match the following regular expression: "[a-zA-Z0-9-_.~%]{1,900}".
FCMPluginNG.subscribeToTopic('topicExample');
```

#### Unsubscribe from topic

```javascript
//FCMPluginNG.unsubscribeFromTopic( topic, successCallback(msg), errorCallback(err) );
FCMPluginNG.unsubscribeFromTopic('topicExample');
```

#### Receiving push notification data

```javascript
//FCMPluginNG.onNotification( onNotificationCallback(data), successCallback(msg), errorCallback(err) )
//Here you define your application behaviour based on the notification data.
FCMPluginNG.onNotification(function(data){
    if(data.wasTapped){
      //Notification was received on device tray and tapped by the user.
      alert( JSON.stringify(data) );
    }else{
      //Notification was received in foreground. Maybe the user needs to be notified.
      alert( JSON.stringify(data) );
    }
});
```

#### Clear push notifications badge
```javascript
FCMPluginNG.clearAllNotifications();
```

#### Send notification. Payload example (REST API)
Full documentation: https://firebase.google.com/docs/cloud-messaging/http-server-ref  
```javascript
//POST: https://fcm.googleapis.com/fcm/send
//HEADER: Content-Type: application/json
//HEADER: Authorization: key=AIzaSy*******************
{
  "notification":{
    "title":"Notification title",
    "body":"Notification body",
    "sound":"default",
    "click_action":"FCM_PLUGIN_ACTIVITY", // Optional on v6.0.3 or higher
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

## Usage of Google Analytics Methods
Every method returns a promise that fulfills when a call was successful.

### logEvent(_name_, _params_)
Logs an app event.
```js
FCMPluginNG.logEvent("my_event", {param1: "value1"});
```

Be aware of [automatically collected events](https://support.google.com/firebase/answer/6317485).

### setUserId(_id_)
Sets the user ID property.
```js
FCMPluginNG.setUserId("12345");
```
This feature must be used in accordance with [Google's Privacy Policy](https://www.google.com/policies/privacy).

### setUserProperty(_name_, _value_)
Sets a user property to a given value.
```js
FCMPluginNG.setUserProperty("name1", "value1");
```

## Dynamic Links

### getDynamicLink

Only works on Android.

```js
FCMPluginNG.getDynamicLink();
```

### onDynamicLink

Only works on iOS

```js
FCMPluginNG.onDynamicLink();
```

## Universal Links

### postUniversalLink

```js
FCMPluginNG.postUniversalLink(string);
```

## License
```
The MIT License

Copyright (c) 2017 Felipe Echanique Torres (felipe.echanique in the gmail.com)

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
