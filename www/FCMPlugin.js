var exec = require("cordova/exec");
var cordova = require("cordova");

function FCMPlugin() {
  console.log("FCMPlugin.js: is created");
}

// CHECK FOR PERMISSION
FCMPlugin.prototype.hasPermission = function (success, error) {
  if (cordova.platformId !== "ios") {
    success(true);
    return;
  }
  exec(success, error, "FCMPlugin", "hasPermission", []);
};

// SUBSCRIBE TO TOPIC //
FCMPlugin.prototype.subscribeToTopic = function (topic, success, error) {
  exec(success, error, "FCMPlugin", "subscribeToTopic", [topic]);
};

// UNSUBSCRIBE FROM TOPIC //
FCMPlugin.prototype.unsubscribeFromTopic = function (topic, success, error) {
  exec(success, error, "FCMPlugin", "unsubscribeFromTopic", [topic]);
};

// NOTIFICATION CALLBACK //
FCMPlugin.prototype.onNotification = function (callback, success, error) {
  FCMPlugin.prototype.onNotificationReceived = callback;
  exec(success, error, "FCMPlugin", "registerNotification", []);
};

// TOKEN REFRESH CALLBACK //
FCMPlugin.prototype.onTokenRefresh = function (callback) {
  FCMPlugin.prototype.onTokenRefreshReceived = callback;
};

// GET TOKEN //
FCMPlugin.prototype.getToken = function (success, error) {
  exec(success, error, "FCMPlugin", "getToken", []);
};

// GET APNS TOKEN //
FCMPlugin.prototype.getAPNSToken = function (success, error) {
  if (cordova.platformId !== "ios") {
    success(null);
    return;
  }
  exec(success, error, "FCMPlugin", "getAPNSToken", []);
};

// CLEAR ALL NOTIFICATIONS //
FCMPlugin.prototype.clearAllNotifications = function (success, error) {
  exec(success, error, "FCMPlugin", "clearAllNotifications", []);
};

// REQUEST IOS PUSH PERMISSION //
FCMPlugin.prototype.requestPushPermissionIOS = function (success, error, options) {
  if (cordova.platformId !== "ios") {
    if (typeof success !== "undefined") {
      success(true);
    }
    return;
  }
  var ios9SupportTimeout = 10;
  var ios9SupportInterval = 0.3;
  if (options && options.ios9Support && options.ios9Support.timeout) {
    ios9SupportTimeout = options.ios9Support.timeout;
  }
  if (options && options.ios9Support && options.ios9Support.interval) {
    ios9SupportInterval = options.ios9Support.interval;
  }
  exec(success, error, "FCMPlugin", "requestPushPermission", [
    ios9SupportTimeout,
    ios9SupportInterval
  ]);
};

// REQUEST THE CREATION OF A NOTIFICATION CHANNEL //
FCMPlugin.prototype.createNotificationChannelAndroid = function (channelConfig, success, error) {
  if (cordova.platformId === "android") {
    exec(success, error, "FCMPlugin", "createNotificationChannel", [channelConfig]);
  }
};

// DEFAULT NOTIFICATION CALLBACK //
FCMPlugin.prototype.onNotificationReceived = function (payload) {
  console.log("Received push notification");
  console.log(payload);
};

// DEFAULT TOKEN REFRESH CALLBACK //
FCMPlugin.prototype.onTokenRefreshReceived = function (token) {
  console.log("Received token refresh");
  console.log(token);
};

// FIRE READY //
exec(
  function (result) {
    console.log("FCMPlugin Ready OK");
  },
  function (result) {
    console.log("FCMPlugin Ready ERROR");
  },
  "FCMPlugin",
  "ready",
  []
);

var fcmPlugin = new FCMPlugin();
module.exports = fcmPlugin;
