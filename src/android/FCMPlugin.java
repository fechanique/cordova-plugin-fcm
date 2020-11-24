package com.gae.scaffolder.plugin;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaInterface;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Bundle;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.analytics.FirebaseAnalytics;

import java.util.HashMap;
import java.util.Map;
import java.util.Iterator;

// Dynamic Link
import android.net.Uri;

import com.google.android.gms.tasks.Continuation;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;

import com.google.firebase.dynamiclinks.DynamicLink;
import com.google.firebase.dynamiclinks.DynamicLink.AndroidParameters;
import com.google.firebase.dynamiclinks.DynamicLink.GoogleAnalyticsParameters;
import com.google.firebase.dynamiclinks.DynamicLink.IosParameters;
import com.google.firebase.dynamiclinks.DynamicLink.ItunesConnectAnalyticsParameters;
import com.google.firebase.dynamiclinks.DynamicLink.NavigationInfoParameters;
import com.google.firebase.dynamiclinks.DynamicLink.SocialMetaTagParameters;

import com.google.firebase.dynamiclinks.FirebaseDynamicLinks;
import com.google.firebase.dynamiclinks.ShortDynamicLink;
import com.google.firebase.dynamiclinks.PendingDynamicLinkData;

import org.apache.cordova.PluginResult;

public class FCMPlugin extends CordovaPlugin {
 
	private static final String TAG = "FCMPlugin";

  private FirebaseAnalytics mFirebaseAnalytics;

  private FirebaseDynamicLinks firebaseDynamicLinks;
  private String domainUriPrefix;
  private CallbackContext dynamicLinkCallback;
	
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
                    Log.d(TAG, "==> FCMPlugin Starting Analytics");
                    mFirebaseAnalytics = FirebaseAnalytics.getInstance(context);

                    Log.d(TAG, "==> FCMPlugin Starting DynamicLink");
                    firebaseDynamicLinks = FirebaseDynamicLinks.getInstance();
                    domainUriPrefix = preferences.getString("DYNAMIC_LINK_URIPREFIX", "");
                    Log.d(TAG, "==> FCMPlugin domainUriPrefix: " + domainUriPrefix);

                    Log.d(TAG, "==> Check if there are notifications");
                    Bundle extras = cordova.getActivity().getIntent().getExtras();
                    if (extras != null && extras.size() > 1) {
                      if (extras.containsKey("google.message_id")) {
                        Log.d(TAG, "==> Set wasTapped true (closed app)");
                        extras.putString("wasTapped", "true");
                        Map<String, Object> data = new HashMap<String, Object>();
                        for (String key : extras.keySet()) {
                          if (extras.get(key) instanceof String) {
                            String value = extras.getString(key);
                            Log.d(TAG, "\tKey: " + key + " Value: " + value);
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
      else if (action.equals("onDynamicLink")) {
        cordova.getActivity().runOnUiThread(new Runnable() {
          public void run() {
            try{
              onDynamicLink(callbackContext);
              callbackContext.success();
            }catch(Exception e){
              callbackContext.error(e.getMessage());
            }
          }
        });
      }
      else if (action.equals("getDynamicLink")) {
        cordova.getThreadPool().execute(new Runnable() {
          public void run() {
            try{
              getDynamicLink(callbackContext);
              callbackContext.success();
            }catch(Exception e){
              callbackContext.error(e.getMessage());
            }
          }
        });
      }
      else if (action.equals("createDynamicLink")) {
        cordova.getThreadPool().execute(new Runnable() {
          public void run() {
            try{
              createDynamicLink(args.getJSONObject(0), args.getInt(1), callbackContext);
              callbackContext.success();
            }catch(Exception e){
              callbackContext.error(e.getMessage());
            }
          }
        });
      }
			else {
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

  private void getDynamicLink(CallbackContext callbackContext) {
    respondWithDynamicLink(cordova.getActivity().getIntent(), callbackContext);
  }

  private void onDynamicLink(CallbackContext callbackContext) {
    dynamicLinkCallback = callbackContext;
  }

  private void createDynamicLink(JSONObject params, int linkType, final CallbackContext callbackContext) throws JSONException {
    DynamicLink.Builder builder = createDynamicLinkBuilder(params);
    if (linkType == 0) {
      callbackContext.success(builder.buildDynamicLink().getUri().toString());
    } else {
      builder.buildShortDynamicLink(linkType)
        .addOnCompleteListener(cordova.getActivity(), new OnCompleteListener<ShortDynamicLink>() {
          @Override
          public void onComplete(Task<ShortDynamicLink> task) {
            if (task.isSuccessful()) {
              callbackContext.success(task.getResult().getShortLink().toString());
            } else {
              callbackContext.error(task.getException().getMessage());
            }
          }
        });
    }
  }

  private void respondWithDynamicLink(Intent intent, final CallbackContext callbackContext) {
    firebaseDynamicLinks.getDynamicLink(intent)
      .continueWith(new Continuation<PendingDynamicLinkData, JSONObject>() {
        @Override
        public JSONObject then(Task<PendingDynamicLinkData> task) throws JSONException {
          PendingDynamicLinkData data = task.getResult();
          Log.d(TAG, "==> FCMPlugin Link DATA: " + data.getLink());

          JSONObject result = new JSONObject();
          result.put("deepLink", data.getLink());
          result.put("clickTimestamp", data.getClickTimestamp());
          result.put("minimumAppVersion", data.getMinimumAppVersion());

          if (callbackContext != null) {
            PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, result);
            pluginResult.setKeepCallback(callbackContext == dynamicLinkCallback);
            callbackContext.sendPluginResult(pluginResult);
          }

          return result;
        }
      })
      .addOnFailureListener(new OnFailureListener() {
        @Override
        public void onFailure(Exception e) {
          if (callbackContext != null && callbackContext != dynamicLinkCallback) {
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, (String)null));
          }
        }
      });
  }

  private DynamicLink.Builder createDynamicLinkBuilder(JSONObject params) throws JSONException {
    DynamicLink.Builder builder = firebaseDynamicLinks.createDynamicLink();
    builder.setDomainUriPrefix(params.optString("domainUriPrefix", domainUriPrefix));
    builder.setLink(Uri.parse(params.getString("link")));

    JSONObject androidInfo = params.optJSONObject("androidInfo");
    if (androidInfo != null) {
      builder.setAndroidParameters(getAndroidParameters(androidInfo));
    }

    JSONObject iosInfo = params.optJSONObject("iosInfo");
    if (iosInfo != null) {
      builder.setIosParameters(getIosParameters(iosInfo));
    }

    JSONObject navigationInfo = params.optJSONObject("navigationInfo");
    if (navigationInfo != null) {
      builder.setNavigationInfoParameters(getNavigationInfoParameters(navigationInfo));
    }

    JSONObject analyticsInfo = params.optJSONObject("analyticsInfo");
    if (analyticsInfo != null) {
      JSONObject googlePlayAnalyticsInfo = analyticsInfo.optJSONObject("googlePlayAnalytics");
      if (googlePlayAnalyticsInfo != null) {
        builder.setGoogleAnalyticsParameters(getGoogleAnalyticsParameters(googlePlayAnalyticsInfo));
      }
      JSONObject itunesConnectAnalyticsInfo = analyticsInfo.optJSONObject("itunesConnectAnalytics");
      if (itunesConnectAnalyticsInfo != null) {
        builder.setItunesConnectAnalyticsParameters(getItunesConnectAnalyticsParameters(itunesConnectAnalyticsInfo));
      }
    }

    JSONObject socialMetaTagInfo = params.optJSONObject("socialMetaTagInfo");
    if (socialMetaTagInfo != null) {
      builder.setSocialMetaTagParameters(getSocialMetaTagParameters(socialMetaTagInfo));
    }

    return builder;
  }

  private AndroidParameters getAndroidParameters(JSONObject androidInfo) throws JSONException {
    AndroidParameters.Builder androidInfoBuilder;
    if (androidInfo.has("androidPackageName")) {
      androidInfoBuilder = new AndroidParameters.Builder(androidInfo.getString("androidPackageName"));
    } else {
      androidInfoBuilder = new AndroidParameters.Builder();
    }
    if (androidInfo.has("androidFallbackLink")) {
      androidInfoBuilder.setFallbackUrl(Uri.parse(androidInfo.getString("androidFallbackLink")));
    }
    if (androidInfo.has("androidMinPackageVersionCode")) {
      androidInfoBuilder.setMinimumVersion(androidInfo.getInt("androidMinPackageVersionCode"));
    }
    return androidInfoBuilder.build();
  }

  private IosParameters getIosParameters(JSONObject iosInfo) throws JSONException {
    IosParameters.Builder iosInfoBuilder = new IosParameters.Builder(iosInfo.getString("iosBundleId"));
    iosInfoBuilder.setAppStoreId(iosInfo.optString("iosAppStoreId"));
    iosInfoBuilder.setIpadBundleId(iosInfo.optString("iosIpadBundleId"));
    iosInfoBuilder.setMinimumVersion(iosInfo.optString("iosMinPackageVersion"));
    if (iosInfo.has("iosFallbackLink")) {
      iosInfoBuilder.setFallbackUrl(Uri.parse(iosInfo.getString("iosFallbackLink")));
    }
    if (iosInfo.has("iosIpadFallbackLink")) {
      iosInfoBuilder.setIpadFallbackUrl(Uri.parse(iosInfo.getString("iosIpadFallbackLink")));
    }
    return iosInfoBuilder.build();
  }

  private NavigationInfoParameters getNavigationInfoParameters(JSONObject navigationInfo) throws JSONException {
    NavigationInfoParameters.Builder navigationInfoBuilder = new NavigationInfoParameters.Builder();
    if (navigationInfo.has("enableForcedRedirect")) {
      navigationInfoBuilder.setForcedRedirectEnabled(navigationInfo.getBoolean("enableForcedRedirect"));
    }
    return navigationInfoBuilder.build();
  }

  private GoogleAnalyticsParameters getGoogleAnalyticsParameters(JSONObject googlePlayAnalyticsInfo) {
    GoogleAnalyticsParameters.Builder gaInfoBuilder = new GoogleAnalyticsParameters.Builder();
    gaInfoBuilder.setSource(googlePlayAnalyticsInfo.optString("utmSource"));
    gaInfoBuilder.setMedium(googlePlayAnalyticsInfo.optString("utmMedium"));
    gaInfoBuilder.setCampaign(googlePlayAnalyticsInfo.optString("utmCampaign"));
    gaInfoBuilder.setContent(googlePlayAnalyticsInfo.optString("utmContent"));
    gaInfoBuilder.setTerm(googlePlayAnalyticsInfo.optString("utmTerm"));
    return gaInfoBuilder.build();
  }

  private ItunesConnectAnalyticsParameters getItunesConnectAnalyticsParameters(JSONObject itunesConnectAnalyticsInfo) {
    ItunesConnectAnalyticsParameters.Builder iosAnalyticsInfo = new ItunesConnectAnalyticsParameters.Builder();
    iosAnalyticsInfo.setAffiliateToken(itunesConnectAnalyticsInfo.optString("at"));
    iosAnalyticsInfo.setCampaignToken(itunesConnectAnalyticsInfo.optString("ct"));
    iosAnalyticsInfo.setProviderToken(itunesConnectAnalyticsInfo.optString("pt"));
    return iosAnalyticsInfo.build();
  }

  private SocialMetaTagParameters getSocialMetaTagParameters(JSONObject socialMetaTagInfo) throws JSONException {
    SocialMetaTagParameters.Builder socialInfoBuilder = new SocialMetaTagParameters.Builder();
    socialInfoBuilder.setTitle(socialMetaTagInfo.optString("socialTitle"));
    socialInfoBuilder.setDescription(socialMetaTagInfo.optString("socialDescription"));
    if (socialMetaTagInfo.has("socialImageLink")) {
      socialInfoBuilder.setImageUrl(Uri.parse(socialMetaTagInfo.getString("socialImageLink")));
    }
    return socialInfoBuilder.build();
  }
  
  @Override
	public void onDestroy() {
		gWebView = null;
		notificationCallBackReady = false;
	}

  @Override public void onNewIntent(Intent intent) {
    super.onNewIntent(intent);
    final Bundle extras = intent.getExtras();
    Log.d(TAG, "==> FCMPlugin onNewIntent (App is running in Background)");
    if (dynamicLinkCallback != null) {
      respondWithDynamicLink(intent, dynamicLinkCallback);
    }
    Map<String, Object> data = new HashMap<String, Object>();
    if (extras != null) {
      Log.d(TAG, "==> FCMPlugin Set wasTapped true");
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
