# Master Guide: Best Hail App Freezer Settings (Shizuku)

Hail (`com.aistra.hail`) is the most powerful open-source app freezer for non-rooted Android 15. It completely disables background trackers, analytics, and wakelocks of heavy apps until you actually tap to open them.

---

## 1. Optimal Settings Configuration

1. **Working Mode:**
   * Go to **Hail Settings (⚙️)** $\rightarrow$ **Working Mode** $\rightarrow$ Select **`Shizuku`** (or `Shizuku - Disable`).
2. **Auto-Freeze Automation:**
   * **Auto freeze on screen lock:** **Enabled (ON)**.
   * **Auto freeze timeout:** **0 seconds (Immediately on lock)**.
   * **Unfreeze & Launch:** **Enabled (ON)** *(Tapping any frozen app unfreezes and opens it in 0.1s)*.
3. **Display & Tagging:**
   * **Show app badge:** ON *(Shows a snowflake icon on frozen apps)*.
   * **Quick Settings Tile:** Add the **"Hail"** tile to your notification quick toggles to 1-tap freeze everything.

---

## 2. High-Impact Apps to Freeze (Recommended List)

### 🛒 Shopping & Quick Commerce (Aggressive Background Trackers)
* Amazon Shopping (`in.amazon.mShop.android.shopping`)
* Flipkart (`com.flipkart.android`)
* Meesho (`com.meesho.supply`)
* Blinkit (`com.grofers.customerapp`)
* Zepto (`com.zeptoconsumerapp`)
* Swiggy & Instamart (`in.swiggy.android`)
* CashKaro & OLX (`com.cashkaro`, `com.olx.southasia`)

### 🚕 Cabs & Travel
* Uber (`com.ubercab`)
* Ola Cabs (`com.olacabs.customer`)
* Rapido (`com.rapido.passenger`)
* MyKia (`com.kia.mykia`)

### 🎮 Heavy Games & Seldom-Used Apps
* Need for Speed No Limits (`com.ea.game.nfs14_row`)
* CarX Street (`com.carxtech.sr`)
* Prime Video (`com.amazon.avod.thirdpartyclient`)
* Cloudstream (`com.lagradost.cloudstream3.prerelease`)
* Facebook, LinkedIn, Twitter (if you don't need continuous notifications)

---

## 3. Apps You Should NEVER Freeze
* Communication / Messaging: **WhatsApp, Telegram, Phone, Messages**.
* Core Background Services: **Shizuku, Bitwarden, Tailscale, Termux, Immich, Lawnchair, KeyMapper**.
