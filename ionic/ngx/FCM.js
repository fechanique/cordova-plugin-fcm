import { __decorate, __extends } from "tslib";
import { Injectable } from "@angular/core";
import { IonicNativePlugin } from "@ionic-native/core";
import { FCMPluginOnIonic } from "../FCM";
var FCM = (function (_super) {
    __extends(FCM, _super);
    function FCM() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    FCM.pluginName = "FCM";
    FCM.plugin = "cordova-plugin-fcm-with-dependecy-updated";
    FCM.pluginRef = "FCM";
    FCM.repo = "https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated";
    FCM.platforms = ["Android", "iOS"];
    FCM.installed = IonicNativePlugin.installed;
    FCM.getPlugin = IonicNativePlugin.getPlugin;
    FCM.getPluginName = IonicNativePlugin.getPluginName;
    FCM.getPluginRef = IonicNativePlugin.getPluginRef;
    FCM.getPluginInstallName = IonicNativePlugin.getPluginInstallName;
    FCM.getSupportedPlatforms = IonicNativePlugin.getSupportedPlatforms;
    FCM = __decorate([
        Injectable()
    ], FCM);
    return FCM;
}(FCMPluginOnIonic));
export { FCM };
