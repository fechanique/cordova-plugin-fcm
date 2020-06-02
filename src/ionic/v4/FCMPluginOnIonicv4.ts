import { Injectable } from "@angular/core"
import { Cordova, Plugin } from "@ionic-native/core"
import { Observable } from "rxjs"
import { FCMPlugin } from "../../www/FCMPlugin"
import type { INotificationPayload } from "../../../typings/INotificationPayload"

@Plugin({
  pluginName: "FCM",
  plugin: "cordova-plugin-fcm-with-dependecy-updated",
  pluginRef: "FCMPlugin",
  repo: "https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated",
  platforms: ["Android", "iOS"],
})
@Injectable()
export class FCMPluginOnIonicv4 extends FCMPlugin {
  /**
   * Event firing when receiving new notifications
   *
   * @returns {Observable<INotificationPayload>} An object to listen for notification data
   */
  @Cordova({
    eventObservable: true,
    element: this.eventTarget,
    event: "notification",
  })
  public onNotification(): Observable<INotificationPayload> {
    return new Observable()
  }

  /**
   * Event firing when receiving a new Firebase token
   *
   * @returns {Observable<string>} An object to listen for the token
   */
  @Cordova({
    eventObservable: true,
    element: this.eventTarget,
    event: "tokenRefresh",
  })
  public onTokenRefresh(): Observable<string> {
    return new Observable()
  }
}
