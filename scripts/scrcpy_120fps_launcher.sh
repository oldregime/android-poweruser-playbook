#!/usr/bin/env bash
# ==============================================================================
# Scrcpy 120FPS Low-Latency Mirroring & 4K Studio Webcam Launcher
# Author: Divyansh Joshi (oldregime)
# ==============================================================================

set -euo pipefail

MODE="${1:-mirror}"

case "$MODE" in
    mirror)
        echo "--> Launching 120FPS Screen Mirror with Opus Audio Forwarding..."
        scrcpy \
            --max-fps=120 \
            --video-codec=h265 \
            --audio-codec=opus \
            --audio-bit-rate=128k \
            --stay-awake \
            --window-title="Phone Display (120Hz)"
        ;;
    camera|webcam)
        echo "--> Launching 50MP Camera as 4K/60FPS Linux Studio Webcam..."
        scrcpy \
            --video-source=camera \
            --camera-size=1920x1080 \
            --camera-fps=60 \
            --window-title="Phone 4K Webcam"
        ;;
    app)
        APP_NAME="${2:-com.whatsapp}"
        echo "--> Launching $APP_NAME in floating desktop window..."
        scrcpy \
            --start-app="$APP_NAME" \
            --max-fps=120 \
            --video-codec=h265 \
            --window-title="$APP_NAME"
        ;;
    *)
        echo "Usage: $0 [mirror|webcam|app <package_name>]"
        exit 1
        ;;
esac
