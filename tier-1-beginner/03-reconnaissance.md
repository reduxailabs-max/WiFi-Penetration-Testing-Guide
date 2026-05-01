# 03 — Reconnaissance and Network Discovery

## Objectives

- Identify all wireless networks in range
- Enumerate clients, encryption types, channels, and hardware vendors
- Discover hidden SSIDs through passive and active techniques
- Map 6 GHz networks (Wi-Fi 6E)

## Tool: airodump-ng

```bash
# Scan all channels, all bands
airodump-ng wlan0mon

# Output columns:
# BSSID         PWR  Beacons  #Data  #/s  CH  MB  ENC CIPHER AUTH ESSID
# 00:11:22:33:44:55  -45    1250     0    0   6  130 WPA2 CCMP   PSK  HomeNetwork
# 66:77:88:99:AA:BB  -72     340     2    0  36  866 WPA3 GCMP   SAE  CorpSecure
```

### Scanning Specific Band

```bash
# 2.4 GHz only (channels 1-14)
airodump-ng wlan0mon --band bg

# 5 GHz only (channels 36-165)
airodump-ng wlan0mon --band a

# 6 GHz (Wi-Fi 6E, channels 1-233)
airodump-ng wlan0mon --band abg
```

### Targeted Channel Scan

```bash
# Lock to channel 6, capture to file
airodump-ng -c 6 --bssid 00:11:22:33:44:55 -w capture wlan0mon
```

## Tool: kismet

```bash
# Start kismet server
kismet -c wlan0mon

# Web interface: http://localhost:2501
# Provides: device list, packet graph, alerts, SSID list
```

## Hidden SSID Discovery

### Passive Method

```bash
# Capture all probe requests and responses
airodump-ng wlan0mon --wps --manufacturer

# When client connects, SSID appears in Association Request
# Wait for natural client activity or force reconnection
```

### Active Method: Deauthentication to Force Probe

```bash
# Deauth all clients on target AP
aireplay-ng -0 5 -a 00:11:22:33:44:55 wlan0mon

# Client reconnects → probe request/association request reveals SSID
# Watch airodump-ng output: hidden SSID now displayed
```

### Scapy Script: Hidden SSID Brute-Force

```python
#!/usr/bin/env python3
from scapy.all import *

interface = "wlan0mon"
ap_bssid = "00:11:22:33:44:55"

# Send probe requests with common SSID list
common_ssids = ["linksys", "NETGEAR", "xfinitywifi", "Home", "Guest", "default"]

for ssid in common_ssids:
    dot11 = Dot11(addr1=ap_bssid, addr2=RandMAC(), addr3=ap_bssid)
    probe = Dot11ProbeReq() / Dot11Elt(ID="SSID", info=ssid)
    sendp(dot11 / probe, iface=interface, verbose=0)
    print(f"Probing: {ssid}")
```

## 6 GHz Enumeration (Wi-Fi 6E)

6 GHz uses channels 1-233. Standard tools may not auto-scan full range.

```bash
# iw list to see supported channels
iw phy phy0 channels

# Scan 6 GHz with iw
iw dev wlan0mon scan freq 5945 5965 5985

# airodump-ng on 6 GHz
airodump-ng wlan0mon --band abg -c 1,5,9,13,21,25,29,33,37,41,45,53,57,61,65,69,73,77,81,85,89,93,97,101,105,109,113,117,121,125,129,133,137,141,145,149,153,157,161,165,169,173,177,181,185,189,193,197,201,205,209,213,217,221,225,229,233
```

## Client Enumeration

```bash
# Show associated clients per AP
airodump-ng -c 6 --bssid 00:11:22:33:44:55 wlan0mon

# Output columns:
# STATION          PWR   Rate   Lost  Frames  Notes  Probes
# AA:BB:CC:DD:EE:FF  -42  130-130    0    1250         HomeNetwork
```

## WPS Enumeration

```bash
# Wash: WPS scanning
wash -i wlan0mon

# Output:
# BSSID              Channel  RSSI  WPS Version  WPS Locked  ESSID
# 00:11:22:33:44:55  6        -45   1.0          No          HomeNetwork
```

## Offensive Application

- **Target selection**: Choose APs based on encryption type (WEP > WPS > WPA2 > WPA3), client count, and signal strength.
- **Client targeting**: Identify high-value clients by hostname or traffic volume.
- **Rogue AP preparation**: Clone legitimate SSID after reconnaissance.

## Defensive Application

- **SSID hiding**: Ineffective; hidden SSIDs trivially discovered via deauth or probe brute-force.
- **MAC filtering**: Easily bypassed via MAC spoofing (`macchanger -m AA:BB:CC:DD:EE:FF wlan0`).
- **WPS disable**: Primary defense against WPS attacks. Disable WPS entirely.
- **Client isolation**: Prevents client-to-client attacks after network access.
- **Monitoring**: Deploy dedicated sensor (Raspberry Pi + kismet) to detect unauthorized scans, deauth floods, and rogue APs.
