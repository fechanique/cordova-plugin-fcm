import { Observable } from "rxjs";
import type { INotificationPayload } from "../typings/INotificationPayload";
import { FCMPlugin } from "../typings/FCMPlugin";
export declare class FCMPluginOnIonic extends FCMPlugin {
    static pluginName: string;
    static plugin: string;
    static pluginRef: string;
    static repo: string;
    static platforms: string[];
    static installed: () => boolean;
    static getPlugin: () => any;
    static getPluginName: () => string;
    static getPluginRef: () => string;
    static getPluginInstallName: () => string;
    static getSupportedPlatforms: () => string[];
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
