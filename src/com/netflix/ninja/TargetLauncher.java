package com.netflix.ninja;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.util.Log;

/** Opens the app named by R.string.target_package. */
final class TargetLauncher {
    private static final String TAG = "NetflixButton";

    private TargetLauncher() {}

    static void launch(Context context) {
        String target = context.getString(R.string.target_package);
        PackageManager pm = context.getPackageManager();
        Intent launch = pm.getLeanbackLaunchIntentForPackage(target);
        if (launch == null) launch = pm.getLaunchIntentForPackage(target);
        if (launch == null) {
            Log.w(TAG, target + " is not installed");
            return;
        }
        launch.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED);
        try {
            context.startActivity(launch);
            Log.i(TAG, "Started " + target);
        } catch (RuntimeException e) {
            Log.e(TAG, "Could not start " + target, e);
        }
    }
}
