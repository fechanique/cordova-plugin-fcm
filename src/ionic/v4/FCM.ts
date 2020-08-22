import { Injectable } from '@angular/core'
import { Plugin } from '@ionic-native/core'
import { Observable, Subject } from 'rxjs'
import type { FCMPlugin } from '../../../typings/FCMPlugin'
import type { IChannelConfiguration } from '../../../typings/IChannelConfiguration'
import type { IRequestPushPermissionOptions } from '../../../typings/IRequestPushPermissionOptions'
import type { INotificationPayload } from '../../../typings/INotificationPayload'

declare namespace window {
    export let FCM: FCMPlugin
}

/** @copyFrom typings/FCMPlugin.d.ts FCMPlugin */
@Plugin({
    pluginName: 'FCM',
    plugin: 'cordova-plugin-fcm-with-dependecy-updated',
    pluginRef: 'FCM',
    repo: 'https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated',
    platforms: ['Android', 'iOS'],
})
@Injectable()
export class FCM {
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

    /** @copyFrom ionic/FCM.d.ts FCMPluginOnIonic onNotification */
    public onNotification(options?: { once?: boolean }): Observable<INotificationPayload> {
        const observable = new Subject<INotificationPayload>()
        const handler = (payload: INotificationPayload) => observable.next(payload)
        window.FCM.onNotification(handler, options)

        return observable
    }

    /** @copyFrom ionic/FCM.d.ts FCMPluginOnIonic onTokenRefresh */
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
