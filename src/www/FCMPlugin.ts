import { Observable } from "rxjs"
import type { INotificationPayload } from "./INotificationPayload"
import type { IChannelConfiguration } from "./IChannelConfiguration"
import type { IRequestPushPermissionOptions } from "./IRequestPushPermissionOptions"
import { execAsPromise } from "./execAsPromise.helper"

/**
 * @name FCM
 * @description
 * Easy plug&play push notification for Google Firebase FCM.
 *
 * @interfaces
 * INotificationPayload
 * IChannelConfiguration
 * IRequestPushPermissionOptions
 */
export class FCMPlugin {
  /**
   * The observable instance for onNotification
   *
   * @private
   */
  private onNotificationObservable?: Observable<INotificationPayload>

  /**
   * The observable instance for onTokenRefresh
   *
   * @private
   */
  private onTokenRefreshObservable?: Observable<string>

  constructor() {
    console.log("FCMPlugin: has been created")
    this.logReadyStatus()
  }

  /**
   * Removes existing push notifications from the notifications center
   *
   * @returns {Promise<void>} Async call to native implementation
   */
  public clearAllNotifications(): Promise<void> {
    return execAsPromise("clearAllNotifications")
  }

  /**
   * For Android, some notification properties are only defined programmatically.
   * Channel can define the default behavior for notifications on Android 8.0+.
   * Once a channel is created, it stays unchangeable until the user uninstalls the app.
   *
   * @param {IChannelConfiguration} channelConfig The parmeters of the new channel
   *
   * @returns {Promise<void>} Async call to native implementation
   */
  public createNotificationChannel(channelConfig: IChannelConfiguration): Promise<void> {
    if (window.cordova.platformId !== "android") {
      return Promise.resolve()
    }

    return execAsPromise("createNotificationChannel", [channelConfig])
  }

  /**
   * Gets ios device's current APNS token
   *
   * @returns {Promise<string>} Returns a Promise that resolves with the APNS token
   */
  public getAPNSToken(): Promise<string> {
    return window.cordova.platformId !== "ios"
      ? Promise.resolve("")
      : execAsPromise("getAPNSToken")
  }

  /**
   * Gets device's current registration id
   *
   * @returns {Promise<string>} Returns a Promise that resolves with the registration id token
   */
  public getToken(): Promise<string> {
    return execAsPromise("getToken")
  }

  /**
   * Checking for permissions on iOS. On android, it always returns `true`.
   *
   * @returns {Promise<boolean | null>} Returns a Promise of:
   * - true: push was allowed (or platform is android)
   * - false: push will not be available
   * - null: still not answered, recommended checking again later.
   */
  public hasPermission(): Promise<boolean> {
    return window.cordova.platformId !== "ios"
      ? Promise.resolve(true)
      : execAsPromise("hasPermission")
  }

  /**
   * Watch for incoming notifications
   *
   * @returns {Observable<INotificationPayload>} returns an object with data from the notification
   */
  public onNotification(): Observable<INotificationPayload> {
    if (!this.onNotificationObservable) {
      this.onNotificationObservable = new Observable<INotificationPayload>()
    }
    this.triggerLastBackgroundPush()

    return this.onNotificationObservable
  }

  /**
   * Event firing on the token refresh
   *
   * @returns {Observable<string>} Returns an Observable that notifies with the change of device's registration id
   */
  public onTokenRefresh(): Observable<string> {
    if (!this.onTokenRefreshObservable) {
      this.onTokenRefreshObservable = new Observable<string>()
    }

    return this.onTokenRefreshObservable
  }

  /**
   * Request push notification permission, alerting the user if it not have yet decided
   *
   * @param {IRequestPushPermissionOptions} options Options for push request
   *
   * @returns {Promise<boolean>} Returns a Promise that resolves with the permission status
   */
  public requestPushPermission(options?: IRequestPushPermissionOptions): Promise<boolean> {
    if (window.cordova.platformId !== "ios") {
      return Promise.resolve(true)
    }
    const ios9SupportTimeout = options?.ios9Support?.timeout ?? 10
    const ios9SupportInterval = options?.ios9Support?.interval ?? 0.3

    return execAsPromise("requestPushPermission", [ios9SupportTimeout, ios9SupportInterval])
  }

  /**
   * Subscribes you to a [topic](https://firebase.google.com/docs/notifications/android/console-topics)
   *
   * @param {string} topic Topic to be subscribed to
   *
   * @returns {Promise<void>} Async call to native implementation
   */
  public subscribeToTopic(topic: string): Promise<void> {
    return execAsPromise("subscribeToTopic", [topic])
  }

  /**
   * Unsubscribes you from a [topic](https://firebase.google.com/docs/notifications/android/console-topics)
   *
   * @param {string} topic Topic to be unsubscribed from
   *
   * @returns {Promise<void>} Async call to native implementation
   */
  public unsubscribeFromTopic(topic: string): Promise<void> {
    return execAsPromise("unsubscribeFromTopic", [topic])
  }

  /**
   * Triggers the last message retried on background
   *
   * @private
   *
   * @returns {Promise<void>} Async call to native implementation
   */
  private triggerLastBackgroundPush(): Promise<void> {
    return execAsPromise("registerNotification")
  }

  /**
   * Logs the cordova ready event
   *
   * @private
   *
   * @returns {Promise<void>} Async call to native implementation
   */
  private logReadyStatus(): Promise<void> {
    return execAsPromise("ready")
      .then(() => console.log("FCMPlugin: Ready!"))
      .catch((error: Error) => console.log("FCMPlugin: Ready error: ", error))
  }
}
