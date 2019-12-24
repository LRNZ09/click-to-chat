package com.whatsadd;

import android.content.Intent;
import android.content.res.Configuration;
import android.os.Bundle;

import com.facebook.react.ReactActivity;
import com.facebook.react.ReactActivityDelegate;
import com.facebook.react.ReactRootView;
import com.swmansion.gesturehandler.react.RNGestureHandlerEnabledRootView;

import org.devio.rn.splashscreen.SplashScreen;

public class MainActivity extends ReactActivity {

    /**
     * https://software-mansion.github.io/react-native-gesture-handler/docs/getting-started.html#android
     */
    @Override
    protected ReactActivityDelegate createReactActivityDelegate() {
        return new ReactActivityDelegate(this, getMainComponentName()) {
            @Override
            protected ReactRootView createRootView() {
                return new RNGestureHandlerEnabledRootView(MainActivity.this);
            }
        };
    }

    /**
     * Returns the name of the main component registered from JavaScript. This is used to schedule
     * rendering of the component.
     */
    @Override
    protected String getMainComponentName() {
        return "WhatsAdd";
    }

    /**
     * https://github.com/crazycodeboy/react-native-splash-screen#third-stepplugin-configuration
     */
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        SplashScreen.show(this, R.style.SplashTheme);

        super.onCreate(savedInstanceState);
    }

    /**
     * https://github.com/expo/react-native-appearance#configuration
     */
    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);

        Intent intent = new Intent("onConfigurationChanged");
        intent.putExtra("newConfig", newConfig);
        sendBroadcast(intent);
    }

}
