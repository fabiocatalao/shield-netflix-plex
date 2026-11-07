#!/usr/bin/env bash
# Builds and signs app.apk with the Android SDK command-line tools only (no Gradle).
# Needs: JDK 11+, an Android SDK with build-tools and one platform installed.
set -euo pipefail
cd "$(dirname "$0")"

SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
BT="$SDK/build-tools/$(ls "$SDK/build-tools" | sort -V | tail -1)"
PLATFORM="$SDK/platforms/$(ls "$SDK/platforms" | sort -V | tail -1)"
ANDROID_JAR="$PLATFORM/android.jar"
KEYSTORE="${KEYSTORE:-$HOME/.android/debug.keystore}"

rm -rf build && mkdir -p build/gen build/classes build/dex

"$BT/aapt2" compile --dir res -o build/res.zip
"$BT/aapt2" link -o build/unsigned.apk -I "$ANDROID_JAR" \
    --manifest AndroidManifest.xml --java build/gen build/res.zip

javac --release 11 -classpath "$ANDROID_JAR" -d build/classes \
    $(find src build/gen -name '*.java')
"$BT/d8" --min-api 21 --release --lib "$ANDROID_JAR" --output build/dex \
    $(find build/classes -name '*.class')

cp build/unsigned.apk build/with-dex.apk
(cd build/dex && zip -q ../with-dex.apk classes.dex)
"$BT/zipalign" -f -p 4 build/with-dex.apk build/aligned.apk

if [ ! -f "$KEYSTORE" ]; then
    keytool -genkeypair -keystore "$KEYSTORE" -storepass android -keypass android \
        -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 \
        -dname "CN=Android Debug,O=Android,C=US"
fi
"$BT/apksigner" sign --ks "$KEYSTORE" --ks-pass pass:android --key-pass pass:android \
    --out app.apk build/aligned.apk
"$BT/apksigner" verify app.apk
echo "Built $(pwd)/app.apk"
