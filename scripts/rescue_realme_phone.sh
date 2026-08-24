#!/usr/bin/env bash
# 🚨 Realme P3 Ultra Emergency Rescue & Screen Mirroring Suite
# Designed for emergency recovery during broken screen, touch failure, or remote control.

TAILSCALE_IP="100.65.98.105"
KNOWN_IPS=("192.168.29.66" "192.168.29.67" "192.168.29.133" "192.168.1.129" "$TAILSCALE_IP")

echo "========================================================"
echo "   🚨 REALME P3 ULTRA EMERGENCY RESCUE SUITE"
echo "========================================================"

# 1. Establish Connection
DEVICE=""
if adb devices | grep -E '\bdevice\b' >/dev/null 2>&1; then
    DEVICE=$(adb devices | grep -E '\bdevice\b' | head -n1 | awk '{print $1}')
    echo "✅ Found active ADB connection: $DEVICE"
else
    echo "🔍 Searching for phone over Wi-Fi and Tailscale..."
    for ip in "${KNOWN_IPS[@]}"; do
        if nc -z -w 1 "$ip" 5555 >/dev/null 2>&1; then
            adb connect "$ip:5555" >/dev/null 2>&1
            if adb devices | grep -E '\bdevice\b' >/dev/null 2>&1; then
                DEVICE="$ip:5555"
                echo "✅ Connected to phone at $DEVICE"
                break
            fi
        fi
    done
fi

if [ -z "$DEVICE" ]; then
    echo "❌ Error: Could not connect to phone."
    echo "👉 Please plug the phone in via USB cable or ensure it is on Wi-Fi/Tailscale."
    exit 1
fi

echo ""
echo "Select Rescue Operation:"
echo "  [1] Launch Interactive Screen Mirror & Mouse Control (scrcpy)"
echo "  [2] Unlock Phone Screen Remotely (Wake & Dismiss Keyguard)"
echo "  [3] Complete Emergency Backup (Photos, Docs, Downloads, Media to PC)"
echo "  [4] Quick Diagnostics & Battery/Thermal State"
echo "  [5] Exit"
echo ""

read -p "Enter choice [1-5]: " choice

case $choice in
    1)
        echo "🖥️ Launching interactive screen control..."
        # Wake screen
        adb -s "$DEVICE" shell input keyevent 224
        # Launch scrcpy with maximum performance flags
        scrcpy -s "$DEVICE" --stay-awake --power-off-on-close
        ;;
    2)
        read -s -p "Enter your phone lockscreen PIN (will not be displayed): " PIN
        echo ""
        echo "🔓 Unlocking device..."
        adb -s "$DEVICE" shell input keyevent 224
        sleep 0.5
        adb -s "$DEVICE" shell input keyevent 82
        sleep 0.5
        if [ -n "$PIN" ]; then
            adb -s "$DEVICE" shell input text "$PIN"
            adb -s "$DEVICE" shell input keyevent 66
        fi
        echo "✅ Unlock signal sent! Launching screen mirror..."
        scrcpy -s "$DEVICE"
        ;;
    3)
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        BACKUP_DIR="$HOME/PhoneRescue_Backup_$TIMESTAMP"
        mkdir -p "$BACKUP_DIR"
        echo "📁 Emergency backup destination: $BACKUP_DIR"
        
        echo "📸 Backing up DCIM (Photos & Camera Videos)..."
        adb -s "$DEVICE" pull /sdcard/DCIM "$BACKUP_DIR/" 2>/dev/null
        
        echo "🖼️ Backing up Pictures & Screenshots..."
        adb -s "$DEVICE" pull /sdcard/Pictures "$BACKUP_DIR/" 2>/dev/null
        
        echo "📄 Backing up Documents..."
        adb -s "$DEVICE" pull /sdcard/Documents "$BACKUP_DIR/" 2>/dev/null
        
        echo "📥 Backing up Downloads..."
        adb -s "$DEVICE" pull /sdcard/Download "$BACKUP_DIR/" 2>/dev/null

        echo "🎵 Backing up Music..."
        adb -s "$DEVICE" pull /sdcard/Music "$BACKUP_DIR/" 2>/dev/null
        
        echo "✅ BACKUP COMPLETE! All files preserved at: $BACKUP_DIR"
        xdg-open "$BACKUP_DIR" >/dev/null 2>&1 &
        ;;
    4)
        echo "=== BATTERY & HARDWARE HEALTH ==="
        adb -s "$DEVICE" shell dumpsys battery
        echo ""
        echo "=== STORAGE DISK USAGE ==="
        adb -s "$DEVICE" shell df -h /data /sdcard
        echo ""
        echo "=== MEMORY & RAM STATE ==="
        adb -s "$DEVICE" shell free -m
        ;;
    *)
        echo "Exiting."
        ;;
esac
