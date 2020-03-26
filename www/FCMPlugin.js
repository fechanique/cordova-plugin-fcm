var exec = require("cordova/exec");
var cordova = require("cordova");

function FCMPlugin() {
  console.log("FCMPlugin.js: is created");
}

// CHECK FOR PERMISSION
FCMPlugin.prototype.hasPermission = function(success, error) {
  if (cordova.platformId !== "ios") {
    success(true);
    return;
  }
  exec(success, error, "FCMPlugin", "hasPermission", []);
};

// SUBSCRIBE TO TOPIC //
FCMPlugin.prototype.subscribeToTopic = function(topic, success, error) {
  exec(success, error, "FCMPlugin", "subscribeToTopic", [topic]);
};

// UNSUBSCRIBE FROM TOPIC //
FCMPlugin.prototype.unsubscribeFromTopic = function(topic, success, error) {
  exec(success, error, "FCMPlugin", "unsubscribeFromTopic", [topic]);
};

// NOTIFICATION CALLBACK //
FCMPlugin.prototype.onNotification = function(callback, success, error) {
  FCMPlugin.prototype.onNotificationReceived = callback;
  exec(success, error, "FCMPlugin", "registerNotification", []);
};

// FIREBASE DATA NOTIFICATION CALLBACK //
FCMPlugin.prototype.onFirebaseDataNotificationIOS = function (callback) {
    FCMPlugin.prototype.onFirebaseDataNotificationReceivedIOS = callback;
};

// TOKEN REFRESH CALLBACK //
FCMPlugin.prototype.onTokenRefresh = function(callback) {
  FCMPlugin.prototype.onTokenRefreshReceived = callback;
};

// GET TOKEN //
FCMPlugin.prototype.getToken = function(success, error) {
  exec(success, error, "FCMPlugin", "getToken", []);
};

// GET APNS TOKEN //
FCMPlugin.prototype.getAPNSToken = function(success, error) {
  if (cordova.platformId !== "ios") {
    success(null);
    return;
  }
  exec(success, error, "FCMPlugin", "getAPNSToken", []);
};

// CLEAR ALL NOTIFICATIONS //
FCMPlugin.prototype.clearAllNotifications = function(success, error) {
  exec(success, error, "FCMPlugin", "clearAllNotifications", []);
};

// DEFAULT NOTIFICATION CALLBACK //
FCMPlugin.prototype.onNotificationReceived = function(payload) {
  console.log("Received push notification");
  console.log(payload);
};

// DEFAULT FIREBASE DATA NOTIFICATION CALLBACK //
FCMPlugin.prototype.onFirebaseDataNotificationReceivedIOS = function (payload) {
    console.log('Received Firebase data notification');
    console.log(payload);
};

// DEFAULT TOKEN REFRESH CALLBACK //
FCMPlugin.prototype.onTokenRefreshReceived = function(token) {
  console.log("Received token refresh");
  console.log(token);
};

// FIRE READY //
exec(
  function(result) {
    console.log("FCMPlugin Ready OK");
  },
  function(result) {
    console.log("FCMPlugin Ready ERROR");
  },
  "FCMPlugin",
  "ready",
  []
);

var fcmPlugin = new FCMPlugin();
module.exports = fcmPlugin;
