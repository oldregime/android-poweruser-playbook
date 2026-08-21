#!/usr/bin/env bash
# 🚀 Smart 1-Click Realme Phone SSHFS Auto-Mounter

MOUNT_DIR="$HOME/phone_storage"
SSH_KEY="$HOME/.ssh/id_ed25519"
PORT=8022

mkdir -p "$MOUNT_DIR"

# Check if already mounted
if mountpoint -q "$MOUNT_DIR"; then
    echo "✅ Phone is already mounted at $MOUNT_DIR"
    exit 0
fi

# Auto-detect active phone IP (LAN or Tailscale)
PHONE_IP=""
for ip in "192.168.29.133" "192.168.29.67" "192.168.29.66" "100.65.98.105"; do
    if ping -c 1 -W 1 "$ip" >/dev/null 2>&1; then
        PHONE_IP="$ip"
        break
    fi
done

if [ -z "$PHONE_IP" ]; then
    echo "❌ Error: Could not reach phone on Wi-Fi or Tailscale."
    exit 1
fi

echo "🔍 Found phone at $PHONE_IP..."

# Check if SSH server is responding
nc -z -w 1 "$PHONE_IP" "$PORT" >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "⚡ SSH server not active. Auto-starting Termux sshd via ADB..."
    adb connect "$PHONE_IP:5555" >/dev/null 2>&1
    adb -s "$PHONE_IP:5555" shell "input keyevent 224 && am start -n com.termux/.app.TermuxActivity && sleep 0.5 && input text 'sshd' && input keyevent 66" >/dev/null 2>&1
    sleep 2
fi

# Attempt Mount
echo "🔗 Mounting storage to $MOUNT_DIR..."
sshfs -p "$PORT" \
    -o IdentityFile="$SSH_KEY" \
    -o reconnect \
    -o follow_symlinks \
    -o ServerAliveInterval=15 \
    -o ServerAliveCountMax=3 \
    "$PHONE_IP:/storage/emulated/0" "$MOUNT_DIR"

if mountpoint -q "$MOUNT_DIR"; then
    echo "✅ SUCCESS: Realme Phone mounted at $MOUNT_DIR"
    echo "📂 Opening file manager..."
    xdg-open "$MOUNT_DIR" >/dev/null 2>&1 &
else
    echo "❌ Mount failed. If screen is locked, unlock your phone once and retry."
fi
