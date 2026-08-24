# Emergency Rescue & Broken Screen Recovery Suite

Complete contingency system to control, unlock, mirror, and back up your Realme P3 Ultra from your Fedora laptop during hardware touch failure, shattered screen, or broken display.

---

## 1. Quick Terminal Commands
```bash
# Launch interactive rescue menu
rescuephone
# or
~/rescue_realme_phone.sh
```

---

## 2. Capabilities
1. **Interactive Screen Control (`scrcpy`):** Control the entire phone with your laptop's mouse and keyboard at 120 FPS.
2. **Remote PIN / Password Unlock:** Wakes screen, types PIN, and dismisses lockscreen directly over ADB.
3. **Automated Zero-Touch Emergency Backup:** Copies `/sdcard/DCIM`, `/sdcard/Pictures`, `/sdcard/Documents`, `/sdcard/Download`, and media into a timestamped directory on your PC (`~/PhoneRescue_Backup_<timestamp>`).
4. **Hardware Diagnostic Readout:** Instant readout of battery health, thermal zone temps, UFS storage wear, and RAM pressure.
