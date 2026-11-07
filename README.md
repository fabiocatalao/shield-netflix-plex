# shield-netflix-plex

Makes the **Netflix button** on the NVIDIA SHIELD TV remote open **Plex** (or any other
app) without Button Mapper, accessibility services or root.

## How it works

The SHIELD firmware handles the Netflix button (keycode 199) in NVIDIA's
`com.nvidia.shieldtech.hooks` (`NvNetflix.handleKeyEvent`):

1. It asks `PackageManager.getLeanbackLaunchIntentForPackage("com.netflix.ninja")`.
2. If that returns an intent, it sends the broadcast
   `com.netflix.ninja.intent.action.NETFLIX_KEY` to package `com.netflix.ninja`.
3. Otherwise it opens `market://details?id=com.netflix.ninja` in the Play Store.

This APK uses the package name `com.netflix.ninja` and contains:

- `NetflixKeyReceiver`: receives `NETFLIX_KEY` and launches the target app. Android
  allows that background start because it exempts the `com.netflix.ninja` package.
- `LaunchActivity`: an invisible `LEANBACK_LAUNCHER` activity. Step 1 needs it. Without
  it the firmware treats Netflix as missing and goes to the Play Store. Opening it from
  the home screen also launches the target app.

Tested on a SHIELD TV Pro (2019) running Android 11.

## Caveats

- **The real Netflix app can't be installed alongside it**, because both use the same
  package name. Uninstall the real one first. To get Netflix back, uninstall this one.
- The app shows up as "Netflix button → Plex" in the app list. Hide it in your launcher
  if you want.
- Long-pressing the button behaves the same as a short press.

## Change the target app

Edit `res/values/strings.xml`:

```xml
<string name="target_package" translatable="false">com.plexapp.android</string>
```

Find a package name with `adb shell pm list packages | grep -i <name>`, then rebuild.

## Build

Needs a JDK 11+ and the Android SDK (build-tools and one platform). Gradle isn't used.

```bash
./build.sh
```

It signs with `~/.android/debug.keystore`, creating it if missing. To use another
keystore, set `KEYSTORE=/path/to.keystore`. The output is `app.apk`.

## Install / uninstall

Enable network debugging on the SHIELD (Settings → Device Preferences → Developer
options), then:

```bash
adb connect <shield-ip>:5555
adb uninstall com.netflix.ninja        # only if the real Netflix is installed
adb install -r app.apk
```

To remove it:

```bash
adb uninstall com.netflix.ninja
```

Check that it works with `adb logcat -s NetflixButton` and a button press. You should
see `Started com.plexapp.android`.
