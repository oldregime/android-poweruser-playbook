#!/usr/bin/env bash
MOUNT_DIR="$HOME/phone_storage"

if mountpoint -q "$MOUNT_DIR"; then
    fusermount3 -u "$MOUNT_DIR" || fusermount -u "$MOUNT_DIR"
    echo "✅ Phone unmounted successfully."
else
    echo "ℹ️ Phone is not currently mounted."
fi
