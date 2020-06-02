import { Injectable } from "@angular/core"
import { Cordova, Plugin } from "@ionic-native/core"
import { Observable } from "rxjs"
import { INotificationPayload } from "../../../typings/INotificationPayload"
import { IRequestPushPermissionOptions } from "../../../typings/IRequestPushPermissionOptions"
import { IChannelConfiguration } from "../../../typings/IChannelConfiguration"

@Plugin({
  pluginName: "FCM",
  plugin: "cordova-plugin-fcm-with-dependecy-updated",
  pluginRef: "FCM",
  repo: "https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated",
  platforms: ["Android", "iOS"],
})
export class FCM {
  public static decorators = [{ type: Injectable }]

  constructor() {
    this.logReadyStatus()
  }

  private logReadyStatus(): Promise<void> {
    console.log("FCM ionic v4: has been created")

    return Promise.resolve()
  }

  public clearAllNotifications(): Promise<void> {
    return Promise.resolve()
  }

  public createNotificationChannel(channelConfig: IChannelConfiguration): Promise<void> {
    return Promise.resolve()
  }

  public getAPNSToken(): Promise<string> {
    return Promise.resolve("")
  }

  public getInitialPushPayload(): Promise<INotificationPayload | null> {
    return Promise.resolve(null)
  }

  public getToken(): Promise<string> {
    return Promise.resolve("getToken")
  }

  public hasPermission(): Promise<boolean> {
    return Promise.resolve(true)
  }

  public requestPushPermission(options?: IRequestPushPermissionOptions): Promise<boolean> {
    return Promise.resolve(true)
  }

  public subscribeToTopic(topic: string): Promise<void> {
    return Promise.resolve()
  }

  public unsubscribeFromTopic(topic: string): Promise<void> {
    return Promise.resolve()
  }

  /**
   * Event firing when receiving new notifications
   *
   * @returns {Observable<INotificationPayload>} An object to listen for notification data
   */
  @Cordova({
    eventObservable: true,
    element: (window as any).FCM.eventTarget,
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
    element: (window as any).FCM.eventTarget,
    event: "tokenRefresh",
  })
  public onTokenRefresh(): Observable<string> {
    return new Observable()
  }
}
