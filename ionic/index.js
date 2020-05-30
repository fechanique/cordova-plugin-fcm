// var __extends =
//   (this && this.__extends) ||
//   (function () {
//     var extendStatics = function (d, b) {
//       extendStatics =
//         Object.setPrototypeOf ||
//         ({ __proto__: [] } instanceof Array &&
//           function (d, b) {
//             d.__proto__ = b;
//           }) ||
//         function (d, b) {
//           for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
//         };
//       return extendStatics(d, b);
//     };
//     return function (d, b) {
//       extendStatics(d, b);
//       function __() {
//         this.constructor = d;
//       }
//       d.prototype = b === null ? Object.create(b) : ((__.prototype = b.prototype), new __());
//     };
//   })();
import { IonicNativePlugin, cordova } from "@ionic-native/core";
import { Observable } from "rxjs";
var FCMOriginal = /** @class */ (function (_super) {
  __extends(FCMOriginal, _super);
  function FCMOriginal() {
    return (_super !== null && _super.apply(this, arguments)) || this;
  }
  FCMOriginal.prototype.getAPNSToken = function () {
    return cordova(this, "getAPNSToken", {}, arguments);
  };
  FCMOriginal.prototype.getToken = function () {
    return cordova(this, "getToken", {}, arguments);
  };
  FCMOriginal.prototype.onTokenRefresh = function () {
    return cordova(this, "onTokenRefresh", { observable: true }, arguments);
  };
  FCMOriginal.prototype.subscribeToTopic = function (topic) {
    return cordova(this, "subscribeToTopic", {}, arguments);
  };
  FCMOriginal.prototype.unsubscribeFromTopic = function (topic) {
    return cordova(this, "unsubscribeFromTopic", {}, arguments);
  };
  FCMOriginal.prototype.hasPermission = function () {
    return cordova(this, "hasPermission", {}, arguments);
  };
  FCMOriginal.prototype.onNotification = function () {
    return cordova(
      this,
      "onNotification",
      { observable: true, successIndex: 0, errorIndex: 2 },
      arguments
    );
  };
  FCMOriginal.prototype.clearAllNotifications = function () {
    return cordova(this, "clearAllNotifications", {}, arguments);
  };
  FCMOriginal.pluginName = "FCM";
  FCMOriginal.plugin = "cordova-plugin-fcm-with-dependecy-updated";
  FCMOriginal.pluginRef = "FCMPlugin";
  FCMOriginal.repo = "https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated";
  FCMOriginal.platforms = ["Android", "iOS"];
  return FCMOriginal;
})(IonicNativePlugin);
var FCM = new FCMOriginal();
export { FCM };
