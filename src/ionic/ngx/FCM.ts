import { Injectable } from '@angular/core'
import { IonicNativePlugin } from '@ionic-native/core'
import { FCMPluginOnIonic } from '../FCM'

@Injectable()
export class FCM extends FCMPluginOnIonic {
    public static pluginName: string = 'FCM'
    public static plugin: string = 'cordova-plugin-fcm-with-dependecy-updated'
    public static pluginRef: string = 'FCM'
    public static repo: string =
        'https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated'
    public static platforms: string[] = ['Android', 'iOS']
    public static installed: () => boolean = IonicNativePlugin.installed
    public static getPlugin: () => any = IonicNativePlugin.getPlugin
    public static getPluginName: () => string = IonicNativePlugin.getPluginName
    public static getPluginRef: () => string = IonicNativePlugin.getPluginRef
    public static getPluginInstallName: () => string = IonicNativePlugin.getPluginInstallName
    public static getSupportedPlatforms: () => string[] = IonicNativePlugin.getSupportedPlatforms
}
