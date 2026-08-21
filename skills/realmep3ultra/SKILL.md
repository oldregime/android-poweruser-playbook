---
name: realmep3ultra
description: Use when connecting to or developing on the user's Realme P3 Ultra 5G (RMX5030) device via Wireless ADB, managing Shizuku/rish, auditing telemetry, configuring 120Hz display locks, tuning Wi-Fi/DNS network settings, managing FOSS power-user apps (RVX, Hail, KeyMapper, LinkSheet), or debugging hardware sensors and Android Auto.
---

# Realme P3 Ultra 5G (RMX5030) Development & Power-User Playbook

## Overview
Comprehensive operational playbook and hardware profile for interacting with, developing on, and optimizing the user's **Realme P3 Ultra 5G (`RMX5030`)** running **Android 15 / Realme UI 6.0**. Covers wireless discovery, Shizuku server execution, kernel/display tuning, network stack optimization, and telemetry eradication.

---

## 📱 Hardware & OS Profile
* **Model:** Realme P3 Ultra 5G (`RMX5030` / `RMX5030IN`)
* **SoC:** MediaTek Dimensity 8300 Ultra (`MT6897` 4nm Octa-core)
* **OS / Build:** Android 15 (SDK 35) / Realme UI 6.0 (`RMX5030_15.0.0.530(EX01)`)
* **RAM / Storage:** LPDDR5X RAM + UFS 4.0 Storage
* **Display:** 120Hz AMOLED (Hardware locked via SQLite settings)
* **Default Network Subnet:** `192.168.29.0/24` (Typical IPs: `192.168.29.67` or `192.168.29.66` on port `5555`)

---

## 🔌 1. Wireless ADB Connection & Auto-Discovery

### Quick Connect (Known IPs)
```bash
adb connect 192.168.29.67:5555 || adb connect 192.168.29.66:5555
adb devices -l
```

### Auto-Discovery Script (If IP changes due to DHCP/Band roaming)
When the device switches between 2.4 GHz (`Lnjoshijio4g`) and 5 GHz (`Lnjoshijio_5G`), run this Python sweep on the host:
```bash
python3 -c '
import subprocess, socket, concurrent.futures

def check_ip(i):
    ip = f"192.168.29.{i}"
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(0.3)
    if s.connect_ex((ip, 5555)) == 0:
        s.close()
        return ip
    s.close()
    return None

with concurrent.futures.ThreadPoolExecutor(max_workers=50) as ex:
    live = [ip for ip in ex.map(check_ip, range(1, 255)) if ip]
    for ip in live:
        print(f"Discovered ADB on {ip}:5555")
        subprocess.run(["adb", "connect", f"{ip}:5555"])
'
```

### Initializing / Verifying Shizuku Server
Always verify Shizuku server status after reboot or wireless connection:
```bash
adb -s <IP>:5555 shell "/data/local/tmp/shizuku_starter"
```

---

## ⚡ 2. System Performance & Display Tuning

### 120Hz Full Hardware Refresh Rate Lock
Prevents ColorOS dynamic refresh rate algorithms from down-clocking to 60Hz/30Hz while reading, typing, or inside web views:
```bash
adb shell "settings put system min_refresh_rate 120.0"
adb shell "settings put system peak_refresh_rate 120.0"
adb shell "settings put system user_refresh_rate 120"
```

### Disable Phantom Process Killer (Critical for Shizuku, Termux & Node/Python daemons)
```bash
adb shell "device_config put activity_manager max_phantom_processes 2147483647"
adb shell "settings put global settings_enable_monitor_phantom_procs false"
```

### Enable Android 15 Predictive Back Animations
```bash
adb shell "settings put global enable_back_animation 1"
```

### Ahead-of-Time (AOT) Speed Compilation
Compile critical or newly installed apps into native 64-bit ARM machine code to eliminate JIT interpretation lag:
```bash
adb shell "cmd package compile -m speed <package.name>"
```

---

## 🌐 3. Network, Wi-Fi & DNS Stack Optimization

### Private DNS Configuration (Cloudflare 1.1.1.1)
Replaced high-latency AdGuard DNS (`209.5ms` European routing) with Cloudflare (`one.one.one.one` at **`17.2ms`**) for 12x faster lookups, 99.99% uptime, and unblocked browsing:
```bash
adb shell "settings put global private_dns_mode hostname"
adb shell "settings put global private_dns_specifier one.one.one.one"
```

### Wi-Fi Disconnection & Stability Fixes
Fixes Android 15 dropping Wi-Fi on JioFiber/Airtel routers due to missed ARP gateway pings or chip sleep:
```bash
# 1. Disable premature IP Reachability disconnect triggers
adb shell "cmd wifi set-ipreach-disconnect disabled"

# 2. Disable Wi-Fi chip power-saving sleep & suspend throttling
adb shell "settings put global wifi_power_save 0"
adb shell "settings put global wifi_suspend_optimizations_enabled 0"
adb shell "settings put global wifi_sleep_policy 2"

# 3. Disable aggressive ColorOS Smart Network auto-drop
adb shell "settings put global oplus_customize_wifi_smart_connect 0"
adb shell "settings put global wifi_watchdog_poor_network_test_enabled 0"

# 4. Disable Wi-Fi scan throttling for real-time RF scanning
adb shell "settings put global wifi_scan_throttle_enabled 0"
```

### Wi-Fi 5GHz Band Steering (Prioritize `Lnjoshijio_5G`)
```bash
adb shell "cmd wifi add-suggestion Lnjoshijio4g wpa2 Divyansh@2008 -d -s"  # -d = autojoin disabled
adb shell "cmd wifi add-suggestion Lnjoshijio_5G wpa2 Divyansh@2008 -s"   # Prioritized 390-433 Mbps
```
*Note for user:* In phone Wi-Fi settings for `Lnjoshijio_5G`, set Privacy to **"Use device MAC"** to prevent router-side DHCP lease churn.

---

## 📦 4. Sideloading & App Installation Rules

### ⚠️ Critical Sideloading Rule (App Market Handling)
* **Rule:** **NEVER suspend or disable `com.heytap.market` completely.** ColorOS intercepts all APK installation intents through App Market for security verification. Suspending it causes the error: *"App isn't available. App Market isn't available at the moment. This is managed by shell."*
* **Correct Procedure:** Keep `com.heytap.market` enabled, but silence all background notifications and popups via `appops`:
```bash
# Ensure package is active
adb shell "cmd package unsuspend --user 0 com.heytap.market"
adb shell "pm enable com.heytap.market"

# Silence completely
adb shell "cmd appops set com.heytap.market POST_NOTIFICATION ignore"
adb shell "cmd appops set com.heytap.market SYSTEM_ALERT_WINDOW ignore"
adb shell "cmd appops set com.heytap.market RUN_IN_BACKGROUND ignore"
adb shell "cmd appops set com.heytap.market RUN_ANY_IN_BACKGROUND ignore"
```

---

## 🚗 5. Android Auto & RVX Music Integration

### Bypassing Google's "Requires Premium" Paywall
1. **Android Auto Developer Settings:**
   * Open Android Auto (`am start -a com.google.android.projection.gearhead.SETTINGS`) $\rightarrow$ Tap Version 10 times $\rightarrow$ 3 dots $\rightarrow$ Developer settings $\rightarrow$ Check **"Unknown sources"**.
2. **RVX Music Client Spoofing:**
   * In RVX Music $\rightarrow$ Settings $\rightarrow$ RVX $\rightarrow$ Miscellaneous $\rightarrow$ Set **Spoof Video Streams / Client** to **`visionOS`** (or `Android VR` / `iOS`).
3. **Doze Whitelist & Background Immunity:**
```bash
adb shell "dumpsys deviceidle whitelist +app.rvx.android.apps.youtube.music"
adb shell "cmd appops set app.rvx.android.apps.youtube.music RUN_ANY_IN_BACKGROUND allow"
adb shell "cmd appops set app.rvx.android.apps.youtube.music START_FOREGROUND allow"
```

---

## 🔒 6. Power-User App Ecosystem & Hibernation Policy

### Granular App Hibernation Exemption
Keep global hibernation enabled (`settings put global app_hibernation_enabled true`) for regular apps, but exempt power-user tools from having permissions stripped:
```bash
POWER_APPS=(
    "moe.shizuku.privileged.api" "io.github.sds100.keymapper" "com.aistra.hail"
    "io.github.samolego.canta" "com.arslan.shizuwall" "com.kieronquinn.app.darq"
    "com.kieronquinn.app.taptap" "fe.linksheet" "moe.chensi.volume" "dev.shizzi"
    "kr.scin.rishmcp" "org.localsend.localsend_app" "org.kde.kdeconnect_tp"
    "com.tailscale.ipn" "com.deniscerri.ytdl" "com.vrem.wifianalyzer"
    "app.rvx.android.apps.youtube.music" "app.revanced.android.youtube"
    "app.revanced.manager.flutter" "app.revanced.android.gms" "com.termux"
    "app.alextran.immich" "com.x8bit.bitwarden" "org.fdroid.fdroid"
)

for pkg in "${POWER_APPS[@]}"; do
    adb shell "cmd appops set $pkg AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore"
done
```

---

## 🛠️ 7. Hardware Sensors, IoT & Remote Control

* **Infrared (IR) Blaster:** Available on top frame (`com.oplus.consumerIRApp`) for TV/AC universal remote control without Wi-Fi.
* **Hardware Sensors Killswitch:** Enable Developer Tile **"Sensors Off"** to physically cut power to Mic, Camera, Gyroscope, and Accelerometer with 1 tap.
* **Lock Screen Smart Home Controls:**
```bash
adb shell "settings put secure controls_enabled 1"
adb shell "settings put secure lockscreen_show_controls 1"
adb shell "settings put secure lockscreen_allow_trivial_controls 1"
```

---

## 🔍 8. Troubleshooting Quick Reference

| Symptom / Issue | Root Cause | Instant Fix Command |
| :--- | :--- | :--- |
| **"App isn't available... managed by shell"** | `com.heytap.market` was suspended | `adb shell "cmd package unsuspend --user 0 com.heytap.market && pm enable com.heytap.market"` |
| **Wi-Fi drops on screen lock** | IP reachability trigger & power save | `adb shell "cmd wifi set-ipreach-disconnect disabled && settings put global wifi_power_save 0"` |
| **Lawnchair / 3rd-party launcher stutter** | Android Quickstep gesture conflict | `adb shell "cmd package compile -m speed app.lawnchair && dumpsys deviceidle whitelist +app.lawnchair"` |
| **Slow domain lookup / app lag** | Slow AdGuard DNS | `adb shell "settings put global private_dns_mode hostname && settings put global private_dns_specifier one.one.one.one"` |
| **Shizuku / Termux background killed** | Phantom process killer | `adb shell "device_config put activity_manager max_phantom_processes 2147483647"` |
| **RVX asks for Premium in car** | Android Auto media check | Enable Developer Mode + Unknown Sources in Android Auto; set RVX spoof to `visionOS`. |

---

## 🗄️ 9. Encrypted Portable Linux Storage Drive (SSHFS)
Mounts phone internal storage (`/sdcard`) natively on Fedora via Termux OpenSSH (`port 8022`):
```bash
# Mount phone storage (auto-detects Wi-Fi or Tailscale)
~/mount_realme_phone.sh

# Unmount
~/unmount_realme_phone.sh
```
* Mount point: `~/phone_storage`
* Access: Full native file manager drag-and-drop, 4K media playback, and zero-friction backup.
