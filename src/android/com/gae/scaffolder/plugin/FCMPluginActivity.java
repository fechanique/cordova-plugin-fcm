package com.gae.scaffolder.plugin;

import android.app.Activity;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;

public class FCMPluginActivity extends Activity {
    private static String TAG = "FCMPlugin";

    /*
     * this activity will be started if the user touches a notification that we own.
     * We send it's data off to the push plugin for processing.
     * If needed, we boot up the main activity to kickstart the application.
     * @see android.app.Activity#onCreate(android.os.Bundle)
     */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "==> FCMPluginActivity onCreate");
        this.sendPushPayload();
        finish();
        forceMainActivityReload();
    }

    private void sendPushPayload() {
        Bundle intentExtras = getIntent().getExtras();
        if(intentExtras == null) {
            return;
        }
        Log.d(TAG, "==> USER TAPPED NOTIFICATION");
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("wasTapped", true);
        for (String key : intentExtras.keySet()) {
            Object value = intentExtras.get(key);
            Log.d(TAG, "\tKey: " + key + " Value: " + value);
            data.put(key, value);
        }
        FCMPlugin.setInitialPushPayload(data);
        FCMPlugin.sendPushPayload(data);
    }

    private void forceMainActivityReload() {
        PackageManager pm = getPackageManager();
        Intent launchIntent = pm.getLaunchIntentForPackage(getApplicationContext().getPackageName());
        startActivity(launchIntent);
    }

    @Override
    protected void onResume() {
        super.onResume();
        Log.d(TAG, "==> FCMPluginActivity onResume");
        final NotificationManager notificationManager = (NotificationManager) this.getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.cancelAll();
    }

    @Override
    public void onStart() {
        super.onStart();
        Log.d(TAG, "==> FCMPluginActivity onStart");
    }

    @Override
    public void onStop() {
        super.onStop();
        Log.d(TAG, "==> FCMPluginActivity onStop");
    }

}