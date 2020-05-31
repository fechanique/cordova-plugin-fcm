package com.gae.scaffolder.plugin;

import android.app.NotificationManager;
import android.content.Context;
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
    public static String notificationEventName = "notification";
    public static String tokenRefreshEventName = "tokenRefresh";
    public static Map<String, Object> initialPushPayload = null;

    protected Context context = null;
    public static final String TAG = "FCMPlugin";
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
            // GET INITIAL PUSH PAYLOAD //
            else if (action.equals("getInitialPushPayload")) {
                cordova.getActivity().runOnUiThread(new Runnable() {
                    public void run() {
                        getInitialPushPayload(callbackContext);
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
            } else if (action.equals("createNotificationChannel")) {
                cordova.getActivity().runOnUiThread(new Runnable() {
                    public void run() {
                        new FCMPluginChannelCreator(getContext()).createNotificationChannel(callbackContext, args);
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

    public void getInitialPushPayload(CallbackContext callback) {
        if(initialPushPayload == null) {
            Log.d(TAG, "getInitialPushPayload: null");
            callback.success((String) null);
            return;
        }
        Log.d(TAG, "getInitialPushPayload");
        try {
            JSONObject jo = new JSONObject();
            for (String key : initialPushPayload.keySet()) {
                jo.put(key, initialPushPayload.get(key));
                Log.d(TAG, "\tinitialPushPayload: " + key + " => " + initialPushPayload.get(key));
            }
            callback.success(jo);
        } catch(Exception error) {
            try {
                callback.error(exceptionToJson(error));
            }
            catch (JSONException jsonErr) {
                Log.e(TAG, "Error when parsing json", jsonErr);
            }
        }
    }

    public void getToken(final TokenListeners<String, JSONObject> callback) {
        try {
            FirebaseInstanceId.getInstance().getInstanceId().addOnCompleteListener(new OnCompleteListener<InstanceIdResult>() {
                @Override
                public void onComplete(Task<InstanceIdResult> task) {
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
                public void onFailure(final Exception e) {
                    try {
                        Log.e(TAG, "Error retrieving token: ", e);
                        callback.error(exceptionToJson(e));
                    } catch (JSONException jsonErr) {
                        Log.e(TAG, "Error when parsing json", jsonErr);
                    }
                }
            });
        } catch (Exception e) {
            Log.w(TAG, "\tError retrieving token", e);
            try {
                callback.error(exceptionToJson(e));
            } catch(JSONException je) {}
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

    private static void dispatchJSEvent(String eventName, String jsData) throws Exception {
        if (gWebView == null) {
            throw new Exception("gWebView not available");
        }
        String callBack = "javascript:window.FCM.events.dispatchEvent(new CustomEvent(\"" + eventName + "\",{detail:" + jsData + "}))";
        Log.d(TAG, "\tSent event: " + eventName + " with " + jsData);
        gWebView.sendJavascript(callBack);
    }

    public static void sendPushPayload(Map<String, Object> payload) {
        Log.d(TAG, "==> FCMPlugin sendPushPayload");
        Log.d(TAG, "\tgWebView: " + gWebView);
        try {
            JSONObject jo = new JSONObject();
            for (String key : payload.keySet()) {
                jo.put(key, payload.get(key));
                Log.d(TAG, "\tpayload: " + key + " => " + payload.get(key));
            }
            FCMPlugin.dispatchJSEvent(notificationEventName, jo.toString());
        } catch (Exception e) {
            Log.d(TAG, "\tERROR sendPushPayload: " + e.getMessage());
            if(initialPushPayload == null) {
                initialPushPayload = payload;
            }
        }
    }

    public static void sendTokenRefresh(String token) {
        Log.d(TAG, "==> FCMPlugin sendTokenRefresh");
        try {
            FCMPlugin.dispatchJSEvent(tokenRefreshEventName, "\"" + token + "\"");
        } catch (Exception e) {
            Log.d(TAG, "\tERROR sendTokenRefresh: " + e.getMessage());
        }
    }

    @Override
    public void onDestroy() {
        initialPushPayload = null;
        gWebView = null;
    }

    protected Context getContext() {
        context = cordova != null ? cordova.getActivity().getBaseContext() : context;
        if (context == null) {
            throw new RuntimeException("The Android Context is required. Verify if the 'activity' or 'context' are passed by constructor");
        }

        return context;
    }
}
