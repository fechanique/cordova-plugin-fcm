package com.gae.scaffolder.plugin;

import android.arch.lifecycle.Observer;
import android.arch.lifecycle.ViewModelProviders;
import android.databinding.DataBindingUtil;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.view.View;

import com.gae.scaffolder.plugin.databinding.ActivityMainBinding;
import com.gae.scaffolder.plugin.interfaces.OnFinishedListener;
import com.gae.scaffolder.plugin.interfaces.TokenListeners;

import org.json.JSONObject;

public class MainActivity extends AppCompatActivity {

    private TokenListeners tokenResults;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        final ActivityMainBinding binding = DataBindingUtil.setContentView(this, R.layout.activity_main);
        final NotificationModel model = ViewModelProviders.of(this).get(NotificationModel.class);

        binding.setNotificationModel(model);
        binding.setLifecycleOwner(this);

        observeLiveData(binding, model);

        final FCMPlugin fcm = FCMPlugin.getInstance(getBaseContext());
        tokenResults = new TokenListeners<String, JSONObject>() {
            @Override
            public void success(String token) {
                model.token.setValue(token);
            }

            @Override
            public void error(JSONObject error) {

                Snackbar.make(binding.getRoot(), error.optString("message"), Snackbar.LENGTH_INDEFINITE)
                        .setAction("TRY AGAIN", new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                fcm.getToken(tokenResults);
                            }
                        }).show();
            }
        };

        fcm.getToken(tokenResults);

        fcm.onNotification(new OnFinishedListener<JSONObject>() {
            @Override
            public void success(@NonNull JSONObject data) {
                model.messageData.postValue(data);
            }
        });
    }

    protected void observeLiveData(final ActivityMainBinding binding, NotificationModel model) {

        model.messageData.observe(this, new Observer<JSONObject>() {
            @Override
            public void onChanged(@Nullable JSONObject jsonObject) {
                binding.message.setText(jsonObject.toString());
                binding.message.setVisibility(View.VISIBLE);
                binding.messageLabel.setVisibility(View.VISIBLE);
            }
        });
    }
}
