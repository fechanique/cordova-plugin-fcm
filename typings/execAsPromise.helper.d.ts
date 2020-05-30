/**
 * This is a simple helper to Promisify the calls to cordova
 *
 * @param {string} command The native cordova implementation command
 * @param {unknown[]} args The native cordova implementation expected arguments
 *
 * @returns {Promise<R>} Returns from the async native call the type expected
 */
export declare const execAsPromise: <R>(command: string, args?: unknown[]) => Promise<R>;
