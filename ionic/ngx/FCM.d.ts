import { FCMPluginOnIonic } from "../FCMPluginOnIonic";
export declare class FCM extends FCMPluginOnIonic {
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
}
