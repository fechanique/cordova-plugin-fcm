import { IonicNativePlugin, cordova } from "@ionic-native/core"
import { Observable } from "rxjs"
import type { INotificationPayload } from "../../typings/INotificationPayload"
import { FCMPlugin } from "../www/FCMPlugin"

export class FCMPluginOnIonic extends FCMPlugin implements IonicNativePlugin {
  public pluginName = "FCM"
  public plugin = "cordova-plugin-fcm-with-dependecy-updated"
  public pluginRef = "FCMPlugin"
  public repo = "https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated"
  public platforms = ["Android", "iOS"]

  /**
   * Event firing when receiving new notifications
   *
   * @returns {Observable<INotificationPayload>} An object to listen for notification data
   */
  public onNotification(): Observable<INotificationPayload> {
    return cordova(
      this,
      "onNotification",
      { eventObservable: true, element: this.eventTarget, event: "notification" },
      arguments
    )
  }

  /**
   * Event firing when receiving a new Firebase token
   *
   * @returns {Observable<string>} An object to listen for the token
   */
  public onTokenRefresh(): Observable<string> {
    return cordova(
      this,
      "onTokenRefresh",
      { eventObservable: true, element: this.eventTarget, event: "tokenRefresh" },
      arguments
    )
  }
}

export const FCM = new FCMPluginOnIonic()
export default FCM
