#!/bin/bash
# 802.11s Mesh topology mapper
IFACE="${1:-wlan0}"
CHANNEL="${2:-6}"
echo "[*] Enabling mesh interface $IFACE on channel $CHANNEL"
iw dev "$IFACE" interface add mesh0 type mp mesh_id test_mesh
iw dev mesh0 set channel "$CHANNEL"
ip link set mesh0 up
iw dev mesh0 station dump
