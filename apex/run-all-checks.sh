#!/data/data/com.termux/files/usr/bin/bash
# APEX Full API Health Check
DIR="$(dirname "$0")"

pass=0; fail=0
check() {
  label=$1; shift
  result=$(timeout 5 "$@" 2>/dev/null)
  if [ $? -eq 0 ] && [ -n "$result" ]; then
    echo "[OK]  $label"
    ((pass++))
  else
    echo "[FAIL] $label"
    ((fail++))
  fi
}

bash "$DIR/api-restart.sh" > /dev/null 2>&1
sleep 2

echo "====== APEX API STATUS ======"
check "Battery"    termux-battery-status
check "WiFi"       termux-wifi-connectioninfo
check "Clipboard"  termux-clipboard-get
check "Location"   termux-location -p network
check "Camera"     termux-camera-info
check "Sensors"    termux-sensor -l
echo "============================="
echo "PASS: $pass  FAIL: $fail"

# Torch separate
echo ""
bash "$DIR/torch-fix.sh"
