#!/bin/zsh
set -e
P=com.baptistelore.converto
OUT=store/screenshots/android-phone-1080x1920
rm -rf store/screenshots/android-phone-*
adb shell wm size 1080x1920
adb shell wm density 420
sleep 3
adb shell settings put global sysui_demo_allowed 1
for c in "enter" "clock -e hhmm 0941" "battery -e level 100 -e plugged false" "network -e wifi show -e level 4 -e fully true" "network -e mobile hide" "notifications -e visible false"; do
  adb shell am broadcast -a com.android.systemui.demo -e command $c >/dev/null
done
for lang in en fr es de it pt nl; do
  mkdir -p $OUT/$lang
  n=1
  for scene in idle ready options running done; do
    adb shell am force-stop $P
    adb shell am start -n $P/.MainActivity --es route "$scene:$lang" >/dev/null
    sleep 12
    adb exec-out screencap -p > $OUT/$lang/$n-$scene.png
    n=$((n+1))
  done
done
adb shell am broadcast -a com.android.systemui.demo -e command exit >/dev/null
adb shell am force-stop $P
adb shell wm size reset
adb shell wm density reset
echo ANDROID_DONE
