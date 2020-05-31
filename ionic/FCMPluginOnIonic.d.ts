import { IonicNativePlugin } from "@ionic-native/core";
import { Observable } from "rxjs";
import type { INotificationPayload } from "../typings/INotificationPayload";
import { FCMPlugin } from "../typings/FCMPlugin";
export declare class FCMPluginOnIonic extends FCMPlugin implements IonicNativePlugin {
    pluginName: string;
    plugin: string;
    pluginRef: string;
    repo: string;
    platforms: string[];
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
export declare const FCM: FCMPluginOnIonic;
export default FCM;
