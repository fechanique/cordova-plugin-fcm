import { IDisposable } from './IDisposable';
/**
 * This is a simple helper to wrapp the event handler into a IDisposable
 *
 * @param {EventTarget} eventTarget EventTarget for native-sourced custom events
 * @param {string} eventName Event name to listen to
 * @param {(data: any) => void} callback Event handler
 * @param {{ once?: boolean }} options once defines if the listener is only trigger once
 * @returns {IDisposable} object of which can request the listener's disposal
 */
export declare const asDisposableListener: <R>(eventTarget: EventTarget, eventName: string, callback: (data: R) => void, options?: {
    once?: boolean | undefined;
}) => IDisposable;
