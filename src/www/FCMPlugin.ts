import type { IChannelConfiguration } from './IChannelConfiguration'
import type { IRequestPushPermissionOptions } from './IRequestPushPermissionOptions'
import type { INotificationPayload } from './INotificationPayload'
import type { IDisposable } from './IDisposable'
import { execAsPromise } from './execAsPromise'
import { asDisposableListener } from './eventAsDisposable'
import { bridgeNativeEvents } from './bridgeNativeEvents'
declare var window: {
    cordova: {
        platformId: string
    }
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
export class FCMPlugin {
    /**
     * EventTarget for native-sourced custom events.
     *
     * @event notification
     * @type {INotificationPayload}
     *
     * @event tokenRefresh
     * @type {string}
     *
     */
    public readonly eventTarget: EventTarget

    constructor() {
        // EventTarget is not fully supported on iOS and older Android
        this.eventTarget = document.createElement('div')
        execAsPromise('ready')
            .catch((error: Error) => console.log('FCM: Ready error: ', error))
            .then(() => {
                console.log('FCM: Ready!')
                bridgeNativeEvents(this.eventTarget)
            })
        console.log('FCM: has been created')
    }

    /**
     * Removes existing push notifications from the notifications center
     *
     * @returns {Promise<void>} Async call to native implementation
     */
    public clearAllNotifications(): Promise<void> {
        return execAsPromise('clearAllNotifications')
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
        if (window.cordova.platformId !== 'android') {
            return Promise.resolve()
        }

        return execAsPromise('createNotificationChannel', [channelConfig])
    }

    /**
     * This method deletes the InstanceId, revoking all tokens.
     *
     * @returns {Promise<void>} Async call to native implementation
     */
    public deleteInstanceId(): Promise<void> {
        return execAsPromise('deleteInstanceId')
    }

    /**
     * Gets ios device's current APNS token
     *
     * @returns {Promise<string>} Returns a Promise that resolves with the APNS token
     */
    public getAPNSToken(): Promise<string> {
        return window.cordova.platformId !== 'ios'
            ? Promise.resolve('')
            : execAsPromise('getAPNSToken')
    }

    /**
     * Retrieves the message that, on tap, opened the app
     *
     * @private
     *
     * @returns {Promise<INotificationPayload | null>} Async call to native implementation
     */
    public getInitialPushPayload(): Promise<INotificationPayload | null> {
        return execAsPromise('getInitialPushPayload')
    }

    /**
     * Gets device's current registration id
     *
     * @returns {Promise<string>} Returns a Promise that resolves with the registration id token
     */
    public getToken(): Promise<string> {
        return execAsPromise('getToken')
    }

    /**
     * Checking for permissions.
     *
     * @returns {Promise<boolean | null>} Returns a Promise of:
     * - true: push was allowed (or platform is android)
     * - false: push will not be available
     * - null: still not answered, recommended checking again later.
     */
    public hasPermission(): Promise<boolean> {
        return window.cordova.platformId === 'ios'
            ? execAsPromise('hasPermission')
            : execAsPromise('hasPermission').then((value) => !!value)
    }

    /**
     * Callback firing when receiving new notifications
     *
     * @argument {(payload: INotificationPayload) => void} callback function to be called when event is triggered
     * @argument {{ once?: boolean }} options once defines if the listener is only trigger once
     * @returns {IDisposable} object of which can request the listener's disposal
     */
    public onNotification(
        callback: (payload: INotificationPayload) => void,
        options?: { once?: boolean }
    ): IDisposable {
        return asDisposableListener(this.eventTarget, 'notification', callback, options)
    }

    /**
     * Callback firing when receiving a new Firebase token
     *
     * @argument {(token: string) => void} callback function to be called when event is triggered
     * @argument {{ once?: boolean }} options once defines if the listener is only trigger once
     * @returns {IDisposable} object of which can request the listener's disposal
     */
    public onTokenRefresh(
        callback: (token: string) => void,
        options?: { once?: boolean }
    ): IDisposable {
        return asDisposableListener(this.eventTarget, 'tokenRefresh', callback, options)
    }

    /**
     * Request push notification permission, alerting the user if it not have yet decided
     *
     * @param {IRequestPushPermissionOptions} options Options for push request
     * @returns {Promise<boolean>} Returns a Promise that resolves with the permission status
     */
    public requestPushPermission(options?: IRequestPushPermissionOptions): Promise<boolean> {
        if (window.cordova.platformId !== 'ios') {
            return Promise.resolve(true)
        }
        const ios9SupportTimeout = options?.ios9Support?.timeout ?? 10
        const ios9SupportInterval = options?.ios9Support?.interval ?? 0.3

        return execAsPromise('requestPushPermission', [ios9SupportTimeout, ios9SupportInterval])
    }

    /**
     * Subscribes you to a [topic](https://firebase.google.com/docs/notifications/android/console-topics)
     *
     * @param {string} topic Topic to be subscribed to
     *
     * @returns {Promise<void>} Async call to native implementation
     */
    public subscribeToTopic(topic: string): Promise<void> {
        return execAsPromise('subscribeToTopic', [topic])
    }

    /**
     * Unsubscribes you from a [topic](https://firebase.google.com/docs/notifications/android/console-topics)
     *
     * @param {string} topic Topic to be unsubscribed from
     *
     * @returns {Promise<void>} Async call to native implementation
     */
    public unsubscribeFromTopic(topic: string): Promise<void> {
        return execAsPromise('unsubscribeFromTopic', [topic])
    }
}
