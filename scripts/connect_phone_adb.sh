#!/usr/bin/env bash
# 🚀 Realme P3 Ultra 5G Persistent Wireless ADB Auto-Connector
# Discovers phone on local Wi-Fi or Tailscale, locks fixed port 5555,
# permanently disables auth timeouts, and starts Shizuku server.

KNOWN_IPS=("192.168.29.133" "192.168.29.67" "192.168.29.66" "100.65.98.105")
CONNECTED_DEV=""

echo "🔍 Searching for Realme P3 Ultra over Wi-Fi..."

for ip in "${KNOWN_IPS[@]}"; do
    if ping -c 1 -W 1 "$ip" >/dev/null 2>&1; then
        echo "📡 Ping responded on $ip. Connecting to ADB port 5555..."
        adb connect "$ip:5555" >/dev/null 2>&1
        if adb devices | grep -E "$ip:5555\s+device" >/dev/null 2>&1; then
            CONNECTED_DEV="$ip:5555"
            echo "✅ Successfully connected to $CONNECTED_DEV"
            break
        fi
    fi
done

if [ -z "$CONNECTED_DEV" ]; then
    echo "⚠️ Standard port 5555 not responding. Checking for active ephemeral wireless debug ports..."
    MDNS_DEV=$(adb devices | grep -E '192\.168\.29\.[0-9]+:[0-9]+\s+device' | head -n1 | awk '{print $1}')
    if [ -n "$MDNS_DEV" ]; then
        echo "⚡ Found ephemeral wireless debug session on $MDNS_DEV. Transitioning to permanent port 5555..."
        adb -s "$MDNS_DEV" tcpip 5555
        sleep 2
        IP_ONLY=$(echo "$MDNS_DEV" | cut -d: -f1)
        adb connect "$IP_ONLY:5555"
        CONNECTED_DEV="$IP_ONLY:5555"
    fi
fi

if [ -z "$CONNECTED_DEV" ]; then
    echo "❌ Could not establish ADB connection."
    echo "👉 If phone was rebooted: In Settings -> Developer Options, turn ON 'Wireless debugging' once."
    exit 1
fi

echo "🔒 Applying permanent ADB stability locks..."
# 1. Disable ADB authorization expiration (never expire host key)
adb -s "$CONNECTED_DEV" shell "settings put global adb_allowed_connection_time 0"

# 2. Prevent Wi-Fi disconnection from disabling ADB
adb -s "$CONNECTED_DEV" shell "settings put global adb_disconnect_on_wifi_network_lost 0"
adb -s "$CONNECTED_DEV" shell "settings put global adb_wifi_enabled 1"
adb -s "$CONNECTED_DEV" shell "settings put global adb_enabled 1"
adb -s "$CONNECTED_DEV" shell "settings put global development_settings_enabled 1"

# 3. Wi-Fi stability & keep-awake tweaks
adb -s "$CONNECTED_DEV" shell "cmd wifi set-ipreach-disconnect disabled"
adb -s "$CONNECTED_DEV" shell "settings put global wifi_power_save 0"
adb -s "$CONNECTED_DEV" shell "settings put global wifi_suspend_optimizations_enabled 0"
adb -s "$CONNECTED_DEV" shell "settings put global wifi_sleep_policy 2"

# 4. Whitelist Shizuku & Termux from battery / phantom process killer
adb -s "$CONNECTED_DEV" shell "dumpsys deviceidle whitelist +moe.shizuku.privileged.api" >/dev/null 2>&1
adb -s "$CONNECTED_DEV" shell "dumpsys deviceidle whitelist +com.termux" >/dev/null 2>&1
adb -s "$CONNECTED_DEV" shell "device_config put activity_manager max_phantom_processes 2147483647" >/dev/null 2>&1

# 5. Launch Shizuku daemon if not running
if ! adb -s "$CONNECTED_DEV" shell "ps -ef" | grep -v grep | grep -q "shizuku_server"; then
    echo "⚡ Starting Shizuku daemon..."
    adb -s "$CONNECTED_DEV" shell "/data/local/tmp/shizuku_starter" >/dev/null 2>&1
fi

echo "🎉 Realme P3 Ultra is permanently locked on $CONNECTED_DEV and fully operational!"
adb devices -l
