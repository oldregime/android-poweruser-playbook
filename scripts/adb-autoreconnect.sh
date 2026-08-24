#!/usr/bin/env bash
# 🚀 24/7 Always-On Wireless ADB Auto-Reconnector for Realme P3 Ultra

TAILSCALE_IP="100.65.98.105"
KNOWN_IPS=("192.168.29.66" "192.168.29.67" "192.168.29.133" "192.168.1.129" "$TAILSCALE_IP")

check_and_connect() {
    # If wireless TCP device is already connected, all good
    if adb devices | grep -E ':(5555|[0-9]{4,5})\s+device' >/dev/null 2>&1; then
        return 0
    fi

    # 1. Fast sweep known IPs on port 5555
    for ip in "${KNOWN_IPS[@]}"; do
        if nc -z -w 1 "$ip" 5555 >/dev/null 2>&1; then
            adb connect "$ip:5555" >/dev/null 2>&1
            if adb devices | grep -E ':(5555|[0-9]{4,5})\s+device' >/dev/null 2>&1; then
                return 0
            fi
        fi
    done

    # 2. Fast subnet discovery if on local Wi-Fi
    python3 -c '
import subprocess, socket, concurrent.futures

def check_ip(i):
    ip = f"192.168.29.{i}"
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(0.1)
    if s.connect_ex((ip, 5555)) == 0:
        s.close()
        return ip
    s.close()
    return None

with concurrent.futures.ThreadPoolExecutor(max_workers=50) as ex:
    for ip in ex.map(check_ip, range(1, 255)):
        if ip:
            subprocess.run(["adb", "connect", f"{ip}:5555"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            break
' 2>/dev/null
}

while true; do
    check_and_connect
    sleep 5
done
