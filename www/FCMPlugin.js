var exec = require('cordova/exec');

function FCMPlugin() { 
	console.log("FCMPlugin.js: is created");
}

// SUBSCRIBE TO TOPIC //
FCMPlugin.prototype.subscribeToTopic = function( topic, success, error ){
	exec(success, error, "FCMPlugin", 'subscribeToTopic', [topic]);
}
// UNSUBSCRIBE FROM TOPIC //
FCMPlugin.prototype.unsubscribeFromTopic = function( topic, success, error ){
	exec(success, error, "FCMPlugin", 'unsubscribeFromTopic', [topic]);
}
// NOTIFICATION CALLBACK //
FCMPlugin.prototype.onNotification = function( callback, success, error ){
	FCMPlugin.prototype.onNotificationReceived = callback;
	exec(success, error, "FCMPlugin", 'registerNotification',[]);
}
// TOKEN REFRESH CALLBACK //
FCMPlugin.prototype.onTokenRefresh = function( callback ){
	FCMPlugin.prototype.onTokenRefreshReceived = callback;
}
// GET TOKEN //
FCMPlugin.prototype.getToken = function( success, error ){
	exec(success, error, "FCMPlugin", 'getToken', []);
}

// DEFAULT NOTIFICATION CALLBACK //
FCMPlugin.prototype.onNotificationReceived = function(payload){
	console.log("Received push notification")
	console.log(payload)
}
// DEFAULT TOKEN REFRESH CALLBACK //
FCMPlugin.prototype.onTokenRefreshReceived = function(token){
	console.log("Received token refresh")
	console.log(token)
}

// Analytics Plugin
FCMPlugin.prototype.clearAllNotifications = function(success, error){
  exec(success, error, 'FCMPlugin', 'clearAllNotifications', []);
}

// Analytics Plugin

FCMPlugin.prototype.logEvent = function(eventName, eventParams, success, error){
  exec(success, error, 'FCMPlugin', 'logEvent', [eventName, eventParams || {}]);
}

FCMPlugin.prototype.setUserId = function(userId, success, error){
  exec(success, error, 'FCMPlugin', 'setUserId', [userId]);
}

FCMPlugin.prototype.setUserProperty = function(name, value, success, error){
  exec(success, error, 'FCMPlugin', 'setUserProperty', [name, value]);
}

// FIRE READY //
exec(function(result){ console.log("FCMPlugin NG Ready OK") }, function(result){ console.log("FCMPlugin Ready ERROR") }, "FCMPlugin",'ready',[]);

var fcmPlugin = new FCMPlugin();
module.exports = fcmPlugin;
