import { __decorate, __extends } from "tslib";
import { Injectable } from "@angular/core";
import { Cordova, Plugin } from "@ionic-native/core";
import { Observable } from "rxjs";
import { FCMPlugin } from "../../www/FCMPlugin";
var FCMPluginOnIonicv4 = (function (_super) {
    __extends(FCMPluginOnIonicv4, _super);
    function FCMPluginOnIonicv4() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    FCMPluginOnIonicv4.prototype.onNotification = function () {
        return new Observable();
    };
    FCMPluginOnIonicv4.prototype.onTokenRefresh = function () {
        return new Observable();
    };
    __decorate([
        Cordova({
            eventObservable: true,
            element: this.eventTarget,
            event: "notification",
        })
    ], FCMPluginOnIonicv4.prototype, "onNotification", null);
    __decorate([
        Cordova({
            eventObservable: true,
            element: this.eventTarget,
            event: "tokenRefresh",
        })
    ], FCMPluginOnIonicv4.prototype, "onTokenRefresh", null);
    FCMPluginOnIonicv4 = __decorate([
        Plugin({
            pluginName: "FCM",
            plugin: "cordova-plugin-fcm-with-dependecy-updated",
            pluginRef: "FCMPlugin",
            repo: "https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated",
            platforms: ["Android", "iOS"],
        }),
        Injectable()
    ], FCMPluginOnIonicv4);
    return FCMPluginOnIonicv4;
}(FCMPlugin));
export { FCMPluginOnIonicv4 };
