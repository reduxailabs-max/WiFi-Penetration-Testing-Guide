# 08 — Enterprise Wi-Fi Basics

## Enterprise vs. Personal

| Feature | WPA2-Personal | WPA2-Enterprise |
|--------|--------------|-----------------|
| Auth | PSK | 802.1X (RADIUS) |
| Key mgmt | SAE/PSK | EAP methods |
| User isolation | Per-network | Per-user |
| Infrastructure | AP only | AP + RADIUS server |

## Common EAP Methods

- **PEAP-MSCHAPv2**: Windows default, vulnerable to relay
- **EAP-TTLS**: Similar to PEAP, tunneled auth
- **EAP-TLS**: Certificate-based, most secure
- **EAP-FAST**: Cisco proprietary, PAC-based
- **LEAP**: Deprecated Cisco, easily cracked

## Reconnaissance

```bash
# Identify EAP type
airodump-ng wlan0mon --wps

# EAP enumeration with hostapd-mana
hostapd-mana /etc/hostapd-mana/hostapd.conf

# EAPHammer (automated)
./eaphammer -i wlan0 --channel 6 --auth wpa2-eap --creds
```
