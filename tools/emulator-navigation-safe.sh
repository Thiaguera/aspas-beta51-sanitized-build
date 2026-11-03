#!/usr/bin/env bash
set -Eeuo pipefail
phase=initial
on_error() { echo "::error title=Android navigation::Failed at ${phase}"; exit 1; }
trap on_error ERR
phase=adb
adb get-state | grep -qx device
echo "::notice::PASS adb"
phase=install
adb install -r app/build/outputs/apk/debug/app-debug.apk >/dev/null
echo "::notice::PASS install"
phase=network
adb shell svc wifi disable
adb shell svc data disable
echo "::notice::PASS offline commands"
phase=launch
adb shell am force-stop br.com.aspas.contingencia.beta51test
adb shell monkey -p br.com.aspas.contingencia.beta51test -c android.intent.category.LAUNCHER 1 >/dev/null
sleep 8
adb shell pidof br.com.aspas.contingencia.beta51test >/dev/null
echo "::notice::PASS launch"
phase=login-screen
adb shell uiautomator dump /sdcard/nav-check.xml >/dev/null
adb pull /sdcard/nav-check.xml /tmp/nav-check.xml >/dev/null 2>&1
grep -qF "Usuário demonstrativo 1" /tmp/nav-check.xml
echo "::notice::PASS login screen"
phase=demo-login
adb shell input tap 540 1040
adb shell input text "$ASPAS_DEMO_PIN"
adb shell input keyevent 66
sleep 7
adb shell uiautomator dump /sdcard/nav-check.xml >/dev/null
adb pull /sdcard/nav-check.xml /tmp/nav-check.xml >/dev/null 2>&1
grep -qF "Mesa" /tmp/nav-check.xml
echo "::notice::PASS demo login and mesas"
phase=order
adb shell input tap 165 1870
sleep 4
adb shell uiautomator dump /sdcard/nav-check.xml >/dev/null
adb pull /sdcard/nav-check.xml /tmp/nav-check.xml >/dev/null 2>&1
grep -qF "Pedido" /tmp/nav-check.xml
echo "::notice::PASS order screen"
rm -f /tmp/nav-check.xml
adb shell rm -f /sdcard/nav-check.xml
