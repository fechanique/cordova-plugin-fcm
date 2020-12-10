package com.gae.scaffolder.plugin;

import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.util.Log;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.analytics.FirebaseAnalytics;
import com.google.firebase.dynamiclinks.FirebaseDynamicLinks;
import com.google.firebase.dynamiclinks.PendingDynamicLinkData;
import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.messaging.FirebaseMessaging;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class FCMPlugin extends CordovaPlugin {

  private static final String TAG = "FCMPlugin";

  private FirebaseAnalytics mFirebaseAnalytics;

  private String domainUriPrefix;
  public static String notificationCallBackLink = "FCMPlugin.getDynamicLinkReceived";
  public static Map<String, Object> lastLink = null;

  public static CordovaWebView gWebView;
  public static String notificationCallBack = "FCMPlugin.onNotificationReceived";
  public static String tokenRefreshCallBack = "FCMPlugin.onTokenRefreshReceived";
  public static Boolean notificationCallBackReady = false;
  public static Map<String, Object> lastPush = null;

  public FCMPlugin() {
  }

  public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    final Context context = cordova.getActivity().getApplicationContext();
    super.initialize(cordova, webView);
    gWebView = webView;
    Log.d(TAG, "Initialize");
    FirebaseMessaging.getInstance().subscribeToTopic("android");
    FirebaseMessaging.getInstance().subscribeToTopic("all");
    Log.d(TAG, "Starting Analytics");
    mFirebaseAnalytics = FirebaseAnalytics.getInstance(context);

    domainUriPrefix = preferences.getString("DYNAMIC_LINK_URIPREFIX", "");
    Log.d(TAG, "Dynamic Link Uri Prefix: " + domainUriPrefix);

    cordova.getThreadPool().execute(new Runnable() {
      public void run() {
        Log.d(TAG, "Check if there are notifications");
        Bundle extras = cordova.getActivity().getIntent().getExtras();
        if (extras != null && extras.size() > 1) {
          if (extras.containsKey("google.message_id")) {
            Log.d(TAG, "Set wasTapped true (app was closed)");
            extras.putString("wasTapped", "true");
            Map<String, Object> data = new HashMap<String, Object>();
            for (String key : extras.keySet()) {
              if (extras.get(key) instanceof String) {
                String value = extras.getString(key);
                data.put(key, value);
              }
            }
            FCMPlugin.sendPushPayload(data);
          }
        }
      }
    });
  }

  public boolean execute(final String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {

    Log.d(TAG, "Execute: " + action);

    try {
      // READY //
      if (action.equals("ready")) {
        callbackContext.success();
      }
      // GET TOKEN //
      else if (action.equals("getToken")) {
        cordova.getActivity().runOnUiThread(new Runnable() {
          public void run() {
            try {
              String token = FirebaseInstanceId.getInstance().getToken();
              callbackContext.success(FirebaseInstanceId.getInstance().getToken());
              Log.d(TAG, "Token: " + token);
            } catch (Exception e) {
              Log.d(TAG, "Error retrieving token");
            }
          }
        });
      }
      // NOTIFICATION CALLBACK REGISTER //
      else if (action.equals("registerNotification")) {
        notificationCallBackReady = true;
        cordova.getActivity().runOnUiThread(new Runnable() {
          public void run() {
            if (lastLink != null) FCMPlugin.sendDynLink(lastLink);
            lastLink = null;
            if (lastPush != null) FCMPlugin.sendPushPayload(lastPush);
            lastPush = null;
            callbackContext.success();
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
      } else if (action.equals("logEvent")) {
        cordova.getThreadPool().execute(new Runnable() {
          public void run() {
            try {
              logEvent(callbackContext, args.getString(0), args.getJSONObject(1));
              callbackContext.success();
            } catch (Exception e) {
              callbackContext.error(e.getMessage());
            }
          }
        });
      } else if (action.equals("setUserId")) {
        cordova.getThreadPool().execute(new Runnable() {
          public void run() {
            try {
              setUserId(callbackContext, args.getString(0));
              callbackContext.success();
            } catch (Exception e) {
              callbackContext.error(e.getMessage());
            }
          }
        });
      } else if (action.equals("setUserProperty")) {
        cordova.getThreadPool().execute(new Runnable() {
          public void run() {
            try {
              setUserProperty(callbackContext, args.getString(0), args.getString(1));
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
              clearAllNotifications(callbackContext);
              callbackContext.success();
            } catch (Exception e) {
              callbackContext.error(e.getMessage());
            }
          }
        });
      } else if (action.equals("getDynamicLink")) {
        cordova.getThreadPool().execute(new Runnable() {
          public void run() {
            try {
              getDynamicLink();
              callbackContext.success();
            } catch (Exception e) {
              callbackContext.error(e.getMessage());
            }
          }
        });
      } else {
        callbackContext.error("Error: method not found");
        return false;
      }
    } catch (Exception e) {
      Log.d(TAG, "Error: onPluginAction: " + e.getMessage());
      callbackContext.error(e.getMessage());
      return false;
    }
    return true;
  }

  public static void sendDynLink(Map<String, Object> dynlink) {
    Log.d(TAG, "sendDynLink");
    try {
      JSONObject jo = new JSONObject();
      for (String key : dynlink.keySet()) {
        jo.put(key, dynlink.get(key));
      }
      String callBack = "javascript:" + notificationCallBackLink + "(" + jo.toString() + ")";
      if (notificationCallBackReady && gWebView != null) {
        Log.d(TAG, "Dynamic Link to view: " + callBack);
        gWebView.sendJavascript(callBack);
      } else {
        Log.d(TAG, "View not ready. Dynamic Link saved: " + callBack);
        lastLink = dynlink;
      }
    } catch (Exception e) {
      Log.d(TAG, "Error: sendDynLink:Exception", e);
      lastLink = dynlink;
    }
  }

  public static void sendPushPayload(Map<String, Object> payload) {
    Log.d(TAG, "sendPushPayload");
    try {
      JSONObject jo = new JSONObject();
      for (String key : payload.keySet()) {
        jo.put(key, payload.get(key));
      }
      String callBack = "javascript:" + notificationCallBack + "(" + jo.toString() + ")";
      if (notificationCallBackReady && gWebView != null) {
        Log.d(TAG, "Sent Push Notification to view: " + callBack);
        gWebView.sendJavascript(callBack);
      } else {
        Log.d(TAG, "View not ready. Push Notification saved: " + callBack);
        lastPush = payload;
      }
    } catch (Exception e) {
      Log.d(TAG, "Error: sendPushToView. Push Notification saved: " + e.getMessage());
      lastPush = payload;
    }
  }

  public static void sendTokenRefresh(String token) {
    Log.d(TAG, "sendRefreshToken");
    try {
      String callBack = "javascript:" + tokenRefreshCallBack + "('" + token + "')";
      gWebView.sendJavascript(callBack);
    } catch (Exception e) {
      Log.d(TAG, "Error: sendRefreshToken: " + e.getMessage());
    }
  }

  public void logEvent(final CallbackContext callbackContext, final String name, final JSONObject params)
    throws JSONException {
    final Bundle bundle = new Bundle();
    Iterator iter = params.keys();
    while (iter.hasNext()) {
      String key = (String) iter.next();
      Object value = params.get(key);

      if (value instanceof Integer || value instanceof Double) {
        bundle.putFloat(key, ((Number) value).floatValue());
      } else {
        bundle.putString(key, value.toString());
      }
    }

    cordova.getThreadPool().execute(new Runnable() {
      public void run() {
        try {
          mFirebaseAnalytics.logEvent(name, bundle);
          callbackContext.success();
        } catch (Exception e) {
          callbackContext.error(e.getMessage());
        }
      }
    });
  }

  public void setUserId(final CallbackContext callbackContext, final String id) {
    cordova.getThreadPool().execute(new Runnable() {
      public void run() {
        try {
          mFirebaseAnalytics.setUserId(id);
          callbackContext.success();
        } catch (Exception e) {
          callbackContext.error(e.getMessage());
        }
      }
    });
  }

  public void setUserProperty(final CallbackContext callbackContext, final String name, final String value) {
    cordova.getThreadPool().execute(new Runnable() {
      public void run() {
        try {
          mFirebaseAnalytics.setUserProperty(name, value);
          callbackContext.success();
        } catch (Exception e) {
          callbackContext.error(e.getMessage());
        }
      }
    });
  }

  public void clearAllNotifications(final CallbackContext callbackContext) {
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
  }

  private void getDynamicLink() {
    respondWithDynamicLink(cordova.getActivity().getIntent());
  }

  // App opened from Play Store (new installation)
  private void respondWithDynamicLink(Intent intent) {
    Log.d(TAG, "respondWithDynamicLink");
    FirebaseDynamicLinks.getInstance()
      .getDynamicLink(intent)
      .addOnSuccessListener(new OnSuccessListener<PendingDynamicLinkData>() {
        @Override
        public void onSuccess(PendingDynamicLinkData pendingDynamicLinkData) {
          Uri deepLink = null;
          if (pendingDynamicLinkData != null) {
            deepLink = pendingDynamicLinkData.getLink();
            if (deepLink != null) {
              Map<String, Object> linkData = new HashMap<String, Object>();
              linkData.put("deepLink", deepLink);
              linkData.put("clickTimestamp", pendingDynamicLinkData.getClickTimestamp());
              linkData.put("minimumAppVersion", pendingDynamicLinkData.getMinimumAppVersion());
              linkData.put("newInstall", true); // Send attribute to identify new install
              FCMPlugin.sendDynLink(linkData);
            }
          }
        }
      })
      .addOnFailureListener(new OnFailureListener() {
        @Override
        public void onFailure(@NonNull Exception e) {
          Log.d(TAG, "Error: respondWithDynamicLink:addOnFailureListener", e);
        }
      });
  }

  @Override
  public void onDestroy() {
    gWebView = null;
    notificationCallBackReady = false;
  }

  @Override
  public void onNewIntent(Intent intent) {
    super.onNewIntent(intent);
    final Bundle extras = intent.getExtras();
    Log.d(TAG, "onNewIntent (App is running in Background)");

    Map<String, Object> data = new HashMap<String, Object>();
    if (extras != null) {
      Log.d(TAG, "Set wasTapped true");
      data.put("wasTapped", true);
      for (String key : extras.keySet()) {
        if (extras.get(key) instanceof String) {
          String value = extras.getString(key);
          data.put(key, value);
        }
      }
      FCMPlugin.sendPushPayload(data);
    }
  }
}
