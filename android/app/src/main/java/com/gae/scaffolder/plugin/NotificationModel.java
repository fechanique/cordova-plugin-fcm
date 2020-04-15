package com.gae.scaffolder.plugin;

import android.arch.lifecycle.MutableLiveData;
import android.arch.lifecycle.ViewModel;
import android.support.transition.Visibility;
import android.util.Log;
import android.view.View;

import org.json.JSONException;
import org.json.JSONObject;

public class NotificationModel extends ViewModel {
    public MutableLiveData<String> token = new MutableLiveData<>();
    public MutableLiveData<JSONObject> messageData = new MutableLiveData<>();

    public void setData(String data) {
        try {

            this.messageData.setValue(new JSONObject(data));
        } catch (JSONException jsonErr) {
            Log.e(getClass().getName(), jsonErr.getMessage(), jsonErr);
        }
    }

    public String getData() {
        JSONObject data = this.messageData.getValue();

        if (data != null && data.length() > 0) {
            return data.toString();
        }
        return "";
    }

    public int containsData() {
        return this.getData().isEmpty() ? View.GONE : View.VISIBLE;
    }
}
