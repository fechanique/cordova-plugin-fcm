import { __decorate, __metadata } from "tslib";
import { Injectable } from "@angular/core";
import { Cordova, Plugin } from "@ionic-native/core";
import { Observable } from "rxjs";
var FCM = (function () {
    function FCM() {
        this.logReadyStatus();
    }
    FCM.prototype.logReadyStatus = function () {
        console.log("FCM ionic v4: has been created");
        return Promise.resolve();
    };
    FCM.prototype.clearAllNotifications = function () {
        return Promise.resolve();
    };
    FCM.prototype.createNotificationChannel = function (channelConfig) {
        return Promise.resolve();
    };
    FCM.prototype.getAPNSToken = function () {
        return Promise.resolve("");
    };
    FCM.prototype.getInitialPushPayload = function () {
        return Promise.resolve(null);
    };
    FCM.prototype.getToken = function () {
        return Promise.resolve("getToken");
    };
    FCM.prototype.hasPermission = function () {
        return Promise.resolve(true);
    };
    FCM.prototype.requestPushPermission = function (options) {
        return Promise.resolve(true);
    };
    FCM.prototype.subscribeToTopic = function (topic) {
        return Promise.resolve();
    };
    FCM.prototype.unsubscribeFromTopic = function (topic) {
        return Promise.resolve();
    };
    FCM.prototype.onNotification = function () {
        return new Observable();
    };
    FCM.prototype.onTokenRefresh = function () {
        return new Observable();
    };
    FCM.decorators = [{ type: Injectable }];
    __decorate([
        Cordova({
            eventObservable: true,
            element: window.FCM.eventTarget,
            event: "notification",
        }),
        __metadata("design:type", Function),
        __metadata("design:paramtypes", []),
        __metadata("design:returntype", Observable)
    ], FCM.prototype, "onNotification", null);
    __decorate([
        Cordova({
            eventObservable: true,
            element: window.FCM.eventTarget,
            event: "tokenRefresh",
        }),
        __metadata("design:type", Function),
        __metadata("design:paramtypes", []),
        __metadata("design:returntype", Observable)
    ], FCM.prototype, "onTokenRefresh", null);
    FCM = __decorate([
        Plugin({
            pluginName: "FCM",
            plugin: "cordova-plugin-fcm-with-dependecy-updated",
            pluginRef: "FCM",
            repo: "https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated",
            platforms: ["Android", "iOS"],
        }),
        __metadata("design:paramtypes", [])
    ], FCM);
    return FCM;
}());
export { FCM };
