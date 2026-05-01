#!/bin/bash
# Auto reconnaissance script
IFACE="${1:-wlan0}"
OUTDIR="${2:-recon-$(date +%Y%m%d)}"
mkdir -p "$OUTDIR"

airmon-ng check kill
airmon-ng start "$IFACE"
MON="${IFACE}mon"

echo "[*] Channel sweep..."
airodump-ng "$MON" --band abg --output-format csv -w "$OUTDIR/sweep" &
PID=$!
sleep 60
kill $PID

echo "[*] WPS scan..."
wash -i "$MON" -C -o "$OUTDIR/wps.csv"

cut -d',' -f1 "$OUTDIR/sweep"-01.csv | grep -E '^[0-9A-F]{2}:' | sort -u > "$OUTDIR/targets.txt"
echo "[+] Recon complete: $OUTDIR"
