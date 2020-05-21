export interface INotificationPayload {
  wasTapped: boolean;
  notification?: {
    title?: string;
    body?: string;
    sound?: string;
    icon?: string;
  };
  priority?: string;
  data?: {
    [others: string]: any;
  };
  [others: string]: any;
}

export interface IChannelConfiguration {
  id: string;
  name: string;
  description?: string;
  importance?: "none" | "min" | "low" | "default" | "high";
  visibility?: "public" | "private" | "secret";
  sound?: string;
  lights?: boolean;
  vibration?: boolean;
}

export interface RequestPushPermissionIOSOptions {
  ios9Support: {
    timeout: number; // Defaults to 10
    interval: number; // Defaults to 0.3
  };
}

export interface FCMPlugin {
  hasPermission(
    onSuccess: (doesIt: boolean | null) => void,
    onError?: (error: Error) => void
  ): void;

  subscribeToTopic(
    topic: string,
    onSuccess?: (message: string) => void,
    onError?: (error: Error) => void
  ): void;

  unsubscribeFromTopic(
    topic: string,
    onSuccess?: (message: string) => void,
    onError?: (error: Error) => void
  ): void;

  onNotification(
    callback: (payload: INotificationPayload) => void,
    onSuccess?: (message: string) => void,
    onError?: (error: Error) => void
  ): void;

  getToken(
    callback: (token: string | null) => void,
    onSuccess?: (message: string) => void,
    onError?: (error: Error) => void
  ): void;

  getAPNSToken(
    callback: (token: string | null) => void,
    onSuccess?: (message: string) => void,
    onError?: (error: Error) => void
  ): void;

  onTokenRefresh(
    callback: (token: string) => void,
    onSuccess?: (message: string) => void,
    onError?: (error: Error) => void
  ): void;

  clearAllNotifications(onSuccess?: () => void, onError?: (error: Error) => void): void;

  requestPushPermissionIOS(
    onSuccess: (wasPermissionGiven: boolean) => void,
    onError?: (error: Error) => void,
    options?: RequestPushPermissionIOSOptions
  ): void;

  createNotificationChannelAndroid(
    channelConfig: IChannelConfiguration,
    onSuccess?: () => void,
    onError?: (error: Error) => void
  ): void;
}
