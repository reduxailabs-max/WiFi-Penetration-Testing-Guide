# Troubleshooting Guide

## Monitor Mode Won't Enable

```bash
# Check monitor mode support
iw list | grep -A 20 "Supported interface modes" | grep "monitor"

# Stop interfering services
systemctl stop NetworkManager wpa_supplicant
airmon-ng check kill
airmon-ng start wlan0

# Interface renamed by systemd
ip link show  # check for wlp2s0, wlx...

# Install missing drivers
apt-get install realtek-rtl88xxau-dkms  # RTL8812AU
# MT7612U: built into kernel 5.4+
# AR9271: built in (ath9k_htc)
```

## Injection Not Working

```bash
# Verify monitor mode and channel
iwconfig wlan0mon | grep Mode
iw dev wlan0mon set channel 6

# Increase TX power
iw reg set US
iw dev wlan0mon set txpower fixed 3000

# RTL8812AU driver issues
git clone https://github.com/aircrack-ng/rtl8812au
cd rtl8812au && make && make install

# VM USB passthrough: use USB 3.0 controller
```

## Airodump-ng Not Showing Networks

```bash
airodump-ng wlan0mon --band abg -f 100000
iw reg set US
iw phy phy0 channels | grep -E "disabled|no IR"
```

## No Handshake Captured

```bash
# Client may not reconnect immediately
aireplay-ng -0 0 -a <BSSID> wlan0mon  # Continuous deauth
# Wait 2-5 minutes for client to auto-reconnect

# Client uses PMF (802.11w)
# Deauth is silently dropped. Try passive capture during natural reconnect.
# Or use PMF bypass techniques from tier-2-intermediate/08-pmf-bypass.md

# Wrong channel
airodump-ng -c <CHANNEL> --bssid <BSSID> -w cap wlan0mon
```

## Hashcat Errors

```bash
# Deprecated mode warning: update to -m 22000 (handshake) / 22001 (PMKID)
# No GPUs found: --force flag for CPU-only
hashcat -m 22000 hash.hc22000 wordlist.txt --force

# Driver installation for GPU
apt-get install nvidia-driver  # NVIDIA
apt-get install rocm-opencl-runtime  # AMD
# Intel: built into mesa
```

## hostapd-mana / EAPHammer Failures

```bash
# EAPHammer cert wizard fails
./eaphammer --cert-wizard
# Manually generate cert: openssl req -x509 -nodes -days 365 -newkey rsa:2048 ...

# hostapd-mana: interface in use
airmon-ng stop wlan0mon
ip link set wlan0 down
hostapd-mana /etc/hostapd-mana/hostapd.conf

# DNS port 53 in use
systemctl stop systemd-resolved
```

## hcxdumptool / hcxpcapngtool Issues

```bash
# hcxdumptool: set monitor mode manually
ip link set wlan0 down
iw dev wlan0 set type monitor
ip link set wlan0 up
hcxdumptool -i wlan0 -o capture.pcapng

# hcxpcapngtool: no hashes found
# Capture may not contain handshake. Ensure client connects during capture.
# Check: hcxpcapngtool -o hash.hc22000 capture.pcapng -E essidlist
```

## Scapy / Python Import Errors

```bash
# Scapy not found
pip3 install scapy

# Permission denied on interface
sudo python3 script.py
# Or: setcap cap_net_raw,cap_net_admin=eip $(which python3)

# Interface name changed after airmon-ng
# Use iw to check: iw dev | grep Interface
```

## 5 GHz / 6 GHz Not Working

```bash
# Check regulatory domain
iw reg get
# Some domains disable 5/6 GHz or DFS channels
iw reg set US  # Or local regulatory domain

# Check adapter supports 5 GHz
iw list | grep -A 5 "Band 2"
# If no Band 2, adapter is 2.4 GHz only

# DFS channels require passive scan (no injection)
# Channels 52-64, 100-144: wait 60s before active scan
```

## WPA3 / SAE Issues

```bash
# SAE not supported by adapter
# Requires adapter that supports SAE offload or software implementation
# Check: iw list | grep -i sae

# Transition mode downgrade not working
# Some clients cache network profile with WPA3
# Delete network profile on client device first
```
