import { Observable, Subject } from 'rxjs'
import { INotificationPayload } from '../../typings/INotificationPayload'
import { FCMPlugin } from '../www/FCMPlugin'
import { IRequestPushPermissionOptions } from '../../typings/IRequestPushPermissionOptions'
import { IChannelConfiguration } from '../../typings/IChannelConfiguration'

declare namespace window {
    export let FCM: FCMPlugin
}

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
export class FCMPluginOnIonic {
    /**
     * Removes existing push notifications from the notifications center
     *
     * @returns {Promise<void>} Async call to native implementation
     */
    public clearAllNotifications(): Promise<void> {
        return window.FCM.clearAllNotifications()
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
        return window.FCM.createNotificationChannel(channelConfig)
    }

    /**
     * Gets ios device's current APNS token
     *
     * @returns {Promise<string>} Returns a Promise that resolves with the APNS token
     */
    public getAPNSToken(): Promise<string> {
        return window.FCM.getAPNSToken()
    }

    /**
     * Retrieves the message that, on tap, opened the app
     *
     * @private
     *
     * @returns {Promise<INotificationPayload | null>} Async call to native implementation
     */
    public getInitialPushPayload(): Promise<INotificationPayload | null> {
        return window.FCM.getInitialPushPayload()
    }

    /**
     * Gets device's current registration id
     *
     * @returns {Promise<string>} Returns a Promise that resolves with the registration id token
     */
    public getToken(): Promise<string> {
        return window.FCM.getToken()
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
        return window.FCM.hasPermission()
    }

    /**
     * Event firing when receiving new notifications
     *
     * @returns {Observable<INotificationPayload>} An object to listen for notification data
     */
    public onNotification(): Observable<INotificationPayload> {
        const observable = new Subject<INotificationPayload>()
        window.FCM.eventTarget.addEventListener(
            'notification',
            (event: CustomEvent<INotificationPayload>) => observable.next(event.detail),
            { passive: true }
        )

        return observable
    }

    /**
     * Event firing when receiving a new Firebase token
     *
     * @returns {Observable<string>} An object to listen for the token
     */
    public onTokenRefresh(): Observable<string> {
        const observable = new Subject<string>()
        window.FCM.eventTarget.addEventListener(
            'tokenRefresh',
            (event: CustomEvent<string>) => observable.next(event.detail),
            { passive: true }
        )

        return observable
    }

    /**
     * Request push notification permission, alerting the user if it not have yet decided
     *
     * @param {IRequestPushPermissionOptions} options Options for push request
     *
     * @returns {Promise<boolean>} Returns a Promise that resolves with the permission status
     */
    public requestPushPermission(options?: IRequestPushPermissionOptions): Promise<boolean> {
        return window.FCM.requestPushPermission(options)
    }

    /**
     * Subscribes you to a [topic](https://firebase.google.com/docs/notifications/android/console-topics)
     *
     * @param {string} topic Topic to be subscribed to
     *
     * @returns {Promise<void>} Async call to native implementation
     */
    public subscribeToTopic(topic: string): Promise<void> {
        return window.FCM.subscribeToTopic(topic)
    }

    /**
     * Unsubscribes you from a [topic](https://firebase.google.com/docs/notifications/android/console-topics)
     *
     * @param {string} topic Topic to be unsubscribed from
     *
     * @returns {Promise<void>} Async call to native implementation
     */
    public unsubscribeFromTopic(topic: string): Promise<void> {
        return window.FCM.unsubscribeFromTopic(topic)
    }
}

export const FCM = new FCMPluginOnIonic()
