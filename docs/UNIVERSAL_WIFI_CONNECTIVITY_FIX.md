# Universal Wi-Fi & Network Roaming Master Guide

Comprehensive fix for Android 14/15 & Realme UI 6.0 to ensure the device can discover, evaluate, and connect to **any** Wi-Fi network (Home 5GHz, Coffee Shops, Airports, Colleges, Hotspots, Captive Portals) without getting stuck on 2.4GHz or failing authentication.

---

## 1. Root Causes Fixed
1. **Shell-Injected Network Suggestions Lock:** Cleared all `cmd wifi add-suggestion` records that were forcing priority evaluation to a specific SSID.
2. **Sticky 2.4GHz Roaming Bias:** Forgot `Lnjoshijio4g` so Android no longer refuses to switch to faster 5GHz channels.
3. **Captive Portal Handshake Failures:** Configured official Google 204 endpoints for instant login pages on public Wi-Fi.
4. **Scan Throttling & Power Throttling:** Disabled scan throttling so newly in-range networks are detected in real-time.

---

## 2. Automated Master Fix Script
```bash
# 1. Purge Shell Suggestions & Reset Evaluator
adb shell "cmd wifi remove-all-suggestions"
adb shell "cmd wifi reset-connected-score"
adb shell "cmd wifi set-ipreach-disconnect enabled"

# 2. Universal Captive Portal Detection Endpoints
adb shell "settings put global captive_portal_mode 1"
adb shell "settings put global captive_portal_detection_enabled 1"
adb shell "settings put global captive_portal_http_url http://connectivitycheck.gstatic.com/generate_204"
adb shell "settings put global captive_portal_https_url https://www.google.com/generate_204"
adb shell "settings put global captive_portal_fallback_url http://www.google.com/gen_204"
adb shell "settings put global captive_portal_other_fallback_urls http://play.googleapis.com/generate_204"

# 3. Real-Time AP Discovery & Seamless Roaming
adb shell "settings put global wifi_scan_throttle_enabled 0"
adb shell "settings put global wifi_scan_always_enabled 1"
adb shell "settings put global wifi_networks_available_notification_on 1"
adb shell "settings put global wifi_wakeup_enabled 1"
adb shell "settings put global wifi_sleep_policy 2"
adb shell "settings put global wifi_power_save 0"
adb shell "settings put global wifi_suspend_optimizations_enabled 0"
adb shell "settings put global wifi_watchdog_poor_network_test_enabled 1"
adb shell "settings put global wifi_max_dhcp_retry_count 9"
adb shell "settings put global oplus_customize_wifi_smart_connect 1"
adb shell "settings put global wifi_select_ssid_type 0"
```
