# Android Auto & RVX Music Integration Guide

Comprehensive guide for running YouTube Music ReVanced / RVX seamlessly inside Android Auto without triggering Google's "Requires Premium" paywall.

---

## 1. Problem Overview
Google enforces server-side license checks when Android Auto (`com.google.android.projection.gearhead`) requests media browsing and playback. Non-premium Google accounts streaming to car head units encounter:
* `"Requires YouTube Music Premium to use this feature"`
* Infinite buffering or blocked media playback.
* App missing completely from the car display app launcher.

---

## 2. Step-by-Step Fix

### Step A: Unlock Android Auto Developer Settings
1. On your phone, navigate to **Settings > Connected devices > Android Auto** (or launch via intent `am start -a com.google.android.projection.gearhead.SETTINGS`).
2. Scroll to the bottom and tap **Version** 10 times consecutively until the toast appears: `Developer mode enabled`.
3. Tap the **3-dot menu** in the top right corner > **Developer settings**.
4. Check **Unknown sources** (enables sideloaded & patched media apps).
5. Set **Application Mode** to `Developer` or `Release`.

### Step B: Configure RVX Music Client Spoofing
1. Open **RVX Music** on the device.
2. Tap your profile icon > **Settings > RVX / ReVanced Extended**.
3. Go to **Miscellaneous** (or **Player** depending on build).
4. Under **Spoof Video Streams / Spoof Client**:
   * Set Default Client to **`visionOS`** (Apple Vision Pro client) or **`Android VR`** / **`iOS`**.
   * `visionOS` completely bypasses server-side playback restrictions, 1-minute buffering bugs, and car verification checks.
5. Force close and relaunch RVX Music.

### Step C: Battery Whitelist & Background Immunity
Prevent aggressive OEM skins (Realme UI / ColorOS) from killing the media session in the background:
```bash
# Add RVX Music to battery optimization whitelist
adb shell "dumpsys deviceidle whitelist +app.rvx.android.apps.youtube.music"

# Grant unrestricted background execution
adb shell "cmd appops set app.rvx.android.apps.youtube.music RUN_IN_BACKGROUND allow"
adb shell "cmd appops set app.rvx.android.apps.youtube.music RUN_ANY_IN_BACKGROUND allow"
adb shell "cmd appops set app.rvx.android.apps.youtube.music START_FOREGROUND allow"
```

### Step D: Auto-Start on Connection
1. In Android Auto settings > **General** > Turn ON **Start music automatically**.
2. Go to **Customize launcher** and ensure **RVX Music** is checked and placed at the top.
3. *Workaround for cold starts:* If the car screen ever complains about browsing, initiate playback of your playlist/track on the phone right before or during connection. Android Auto will seamlessly maintain the audio session with full steering wheel and head-unit controls.
