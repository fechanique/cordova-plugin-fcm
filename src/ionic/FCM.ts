import { Observable, Subject } from 'rxjs'
import { INotificationPayload } from '../../typings/INotificationPayload'
import { FCMPlugin } from '../www/FCMPlugin'
import { IRequestPushPermissionOptions } from '../../typings/IRequestPushPermissionOptions'
import { IChannelConfiguration } from '../../typings/IChannelConfiguration'

declare namespace window {
    export let FCM: FCMPlugin
}

/** @copyFrom typings/FCMPlugin.d.ts FCMPlugin */
export class FCMPluginOnIonic {
    /** @copyFrom typings/FCMPlugin.d.ts FCMPlugin clearAllNotifications */
    public clearAllNotifications(): Promise<void> {
        return window.FCM.clearAllNotifications()
    }

    /** @copyFrom typings/FCMPlugin.d.ts FCMPlugin createNotificationChannel */
    public createNotificationChannel(channelConfig: IChannelConfiguration): Promise<void> {
        return window.FCM.createNotificationChannel(channelConfig)
    }

    /** @copyFrom typings/FCMPlugin.d.ts FCMPlugin deleteInstanceId */
    public deleteInstanceId(): Promise<void> {
        return window.FCM.deleteInstanceId()
    }

    /** @copyFrom typings/FCMPlugin.d.ts FCMPlugin getAPNSToken */
    public getAPNSToken(): Promise<string> {
        return window.FCM.getAPNSToken()
    }

    /** @copyFrom typings/FCMPlugin.d.ts FCMPlugin getInitialPushPayload */
    public getInitialPushPayload(): Promise<INotificationPayload | null> {
        return window.FCM.getInitialPushPayload()
    }

    /** @copyFrom typings/FCMPlugin.d.ts FCMPlugin getToken */
    public getToken(): Promise<string> {
        return window.FCM.getToken()
    }

    /** @copyFrom typings/FCMPlugin.d.ts FCMPlugin hasPermission */
    public hasPermission(): Promise<boolean> {
        return window.FCM.hasPermission()
    }

    /**
     * Event firing when receiving new notifications
     *
     * @argument {{ once?: boolean }} options once defines if the listener is only trigger once
     * @returns {Observable<INotificationPayload>} An object to listen for notification data
     */
    public onNotification(options?: { once?: boolean }): Observable<INotificationPayload> {
        const observable = new Subject<INotificationPayload>()
        const handler = (payload: INotificationPayload) => observable.next(payload)
        window.FCM.onNotification(handler, options)

        return observable
    }

    /**
     * Event firing when receiving a new Firebase token
     *
     * @argument {{ once?: boolean }} options once defines if the listener is only trigger once
     * @returns {Observable<string>} An object to listen for the token
     */
    public onTokenRefresh(options?: { once?: boolean }): Observable<string> {
        const observable = new Subject<string>()
        window.FCM.onTokenRefresh((token: string) => observable.next(token), options)

        return observable
    }

    /** @copyFrom typings/FCMPlugin.d.ts FCMPlugin requestPushPermission */
    public requestPushPermission(options?: IRequestPushPermissionOptions): Promise<boolean> {
        return window.FCM.requestPushPermission(options)
    }

    /** @copyFrom typings/FCMPlugin.d.ts FCMPlugin subscribeToTopic */
    public subscribeToTopic(topic: string): Promise<void> {
        return window.FCM.subscribeToTopic(topic)
    }

    /** @copyFrom typings/FCMPlugin.d.ts FCMPlugin unsubscribeFromTopic */
    public unsubscribeFromTopic(topic: string): Promise<void> {
        return window.FCM.unsubscribeFromTopic(topic)
    }
}

export const FCM = new FCMPluginOnIonic()
