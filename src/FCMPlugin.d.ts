export interface INotificationData {
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
    callback: (data: INotificationData) => void,
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
}
