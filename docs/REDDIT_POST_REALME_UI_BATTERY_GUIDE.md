# 📱 Reddit Post Draft: r/realme & Realme Community

**Suggested Subreddits:** `r/realme`, `r/Android`, `r/RealmeIndia`  
**Flair:** `Guide / Tips` or `Discussion`  
**Title:** `[GUIDE] How I Fixed Battery Drain, Overheating & Unlocked 120Hz in Power Saving Mode on Realme UI 6.0 (Realme P3 Ultra / Dimensity 8300)`

---

## 📝 Post Content (Copy & Paste below)

### **The Frustration: 6,000 mAh Battery Draining Like a 4,000 mAh Cell?**

If you recently got the **Realme P3 Ultra 5G (RMX5030)** or are running **Realme UI 6.0 / ColorOS 15**, you’ve probably noticed:
1. Battery draining much faster than expected, even with a massive 6,000 mAh battery.
2. The phone gets warm during basic scrolling, Instagram, or casual use.
3. Turning on **Power Saving Mode** locks your display to a choppy **60Hz**, completely ruining the 120Hz AMOLED experience.
4. YouTube ReVanced constantly buffering or freezing after 30 seconds.

I ran a deep ADB telemetry audit on my device over the past few weeks (inspecting `batterystats`, `deviceidle`, kernel wakelocks, and system registers). Here is the complete breakdown of why this happens and how to permanently fix it.

---

### ⚠️ Warning on Software Updates (Don't Rush to Update!)

If you are on **Build `RMX5030_15.0.0.530(EX01)`**, **STAY ON IT**.
* Community reports across Reddit and the official Realme Community show that updates like **`15.0.0.535`**, **`15.0.0.538`**, and the early **`16.0.x`** builds introduce severe battery drain and thermal throttling.
* Many users are actively looking for rollback packages. `15.0.0.530` remains the golden baseline for thermals (32°C–34°C) with zero throttling.

---

### 🚀 Breakthrough 1: "Hybrid 120Hz Mode" (120Hz Fluidity + Battery Saver 24/7)

ColorOS normally caps your screen to 60Hz the moment Battery Saver is turned on. You can completely bypass this cap using ADB:

```bash
# 1. Uncap the 60Hz limit in Power Saving Mode
adb shell "settings put system power_save_screen_refresh_rate 0"

# 2. Prevent Battery Saver from auto-turning off when charged past 90%
adb shell "settings put system power_save_auto_close_switch 0"

# 3. Lock Power Saving Mode permanently ON across reboots
adb shell "settings put global low_power 1"
adb shell "settings put global low_power_sticky 1"

# 4. Force 120Hz high refresh profile
adb shell "settings put secure oplus_customize_screen_refresh_rate 3"
adb shell "settings put secure oplus_refreshrate_override 1"
adb shell "settings put system peak_refresh_rate 120.0"
adb shell "settings put system user_refresh_rate 120"
```
*Result:* You get all the background limits, CPU idle frequency downscaling, and modem power management of Battery Saver, while your display stays **120Hz butter-smooth**.

---

### 🔍 Breakthrough 2: The Rogue Launcher & Motion Sensor Leak

In my battery dump, **Smart Launcher 6 burned 5,932 mAh (literally 99% of a battery cycle)**.
* **Why:** On Android 15, gesture navigation is hardcoded to the stock Realme launcher (`com.android.launcher`). Third-party launchers run simultaneously in RAM.
* Smart Launcher was polling the **gyroscope and motion sensors for 20 hours and 48 minutes**, preventing the Dimensity 8300 Ultra SoC from entering deep C-state sleep!
* **Fix:** If you use a third-party launcher, turn OFF all 3D tilt/parallax effects and motion gestures. If you switch back to the stock Realme launcher, freeze the secondary launcher in **Hail** or suspend it:
  ```bash
  adb shell "cmd package suspend --user 0 ginlemon.flowerfree"
  ```

---

### 🔋 Breakthrough 3: Killing Hidden Background Radio Drains

Even with Wi-Fi and Bluetooth toggled off, Android is secretly scanning for Wi-Fi APs and BLE beacons for Google Location Services:

```bash
# 1. Turn OFF continuous background Wi-Fi AP scanning
adb shell "settings put global wifi_scan_always_enabled 0"

# 2. Disable Google Print Recommendation background broadcast spam
adb shell "pm disable-user --user 0 com.google.android.printservice.recommendation"

# 3. Disable High Performance Mode (prevents CPU clock gates from staying high)
adb shell "settings put global oplus_high_performance_mode 0"
adb shell "settings put system high_performance_mode_on 0"

# 4. Enable Smart 5G auto-release (drops modem power during screen-off)
adb shell 'settings put global smart_5g 1'
adb shell 'settings put global oplus.radio.smart5g_local_release "ver_num=2;enable=true;screen_off=true;count_per_hour=100;local_release_timer=10;local_release_cnt=20;nonDDS_local_release_enable=true"'

# 5. Restrict background battery drain on heavy shopping/delivery apps
for pkg in in.amazon.mShop.android.shopping com.flipkart.android com.grofers.customerapp \
           com.zeptoconsumerapp in.swiggy.android com.application.zomato com.meesho.supply; do
    adb shell "cmd appops set $pkg RUN_ANY_IN_BACKGROUND ignore"
    adb shell "cmd appops set $pkg RUN_IN_BACKGROUND ignore"
done
```

---

### 📺 Breakthrough 4: Fixing YouTube ReVanced Buffering & Freezing

If your ReVanced YouTube videos keep spinning or freeze after 30 seconds:
1. Open YouTube ReVanced $\rightarrow$ **Settings $\rightarrow$ ReVanced $\rightarrow$ Player / Miscellaneous**.
2. **Turn OFF "Spoof video streams"** (on modern v20.x+ builds, Google flags the `VisionOS` / `Android VR` spoof client headers, but passes native streams directly!).
3. Whitelist YouTube and GmsCore from battery optimization so ColorOS doesn't kill the microG session:
   ```bash
   adb shell "dumpsys deviceidle whitelist +app.revanced.android.youtube"
   adb shell "dumpsys deviceidle whitelist +app.revanced.android.gms"
   ```

---

### 💡 2 Settings to Change in Your Phone's UI

1. **Turn OFF RAM Expansion (Virtual RAM):**
   * *Settings $\rightarrow$ About device $\rightarrow$ RAM $\rightarrow$ RAM Expansion OFF $\rightarrow$ Restart phone.*
   * You already have **12 GB of LPDDR5X RAM**. Virtual RAM writes swap to flash storage, heating up the SoC and burning battery.
2. **Turn ON Sleep Standby Optimization:**
   * *Settings $\rightarrow$ Battery $\rightarrow$ More settings $\rightarrow$ Sleep Standby Optimization ON.*
   * Cuts overnight battery drain down to **1%–2% total**.

---

### 📊 Results After Optimization:
* **Overnight Standby Drain:** Down from ~8–10% to **1.5%**.
* **Screen-On Time:** Increased from ~5–6 hours to **9.5–10.5+ hours**.
* **Idle Thermals:** 32.7°C (runs completely cool).
* **Display:** Permanent 120Hz fluid motion with Battery Saver active.

Feel free to ask questions in the comments! Happy to help troubleshoot.
