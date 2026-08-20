# ⚡ Shizuku & `rish` Rootless Terminal Automation Guide

Shizuku leverages Android's hidden inter-process communication (IPC) bindings to grant privileged ADB / `android.permission.INTERACT_ACROSS_USERS` access to user-space apps without unlocking the bootloader or rooting the device.

---

## 🎯 What is Shizuku & `rish`?

* **Shizuku Service:** Runs a Binder server with system/ADB credentials (`uid=2000`), exposing system service APIs (`IPackageManager`, `IActivityManager`, `IAppOpsService`, `IWindowManager`).
* **`rish` (Rootless Interactive Shell):** A native binary executable bundled with Shizuku that allows terminal emulators like **Termux** to run full ADB shell commands directly on-device without needing a PC or Wi-Fi debugging reconnection after initial boot.

---

## 🚀 1. Setting Up `rish` inside Termux

Once Shizuku is activated via Wireless Debugging:

1. Open **Termux** and export the `rish` files:
   ```bash
   cp /sdcard/Android/data/moe.shizuku.privileged.api/files/rish* $HOME/
   chmod +x $HOME/rish
   ```

2. Generate or link the dex loader:
   ```bash
   echo "alias rish='$HOME/rish'" >> ~/.bashrc
   source ~/.bashrc
   ```

3. Launch privileged rootless shell:
   ```bash
   rish
   ```
   > When prompted, grant Termux permission inside the Shizuku authorization dialog.

---

## 🛠️ 2. Automated App Ops & Background Execution Permissions

Through `rish` or ADB, grant background execution and unrestricted network permissions to critical tools:

```bash
# Grant SD Maid SE privileged package inspection
appops set eu.thedarken.sdm GET_USAGE_STATS allow
appops set eu.thedarken.sdm PACKAGE_USAGE_STATS allow

# Grant Hail / Canta instant rootless app freezing & uninstallation
appops set com.aistra.hail SYSTEM_ALERT_WINDOW allow
appops set io.github.samolego.canta INTERACT_ACROSS_USERS allow

# Force App Standby exemption (White-list from Doze)
dumpsys deviceidle whitelist +app.revanced.android.apps.youtube.music
dumpsys deviceidle whitelist +com.google.android.gms
```

---

## ⚙️ 3. Headless Battery & Governor Scripts via Termux Cron

You can run automated maintenance routines on your device at scheduled times:

```bash
# Flush memory caches and compile newly updated apps overnight
rish -c "pm compile -m speed -a"
rish -c "am kill-all"
```

---

## 🔒 Security Best Practices
- Only grant Shizuku permission to verified open-source applications (Canta, Hail, SD Maid SE, Termux, App Manager).
- Revoke permissions immediately if an app is no longer actively used.
