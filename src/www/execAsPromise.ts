declare var window: {
    cordova: {
        exec: Function
    }
}

/**
 * This is a simple helper to Promisify the calls to cordova
 *
 * @param {string} command The native cordova implementation command
 * @param {unknown[]} args The native cordova implementation expected arguments
 *
 * @returns {Promise<R>} Returns from the async native call the type expected
 */
export const execAsPromise = <R>(command: string, args: unknown[] = []): Promise<R> =>
    new Promise<R>(
        (resolve: (value: R | PromiseLike<R>) => void, reject: (reason?: any) => void) => {
            window.cordova.exec(resolve, reject, 'FCMPlugin', command, args)
        }
    )
