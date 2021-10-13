export interface IRequestPushPermissionOptions {
    /**
     * Options exclusive for iOS 9 support
     */
    ios9Support?: {
        /**
         * How long it will wait for a decision from the user before returning `false`
         *
         * @default 10
         */
        timeout?: number

        /**
         * How long between each permission verification
         *
         * @default 0.3
         */
        interval?: number
    }
}
