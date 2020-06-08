export interface INotificationPayload {
    /**
     * Determines whether the notification was tapped or not
     */
    wasTapped: boolean
    /**
     * FCM notification data hash item
     */
    [others: string]: any
}
