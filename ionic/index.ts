import { IonicNativePlugin, cordova } from "@ionic-native/core";
import { Observable } from "rxjs";
import { FCMPlugin } from "../typings/FCMPlugin";

export class FCM implements IonicNativePlugin {
  
  public pluginName = "FCM";
  public plugin = "cordova-plugin-fcm-with-dependecy-updated";
  public pluginRef = "FCMPlugin";
  public repo = "https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated";
  public platforms = ["Android", "iOS"];
}

var FCM = new FCMOriginal();
export { FCM };
