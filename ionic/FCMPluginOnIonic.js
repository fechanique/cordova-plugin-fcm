var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
import { IonicNativePlugin, cordova } from "@ionic-native/core";
import { FCMPlugin } from "../www/FCMPlugin";
var FCMPluginOnIonic = (function (_super) {
    __extends(FCMPluginOnIonic, _super);
    function FCMPluginOnIonic() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    FCMPluginOnIonic.prototype.onNotification = function () {
        return cordova(this, "onNotification", { eventObservable: true, element: this.eventTarget, event: "notification" }, arguments);
    };
    FCMPluginOnIonic.prototype.onTokenRefresh = function () {
        return cordova(this, "onTokenRefresh", { eventObservable: true, element: this.eventTarget, event: "tokenRefresh" }, arguments);
    };
    FCMPluginOnIonic.pluginName = "FCM";
    FCMPluginOnIonic.plugin = "cordova-plugin-fcm-with-dependecy-updated";
    FCMPluginOnIonic.pluginRef = "FCMPlugin";
    FCMPluginOnIonic.repo = "https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated";
    FCMPluginOnIonic.platforms = ["Android", "iOS"];
    FCMPluginOnIonic.installed = IonicNativePlugin.installed;
    FCMPluginOnIonic.getPlugin = IonicNativePlugin.getPlugin;
    FCMPluginOnIonic.getPluginName = IonicNativePlugin.getPluginName;
    FCMPluginOnIonic.getPluginRef = IonicNativePlugin.getPluginRef;
    FCMPluginOnIonic.getPluginInstallName = IonicNativePlugin.getPluginInstallName;
    FCMPluginOnIonic.getSupportedPlatforms = IonicNativePlugin.getSupportedPlatforms;
    return FCMPluginOnIonic;
}(FCMPlugin));
export { FCMPluginOnIonic };
