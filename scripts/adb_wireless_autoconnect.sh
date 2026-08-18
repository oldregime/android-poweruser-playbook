#!/usr/bin/env bash
# ==============================================================================
# Wireless ADB Auto-Connect Helper for Fedora Linux
# Author: Divyansh Joshi (oldregime)
# ==============================================================================

set -euo pipefail

PHONE_IP="${1:-192.168.29.67}"
PORT="${2:-5555}"

echo "================================================================"
echo "📶 Connecting to Phone Wirelessly over Wi-Fi ($PHONE_IP:$PORT)"
echo "================================================================"

echo "--> Pinging phone at $PHONE_IP..."
if ping -c 1 -W 2 "$PHONE_IP" >/dev/null 2>&1; then
    echo "--> Phone is reachable on network."
else
    echo "⚠️ Phone is not responding to ping. Make sure both laptop and phone are on the same Wi-Fi!"
fi

echo "--> Attempting ADB connection..."
adb connect "$PHONE_IP:$PORT"

echo "--> Current active ADB devices:"
adb devices -l
