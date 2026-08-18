# 📱 Realme P3 Ultra 5G — Complete Hardware, OS & System Manifest

**Audited & Compiled at:** `2026-08-18`  
**Serial Number:** `5LSWFQKNL7EQWKBU`  
**Hardware Platform:** `  ()`  

---
## 🛠️ 1. Hardware & System Kernel Specifications

| Specification | Value |
| :--- | :--- |
| **Device Model** | `` / `` |
| **Brand & Manufacturer** | `` / `` |
| **Processor (SoC)** | `MediaTek Dimensity 8350 Ultra (4nm)` |
| **CPU Architecture / ABIs** | `` |
| **Display Native Resolution** | `` |
| **Display Density** | `` |
| **Android Version** | `Android ` (Realme UI 6.0) |
| **Build ID / Firmware** | `` |
| **Android Security Patch** | `` |
| **System Kernel** | `` |
| **Build Fingerprint** | `` |

---
## ⚡ 2. Active System Tuning & Low-Latency Parameter Table

| Parameter / Subsystem | Active Setting | Stock Default | Impact & Benefit |
| :--- | :--- | :--- | :--- |
| **Display Min Refresh Rate** | **` Hz`** | `60.0 Hz` | Locks 120Hz display refresh rate; eliminates frame-pacing lag |
| **Display Peak Refresh Rate** | **` Hz`** | `120.0 Hz` | Prevents display controller down-clocking |
| **Window Animation Scale** | **`x`** | `1.0x` | 50% faster UI window animations |
| **Transition Animation Scale** | **`x`** | `1.0x` | 50% faster screen transition animations |
| **Animator Duration Scale** | **`x`** | `1.0x` | 50% faster widget and button physics |
| **Long Press Timeout** | **` ms`** | `400 ms` | 40% faster touch hold / text selection response |
| **Battery Saver Auto-Level** | **``** | `20` | Battery saver NEVER automatically engages or forces 60Hz |
| **Doze Deep Sleep State** | **`30s Trigger`** | `30m Trigger` | Processor enters deep sleep in 30s; overnight drain <1% |
| **Mobile Data on Wi-Fi** | **``** | `1` | 5G modem powers down on Wi-Fi, saving ~10% battery |
| **Encrypted Private DNS** | **``** | `Off` | System-wide ad-blocking and encrypted DNS-over-TLS |

---
## 📦 3. Complete Third-Party Installed Packages (0 Apps)

All installed applications below are compiled to **Native ARMv9 Machine Code (AOT Speed Dexopt)**:

---
## ❄️ 4. Suspended / Debloated Telemetry & Bloatware (0 Packages)


---
## 🔗 5. Fedora Linux Workstation Ecosystem Binding

* **Workstation Host:** Fedora Linux (`x86_64`)
* **KDE Connect Device Node:** `realme P3 Ultra 5G` (`adef11437f9644068fc484d0542f4f14`)
* **Network Channels:**
  * Local LAN Wi-Fi 6 (`192.168.29.67`)
  * Tailscale Mesh VPN (`100.91.79.4`)
* **Scrcpy Low-Latency Profile:**
  ```bash
  scrcpy --max-fps=120 --video-codec=h265 --audio-codec=opus --stay-awake
  ```