# Wireshark / tshark Wi-Fi Analysis Guide

## Capture Setup

```bash
# Capture on monitor mode interface
tshark -i wlan0mon -w capture.pcapng

# Capture with WPA2 decryption key
tshark -i wlan0mon -o "wlan.enable_decryption:TRUE" \
  -o "wlan.wep_key1:wpa-pwd:MyPassword:MySSID" -w capture.pcapng

# Capture specific frame types
tshark -i wlan0mon -f "type mgt subtype beacon"
tshark -i wlan0mon -f "type mgt subtype deauth"
```

## Essential Display Filters

### Frame Types
```
wlan.fc.type_subtype == 0x08   # Beacon
wlan.fc.type_subtype == 0x04   # Probe Request
wlan.fc.type_subtype == 0x05   # Probe Response
wlan.fc.type_subtype == 0x0b   # Authentication
wlan.fc.type_subtype == 0x0c   # Deauthentication
wlan.fc.type_subtype == 0x0a   # Disassociation
wlan.fc.type_subtype == 0x00   # Association Request
wlan.fc.type_subtype == 0x01   # Association Response
wlan.fc.type_subtype == 0x13   # EAPOL-Key
wlan.fc.type_subtype == 0x0d   # Action
```

### Address Filtering
```
wlan.addr == 00:11:22:33:44:55
wlan.sa == 00:11:22:33:44:55    # Source
wlan.da == 00:11:22:33:44:55    # Destination
wlan.bssid == 00:11:22:33:44:55 # BSSID
wlan.addr[0:3] == 00:11:22      # OUI wildcard
```

### EAPOL / Handshake
```
# WPA2 4-way handshake messages
eapol.keydes.type == 2

# Message 1 (ANonce, no MIC, no Secure)
eapol.keydes.key_information.secure == 0 && eapol.keydes.key_information.mic == 0

# Message 2 (SNonce, MIC)
eapol.keydes.key_information.secure == 0 && eapol.keydes.key_information.mic == 1

# Message 3 (GTK, Secure set, Install)
eapol.keydes.key_information.secure == 1 && eapol.keydes.key_information.install == 1

# Message 4 (MIC, Secure, no Install)
eapol.keydes.key_information.secure == 1 && eapol.keydes.key_information.install == 0

# PMKID in Message 1
eapol.rsn.keydes.akmp == 0x01 && eapol.keydes.keydes.data_length > 0
```

### RSN / WPA Analysis
```
wlan.rsn.akms.type    # AKM: 02=PSK, 01=802.1X, 08=SAE
wlan.rsn.pcs.type     # Pairwise: 04=CCMP, 08=GCMP-128, 09=GCMP-256
wlan.rsn.capabilities.mfpc  # Management Frame Protection Capable
wlan.rsn.capabilities.mfpr  # Management Frame Protection Required
```

### WPS
```
wlan.wps
wlan.tag.number == 221 && wlan.tag.vendor.oui == 0x0050f2
```

### Hotspot 2.0 / Passpoint
```
wlan.hs20  # Hotspot 2.0 IE
wlan.anqp   # ANQP elements
```

## tshark Export Commands

```bash
# Extract all beacon SSIDs and BSSIDs
tshark -r capture.pcapng -Y "wlan.fc.type_subtype==0x08" \
  -T fields -e wlan.bssid -e wlan.ssid -E separator=tab

# Extract all probe request SSIDs
tshark -r capture.pcapng -Y "wlan.fc.type_subtype==0x04" \
  -T fields -e wlan.sa -e wlan.ssid

# Extract all deauth frames
tshark -r capture.pcapng -Y "wlan.fc.type_subtype==0x0c" \
  -T fields -e wlan.sa -e wlan.da -e wlan.deauth.reason_code

# Extract EAPOL handshake messages
tshark -r capture.pcapng -Y "eapol" \
  -T fields -e frame.number -e wlan.sa -e wlan.da -e eapol.keydes.key_information

# Extract WPS info
tshark -r capture.pcapng -Y "wlan.wps" \
  -T fields -e wlan.sa -e wlan.wps.device_name -e wlan.wps.manufacturer

# Export specific frame bytes for analysis
# Frame 100, data starting at offset 24 (skip radiotap)
tshark -r capture.pcapng -Y "frame.number==100" -x
```

## Decrypting Captured Traffic

```bash
# Method 1: Edit → Preferences → Protocols → IEEE 802.11 → Decryption Keys
# Add: wpa-pwd:MyPassword:MySSID
# Or: wpa-psk:<hex PSK>

# Method 2: tshark with key inline
tshark -r capture.pcapng -o "wlan.enable_decryption:TRUE" \
  -o "wlan.wep_key1:wpa-pwd:password123:MyHomeNet" \
  -Y "http or dns or icmp" -V

# Method 3: airdecap-ng (bulk decryption)
airdecap-ng -e MyHomeNet -p password123 capture.pcapng
# Outputs: capture-dec.pcapng
```

## Wi-Fi 6/7 IE Analysis

```
# HE (802.11ax) IE
wlan.ext_tag.number == 35  # HE Capabilities
wlan.ext_tag.number == 36  # HE Operation

# EHT (802.11be) IE
wlan.ext_tag.number == 108  # EHT Capabilities
wlan.ext_tag.number == 109  # EHT Operation

# Multi-Link IE
wlan.ext_tag.number == 107  # Multi-Link
# Contains: Common Info, Per-STA Profile, Link ID

# Extract MLD MAC from Multi-Link IE
tshark -r capture.pcapng -Y "wlan.ext_tag.number==107" \
  -T fields -e wlan.bssid -e wlan.ext_tag.number
```

## Statistical Analysis

```bash
# Frame type distribution
tshark -r capture.pcapng -q -z "wlan,stat"

# Conversation list (who talks to whom)
tshark -r capture.pcapng -q -z "conv,wlan"

# Protocol hierarchy
tshark -r capture.pcapng -q -z "io,phs"

# Throughput over time
tshark -r capture.pcapng -q -z "io,stat,1"
```

## Hex Dump Analysis

```bash
# Extract raw bytes of all beacon frames
tshark -r capture.pcapng -Y "wlan.fc.type_subtype==0x08" -x

# Extract just the IEs (skip radiotap + fixed parameters)
# Radiotap is variable length; use frame offset to skip to IEs
tshark -r capture.pcapng -Y "wlan.fc.type_subtype==0x08" \
  -T fields -e data

# Extract specific IE by number
tshark -r capture.pcapng -Y "wlan.tag.number==0" \
  -T fields -e wlan.ssid  # IE 0 = SSID
```
