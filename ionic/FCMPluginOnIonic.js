import { __extends } from "tslib";
import { IonicNativePlugin, cordova } from "@ionic-native/core";
import { FCMPlugin } from "../www/FCMPlugin";
var FCMPluginOnIonic = (function (_super) {
    __extends(FCMPluginOnIonic, _super);
    function FCMPluginOnIonic() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    FCMPluginOnIonic.prototype.onNotification = function () {
        return cordova(this, "onNotification", { eventObservable: true, element: FCMPlugin.eventTarget, event: "notification" }, arguments);
    };
    FCMPluginOnIonic.prototype.onTokenRefresh = function () {
        return cordova(this, "onTokenRefresh", { eventObservable: true, element: FCMPlugin.eventTarget, event: "tokenRefresh" }, arguments);
    };
    FCMPluginOnIonic.pluginName = "FCM";
    FCMPluginOnIonic.plugin = "cordova-plugin-fcm-with-dependecy-updated";
    FCMPluginOnIonic.pluginRef = "FCM";
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
