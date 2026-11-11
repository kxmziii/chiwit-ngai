#!/usr/bin/env bash
# Builds index.html from src/app.html.
# src/app.html holds the whole app: its own <title>, <style>, page markup and script, but no <html>/<head>/<body>.
# This script wraps it into a full page and adds what an installable web app needs.
set -e
cd "$(dirname "$0")"
n=$(grep -n '^<header class="appbar">' src/app.html | head -1 | cut -d: -f1)
{
  cat <<'EOF'
<!doctype html>
<html lang="th">
<head>
<meta charset="utf-8">
EOF
  head -n $((n - 1)) src/app.html
  cat <<'EOF'
<meta name="description" content="ผู้ช่วยเรื่องประจำวัน เริ่มจากครัว: หาเมนูจากของที่มี จัดมื้อ และทำตามทีละขั้น">
<meta name="theme-color" content="#f3f5f9" media="(prefers-color-scheme: light)">
<meta name="theme-color" content="#0f172a" media="(prefers-color-scheme: dark)">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-title" content="ชีวิตง่าย">
<meta name="apple-mobile-web-app-status-bar-style" content="default">
<link rel="manifest" href="manifest.webmanifest">
<link rel="icon" type="image/png" sizes="192x192" href="icons/icon-192.png">
<link rel="apple-touch-icon" href="icons/icon-180.png">
<style>:root { color-scheme: light; padding-top: env(safe-area-inset-top, 0px); padding-bottom: env(safe-area-inset-bottom, 0px); }</style>
</head>
<body>
EOF
  tail -n +"$n" src/app.html
  cat <<'EOF'
<script>if ("serviceWorker" in navigator) addEventListener("load", () => { navigator.serviceWorker.register("sw.js").catch(() => {}); });</script>
</body>
</html>
EOF
} > index.html
echo "built index.html ($(wc -c < index.html) bytes)"
