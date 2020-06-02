import { __decorate, __extends } from "tslib";
import { Injectable } from "@angular/core";
import { IonicNativePlugin } from "@ionic-native/core";
import { FCMPluginOnIonic } from "../FCMPluginOnIonic";
var FCMPluginOnIonicNGX = (function (_super) {
    __extends(FCMPluginOnIonicNGX, _super);
    function FCMPluginOnIonicNGX() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    FCMPluginOnIonicNGX.pluginName = "FCM";
    FCMPluginOnIonicNGX.plugin = "cordova-plugin-fcm-with-dependecy-updated";
    FCMPluginOnIonicNGX.pluginRef = "FCMPlugin";
    FCMPluginOnIonicNGX.repo = "https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated";
    FCMPluginOnIonicNGX.platforms = ["Android", "iOS"];
    FCMPluginOnIonicNGX.installed = IonicNativePlugin.installed;
    FCMPluginOnIonicNGX.getPlugin = IonicNativePlugin.getPlugin;
    FCMPluginOnIonicNGX.getPluginName = IonicNativePlugin.getPluginName;
    FCMPluginOnIonicNGX.getPluginRef = IonicNativePlugin.getPluginRef;
    FCMPluginOnIonicNGX.getPluginInstallName = IonicNativePlugin.getPluginInstallName;
    FCMPluginOnIonicNGX.getSupportedPlatforms = IonicNativePlugin.getSupportedPlatforms;
    FCMPluginOnIonicNGX = __decorate([
        Injectable()
    ], FCMPluginOnIonicNGX);
    return FCMPluginOnIonicNGX;
}(FCMPluginOnIonic));
export { FCMPluginOnIonicNGX };
