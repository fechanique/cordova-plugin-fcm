export type { INotificationPayload } from "./INotificationPayload"
export type { IChannelConfiguration } from "./IChannelConfiguration"
export type { IRequestPushPermissionOptions } from "./IRequestPushPermissionOptions"
import { FCMPlugin } from "./FCMPlugin"

interface Window {
  FCM: FCMPlugin
}

export const FCM = new FCMPlugin()
export { FCMPlugin }
export default FCM
