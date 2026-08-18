# 🔋 Deep Doze State Machine & Battery Chemistry Analysis

## 🧪 1. Lithium-Ion Battery Degradation Mechanics

Lithium-ion cells in modern smartphones (e.g. Realme 5,000mAh, Moto 5,000mAh) degrade primarily through:
1. **High-Voltage Saturation (>4.20V per cell):** Holding an electrochemical cell at 100% capacity (4.35V - 4.45V) accelerates electrolyte decomposition and SEI (Solid Electrolyte Interphase) thickening.
2. **Thermal Stress (>35°C during rapid charging):** Increases internal impedance and promotes lithium plating.
3. **Cycle Depth:** Charging from 20% to 80% represents approximately **0.2 nominal charge cycles**, allowing a battery to last **1,500–2,000 cycles** (4–6 years) compared to just 500 cycles with standard 0%–100% charging.

---

## ⚡ 2. Android Doze Mode State Transitions

Android manages power via two cascaded idle loops:
1. **Light Doze (Screen off, battery discharging):** Batches network jobs every 5–15 minutes.
2. **Deep Doze (Screen off, stationary, no movement):** Shuts down maintenance windows, pauses alarms, suspends location requests, and limits sync adapters.

### Stock vs Power-User Doze Parameters:

| Parameter | Stock Android Default | Tuned Power-User Value | Purpose |
| :--- | :--- | :--- | :--- |
| `inactive_to` | 1800000 ms (30 mins) | **30000 ms (30 secs)** | Time after screen off before entering idle state |
| `sensing_to` | 240000 ms (4 mins) | **0 ms** | Disables motion sensing verification loop |
| `locating_to` | 30000 ms (30 secs) | **0 ms** | Disables GPS location fixes prior to deep idle |
| `motion_inactive_to` | 600000 ms (10 mins) | **0 ms** | Instantly triggers deep sleep upon stillness |
| `idle_after_inactive_to` | 1800000 ms (30 mins) | **0 ms** | Zero delay between inactive and deep sleep |

---

## 🛠️ 3. ADB Deployment Command

```bash
device_idle_constants="inactive_to=30000,sensing_to=0,locating_to=0,location_accuracy=20.0,motion_inactive_to=0,idle_after_inactive_to=0"
adb shell settings put global device_idle_constants $device_idle_constants
```
