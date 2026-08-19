# Android Network, DNS & Wi-Fi Optimization Guide

Comprehensive optimization reference for DNS latency, ISP censorship bypass, dual-band Wi-Fi steering, and fast 5G/4G network toggles.

---

## 1. Private DNS Benchmark & Optimization

### Why Stock ISP & AdGuard DNS Struggle
* **Stock ISP DNS (Jio/Airtel):** Applies heavy DNS-level domain blocking, tracks browsing history, and suffers from inconsistent routing to international servers.
* **AdGuard DNS (`dns.adguard-dns.com`):** Adds **200–290 ms** latency overhead due to overseas traffic filtering and inspection nodes.

### Device Latency Benchmark Results (India)
| DNS Provider | Specifier | Round-Trip Latency | Result |
| :--- | :--- | :--- | :--- |
| **AdGuard DNS** | `dns.adguard-dns.com` | `209.5 ms` (Peak 290 ms) | 🔴 Slow / High Jitter |
| **Cloudflare 1.1.1.1** | `one.one.one.one` | **`17.2 ms`** | 🟢 **Ultra-Fast (12x Faster)** |
| **Google DNS** | `dns.google` | `17.3 ms` | 🟢 Ultra-Fast |
| **Control D (Ad-Block)** | `p2.freedns.controld.com` | `25.2 ms` | 🟢 Fast + Ad-Blocking |

### Setting Cloudflare via ADB
```bash
adb shell "settings put global private_dns_mode hostname"
adb shell "settings put global private_dns_specifier one.one.one.one"
```

---

## 2. Wi-Fi Dual-Band Steering & Scan Throttling

### The 2.4 GHz vs 5 GHz Auto-Connect Dilemma
When a router broadcasts separate SSIDs for 2.4 GHz (e.g., `Lnjoshijio4g`) and 5 GHz (e.g., `Lnjoshijio_5G`), Android defaults to the stronger RSSI signal (e.g., -51 dBm on 2.4 GHz vs -65 dBm on 5 GHz).

#### Solution:
1. In phone **Settings > Wi-Fi**, tap `ⓘ` on `Lnjoshijio4g` and **Turn OFF Auto-connect**.
2. Tap `Lnjoshijio_5G` and ensure **Auto-connect is ON**.
3. Push suggestion directly to the OS:
```bash
adb shell "cmd wifi add-suggestion <SSID_5G> wpa2 <PASSWORD> -s"
```

### Disable Wi-Fi Scan Throttling
Android limits background Wi-Fi scanning to 4 times per 2 minutes. For real-time signal analysis:
```bash
adb shell "settings put global wifi_scan_throttle_enabled 0"
```

---

## 3. One-Tap 5G / 4G Network Switching

* **Control Center Quick Settings Tile:** Edit active tiles and add **"5G"** / **"Smart 5G"** to the primary drawer.
* **Home Screen Shortcut / KeyMapper:** Create a one-tap action targeting the Testing menu (`*#*#4636#*#*` / `com.android.settings/.RadioInfo`) to lock `NR Only` (Pure 5G) or fallback to `LTE Only`.
