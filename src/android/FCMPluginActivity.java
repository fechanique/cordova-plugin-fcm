package com.gae.scaffolder.plugin;

import android.app.Activity;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.util.Log;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.dynamiclinks.FirebaseDynamicLinks;
import com.google.firebase.dynamiclinks.PendingDynamicLinkData;

import java.util.HashMap;
import java.util.Map;

public class FCMPluginActivity extends Activity {
  private static String TAG = "FCMPluginActivity";

  /*
   * this activity will be started if the user touches a notification that we own.
   * We send it's data off to the push plugin for processing.
   * If needed, we boot up the main activity to kickstart the application.
   * @see android.app.Activity#onCreate(android.os.Bundle)
   */
  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    Log.d(TAG, "onCreate");

    /*
     * Handle deepLink (app closed/background)
     */
    FirebaseDynamicLinks.getInstance()
      .getDynamicLink(getIntent())
      .addOnSuccessListener(this, new OnSuccessListener<PendingDynamicLinkData>() {
        @Override
        public void onSuccess(PendingDynamicLinkData pendingDynamicLinkData) {
          Uri deepLink = null;
          if (pendingDynamicLinkData != null) {
            deepLink = pendingDynamicLinkData.getLink();
          }
          if (deepLink != null) {
            Log.d(TAG, "getDynamicLink:onSuccess -> " + deepLink);
            Map<String, Object> linkData = new HashMap<String, Object>();
            linkData.put("deepLink", deepLink);
            linkData.put("clickTimestamp", pendingDynamicLinkData.getClickTimestamp());
            linkData.put("minimumAppVersion", pendingDynamicLinkData.getMinimumAppVersion());
            FCMPlugin.sendDynLink(linkData);
          }
        }
      })
      .addOnFailureListener(this, new OnFailureListener() {
        @Override
        public void onFailure(@NonNull Exception e) {
          Log.d(TAG, "Error: getDynamicLink:onFailure", e);
        }
      });

    /*
     * Open received push notification.
     * Note: Dynamic Links are considerate as notification when app is closed
     */
    if (getIntent().getExtras() != null) {
      Map<String, Object> data = new HashMap<String, Object>();
      for (String key : getIntent().getExtras().keySet()) {
        String value = getIntent().getExtras().getString(key);
        data.put(key, value);
      }
      // Tapped from notification center
      if (!data.containsKey("com.android.browser.application_id")) {
        Log.d(TAG, "User tapped notification");
        data.put("wasTapped", true);
        FCMPlugin.sendPushPayload(data);
      }
    }

    finish();
    forceMainActivityReload();
  }

  private void forceMainActivityReload() {
    PackageManager pm = getPackageManager();
    Intent launchIntent = pm.getLaunchIntentForPackage(getApplicationContext().getPackageName());
    startActivity(launchIntent);
  }

  @Override
  protected void onResume() {
    super.onResume();
    Log.d(TAG, "onResume");
    final NotificationManager notificationManager = (NotificationManager) this.getSystemService(Context.NOTIFICATION_SERVICE);
    notificationManager.cancelAll();
  }

  @Override
  public void onStart() {
    super.onStart();
    Log.d(TAG, "onStart");
  }

  @Override
  public void onStop() {
    super.onStop();
    Log.d(TAG, "onStop");
  }

}
