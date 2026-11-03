#!/usr/bin/env bash
set -Eeuo pipefail
phase=initial
on_error() { echo "::error title=Android diagnostic::Failed or timed out at ${phase}"; exit 1; }
trap on_error ERR
phase=adb
 timeout 30s adb get-state | grep -qx device
echo "::notice::PASS adb"
phase=package-manager
 echo "::notice::START package manager"
timeout 60s adb shell pm path android >/dev/null
echo "::notice::PASS package manager"
phase=install
 echo "::notice::START install"
timeout 100s adb install -r app/build/outputs/apk/debug/app-debug.apk >/dev/null
echo "::notice::PASS install"
phase=network
timeout 20s adb shell svc wifi disable
timeout 20s adb shell svc data disable
echo "::notice::PASS offline commands"
phase=launch
timeout 20s adb shell am force-stop br.com.aspas.contingencia.beta51test
timeout 30s adb shell monkey -p br.com.aspas.contingencia.beta51test -c android.intent.category.LAUNCHER 1 >/dev/null
sleep 15
timeout 20s adb shell pidof br.com.aspas.contingencia.beta51test >/dev/null
echo "::notice::PASS process started"
phase=ui-dump
echo "::notice::START UI dump"
timeout 60s adb shell uiautomator dump /sdcard/nav-check.xml >/dev/null
echo "::notice::PASS UI dump"
phase=ui-pull
timeout 20s adb pull /sdcard/nav-check.xml /tmp/nav-check.xml >/dev/null 2>&1
echo "::notice::PASS UI pull"
phase=ui-analysis
python3 - <<PY
import xml.etree.ElementTree as ET
root = ET.parse("/tmp/nav-check.xml").getroot()
nodes = list(root.iter("node"))
text = " ".join((n.get("text", "") + " " + n.get("content-desc", "")) for n in nodes)
checks = {"webview": any("WebView" in n.get("class", "") for n in nodes), "demo_user": "Usuário demonstrativo 1" in text, "login": any(x in text.lower() for x in ["entrar", "login", "senha", "pin"]), "mesas": "mesa" in text.lower(), "text_nodes": any(n.get("text", "") for n in nodes), "editable": any(n.get("class", "").endswith("EditText") for n in nodes)}
for key, value in checks.items():
    print("::notice::UI_" + key + "=" + str(value))
PY
phase=login-selector
grep -qF "Usuário demonstrativo 1" /tmp/nav-check.xml
echo "::notice::PASS expected demo user visible"
phase=demo-login
timeout 20s adb shell input tap 540 1040
timeout 20s adb shell input text "$ASPAS_DEMO_PIN"
timeout 20s adb shell input keyevent 66
sleep 7
phase=mesas-dump
timeout 60s adb shell uiautomator dump /sdcard/nav-check.xml >/dev/null
timeout 20s adb pull /sdcard/nav-check.xml /tmp/nav-check.xml >/dev/null 2>&1
phase=mesas-selector
grep -qF "Mesa" /tmp/nav-check.xml
echo "::notice::PASS demo login and mesas"
phase=order
timeout 20s adb shell input tap 165 1870
sleep 4
timeout 60s adb shell uiautomator dump /sdcard/nav-check.xml >/dev/null
timeout 20s adb pull /sdcard/nav-check.xml /tmp/nav-check.xml >/dev/null 2>&1
grep -qF "Pedido" /tmp/nav-check.xml
echo "::notice::PASS order screen"
rm -f /tmp/nav-check.xml
timeout 20s adb shell rm -f /sdcard/nav-check.xml
