#!/usr/bin/env bash
# ==============================================================================
# Realme P3 Ultra 5G (RMX5030 / Dimensity 8350 Ultra) Power-User Optimizer
# Author: Divyansh Joshi (oldregime)
# ==============================================================================

set -euo pipefail

echo "================================================================"
echo "⚡ Starting Realme P3 Ultra 5G Master Optimization"
echo "================================================================"

DEVICE_SERIAL="${1:-}"
ADB_CMD="adb"

if [ -n "$DEVICE_SERIAL" ]; then
    ADB_CMD="adb -s $DEVICE_SERIAL"
fi

echo "--> Verifying device connection..."
$ADB_CMD wait-for-device

echo "--> [1/7] Locking 120Hz Hardware Display Refresh Rate..."
$ADB_CMD shell "settings put system min_refresh_rate 120.0"
$ADB_CMD shell "settings put system peak_refresh_rate 120.0"

echo "--> [2/7] Disabling Automatic Battery Saver Auto-Throttling..."
$ADB_CMD shell "settings put global low_power 0"
$ADB_CMD shell "settings put global low_power_trigger_level 0"
$ADB_CMD shell "settings put global automatic_power_save_mode 0"
$ADB_CMD shell "settings put global dynamic_power_savings_enabled 0"
$ADB_CMD shell "settings put global dynamic_power_savings_disable_threshold 0"
$ADB_CMD shell "settings put global low_power_sticky 0"

echo "--> [3/7] Setting 0.5x Snappy Hardware Animations & 250ms Touch Latency..."
$ADB_CMD shell "settings put secure long_press_timeout 250"
$ADB_CMD shell "settings put secure multi_press_timeout 200"
$ADB_CMD shell "settings put global window_animation_scale 0.5"
$ADB_CMD shell "settings put global transition_animation_scale 0.5"
$ADB_CMD shell "settings put global animator_duration_scale 0.5"

echo "--> [4/7] Applying Extreme Standby Doze Mode (Deep Sleep in 30s)..."
$ADB_CMD shell 'settings put global device_idle_constants "inactive_to=30000,sensing_to=0,locating_to=0,location_accuracy=20.0,motion_inactive_to=0,idle_after_inactive_to=0"'

echo "--> [5/7] Freezing OTA Update Coordinator & Telemetry Daemons..."
$ADB_CMD shell "pm disable-user --user 0 com.oplus.logkit 2>/dev/null || true"
$ADB_CMD shell "pm disable-user --user 0 com.google.android.feedback 2>/dev/null || true"
$ADB_CMD shell "cmd package suspend --user 0 com.oplus.ota 2>/dev/null || true"
$ADB_CMD shell "settings put system app_launch_predict 0"

echo "--> [6/7] Applying System-Wide AdGuard Private DNS..."
$ADB_CMD shell "settings put global private_dns_mode hostname"
$ADB_CMD shell "settings put global private_dns_specifier dns.adguard-dns.com"

echo "--> [7/7] Executing F2FS Storage TRIM..."
$ADB_CMD shell "sm fstrim"

echo "================================================================"
echo "✅ Realme P3 Ultra 5G Optimization Complete! Butter-smooth 120Hz locked."
echo "================================================================"
