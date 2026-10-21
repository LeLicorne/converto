#!/bin/zsh
set -e
trap 'rm -f /tmp/converto_scene' EXIT
APP=build/ios/iphonesimulator/Runner.app
BUNDLE=com.baptistelore.converto
OUT=store/screenshots
SCENES=(idle ready options running done)
LANGS=(en fr es de it pt nl)
shoot() {
  local udid=$1 folder=$2
  xcrun simctl boot $udid 2>/dev/null || true
  xcrun simctl bootstatus $udid -b >/dev/null
  xcrun simctl uninstall $udid $BUNDLE 2>/dev/null || true
  xcrun simctl install $udid $APP
  xcrun simctl status_bar $udid override --time 9:41 --batteryState charged --batteryLevel 100 --cellularMode active --cellularBars 4 --wifiBars 3
  for lang in $LANGS; do
    mkdir -p $OUT/$folder/$lang
    n=1
    for scene in $SCENES; do
      xcrun simctl terminate $udid $BUNDLE 2>/dev/null || true
      echo "$scene:$lang" > /tmp/converto_scene
      xcrun simctl launch $udid $BUNDLE >/dev/null
      sleep 3.5
      xcrun simctl io $udid screenshot --type=png $OUT/$folder/$lang/$n-$scene.png >/dev/null
      n=$((n+1))
    done
  done
  xcrun simctl terminate $udid $BUNDLE 2>/dev/null || true
}
[[ "$1" == "ipad" ]] || shoot C85DF521-D4C6-4B53-B6EC-15811C80E164 ios-iphone-6.9
shoot D926268D-8ED2-4C1B-80F8-B3B458314058 ios-ipad-13
