#!/usr/bin/env python3
"""
🚀 Desk Ambient Telemetry & Smart Dock Server for Fedora Linux
Provides real-time WebSockets telemetry and Macropad remote actions.
"""

import asyncio
import json
import os
import subprocess
import time
import psutil
from aiohttp import web

# Homelab nodes to monitor via Tailscale
HOMELAB_NODES = {
    "TrueNAS Office": "100.91.79.4",
    "TrueNAS Home": "100.89.54.60",
    "Immich AI Server": "100.119.62.87",
}

# Network tracking state
last_net = psutil.net_io_counters()
last_time = time.time()
connected_websockets = set()

def get_cpu_temp():
    try:
        temps = psutil.sensors_temperatures()
        if 'k10temp' in temps:
            for sensor in temps['k10temp']:
                if sensor.label in ('Tctl', 'Tccd1', ''):
                    return round(sensor.current, 1)
        if 'coretemp' in temps:
            return round(temps['coretemp'][0].current, 1)
    except Exception:
        pass
    return 42.0

def get_gpu_telemetry():
    try:
        cmd = [
            "nvidia-smi",
            "--query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total,power.draw",
            "--format=csv,noheader,nounits"
        ]
        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=1)
        if res.returncode == 0 and res.stdout.strip():
            parts = [p.strip() for p in res.stdout.strip().split(",")]
            return {
                "name": "NVIDIA RTX 4050",
                "load": int(parts[0]),
                "temp": int(parts[1]),
                "mem_used": int(parts[2]),
                "mem_total": int(parts[3]),
                "power_w": round(float(parts[4]), 1)
            }
    except Exception:
        pass
    return {
        "name": "Radeon 780M / RTX 4050",
        "load": 0,
        "temp": 40,
        "mem_used": 0,
        "mem_total": 6144,
        "power_w": 0.0
    }

def get_mic_mute_status():
    try:
        res = subprocess.run(["pactl", "get-source-mute", "@DEFAULT_SOURCE@"], stdout=subprocess.PIPE, text=True, timeout=1)
        return "yes" in res.stdout.lower()
    except Exception:
        return False

def ping_node(ip):
    try:
        res = subprocess.run(["ping", "-c", "1", "-W", "0.5", ip], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return res.returncode == 0
    except Exception:
        return False

def collect_telemetry():
    global last_net, last_time
    now = time.time()
    dt = max(now - last_time, 0.1)
    
    cur_net = psutil.net_io_counters()
    rx_rate = max((cur_net.bytes_recv - last_net.bytes_recv) / dt, 0)
    tx_rate = max((cur_net.bytes_sent - last_net.bytes_sent) / dt, 0)
    last_net = cur_net
    last_time = now

    cpu_percents = psutil.cpu_percent(interval=None, percpu=True)
    cpu_overall = round(sum(cpu_percents) / len(cpu_percents), 1) if cpu_percents else 0
    cpu_freq = psutil.cpu_freq()
    freq_ghz = round(cpu_freq.current / 1000, 2) if cpu_freq else 3.8

    vm = psutil.virtual_memory()
    sm = psutil.swap_memory()
    disk = psutil.disk_usage('/')

    # Check homelab nodes
    nodes_status = []
    for name, ip in HOMELAB_NODES.items():
        nodes_status.append({
            "name": name,
            "ip": ip,
            "online": ping_node(ip)
        })

    return {
        "timestamp": int(now * 1000),
        "cpu": {
            "model": "AMD Ryzen 7 7840HS",
            "overall": cpu_overall,
            "cores": cpu_percents,
            "temp": get_cpu_temp(),
            "freq_ghz": freq_ghz
        },
        "gpu": get_gpu_telemetry(),
        "ram": {
            "used_gb": round((vm.total - vm.available) / (1024**3), 2),
            "total_gb": round(vm.total / (1024**3), 2),
            "percent": vm.percent,
            "swap_used_gb": round(sm.used / (1024**3), 2),
            "swap_total_gb": round(sm.total / (1024**3), 2)
        },
        "disk": {
            "used_gb": round(disk.used / (1024**3), 1),
            "total_gb": round(disk.total / (1024**3), 1),
            "percent": disk.percent
        },
        "network": {
            "rx_kbps": round(rx_rate / 1024, 1),
            "tx_kbps": round(tx_rate / 1024, 1),
            "rx_mbps": round((rx_rate * 8) / (1024**2), 2),
            "tx_mbps": round((tx_rate * 8) / (1024**2), 2)
        },
        "controls": {
            "mic_muted": get_mic_mute_status()
        },
        "homelab": nodes_status
    }

async def websocket_handler(request):
    ws = web.WebSocketResponse()
    await ws.prepare(request)
    connected_websockets.add(ws)
    
    # Send immediate initial packet
    try:
        await ws.send_str(json.dumps(collect_telemetry()))
    except Exception:
        pass

    try:
        async for msg in ws:
            pass
    finally:
        connected_websockets.discard(ws)
    return ws

async def api_telemetry(request):
    return web.json_response(collect_telemetry())

async def api_action(request):
    action = request.match_info.get('name')
    if action == 'mute_mic':
        subprocess.run(["pactl", "set-source-mute", "@DEFAULT_SOURCE@", "toggle"])
    elif action == 'vol_up':
        subprocess.run(["pactl", "set-sink-volume", "@DEFAULT_SINK@", "+5%"])
    elif action == 'vol_down':
        subprocess.run(["pactl", "set-sink-volume", "@DEFAULT_SINK@", "-5%"])
    elif action == 'mute_vol':
        subprocess.run(["pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle"])
    elif action == 'lock_pc':
        subprocess.run(["loginctl", "lock-session"])
    elif action == 'play_pause':
        subprocess.run(["playerctl", "play-pause"], stderr=subprocess.DEVNULL)
    elif action == 'next_track':
        subprocess.run(["playerctl", "next"], stderr=subprocess.DEVNULL)
    elif action == 'prev_track':
        subprocess.run(["playerctl", "previous"], stderr=subprocess.DEVNULL)
    return web.json_response({"status": "ok", "action": action, "mic_muted": get_mic_mute_status()})

async def background_broadcaster():
    while True:
        await asyncio.sleep(1.0)
        if connected_websockets:
            data = json.dumps(collect_telemetry())
            dead = set()
            for ws in connected_websockets:
                try:
                    await ws.send_str(data)
                except Exception:
                    dead.add(ws)
            connected_websockets.difference_update(dead)

async def start_background_tasks(app):
    app['broadcaster'] = asyncio.create_task(background_broadcaster())

async def cleanup_background_tasks(app):
    app['broadcaster'].cancel()
    await app['broadcaster']

app = web.Application()
app.on_startup.append(start_background_tasks)
app.on_cleanup.append(cleanup_background_tasks)

app.router.add_get('/ws', websocket_handler)
app.router.add_get('/api/telemetry', api_telemetry)
app.router.add_post('/api/action/{name}', api_action)
app.router.add_get('/', lambda r: web.FileResponse(os.path.join(os.path.dirname(__file__), 'static', 'index.html')))
app.router.add_static('/static/', path=os.path.join(os.path.dirname(__file__), 'static'), name='static')

if __name__ == '__main__':
    print("🚀 Desk Telemetry Server starting on port 7890...")
    web.run_app(app, host='0.0.0.0', port=7890, access_log=None)
