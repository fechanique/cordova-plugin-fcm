package com.gae.scaffolder.plugin;

import android.app.NotificationManager;
import android.content.Context;
import android.support.annotation.NonNull;
import android.util.Log;

import com.gae.scaffolder.plugin.interfaces.OnFinishedListener;
import com.gae.scaffolder.plugin.interfaces.TokenListeners;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.InstanceIdResult;
import com.google.firebase.messaging.FirebaseMessaging;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

public class FCMPlugin extends CordovaPlugin {
    public static CordovaWebView gWebView;
    public static String notificationCallBack = "FCMPlugin.onNotificationReceived";
    public static String tokenRefreshCallBack = "FCMPlugin.onTokenRefreshReceived";
    public static Boolean notificationCallBackReady = false;
    public static Map<String, Object> lastPush = null;

    protected Context context = null;
    protected static OnFinishedListener<JSONObject> notificationFn = null;
    private static final String TAG = "FCMPlugin";
    private static CordovaPlugin instance = null;

    public FCMPlugin() {}
    public FCMPlugin(Context context) {
        this.context = context;
    }

    public static synchronized FCMPlugin getInstance(Context context) {
        if (instance == null) {
            instance = new FCMPlugin(context);
            instance = getPlugin(instance);
        }

        return (FCMPlugin) instance;
    }

    public static synchronized FCMPlugin getInstance() {
        if (instance == null) {
            instance = new FCMPlugin();
            instance = getPlugin(instance);
        }

        return (FCMPlugin) instance;
    }

    public static CordovaPlugin getPlugin(CordovaPlugin plugin) {
        if (plugin.webView != null) {
            instance = plugin.webView.getPluginManager().getPlugin(FCMPlugin.class.getName());
        } else {
            plugin.initialize(null, null);
            instance = plugin;
        }

        return instance;
    }

    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        gWebView = webView;
        Log.d(TAG, "==> FCMPlugin initialize");

        FirebaseMessaging.getInstance().subscribeToTopic("android");
        FirebaseMessaging.getInstance().subscribeToTopic("all");
    }

    public boolean execute(final String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        Log.d(TAG, "==> FCMPlugin execute: " + action);

        try {
            // READY //
            if (action.equals("ready")) {
                callbackContext.success();
            }
            // GET TOKEN //
            else if (action.equals("getToken")) {
                cordova.getActivity().runOnUiThread(new Runnable() {
                    public void run() {
                        getToken(callbackContext);
                    }
                });
            }
            // NOTIFICATION CALLBACK REGISTER //
            else if (action.equals("registerNotification")) {
                notificationCallBackReady = true;
                cordova.getActivity().runOnUiThread(new Runnable() {
                    public void run() {
                        registerNotification(callbackContext);
                    }
                });
            }
            // UN/SUBSCRIBE TOPICS //
            else if (action.equals("subscribeToTopic")) {
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        try {
                            FirebaseMessaging.getInstance().subscribeToTopic(args.getString(0));
                            callbackContext.success();
                        } catch (Exception e) {
                            callbackContext.error(e.getMessage());
                        }
                    }
                });
            } else if (action.equals("unsubscribeFromTopic")) {
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        try {
                            FirebaseMessaging.getInstance().unsubscribeFromTopic(args.getString(0));
                            callbackContext.success();
                        } catch (Exception e) {
                            callbackContext.error(e.getMessage());
                        }
                    }
                });
            } else if (action.equals("clearAllNotifications")) {
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        try {
                            Context context = cordova.getActivity();
                            NotificationManager nm = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
                            nm.cancelAll();
                            callbackContext.success();
                        } catch (Exception e) {
                            callbackContext.error(e.getMessage());
                        }
                    }
                });
            } else {
                callbackContext.error("Method not found");
                return false;
            }
        } catch (Exception e) {
            Log.d(TAG, "ERROR: onPluginAction: " + e.getMessage());
            callbackContext.error(e.getMessage());
            return false;
        }

        return true;
    }

    public void registerNotification(CallbackContext callbackContext) {
        if (lastPush != null) FCMPlugin.sendPushPayload(lastPush);
        lastPush = null;
        callbackContext.success();
    }

    public void registerNotification(OnFinishedListener<JSONObject> callback) {
        notificationFn = callback;
        if (lastPush != null) FCMPlugin.sendPushPayload(lastPush);
        lastPush = null;
    }

    public void onNotification(OnFinishedListener<JSONObject> callback) {
        this.registerNotification(callback);
    }

    public void getToken(final TokenListeners<String, JSONObject> callback) {
        try {
            FirebaseInstanceId.getInstance().getInstanceId().addOnCompleteListener(new OnCompleteListener<InstanceIdResult>() {
                @Override
                public void onComplete(@NonNull Task<InstanceIdResult> task) {
                    if (!task.isSuccessful()) {
                        Log.w(TAG, "getInstanceId failed", task.getException());
                        try {
                            callback.error(exceptionToJson(task.getException()));
                        }
                        catch (JSONException jsonErr) {
                            Log.e(TAG, "Error when parsing json", jsonErr);
                        }
                        return;
                    }

                    // Get new Instance ID token
                    String newToken = task.getResult().getToken();

                    Log.i(TAG, "\tToken: " + newToken);
                    callback.success(newToken);
                }
            });

            FirebaseInstanceId.getInstance().getInstanceId().addOnFailureListener(new OnFailureListener() {
                @Override
                public void onFailure(@NonNull final Exception e) {
                    try {
                        Log.e(TAG, "Error retrieving token: ", e);
                        callback.error(exceptionToJson(e));
                    } catch (JSONException jsonErr) {
                        Log.e(TAG, "Error when parsing json", jsonErr);
                    }
                }
            });
        } catch (Exception e) {
            Log.d(TAG, "\tError retrieving token", e);
        }
    }

    private JSONObject exceptionToJson(Exception exception) throws JSONException {
        return new JSONObject() {
            {
                put("message", exception.getMessage());
                put("cause", exception.getClass().getName());
                put("stacktrace", exception.getStackTrace().toString());
            }
        };
    }

    public void getToken(final CallbackContext callbackContext) {
        this.getToken(new TokenListeners<String, JSONObject>() {
            @Override
            public void success(String message) {
                callbackContext.success(message);
            }

            @Override
            public void error(JSONObject message) {
                callbackContext.error(message);
            }
        });
    }

    public static void sendPushPayload(Map<String, Object> payload) {
        Log.d(TAG, "==> FCMPlugin sendPushPayload");
        Log.d(TAG, "\tnotificationCallBackReady: " + notificationCallBackReady);
        Log.d(TAG, "\tgWebView: " + gWebView);
        try {
            JSONObject jo = new JSONObject();
            for (String key : payload.keySet()) {
                jo.put(key, payload.get(key));
                Log.d(TAG, "\tpayload: " + key + " => " + payload.get(key));
            }
            String callBack = "javascript:" + notificationCallBack + "(" + jo.toString() + ")";
            if (notificationCallBackReady && gWebView != null) {
                Log.d(TAG, "\tSent PUSH to view: " + callBack);
                gWebView.sendJavascript(callBack);
            } else {
                Log.d(TAG, "\tView not ready. SAVED NOTIFICATION: " + callBack);
                if (notificationFn != null) {
                    notificationFn.success(jo);
                    Log.i(TAG, "\tCalled java callback to get notification: with data:" + jo.toString());
                }

                lastPush = payload;
            }
        } catch (Exception e) {
            Log.d(TAG, "\tERROR sendPushToView. SAVED NOTIFICATION: " + e.getMessage());
            lastPush = payload;
        }
    }

    public static void sendTokenRefresh(String token) {
        Log.d(TAG, "==> FCMPlugin sendRefreshToken");
        try {
            String callBack = "javascript:" + tokenRefreshCallBack + "('" + token + "')";
            gWebView.sendJavascript(callBack);
        } catch (Exception e) {
            Log.d(TAG, "\tERROR sendRefreshToken: " + e.getMessage());
        }
    }

    @Override
    public void onDestroy() {
        gWebView = null;
        notificationCallBackReady = false;
    }

    protected Context getContext() {
        context = cordova != null ? cordova.getActivity().getBaseContext() : context;
        if (context == null) {
            throw new RuntimeException("The Android Context is required. Verify if the 'activity' or 'context' are passed by constructor");
        }

        return context;
    }
}
