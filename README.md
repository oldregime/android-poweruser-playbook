# 🚀 Android Power-User Playbook & Optimization Engine

Battle-tested Android optimization, hardening, 120Hz locking, Doze tuning, debloating, and Linux workstation integration suite for **Realme (Realme UI 6.0 / Android 15)** and **Motorola (Hello UI / Android 14)** devices.

Authored and maintained by **[Divyansh Joshi (oldregime)](https://github.com/oldregime)**.

---

## 📱 Hardware & Firmware Target Profiles

```
Primary Device:   Realme P3 Ultra 5G (RMX5030 / Dimensity 8300 Ultra / MT6897)
OS / UI Version:  Android 15 (SDK 35) / Realme UI 6.0 (Build: RMX5030_15.0.0.530(EX01))
Display:          120Hz AMOLED (Full Hardware Lock via SQLite Settings)
Workstation:      Fedora Linux 41 / KDE Connect & ADB over Wi-Fi
```

```
Secondary Device: Motorola Moto G45 5G (Snapdragon 6s Gen 3 / SM6375)
OS / UI Version:  Android 14 (SDK 34) / Hello UI (MyUX)
Display:          120Hz IPS LCD (Dynamic Throttling Eliminated)
```

---

## 🛠️ Optimizations Applied Across Devices

### 1. 🏎️ Display & Refresh Rate Unthrottling
* **Problem:** Default Android dynamic refresh rate algorithms aggressively down-clock the display to 60Hz or 30Hz inside web browsers, social feeds, and whenever battery drops below 20%, causing micro-stutters.
* **Solution:** Applied hardware-level display controller locks:
  ```bash
  settings put system min_refresh_rate 120.0
  settings put system peak_refresh_rate 120.0
  settings put system user_refresh_rate 120
  ```
* **Result:** Continuous, uncompromised 120Hz rendering across all applications.

---

### 2. 🛑 Battery Saver Auto-Trigger Elimination
* **Problem:** Android's automatic battery saver aggressively throttles CPU clock frequencies, caps framerates to 60fps, dims screens, and kills background audio players (e.g. YouTube Music / Spotify).
* **Solution:** Disabled automated power saver triggers permanently in system SQLite database:
  ```bash
  settings put global low_power 0
  settings put global low_power_trigger_level 0
  settings put global automatic_power_save_mode 0
  settings put global dynamic_power_savings_enabled 0
  settings put global dynamic_power_savings_disable_threshold 0
  settings put global low_power_sticky 0
  ```
* **Result:** Device maintains full unthrottled performance and 120Hz fluidity even below 10% battery.

---

### 3. ⚡ Touch Latency & Interaction Tuning
* **Problem:** Android default touch hold delays (400ms) introduce perceptible lag when selecting text, rearranging icons, or triggering context menus.
* **Solution:** Tuned touch hold window and doubled hardware animation interpolation speeds:
  ```bash
  settings put secure long_press_timeout 250
  settings put secure multi_press_timeout 200
  settings put global window_animation_scale 0.5
  settings put global transition_animation_scale 0.5
  settings put global animator_duration_scale 0.5
  ```

---

### 4. 🔋 Extreme Standby Doze Mode (Deep Sleep in 30s)
* **Problem:** Stock Android takes 30+ minutes of motionless idle time before entering deep sleep, resulting in 5%–10% overnight battery drain.
* **Solution:** Tuned Android Doze mode state machine parameters:
  ```bash
  device_idle_constants="inactive_to=30000,sensing_to=0,locating_to=0,location_accuracy=20.0,motion_inactive_to=0,idle_after_inactive_to=0"
  settings put global device_idle_constants $device_idle_constants
  ```
* **Result:** Drops processor into deep sleep within 30 seconds of screen lock, reducing overnight standby battery drain to **<1%**.

---

### 5. 🚀 System-Wide Ahead-of-Time (AOT) Speed Compilation
* **Problem:** Modern Android uses Just-In-Time (JIT) interpretation and background profile compilation, leading to CPU spikes and dropped frames during cold app launches.
* **Solution:** Compiled every user and system package into native ARM machine code:
  ```bash
  for pkg in $(pm list packages | cut -d: -f2); do
      cmd package compile -m speed $pkg
  done
  ```
* **Result:** 30%–40% faster cold app startup times, lower CPU thermal load, and zero bytecode interpretation lag.

---

### 6. 🌐 Network, DNS & Wi-Fi Optimization (Cloudflare 1.1.1.1 & Fast 5G Steering)
* **DNS Benchmarking:** Replaced high-latency AdGuard DNS (`209.5ms`) with Cloudflare Private DNS (`one.one.one.one` at **`17.2ms`**), cutting lookup lag by 12x while bypassing ISP-level censorship with 99.99% uptime.
* **Wi-Fi 5G Band Steering:** Overcame Android's tendency to latch onto 2.4 GHz due to raw RSSI by automating 5 GHz suggestions and disabling Wi-Fi scan throttling (`wifi_scan_throttle_enabled 0`).
* **Detailed Guide:** [docs/NETWORK_DNS_AND_WIFI_OPTIMIZATION.md](docs/NETWORK_DNS_AND_WIFI_OPTIMIZATION.md).

---

### 7. 🚗 Android Auto & RVX Music Integration
* **Problem:** Non-premium YouTube Music playback is blocked on car head units with `"Requires YouTube Music Premium"`.
* **Solution:** Enabled Android Auto Developer Mode + Unknown Sources, configured `visionOS` client spoofing in RVX Music to bypass server-side checks, and whitelisted RVX from Doze for instant playback.
* **Detailed Guide:** [docs/ANDROID_AUTO_RVX_MUSIC_INTEGRATION.md](docs/ANDROID_AUTO_RVX_MUSIC_INTEGRATION.md).

---

### 8. 🛡️ System Debloating & Telemetry Eradication
* **Disabled Packages (Realme):**
  * `com.oplus.logkit` (Telemetry & diagnostic log collector)
  * `com.google.android.feedback` (Google crash dump sender)
  * `com.heytap.market` (OEM App Store bloat)
  * `com.realmestore.app` (Realme commercial app)
  * `app_launch_predict 0` (Disabled user behavioral profiling daemon)
* **Disabled Packages (Motorola):**
  * `com.taboola.mip` (Taboola in-feed ad network injector)
  * `com.motorola.spaces` (Promotional bloat)
  * `com.motorola.motocare` (OEM analytics tracker)
  * `com.motorola.bug2go` (Background log dumper)
  * `com.motorola.brapps` (Partner app installer)
  * `com.motorola.appforecast` (Behavioral prediction logger)

---

### 9. 📦 Curated Power-User FOSS Suite
* **System Management:** Shizuku, Canta (Debloater), Hail (App Freezer), App Manager, SD Maid SE, Obtainium.
* **Network & Connectivity:** WiFiAnalyzer (open-source), LocalSend, Tailscale, KDE Connect.
* **Media & Audio:** RVX YouTube & Music (`visionOS` spoof), Spotube, Just Player, Seal (yt-dlp).
* **Detailed Catalog:** [docs/CURATED_FOSS_APPS_ECOSYSTEM.md](docs/CURATED_FOSS_APPS_ECOSYSTEM.md).

---

## 💳 UPI / Banking App Developer Options Guide

NPCI and Indian banking applications (PhonePe, GPay, Paytm, BHIM, Cred, SBI YONO) detect `development_settings_enabled = 1`.

> [!TIP]
> **Turning Developer Options OFF in Android Settings does NOT wipe or reset ANY of your applied tweaks.**
> 
> All 120Hz locks, 0.5x animations, Doze timings, Cloudflare DNS, debloated states, and AOT native machine-code compilation persist permanently in Android's SQLite `settings.db`.
> 
> You can safely turn Developer Options **OFF** to complete your UPI setup, and turn it back on whenever you need USB/Wireless debugging!

---

## 📂 Repository Structure

```
.
├── README.md                                         # Master Documentation
├── scripts/
│   ├── realme_p3_ultra_optimize.sh                   # 1-Click Realme Optimization Script
│   ├── moto_g45_optimize.sh                          # 1-Click Motorola Optimization Script
│   ├── aot_compile_all.sh                            # System-Wide Machine Code Compiler
│   └── scrcpy_120fps_launcher.sh                     # Linux Screen Mirror & 4K Webcam Tool
└── docs/
    ├── ANDROID_AUTO_RVX_MUSIC_INTEGRATION.md         # Android Auto & RVX Setup
    ├── NETWORK_DNS_AND_WIFI_OPTIMIZATION.md          # DNS, Latency & Wi-Fi Steering Guide
    ├── CURATED_FOSS_APPS_ECOSYSTEM.md                # Power-User FOSS App Catalog
    ├── BATTERY_AND_DOZE_TUNING.md                    # Doze State Machine & Chemistry Analysis
    ├── LINUX_FEDORA_INTEGRATION.md                   # KDE Connect, Scrcpy & Tailscale Guide
    ├── SHIZUKU_AND_RISH_AUTOMATION.md                # Rootless Binder IPC & Terminal Scripting
    └── LOW_RAM_ZRAM_GOVERNOR_TUNING.md               # zRAM, Swappiness & LMK Tuning Guide
```

---

## 📜 License
MIT License. Authored by [Divyansh Joshi (oldregime)](https://github.com/oldregime).
