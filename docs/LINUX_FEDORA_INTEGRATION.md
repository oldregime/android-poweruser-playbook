# 🐧 Fedora Linux Workstation & Android Cross-Device Suite

## 🔗 1. KDE Connect Protocol & Desktop Hub

KDE Connect operates an end-to-end TLS-encrypted UDP/TCP socket across the local LAN (ports `1714:1764`).

### Configured Features:
1. **SMS & 2FA / OTP Auto-Forwarding:** Incoming bank OTPs and authentication tokens trigger an instant desktop notification with a 1-click clipboard copy action.
2. **Universal Clipboard Sharing:** Bi-directional sync between Linux X11/Wayland clipboard and Android `ClipboardManager`.
3. **Doze Whitelisting:** Configured via `dumpsys deviceidle whitelist +org.kde.kdeconnect_tp` to prevent background drops.
4. **Remote Input:** Touchpad and virtual keyboard control via Android accessibility service.

---

## 🖥️ 2. Scrcpy Ultra-Low Latency Display & Audio Pipeline

* **Video Codec:** `H.265 (HEVC)` hardware decoded on Linux GPU.
* **Framerate:** Locked to `120 FPS` matching device refresh rate.
* **Audio Codec:** `Opus` 48kHz audio stream forwarded via PipeWire/PulseAudio.
* **Studio Webcam:** Direct V4L2 video loopback for Zoom, Google Meet, and OBS Studio.

```bash
# High-Definition 120Hz Screen Mirror
scrcpy --max-fps=120 --video-codec=h265 --audio-codec=opus --stay-awake

# 4K Camera Web-Camera Forwarding
scrcpy --video-source=camera --camera-size=1920x1080 --camera-fps=60
```

---

## 🤖 7. Antigravity (AGY) & Claude MCP Phone Bridge (`rish-mcp`)

The **`rish-mcp`** integration exposes the Realme P3 Ultra's elevated Shizuku shell directly to AI agents (Antigravity AGY CLI & Claude Code) as native MCP tools.

### Architecture Topology:
* **Relay Server Container:** `localhost/rish-mcp-relay:latest` running via Podman on `0.0.0.0:8080`.
* **Local Bridge Script:** `/home/dj/.gemini/config/rish_mcp_bridge.py`.
* **Global MCP Config:** `/home/dj/.gemini/config/mcp_config.json`.
* **Available MCP Tools:**
  * `run_shell(cmd)`: Run any elevated shell command on the phone as UID 2000 (`adb shell`).
  * `list_devices()`: List active connected phones/tablets.

---

## ☁️ 8. Oracle Cloud Always-Free 24/7/365 Deployment

The `rish-mcp` relay server is permanently deployed on the **Oracle Cloud Always Free VM** (`immich-amd-vnic`):

* **Oracle VM Tailscale IP:** `100.119.62.87` (Port `8080`)
* **Security Model:**
  * Zero open inbound public ports on the Internet.
  * Encrypted WireGuard mesh communication via Tailscale between Oracle Cloud, your phone, and your laptop.
  * Your laptop runs **0 background services**, uses **0 CPU/battery**, and can be asleep or offline while your phone stays connected to the AI cloud relay.
