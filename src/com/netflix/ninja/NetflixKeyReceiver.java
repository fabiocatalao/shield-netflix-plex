package com.netflix.ninja;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

/** Receives NVIDIA's NETFLIX_KEY broadcast for each press of the remote's Netflix button. */
public final class NetflixKeyReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        TargetLauncher.launch(context);
    }
}
