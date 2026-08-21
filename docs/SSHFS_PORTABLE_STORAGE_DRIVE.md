# Android as an Encrypted Portable Linux Storage Drive (SSHFS)

Mount your Realme P3 Ultra internal storage (`/sdcard`) natively as a high-speed encrypted Linux drive on Fedora via Termux OpenSSH, local Wi-Fi, or Tailscale mesh networking.

---

## 1. Architecture Overview
* **Phone Side:** Termux running OpenSSH server on port `8022` with key-based authentication (`id_ed25519`).
* **Storage Symlink:** `/storage/emulated/0` (Internal Storage: DCIM, Downloads, Documents, Pictures, Music).
* **Linux Host:** FUSE `sshfs` client mounting to `~/phone_storage`.
* **Transport:** 5 GHz Wi-Fi (`390–433 Mbps`) for local zero-latency transfers or Tailscale (`100.65.98.105`) for remote worldwide mounting over 5G cellular data.

---

## 2. Phone Setup (One-Time Termux Command)
Inside the Termux application on your phone:
```bash
pkg update -y && pkg install -y openssh
mkdir -p ~/.ssh
echo "<HOST_SSH_PUBLIC_KEY>" > ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys && chmod 700 ~/.ssh
termux-setup-storage
termux-wake-lock
sshd
```

---

## 3. Fedora 1-Click Mount & Unmount

### Mount Command
```bash
~/mount_realme_phone.sh
```
*Auto-detects active phone IP on local Wi-Fi or Tailscale, mounts internal storage at `~/phone_storage`, and automatically launches your desktop file manager.*

### Unmount Command
```bash
~/unmount_realme_phone.sh
```

---

## 4. SSHFS Command Syntax Reference
```bash
sshfs -p 8022 \
    -o IdentityFile=~/.ssh/id_ed25519 \
    -o reconnect \
    -o follow_symlinks \
    -o ServerAliveInterval=15 \
    -o ServerAliveCountMax=3 \
    <PHONE_IP>:/storage/emulated/0 ~/phone_storage
```
