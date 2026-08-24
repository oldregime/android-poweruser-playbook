# Desk Ambient Homelab & PC Telemetry Smart Dock

Transform your Realme P3 Ultra 5G into an always-on, high-contrast, pure-black OLED desk monitor showing live PC stats (AMD Ryzen CPU, NVIDIA GPU, RAM, Network), Homelab node pings (TrueNAS, Immich), weather, and a 1-tap PC Macropad.

---

## 1. Features
* **OLED Pure Black (#000000):** Consumes zero backlight power on AMOLED pixels.
* **Anti-Burn-In Protection:** Dynamic pixel-shifting moves DOM elements every 60 seconds.
* **Live PC Telemetry (WebSockets):** Ryzen 7 7840HS temp/load, RTX 4050 VRAM/power/temp, RAM, Network I/O.
* **Homelab Sentinel:** Real-time ping indicators for TrueNAS SCALE and Immich servers over Tailscale.
* **Interactive Macropad:** 1-tap Mic Mute, Volume adjustments, Media controls, and PC Screen Lock.
* **Weather & Clock:** Auto-synced live temperature, humidity, wind, and digital clock.

---

## 2. Accessing the Dashboard

### On Your Phone
* **Local Home Wi-Fi URL:** `http://192.168.29.97:7890`
* **Tailscale Remote URL:** `http://100.112.130.105:7890`

*(Tap the **3 dots** in Chrome/Brave $\rightarrow$ **"Add to Home screen"** or **"Install app"** for an immersive zero-border fullscreen app).*

---

## 3. Service Management
```bash
# Check service status on Fedora
systemctl --user status desk-telemetry.service

# Restart service
systemctl --user restart desk-telemetry.service
```
