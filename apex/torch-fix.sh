#!/data/data/com.termux/files/usr/bin/bash
# APEX Torch Fix — Camera2 API + sysfs fallback

echo "[APEX] Checking flash hardware..."
FLASH=$(termux-camera-info 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0].get('flash-available','unknown'))" 2>/dev/null || echo 'unknown')
echo "[APEX] Flash available: $FLASH"

if [ "$FLASH" = "false" ]; then
  echo "[APEX] ERROR: No flash hardware on this device. Torch impossible."
  exit 1
fi

# Restart API before torch attempt
bash "$(dirname "$0")/api-restart.sh"
sleep 1

echo "[APEX] Attempting termux-torch on..."
if timeout 4 termux-torch on 2>/dev/null; then
  echo "[APEX] TORCH ON"
  sleep 2
  termux-torch off
  echo "[APEX] TORCH OFF"
  exit 0
fi

# Fallback: kernel sysfs
echo "[APEX] API torch failed — trying sysfs fallback..."
NODES=(
  /sys/class/leds/torch-light/brightness
  /sys/class/leds/flashlight/brightness
  /sys/class/leds/led:torch_0/brightness
  /sys/class/leds/led:flash_torch/brightness
  /sys/devices/virtual/misc/torch/enable
)
for node in "${NODES[@]}"; do
  if [ -w "$node" ]; then
    echo 200 > "$node"
    echo "[APEX] TORCH ON via $node"
    sleep 2
    echo 0 > "$node"
    echo "[APEX] TORCH OFF"
    exit 0
  fi
done

echo "[APEX] ALL torch methods failed."
echo "Fix: Settings > Apps > Termux:API > Permissions > Camera > Allow"
exit 1
