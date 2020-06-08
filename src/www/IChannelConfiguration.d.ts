export interface IChannelConfiguration {
    /**
     * Channel id, used in the android_channel_id push payload key
     */
    id: string
    /**
     * Channel name, visible for the user
     */
    name: string
    /**
     * Channel description, visible for the user
     */
    description?: string
    /**
     * Importance for notifications of this channel
     * https://developer.android.com/guide/topics/ui/notifiers/notifications#importance
     */
    importance?: 'none' | 'min' | 'low' | 'default' | 'high'
    /**
     * Visibility for notifications of this channel
     * https://developer.android.com/training/notify-user/build-notification#lockscreenNotification
     */
    visibility?: 'public' | 'private' | 'secret'
    /**
     * Default sound resource for notifications of this channel
     * The file should located as resources/raw/[resource name].mp3
     */
    sound?: string
    /**
     * Enable lights for notifications of this channel
     */
    lights?: boolean
    /**
     * Enable vibration for notifications of this channel
     */
    vibration?: boolean
}
