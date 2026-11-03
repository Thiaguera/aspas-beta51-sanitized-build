#!/usr/bin/env bash
set -Eeuo pipefail
phase=initial
on_error() { echo "::error title=Android diagnostic::Failed or timed out at ${phase}"; exit 1; }
trap on_error ERR
phase=adb
timeout 30s adb get-state | grep -qx device
phase=package-manager
timeout 60s adb shell pm path android >/dev/null
phase=install
timeout 100s adb install -r app/build/outputs/apk/debug/app-debug.apk >/dev/null
echo "::notice::PASS demo APK installed"
phase=network
timeout 20s adb shell svc wifi disable
timeout 20s adb shell svc data disable
phase=launch
timeout 20s adb shell am force-stop br.com.aspas.contingencia.beta51test
timeout 30s adb shell monkey -p br.com.aspas.contingencia.beta51test -c android.intent.category.LAUNCHER 1 >/dev/null
sleep 15
timeout 20s adb shell pidof br.com.aspas.contingencia.beta51test >/dev/null
phase=ui-dump
timeout 60s adb shell uiautomator dump /sdcard/nav-check.xml >/dev/null
timeout 20s adb pull /sdcard/nav-check.xml /tmp/nav-check.xml >/dev/null 2>&1
phase=ui-analysis
python3 - <<'PY'
import xml.etree.ElementTree as ET
root = ET.parse('/tmp/nav-check.xml').getroot()
nodes = list(root.iter('node'))
text = ' '.join((n.get('text','') + ' ' + n.get('content-desc','')) for n in nodes)
webview = any('WebView' in n.get('class','') for n in nodes)
visible_text = any(n.get('text','') for n in nodes)
demo_user = 'Usuário demonstrativo 1' in text
print(f'::notice::UI webview={webview} visible_text={visible_text} demo_user={demo_user}')
if webview and not visible_text:
    print('::warning title=WebView opaque::Android UIAutomator sees the WebView container but not its HTML DOM; a missing user label does not prove the login is absent.')
PY
phase=webview-presence
grep -q 'WebView' /tmp/nav-check.xml
phase=login-selector
if ! grep -qF 'Usuário demonstrativo 1' /tmp/nav-check.xml; then
  echo '::error title=Login DOM not accessible::The native accessibility tree cannot select the HTML demo user. Do not infer credentials are invalid; use an isolated WebView DOM-debug probe next.'
  exit 2
fi
echo '::notice::PASS native login selector exposed'
rm -f /tmp/nav-check.xml
timeout 20s adb shell rm -f /sdcard/nav-check.xml
