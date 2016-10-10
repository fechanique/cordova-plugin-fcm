var exec = require('cordova/exec');

function FCMPlugin() { 
	console.log("FCMPlugin.js: is created");
}




FCMPlugin.prototype.logEvent = function( key, value, success, error ){
    exec(success, error, "FCMPlugin", 'logEvent', [key,value]);
}

FCMPlugin.prototype.setUserId = function( userId, success, error ){
    exec(success, error, "FCMPlugin", 'setUserId', [userId]);
}

FCMPlugin.prototype.setUserProperty = function( propertyString,propertyName, success, error ){
    exec(success, error, "FCMPlugin", 'setUserProperty', [propertyString,propertyName]);
}


// GET TOKEN //
FCMPlugin.prototype.getToken = function( success, error ){
	exec(success, error, "FCMPlugin", 'getToken', []);
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
// DEFAULT NOTIFICATION CALLBACK //
FCMPlugin.prototype.onNotificationReceived = function(payload){
	console.log("Received push notification")
	console.log(payload)
}

// REMOTE CONFIGURATION //
FCMPlugin.prototype.initializeRemoteConfig = function(success, error ){
    exec(success, error, "FCMPlugin", 'initializeRemoteConfig', []);
}

FCMPlugin.prototype.getStringValueForKey = function( configKey, success, error ){
    exec(success, error, "FCMPlugin", 'getStringValueForKey', [configKey]);
}
// FIRE READY //
exec(function(result){ console.log("FCMPlugin Ready OK") }, function(result){ console.log("FCMPlugin Ready ERROR") }, "FCMPlugin",'ready',[]);





var fcmPlugin = new FCMPlugin();
module.exports = fcmPlugin;
