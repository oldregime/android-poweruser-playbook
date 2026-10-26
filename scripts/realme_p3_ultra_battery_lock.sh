#!/usr/bin/env bash
# ==============================================================================
# 🔋 Realme P3 Ultra 5G (RMX5030) Master Battery & Hybrid 120Hz Optimizer
# Author: Divyansh Joshi (oldregime)
# ==============================================================================

set -euo pipefail

echo "================================================================"
echo "⚡ Starting Realme P3 Ultra 5G Master Battery & Power Optimization"
echo "================================================================"

DEVICE_IP="${1:-192.168.29.133:5555}"
ADB_CMD="adb -s $DEVICE_IP"

echo "--> [1/8] Verifying ADB Connection on $DEVICE_IP..."
adb connect "$DEVICE_IP" >/dev/null 2>&1 || true
$ADB_CMD wait-for-device

echo "--> [2/8] Disabling High Performance Mode & Restoring Governor Savings..."
$ADB_CMD shell "settings put global oplus_high_performance_mode 0"
$ADB_CMD shell "settings put system high_performance_mode_on 0"

echo "--> [3/8] Configuring Permanent Hybrid 120Hz Power Saving Mode..."
# Force 120Hz even when Power Saver is active (bypasses ColorOS 60Hz lock)
$ADB_CMD shell "settings put system power_save_screen_refresh_rate 0"
$ADB_CMD shell "settings put system power_save_auto_close_switch 0"
$ADB_CMD shell "settings put global low_power 1"
$ADB_CMD shell "settings put global low_power_sticky 1"
$ADB_CMD shell "settings put secure oplus_customize_screen_refresh_rate 3"
$ADB_CMD shell "settings put secure oplus_refreshrate_override 1"
$ADB_CMD shell "settings put system peak_refresh_rate 120.0"
$ADB_CMD shell "settings put system user_refresh_rate 120"

echo "--> [4/8] Disabling Background RF & Wi-Fi Beacon Scanning..."
$ADB_CMD shell "settings put global wifi_scan_always_enabled 0"
$ADB_CMD shell "pm disable-user --user 0 com.google.android.printservice.recommendation 2>/dev/null || true"

echo "--> [5/8] Enabling Smart 5G Power-Saving Auto-Release..."
$ADB_CMD shell 'settings put global smart_5g 1'
$ADB_CMD shell 'settings put global oplus.radio.smart5g_local_release "ver_num=2;enable=true;screen_off=true;count_per_hour=100;local_release_timer=10;local_release_cnt=20;nonDDS_local_release_enable=true"'

echo "--> [6/8] Enabling Sleep Standby Optimization..."
$ADB_CMD shell "settings put system oplus_deep_sleep_status 1"
$ADB_CMD shell "settings put system deepsleep_network_disable_state 1"
$ADB_CMD shell "settings put global oplus_customize_system_stable_plan_switch 0"

echo "--> [7/8] Neutralizing Rogue Background Apps & Suspending Smart Launcher..."
$ADB_CMD shell "cmd package suspend --user 0 ginlemon.flowerfree 2>/dev/null || true"

SHOPPING_APPS=(
    "in.amazon.mShop.android.shopping" "com.flipkart.android"
    "com.grofers.customerapp" "com.zeptoconsumerapp"
    "in.swiggy.android" "com.application.zomato" "com.meesho.supply"
)

for pkg in "${SHOPPING_APPS[@]}"; do
    $ADB_CMD shell "cmd appops set $pkg RUN_ANY_IN_BACKGROUND ignore 2>/dev/null || true"
    $ADB_CMD shell "cmd appops set $pkg RUN_IN_BACKGROUND ignore 2>/dev/null || true"
done

echo "--> [8/8] Permanent ADB Auth & Wi-Fi Keep-Alive..."
$ADB_CMD shell "settings put global adb_allowed_connection_time 0"
$ADB_CMD shell "settings put global adb_disconnect_on_wifi_network_lost 0"
$ADB_CMD shell "settings put global adb_wifi_enabled 1"
$ADB_CMD shell "settings put global adb_enabled 1"
$ADB_CMD shell "settings put global development_settings_enabled 1"

echo "================================================================"
echo "✅ Master Battery & 120Hz Hybrid Power Saving Mode Fully Applied!"
echo "================================================================"
