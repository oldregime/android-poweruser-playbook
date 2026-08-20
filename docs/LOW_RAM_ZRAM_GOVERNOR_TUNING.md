# 🧠 Low-RAM (2GB–4GB) Optimization, zRAM & LMK Tuning

Tuning guide for resource-constrained Android hardware (MediaTek Helio G25/G35, Snapdragon 400/600 series, 2GB/3GB/4GB RAM configurations).

---

## 🏎️ 1. zRAM Compression & Swappiness Optimization

zRAM creates a compressed block device in physical RAM. On 2GB–3GB RAM devices, stock kernel parameters frequently suffer from memory pressure due to inadequate swap ratios.

### Optimal Configuration Matrix:

| Total Physical RAM | Recommended zRAM Size | Compression Algorithm | `vm.swappiness` |
| :--- | :--- | :--- | :--- |
| **2 GB (e.g. Redmi 9A)** | **1.5 GB - 2.0 GB** | `lz4` / `zstd` | **100 - 140** |
| **3 GB - 4 GB** | **2.5 GB - 3.0 GB** | `zstd` | **100** |
| **8 GB - 12 GB (Realme P3 Ultra)** | **3.0 GB - 4.0 GB** | `zstd` | **60 - 80** |

```bash
# Check current zRAM device status
cat /proc/sys/vm/swappiness
cat /sys/block/zram0/comp_algorithm
cat /sys/block/zram0/disksize
```

---

## ⚡ 2. Tuning Low Memory Killer (LMK) & Minfree

Android's LMK drops background applications when free pages drop below defined thresholds:

```bash
# Disable aggressive OEM killer daemons (allow standard Android AOSP LMK)
setprop persist.sys.hardcoder.name 0
setprop persist.sys.oiface.enable 0

# Limit background cached processes on 2GB devices
setprop ro.sys.fw.bg_apps_limit 16
```

---

## 🚀 3. Speed-Profile AOT Compilation for Entry-Level SoCs

Entry-level SoCs spend substantial CPU cycles on Just-In-Time (JIT) runtime compilation. Forcing Ahead-of-Time (AOT) machine code compilation eliminates compilation overhead during app runtime:

```bash
# Compile system framework and user apps
cmd package compile -m speed-profile -a
# Or compile critical daily apps into full native machine code:
cmd package compile -m speed com.google.android.apps.photos
cmd package compile -m speed app.revanced.android.apps.youtube.music
```

---

## 🔋 4. Governor & CPU Core Affinity

For MediaTek Big.LITTLE (4x Cortex-A53 @ 2.0GHz + 4x Cortex-A53 @ 1.5GHz):
- Prevent core unparking delays during UI touch events:
  ```bash
  settings put system power_save_touch_boost 1
  ```
- Keep animations at 0.5x to reduce GPU compositor duration.
