# Google Firebase Cloud Messaging and Analytics for Cordova

- Android and iOS tested.
- Available SDK functions: getToken, subscribeToTopic, unsubscribeFromTopic and JavaScript notification data reception.
- Added data payload parameter to check whether the user tapped on the notification or was received in foreground.

##Installation
1. Configure your app with the correct bundle name in Firebase Console.
2. For iOS - upload the APNS certificates to Firebase. For Android - add the SHA1 Fingerprint for both release and debug.
3. Generate the config file(s): for Android 'google-services.json'. For iOS 'GoogleService-Info.plist'. Move them to the project root folder (e.g. the location of cordova config.xml, www etc)
4. Install the plugin:
```Bash
cordova plugin add https://github.com/guyromb/cordova-plugin-fcm-plus --save

```

##Usage

####Get token

```javascript
//FCMPlugin.getToken( successCallback(token), errorCallback(err) );
//Keep in mind the function will return null if the token has not been established yet.
FCMPlugin.getToken(
  function(token){
    alert(token);
  },
  function(err){
    console.log('error retrieving token: ' + err);
  }
)
```

####Subscribe to topic

```javascript
//FCMPlugin.subscribeToTopic( topic, successCallback(msg), errorCallback(err) );
//All devices are subscribed automatically to 'all' and 'ios' or 'android' topic respectively.
//Must match the following regular expression: "[a-zA-Z0-9-_.~%]{1,900}".
FCMPlugin.subscribeToTopic('topicExample');
```

####Unsubscribe from topic

```javascript
//FCMPlugin.unsubscribeFromTopic( topic, successCallback(msg), errorCallback(err) );
FCMPlugin.unsubscribeFromTopic('topicExample');
```

####Receiving push notification data

```javascript
//FCMPlugin.onNotification( onNotificationCallback(data), successCallback(msg), errorCallback(err) )
//Here you define your application behaviour based on the notification data.
FCMPlugin.onNotification(
  function(data){
    if(data.wasTapped){
      //Notification was received on device tray and tapped by the user.
      alert( JSON.stringify(data) );
    }else{
      //Notification was received in foreground. Maybe the user needs to be notified.
      alert( JSON.stringify(data) );
    }
  },
  function(msg){
    console.log('onNotification callback successfully registered: ' + msg);
  },
  function(err){
    console.log('Error registering onNotification callback: ' + err);
  }
);
```

####Send notification. Payload example (REST API)
Full documentation: https://firebase.google.com/docs/cloud-messaging/http-server-ref  
```javascript
//POST: https://fcm.googleapis.com/fcm/send
//HEADER: Content-Type: application/json
//HEADER: Authorization: key=AIzaSy*******************
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
    "priority":"high", //If not set, notification won't be delivered on completely closed iOS app
    "restricted_package_name":"" //Optional. Set for application filtering
}
```
##How it works
Send a push notification to a single device or topic.
- 1.a Application is in foreground:
 - The user receives the notification data in the JavaScript callback without notification alert message (this is the normal behaviour of mobile push notifications).
- 1.b Application is in background:
 - The user receives the notification message in its device notification bar.
 - The user taps the notification and the application is opened.
 - The user receives the notification data in the JavaScript callback'.

##Test
You can use Firebase console to trigger a notification without your own server.

##License
```
The MIT License

Copyright (c) 2016
Refactored by Guy Rombaut based on Felipe Echanique Torres code.

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
