import { __decorate } from 'tslib'
import { Injectable } from '@angular/core'
import { Plugin } from '@ionic-native/core'
import { Subject } from 'rxjs'

function FCM() {}
FCM.prototype.clearAllNotifications = function () {
    return window.FCM.clearAllNotifications()
}
FCM.prototype.createNotificationChannel = function (channelConfig) {
    return window.FCM.createNotificationChannel(channelConfig)
}
FCM.prototype.getAPNSToken = function () {
    return window.FCM.getAPNSToken()
}
FCM.prototype.getInitialPushPayload = function () {
    return window.FCM.getInitialPushPayload()
}
FCM.prototype.getToken = function () {
    return window.FCM.getToken()
}
FCM.prototype.hasPermission = function () {
    return window.FCM.hasPermission()
}
FCM.prototype.onNotification = function (options) {
    var observable = new Subject()
    var handler = function (payload) {
        return observable.next(payload)
    }
    window.FCM.onNotification(handler, options)
    return observable
}
FCM.prototype.onTokenRefresh = function (options) {
    var observable = new Subject()
    window.FCM.onTokenRefresh(function (token) {
        return observable.next(token)
    }, options)
    return observable
}
FCM.prototype.requestPushPermission = function (options) {
    return window.FCM.requestPushPermission(options)
}
FCM.prototype.subscribeToTopic = function (topic) {
    return window.FCM.subscribeToTopic(topic)
}
FCM.prototype.unsubscribeFromTopic = function (topic) {
    return window.FCM.unsubscribeFromTopic(topic)
}
FCM = __decorate(
    [
        Plugin({
            pluginName: 'FCM',
            plugin: 'cordova-plugin-fcm-with-dependecy-updated',
            pluginRef: 'FCM',
            repo: 'https://github.com/andrehtissot/cordova-plugin-fcm-with-dependecy-updated',
            platforms: ['Android', 'iOS']
        }),
        Injectable()
    ],
    FCM
)

export { FCM }
