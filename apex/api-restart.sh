#!/data/data/com.termux/files/usr/bin/bash
# APEX Termux:API Restart — correct component names from AndroidManifest
echo "[APEX] Force-stopping Termux:API..."
am force-stop com.termux.api
sleep 1

echo "[APEX] Starting KeepAliveService..."
am startservice com.termux.api/.KeepAliveService
sleep 1

echo "[APEX] Starting main activity..."
am start -n com.termux.api/.activities.TermuxAPIMainActivity
sleep 2

echo "[APEX] Testing API..."
termux-battery-status && echo "[APEX] API ALIVE" || echo "[APEX] API DEAD"
