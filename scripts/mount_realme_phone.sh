#!/usr/bin/env bash
# 🚀 1-Click Realme Phone SSHFS Mount Script for Fedora Linux

MOUNT_DIR="$HOME/phone_storage"
SSH_KEY="$HOME/.ssh/id_ed25519"
PORT=8022

mkdir -p "$MOUNT_DIR"

# Auto-detect IP (Local Wi-Fi or Tailscale)
PHONE_IP=""
for ip in "192.168.29.133" "192.168.29.67" "192.168.29.66" "100.65.98.105"; do
    if ping -c 1 -W 1 "$ip" >/dev/null 2>&1; then
        PHONE_IP="$ip"
        break
    fi
done

if [ -z "$PHONE_IP" ]; then
    echo "❌ Error: Could not reach phone on Wi-Fi or Tailscale (100.65.98.105)."
    exit 1
fi

echo "🔍 Connecting to Realme Phone at $PHONE_IP:$PORT..."

# Check if already mounted
if mountpoint -q "$MOUNT_DIR"; then
    echo "✅ Phone is already mounted at $MOUNT_DIR"
    exit 0
fi

# Mount phone internal storage via SSHFS
sshfs -p "$PORT" \
    -o IdentityFile="$SSH_KEY" \
    -o reconnect \
    -o follow_symlinks \
    -o ServerAliveInterval=15 \
    -o ServerAliveCountMax=3 \
    "$PHONE_IP:/storage/emulated/0" "$MOUNT_DIR"

if mountpoint -q "$MOUNT_DIR"; then
    echo "✅ SUCCESS: Realme Phone mounted as native drive at $MOUNT_DIR"
    echo "📂 Opening file manager..."
    xdg-open "$MOUNT_DIR" >/dev/null 2>&1 &
else
    echo "❌ Mount failed. Ensure sshd is running in Termux on your phone."
fi
