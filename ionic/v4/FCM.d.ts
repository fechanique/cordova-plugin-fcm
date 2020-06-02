import { Observable } from "rxjs";
import { INotificationPayload } from "../../typings/INotificationPayload";
import { IRequestPushPermissionOptions } from "../../typings/IRequestPushPermissionOptions";
import { IChannelConfiguration } from "../../typings/IChannelConfiguration";
export declare class FCM {
    static decorators: {
        type: import("@angular/core").InjectableDecorator;
    }[];
    constructor();
    private logReadyStatus;
    clearAllNotifications(): Promise<void>;
    createNotificationChannel(channelConfig: IChannelConfiguration): Promise<void>;
    getAPNSToken(): Promise<string>;
    getInitialPushPayload(): Promise<INotificationPayload | null>;
    getToken(): Promise<string>;
    hasPermission(): Promise<boolean>;
    requestPushPermission(options?: IRequestPushPermissionOptions): Promise<boolean>;
    subscribeToTopic(topic: string): Promise<void>;
    unsubscribeFromTopic(topic: string): Promise<void>;
    /**
     * Event firing when receiving new notifications
     *
     * @returns {Observable<INotificationPayload>} An object to listen for notification data
     */
    onNotification(): Observable<INotificationPayload>;
    /**
     * Event firing when receiving a new Firebase token
     *
     * @returns {Observable<string>} An object to listen for the token
     */
    onTokenRefresh(): Observable<string>;
}
