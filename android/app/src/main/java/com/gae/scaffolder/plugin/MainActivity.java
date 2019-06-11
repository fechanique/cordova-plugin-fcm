package com.gae.scaffolder.plugin;

import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import com.gae.scaffolder.plugin.interfaces.OnFinishedListener;
import com.gae.scaffolder.plugin.interfaces.TokenListeners;

import org.json.JSONObject;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        final FCMPlugin fcm = FCMPlugin.getInstance(getBaseContext());
        TokenListeners tokenResults = new TokenListeners<String, JSONObject>() {
            @Override
            public void success(String message) {
                Toast.makeText(MainActivity.this, message, Toast.LENGTH_LONG).show();
            }

            @Override
            public void error(JSONObject message) {

            }
        };

        fcm.getToken(tokenResults);

        fcm.onNotification(new OnFinishedListener<JSONObject>() {
            @Override
            public void success(@NonNull JSONObject jsonObject) {
                Log.i(fcm.getClass().getName(), jsonObject.toString());
            }
        });
    }
}
