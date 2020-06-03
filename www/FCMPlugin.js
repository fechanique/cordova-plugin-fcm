'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

var execAsPromise = function (command, args) {
    if (args === void 0) { args = []; }
    return new Promise(function (resolve, reject) {
        window.cordova.exec(resolve, reject, "FCMPlugin", command, args);
    });
};

var FCMPlugin = (function () {
    function FCMPlugin() {
        try {
            this.eventTarget = new EventTarget();
        }
        catch (e) {
            this.eventTarget = document.createElement("div");
        }
        console.log("FCMPlugin: has been created");
        this.logReadyStatus();
    }
    FCMPlugin.prototype.clearAllNotifications = function () {
        return execAsPromise("clearAllNotifications");
    };
    FCMPlugin.prototype.createNotificationChannel = function (channelConfig) {
        if (window.cordova.platformId !== "android") {
            return Promise.resolve();
        }
        return execAsPromise("createNotificationChannel", [channelConfig]);
    };
    FCMPlugin.prototype.getAPNSToken = function () {
        return window.cordova.platformId !== "ios"
            ? Promise.resolve("")
            : execAsPromise("getAPNSToken");
    };
    FCMPlugin.prototype.getInitialPushPayload = function () {
        return execAsPromise("getInitialPushPayload");
    };
    FCMPlugin.prototype.getToken = function () {
        return execAsPromise("getToken");
    };
    FCMPlugin.prototype.hasPermission = function () {
        return window.cordova.platformId !== "ios"
            ? Promise.resolve(true)
            : execAsPromise("hasPermission");
    };
    FCMPlugin.prototype.onNotification = function (callback) {
        this.eventTarget.addEventListener("notification", function (event) { return callback(event.detail); }, { passive: true });
    };
    FCMPlugin.prototype.onTokenRefresh = function (callback) {
        this.eventTarget.addEventListener("tokenRefresh", function (event) { return callback(event.detail); }, { passive: true });
    };
    FCMPlugin.prototype.requestPushPermission = function (options) {
        var _a, _b, _c, _d;
        if (window.cordova.platformId !== "ios") {
            return Promise.resolve(true);
        }
        var ios9SupportTimeout = (_b = (_a = options === null || options === void 0 ? void 0 : options.ios9Support) === null || _a === void 0 ? void 0 : _a.timeout) !== null && _b !== void 0 ? _b : 10;
        var ios9SupportInterval = (_d = (_c = options === null || options === void 0 ? void 0 : options.ios9Support) === null || _c === void 0 ? void 0 : _c.interval) !== null && _d !== void 0 ? _d : 0.3;
        return execAsPromise("requestPushPermission", [ios9SupportTimeout, ios9SupportInterval]);
    };
    FCMPlugin.prototype.subscribeToTopic = function (topic) {
        return execAsPromise("subscribeToTopic", [topic]);
    };
    FCMPlugin.prototype.unsubscribeFromTopic = function (topic) {
        return execAsPromise("unsubscribeFromTopic", [topic]);
    };
    FCMPlugin.prototype.logReadyStatus = function () {
        return execAsPromise("ready")
            .then(function () { return console.log("FCMPlugin: Ready!"); })
            .catch(function (error) { return console.log("FCMPlugin: Ready error: ", error); });
    };
    return FCMPlugin;
}());

var FCM = new FCMPlugin();

exports.FCM = FCM;
exports.FCMPlugin = FCMPlugin;
module.exports = FCM;
