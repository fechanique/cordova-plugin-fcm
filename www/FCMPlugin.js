cordova.define("cordova-plugin-fcm.FCMPlugin", function(require, exports, module) {
var exec = require('cordova/exec');

exports.subscribeToTopic = function(topic,success, error) {
    exec(success, error, "FCMPlugin", "subscribeToTopic", [topic]);
};

exports.getToken = function(success, error) {
    exec(success, error, "FCMPlugin", "getToken", []);
};

exports.setBadgeNumber = function(number, success, error) {
    exec(success, error, "FCMPlugin", "setBadgeNumber", [number]);
};

exports.getBadgeNumber = function(success, error) {
    exec(success, error, "FCMPlugin", "getBadgeNumber", []);
};


exports.unsubscribeFromTopic = function( topic, success, error ){
	exec(success, error, "FCMPlugin", 'unsubscribeFromTopic', [topic]);
}


// NOTIFICATION CALLBACK //
exports.onNotification = function( callback, success, error ){
	FCMPlugin.onNotificationReceived = callback;
	exec(success, error, "FCMPlugin", 'registerNotification',[]);
}
// DEFAULT NOTIFICATION CALLBACK //
exports.onNotificationReceived = function(payload){
	console.log("Received push notification")
	console.log(payload)
}

// SET BADGE NUMBER //
exports.setBadgeNumber = function(number, success, error){
	exec(success, error, "FCMPlugin", 'setBadgeNumber',[number]);
	
}

});
