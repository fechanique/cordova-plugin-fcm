import { Observable } from 'rxjs';
import { IChannelConfiguration } from '../../typings/IChannelConfiguration';
import { IRequestPushPermissionOptions } from '../../typings/IRequestPushPermissionOptions';
import { INotificationPayload } from '../../typings/INotificationPayload';
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
export declare class FCM {
    /**
     * Removes existing push notifications from the notifications center
     *
     * @returns {Promise<void>} Async call to native implementation
     */
    clearAllNotifications(): Promise<void>;
    /**
     * For Android, some notification properties are only defined programmatically.
     * Channel can define the default behavior for notifications on Android 8.0+.
     * Once a channel is created, it stays unchangeable until the user uninstalls the app.
     *
     * @param {IChannelConfiguration} channelConfig The parmeters of the new channel
     *
     * @returns {Promise<void>} Async call to native implementation
     */
    createNotificationChannel(channelConfig: IChannelConfiguration): Promise<void>;
    /**
     * This method deletes the InstanceId, revoking all tokens.
     *
     * @returns {Promise<void>} Async call to native implementation
     */
    deleteInstanceId(): Promise<void>;
    /**
     * Gets ios device's current APNS token
     *
     * @returns {Promise<string>} Returns a Promise that resolves with the APNS token
     */
    getAPNSToken(): Promise<string>;
    /**
     * Retrieves the message that, on tap, opened the app
     *
     * @private
     *
     * @returns {Promise<INotificationPayload | null>} Async call to native implementation
     */
    getInitialPushPayload(): Promise<INotificationPayload | null>;
    /**
     * Gets device's current registration id
     *
     * @returns {Promise<string>} Returns a Promise that resolves with the registration id token
     */
    getToken(): Promise<string>;
    /**
     * Checking for permissions.
     *
     * @returns {Promise<boolean | null>} Returns a Promise of:
     * - true: push was allowed (or platform is android)
     * - false: push will not be available
     * - null: still not answered, recommended checking again later.
     */
    hasPermission(): Promise<boolean>;
    /**
     * Event firing when receiving new notifications
     *
     * @argument {{ once?: boolean }} options once defines if the listener is only trigger once
     * @returns {Observable<INotificationPayload>} An object to listen for notification data
     */
    onNotification(options?: {
        once?: boolean;
    }): Observable<INotificationPayload>;
    /**
     * Event firing when receiving a new Firebase token
     *
     * @argument {{ once?: boolean }} options once defines if the listener is only trigger once
     * @returns {Observable<string>} An object to listen for the token
     */
    onTokenRefresh(options?: {
        once?: boolean;
    }): Observable<string>;
    /**
     * Request push notification permission, alerting the user if it not have yet decided
     *
     * @param {IRequestPushPermissionOptions} options Options for push request
     * @returns {Promise<boolean>} Returns a Promise that resolves with the permission status
     */
    requestPushPermission(options?: IRequestPushPermissionOptions): Promise<boolean>;
    /**
     * Subscribes you to a [topic](https://firebase.google.com/docs/notifications/android/console-topics)
     *
     * @param {string} topic Topic to be subscribed to
     *
     * @returns {Promise<void>} Async call to native implementation
     */
    subscribeToTopic(topic: string): Promise<void>;
    /**
     * Unsubscribes you from a [topic](https://firebase.google.com/docs/notifications/android/console-topics)
     *
     * @param {string} topic Topic to be unsubscribed from
     *
     * @returns {Promise<void>} Async call to native implementation
     */
    unsubscribeFromTopic(topic: string): Promise<void>;
}
