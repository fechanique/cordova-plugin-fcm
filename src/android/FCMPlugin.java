package com.gae.scaffolder.plugin;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaInterface;
import android.app.NotificationManager;
import android.content.Context;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Bundle;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.analytics.FirebaseAnalytics;

import java.util.Map;
import java.util.Iterator;

public class FCMPlugin extends CordovaPlugin {
 
	private static final String TAG = "FCMPlugin";

        private FirebaseAnalytics mFirebaseAnalytics;
	
	public static CordovaWebView gWebView;
	public static String notificationCallBack = "FCMPlugin.onNotificationReceived";
	public static String tokenRefreshCallBack = "FCMPlugin.onTokenRefreshReceived";
	public static Boolean notificationCallBackReady = false;
	public static Map<String, Object> lastPush = null;
	 
	public FCMPlugin() {}
	
	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
                final Context context = cordova.getActivity().getApplicationContext();
		super.initialize(cordova, webView);
		gWebView = webView;
		Log.d(TAG, "==> FCMPlugin initialize");
		FirebaseMessaging.getInstance().subscribeToTopic("android");
		FirebaseMessaging.getInstance().subscribeToTopic("all");
                cordova.getThreadPool().execute(new Runnable() {
                  public void run() {
                    Log.d(TAG, "Starting Analytics");
                    mFirebaseAnalytics = FirebaseAnalytics.getInstance(context);
                  }
                });
        }
	 
	public boolean execute(final String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {

		Log.d(TAG,"==> FCMPlugin execute: "+ action);
		
		try{
			// READY //
			if (action.equals("ready")) {
				//
				callbackContext.success();
			}
			// GET TOKEN //
			else if (action.equals("getToken")) {
				cordova.getActivity().runOnUiThread(new Runnable() {
					public void run() {
						try{
							String token = FirebaseInstanceId.getInstance().getToken();
							callbackContext.success( FirebaseInstanceId.getInstance().getToken() );
							Log.d(TAG,"\tToken: "+ token);
						}catch(Exception e){
							Log.d(TAG,"\tError retrieving token");
						}
					}
				});
			}
			// NOTIFICATION CALLBACK REGISTER //
			else if (action.equals("registerNotification")) {
				notificationCallBackReady = true;
				cordova.getActivity().runOnUiThread(new Runnable() {
					public void run() {
						if(lastPush != null) FCMPlugin.sendPushPayload( lastPush );
						lastPush = null;
						callbackContext.success();
					}
				});
			}
			// UN/SUBSCRIBE TOPICS //
			else if (action.equals("subscribeToTopic")) {
				cordova.getThreadPool().execute(new Runnable() {
					public void run() {
						try{
							FirebaseMessaging.getInstance().subscribeToTopic( args.getString(0) );
							callbackContext.success();
						}catch(Exception e){
							callbackContext.error(e.getMessage());
						}
					}
				});
			}
			else if (action.equals("unsubscribeFromTopic")) {
				cordova.getThreadPool().execute(new Runnable() {
					public void run() {
						try{
							FirebaseMessaging.getInstance().unsubscribeFromTopic( args.getString(0) );
							callbackContext.success();
						}catch(Exception e){
							callbackContext.error(e.getMessage());
						}
					}
				});
			}
                        else if (action.equals("logEvent")) {
				cordova.getThreadPool().execute(new Runnable() {
					public void run() {
						try{
                                                  logEvent(callbackContext, args.getString(0), args.getJSONObject(1));
							callbackContext.success();
						}catch(Exception e){
							callbackContext.error(e.getMessage());
						}
					}
				});
                        }
                        else if (action.equals("setUserId")) {
				cordova.getThreadPool().execute(new Runnable() {
					public void run() {
						try{
                                                  setUserId(callbackContext, args.getString(0));
							callbackContext.success();
						}catch(Exception e){
							callbackContext.error(e.getMessage());
						}
					}
				});
			}
                        else if (action.equals("setUserProperty")) {
				cordova.getThreadPool().execute(new Runnable() {
					public void run() {
						try{
                                                  setUserProperty(callbackContext, args.getString(0), args.getString(1));
							callbackContext.success();
						}catch(Exception e){
							callbackContext.error(e.getMessage());
						}
					}
				});
			}
                        else if (action.equals("clearAllNotifications")) {
				cordova.getThreadPool().execute(new Runnable() {
					public void run() {
						try{
                                                  clearAllNotifications(callbackContext);
							callbackContext.success();
						}catch(Exception e){
							callbackContext.error(e.getMessage());
						}
					}
				});
			}
			else{
				callbackContext.error("Method not found");
				return false;
			}
		}catch(Exception e){
			Log.d(TAG, "ERROR: onPluginAction: " + e.getMessage());
			callbackContext.error(e.getMessage());
			return false;
		}
		
		//cordova.getThreadPool().execute(new Runnable() {
		//	public void run() {
		//	  //
		//	}
		//});
		
		//cordova.getActivity().runOnUiThread(new Runnable() {
        //    public void run() {
        //      //
        //    }
        //});
		return true;
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
			if(notificationCallBackReady && gWebView != null){
				Log.d(TAG, "\tSent PUSH to view: " + callBack);
				gWebView.sendJavascript(callBack);
			}else {
				Log.d(TAG, "\tView not ready. SAVED NOTIFICATION: " + callBack);
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
  
  @Override
	public void onDestroy() {
		gWebView = null;
		notificationCallBackReady = false;
	}
} 
