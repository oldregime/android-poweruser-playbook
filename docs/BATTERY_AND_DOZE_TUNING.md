# 🔋 Deep Doze State Machine & Battery Chemistry Analysis

## 🧪 1. Lithium-Ion Battery Degradation Mechanics

Lithium-ion cells in modern smartphones (e.g. Realme 5,000mAh, Moto 5,000mAh) degrade primarily through:
1. **High-Voltage Saturation (>4.20V per cell):** Holding an electrochemical cell at 100% capacity (4.35V - 4.45V) accelerates electrolyte decomposition and SEI (Solid Electrolyte Interphase) thickening.
2. **Thermal Stress (>35°C during rapid charging):** Increases internal impedance and promotes lithium plating.
3. **Cycle Depth:** Charging from 20% to 80% represents approximately **0.2 nominal charge cycles**, allowing a battery to last **1,500–2,000 cycles** (4–6 years) compared to just 500 cycles with standard 0%–100% charging.

---

## ⚡ 2. Android Doze Mode State Transitions

Android manages power via two cascaded idle loops:
1. **Light Doze (Screen off, battery discharging):** Batches network jobs every 5–15 minutes.
2. **Deep Doze (Screen off, stationary, no movement):** Shuts down maintenance windows, pauses alarms, suspends location requests, and limits sync adapters.

### Stock vs Power-User Doze Parameters:

| Parameter | Stock Android Default | Tuned Power-User Value | Purpose |
| :--- | :--- | :--- | :--- |
| `inactive_to` | 1800000 ms (30 mins) | **30000 ms (30 secs)** | Time after screen off before entering idle state |
| `sensing_to` | 240000 ms (4 mins) | **0 ms** | Disables motion sensing verification loop |
| `locating_to` | 30000 ms (30 secs) | **0 ms** | Disables GPS location fixes prior to deep idle |
| `motion_inactive_to` | 600000 ms (10 mins) | **0 ms** | Instantly triggers deep sleep upon stillness |
| `idle_after_inactive_to` | 1800000 ms (30 mins) | **0 ms** | Zero delay between inactive and deep sleep |

---

## 🛠️ 3. ADB Deployment Command

```bash
device_idle_constants="inactive_to=30000,sensing_to=0,locating_to=0,location_accuracy=20.0,motion_inactive_to=0,idle_after_inactive_to=0"
adb shell settings put global device_idle_constants $device_idle_constants
```


---

## 🚀 4. Realme UI 6.0 / ColorOS 15 Hybrid 120Hz Power Save Mode

By default, turning on Android / ColorOS Power Saving Mode (`low_power=1`) forces the display to downclock to 60Hz. You can bypass this restriction and achieve **Hybrid Endurance Mode** (all background governor savings active, but with locked 120Hz display refresh):

```bash
# 1. Disable ColorOS from downclocking refresh rate in Power Saving Mode
adb shell "settings put system power_save_screen_refresh_rate 0"

# 2. Prevent Power Saving Mode from auto-closing when charged past 90%
adb shell "settings put system power_save_auto_close_switch 0"

# 3. Lock Power Saving Mode permanently ON across reboots & battery cycles
adb shell "settings put global low_power 1"
adb shell "settings put global low_power_sticky 1"

# 4. Lock 120Hz High Refresh Rate & bypass ColorOS dynamic caps
adb shell "settings put secure oplus_customize_screen_refresh_rate 3"
adb shell "settings put secure oplus_refreshrate_override 1"
adb shell "settings put system peak_refresh_rate 120.0"
adb shell "settings put system user_refresh_rate 120"
```

---

## 🔍 5. Rogue App & Motion Sensor Drain Postmortem (Smart Launcher 6)

During diagnostic audits, Smart Launcher 6 (`ginlemon.flowerfree`) was identified burning **5,932 mAh (98.8% of a full 6,000 mAh battery)** due to:
* **Continuous Sensor Wakeups:** Gyroscope and accelerometer polled for **20 hours, 48 minutes**, blocking MediaTek Dimensity 8300 Ultra low-power C-states.
* **Sticky Background Daemons:** `:ssd` (Smart Search Daemon) and NotificationListener running continuously even when the default launcher was switched back to stock ColorOS (`com.android.launcher`).

### Prevention & Solution:
* **Avoid Dual-Launcher Overhead:** On Android 15, gesture navigation is hardcoded into `com.android.launcher`. Third-party launchers run simultaneously in RAM.
* **Freeze in Hail:** When not actively used, keep secondary launchers frozen in **Hail** or suspended via ADB:
  ```bash
  adb shell "cmd package suspend --user 0 ginlemon.flowerfree"
  ```

---

## 📡 6. Radio Frequency (RF) & Wi-Fi Background Scanning Elimination

Google Location Services and Print Spooler periodically wake the cellular and Wi-Fi modems even when Wi-Fi is toggled off:

```bash
# Disable continuous Wi-Fi AP scanning in the background
adb shell "settings put global wifi_scan_always_enabled 0"

# Disable Google Print Recommendation network broadcast scanner
adb shell "pm disable-user --user 0 com.google.android.printservice.recommendation"
```

---

## 📶 7. Smart 5G Auto-Release & Cellular Modem Optimization

5G Standalone (`SA`) keeps high-power RF transmit chains active. Enabling Smart 5G auto-release allows the modem to transition to 4G LTE during idle screen-off states:

```bash
adb shell "settings put global smart_5g 1"
adb shell 'settings put global oplus.radio.smart5g_local_release "ver_num=2;enable=true;screen_off=true;count_per_hour=100;local_release_timer=10;local_release_cnt=20;nonDDS_local_release_enable=true"'
```

---

## 🛡️ 8. Background Isolation for Shopping & Delivery Apps

Indian quick-commerce apps (Amazon, Flipkart, Swiggy, Zomato, Blinkit, Zepto, Meesho) run frequent background location and alarm checks:

```bash
SHOPPING_APPS=(
    "in.amazon.mShop.android.shopping" "com.flipkart.android"
    "com.grofers.customerapp" "com.zeptoconsumerapp"
    "in.swiggy.android" "com.application.zomato" "com.meesho.supply"
)

for pkg in "${SHOPPING_APPS[@]}"; do
    adb shell "cmd appops set $pkg RUN_ANY_IN_BACKGROUND ignore"
    adb shell "cmd appops set $pkg RUN_IN_BACKGROUND ignore"
done
```

---

## ⚠️ 9. Firmware Update Policy: Why Staying on 15.0.0.530 Is Optimal

Telemetry from Realme Community & Reddit for **RMX5030**:
* Builds such as `15.0.0.535`, `15.0.0.538`, and `16.0.x` introduce severe thermal throttling and battery drain (effective battery backup drops to feeling like ~4,000 mAh).
* **Current build `15.0.0.530(EX01)` remains the golden build** for thermal stability (33.9°C), zero throttling, and full 6,000 mAh learned capacity retention.
