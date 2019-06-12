package com.gae.scaffolder.plugin;

import android.content.Context;

import com.gae.scaffolder.plugin.interfaces.TokenListeners;

import org.json.JSONObject;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mockito;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.RuntimeEnvironment;

import static org.mockito.Mockito.any;
import static org.mockito.Mockito.anyString;
import static org.mockito.Mockito.mock;

/**
 * Example local unit test, which will execute on the development machine (host).
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
@RunWith(RobolectricTestRunner.class)
public class FCMPluginTest {

    protected FCMPlugin fcmPlugin;
    protected Context context;

    @Before
    public void setUp() {
        context = mock(Context.class);
        fcmPlugin = FCMPlugin.getInstance(RuntimeEnvironment.application);
    }

    /**
     * @todo Verify how to run integration tests for Firebase Cloud Messaging
     *       Until here, that throws a error for FirebaseApp is not initialized
     */
    @Test
    public void getToken() {

        TokenListeners<String, JSONObject> events = Mockito.mock(TokenListeners.class);
        fcmPlugin.getToken(events);


        Mockito.verify(events, Mockito.times(0)).error(any(JSONObject.class));
        Mockito.verify(events, Mockito.times(1)).success(anyString());
    }
}