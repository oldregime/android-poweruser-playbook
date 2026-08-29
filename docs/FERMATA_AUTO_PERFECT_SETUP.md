# Fermata Auto v2.0.2: Perfect Android Auto Video Setup

Fermata Auto (`me.aap.fermata.auto.dear.google.why`) is the premier open-source multimedia player for Android Auto. It allows full 1080p/4K movie and video playback with subtitles and multi-audio support directly on your car's touchscreen display.

---

## 1. Automated Installation & System Config
* **Package:** `me.aap.fermata.auto.dear.google.why` (v2.0.2 arm64-v8a)
* **Play Store Tag:** `installerPackageName=com.android.vending` *(Enables Android Auto detection on Android 15)*.
* **Storage Access:** `MANAGE_EXTERNAL_STORAGE` and `READ_MEDIA_VIDEO` granted.
* **Doze Exemption:** Added to battery whitelist (`dumpsys deviceidle whitelist`).
* **Performance:** AOT 64-bit speed compiled (`cmd package compile -m speed`).

---

## 2. 1-Minute Android Auto Car Launcher Verification

### On Your Phone:
1. Open **Settings $\rightarrow$ Android Auto**.
2. Scroll to the bottom and **tap "Version" 10 times** to enable Developer settings.
3. Tap the **3 dots (⋮)** in the top-right $\rightarrow$ **Developer settings** $\rightarrow$ Check **"Unknown sources"**.
4. Go back to the main Android Auto menu $\rightarrow$ Tap **"Customize launcher"** $\rightarrow$ Ensure **Fermata Auto** is checked!

---

## 3. Adding Your Downloaded Movies Folder

1. Open **Fermata Auto** on your phone.
2. Tap the **Folders / Video** icon at the bottom $\rightarrow$ Tap **"Add folder"** (+).
3. Select your **`Download`** or **`Movies`** directory.
4. Connect to your car (Wired or Wireless Android Auto) $\rightarrow$ Tap **Fermata Auto** on your dashboard!
