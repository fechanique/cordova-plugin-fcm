import { Subject } from 'rxjs'

function FCMPluginOnIonic() {}
FCMPluginOnIonic.prototype.clearAllNotifications = function () {
    return window.FCM.clearAllNotifications()
}
FCMPluginOnIonic.prototype.createNotificationChannel = function (channelConfig) {
    return window.FCM.createNotificationChannel(channelConfig)
}
FCMPluginOnIonic.prototype.deleteInstanceId = function () {
    return window.FCM.deleteInstanceId()
}
FCMPluginOnIonic.prototype.getAPNSToken = function () {
    return window.FCM.getAPNSToken()
}
FCMPluginOnIonic.prototype.getInitialPushPayload = function () {
    return window.FCM.getInitialPushPayload()
}
FCMPluginOnIonic.prototype.getToken = function () {
    return window.FCM.getToken()
}
FCMPluginOnIonic.prototype.hasPermission = function () {
    return window.FCM.hasPermission()
}
FCMPluginOnIonic.prototype.onNotification = function (options) {
    var observable = new Subject()
    var handler = function (payload) {
        return observable.next(payload)
    }
    window.FCM.onNotification(handler, options)
    return observable
}
FCMPluginOnIonic.prototype.onTokenRefresh = function (options) {
    var observable = new Subject()
    window.FCM.onTokenRefresh(function (token) {
        return observable.next(token)
    }, options)
    return observable
}
FCMPluginOnIonic.prototype.requestPushPermission = function (options) {
    return window.FCM.requestPushPermission(options)
}
FCMPluginOnIonic.prototype.subscribeToTopic = function (topic) {
    return window.FCM.subscribeToTopic(topic)
}
FCMPluginOnIonic.prototype.unsubscribeFromTopic = function (topic) {
    return window.FCM.unsubscribeFromTopic(topic)
}

export { FCMPluginOnIonic }
export var FCM = new FCMPluginOnIonic()
