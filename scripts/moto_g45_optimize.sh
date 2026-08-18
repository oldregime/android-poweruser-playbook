#!/usr/bin/env bash
# ==============================================================================
# Motorola Moto G45 5G (fogos / Snapdragon 6s Gen 3) Power-User Optimizer
# Author: Divyansh Joshi (oldregime)
# ==============================================================================

set -euo pipefail

echo "================================================================"
echo "⚡ Starting Motorola Moto G45 5G Master Optimization"
echo "================================================================"

DEVICE_SERIAL="${1:-}"
ADB_CMD="adb"

if [ -n "$DEVICE_SERIAL" ]; then
    ADB_CMD="adb -s $DEVICE_SERIAL"
fi

echo "--> Verifying device connection..."
$ADB_CMD wait-for-device

echo "--> [1/7] Fixing Stutter & Locking 120Hz Hardware Refresh Rate..."
$ADB_CMD shell "settings put system min_refresh_rate 120.0"
$ADB_CMD shell "settings put system peak_refresh_rate 120.0"
$ADB_CMD shell "settings put system user_refresh_rate 120"

echo "--> [2/7] Restoring 0.5x Snappy Hardware Animations (Fixes Broken 0.0x Lag)..."
$ADB_CMD shell "settings put global window_animation_scale 0.5"
$ADB_CMD shell "settings put global transition_animation_scale 0.5"
$ADB_CMD shell "settings put global animator_duration_scale 0.5"
$ADB_CMD shell "settings put secure long_press_timeout 250"
$ADB_CMD shell "settings put secure multi_press_timeout 200"

echo "--> [3/7] Disabling Automatic Battery Saver 60Hz Throttling..."
$ADB_CMD shell "settings put global low_power 0"
$ADB_CMD shell "settings put global low_power_trigger_level 0"
$ADB_CMD shell "settings put global automatic_power_save_mode 0"
$ADB_CMD shell "settings put global dynamic_power_savings_enabled 0"
$ADB_CMD shell "settings put global dynamic_power_savings_disable_threshold 0"

echo "--> [4/7] Freezing Motorola OTA, FOTA, and Update Daemons..."
$ADB_CMD shell "pm disable-user --user 0 com.motorola.ccc.ota 2>/dev/null || true"
$ADB_CMD shell "cmd package suspend --user 0 com.motorola.ccc.ota 2>/dev/null || true"
$ADB_CMD shell "pm disable-user --user 0 com.motorola.android.fota 2>/dev/null || true"
$ADB_CMD shell "cmd package suspend --user 0 com.motorola.android.fota 2>/dev/null || true"
$ADB_CMD shell "pm disable-user --user 0 com.motorola.omadm.service 2>/dev/null || true"
$ADB_CMD shell "cmd package suspend --user 0 com.motorola.omadm.service 2>/dev/null || true"

echo "--> [5/7] Disabling Taboola Ad Injector & Promotional Bloat..."
$ADB_CMD shell "pm disable-user --user 0 com.taboola.mip 2>/dev/null || true"
$ADB_CMD shell "cmd package suspend --user 0 com.taboola.mip 2>/dev/null || true"
$ADB_CMD shell "pm disable-user --user 0 com.motorola.spaces 2>/dev/null || true"
$ADB_CMD shell "pm disable-user --user 0 com.motorola.motocare 2>/dev/null || true"
$ADB_CMD shell "pm disable-user --user 0 com.motorola.bug2go 2>/dev/null || true"
$ADB_CMD shell "pm disable-user --user 0 com.motorola.brapps 2>/dev/null || true"
$ADB_CMD shell "pm disable-user --user 0 com.motorola.appforecast 2>/dev/null || true"

echo "--> [6/7] Applying AdGuard Private DNS & Wi-Fi Scan Optimization..."
$ADB_CMD shell "settings put global private_dns_mode hostname"
$ADB_CMD shell "settings put global private_dns_specifier dns.adguard-dns.com"
$ADB_CMD shell "settings put global wifi_scan_always_enabled 0"
$ADB_CMD shell "settings put global ble_scan_always_enabled 0"

echo "--> [7/7] Applying Extreme Standby Doze Mode & Storage TRIM..."
$ADB_CMD shell 'settings put global device_idle_constants "inactive_to=30000,sensing_to=0,locating_to=0,location_accuracy=20.0,motion_inactive_to=0,idle_after_inactive_to=0"'
$ADB_CMD shell "sm fstrim"

echo "================================================================"
echo "✅ Motorola Moto G45 5G Optimization Complete!"
echo "================================================================"
