import { Observable } from "rxjs";
import { FCMPlugin } from "../../www/FCMPlugin";
import type { INotificationPayload } from "../../typings/INotificationPayload";
export declare class FCMPluginOnIonicv4 extends FCMPlugin {
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
