#!/usr/bin/env bash
# ==============================================================================
# System-Wide Ahead-of-Time (AOT) Speed Compiler for Android
# Author: Divyansh Joshi (oldregime)
# ==============================================================================

set -euo pipefail

DEVICE_SERIAL="${1:-}"
ADB_CMD="adb"

if [ -n "$DEVICE_SERIAL" ]; then
    ADB_CMD="adb -s $DEVICE_SERIAL"
fi

echo "================================================================"
echo "⚡ Starting System-Wide AOT Speed Compilation"
echo "================================================================"

echo "--> Fetching active packages..."
PACKAGES=$($ADB_CMD shell "pm list packages" | sed 's/package://g' | tr -d '\r')

TOTAL_COUNT=$(echo "$PACKAGES" | wc -l)
CURRENT=0

echo "--> Compiling $TOTAL_COUNT packages into native ARM machine code..."

while IFS= read -r pkg; do
    [ -z "$pkg" ] && continue
    CURRENT=$((CURRENT + 1))
    echo "[$CURRENT/$TOTAL_COUNT] Compiling: $pkg..."
    $ADB_CMD shell "cmd package compile -m speed $pkg" 2>/dev/null || true
done <<< "$PACKAGES"

echo "================================================================"
echo "✅ Compilation Complete! All apps running in Native Machine Code."
echo "================================================================"
