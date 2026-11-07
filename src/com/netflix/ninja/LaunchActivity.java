package com.netflix.ninja;

import android.app.Activity;
import android.os.Bundle;

/**
 * Invisible launcher entry. NVIDIA's hook treats com.netflix.ninja as installed only when
 * getLeanbackLaunchIntentForPackage() finds an activity, so this exists for that check.
 * Opening it from the home screen forwards to the target app too.
 */
public final class LaunchActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TargetLauncher.launch(this);
        finish();
    }
}
