# Advanced WiFi Penetration Testing

> **Legal Notice:** Advanced techniques including SAE side-channel attacks, SDR exploitation, and WIDS evasion are for authorized red team engagements, security research, and academic study only.

## Learning Path

| Module | Topic | Difficulty |
|--------|-------|-----------|
| [01 - WPA3 & DragonBlood](01-wpa3-dragonblood.md) | SAE handshake, timing/cache side-channels | ★★★★★ |
| [02 - Wi-Fi 6/6E Attacks](02-wifi6-attacks.md) | 802.11ax, OFDMA, BSS Coloring, TWT attacks | ★★★★★ |
| [03 - SDR-Based Attacks](03-sdr-attacks.md) | HackRF, jamming, signal analysis | ★★★★★ |
| [04 - Mesh Network Attacks](04-mesh-networks.md) | 802.11s, OLSR, topology poisoning | ★★★★★ |
| [05 - WIDS/WIPS Evasion](05-wids-evasion.md) | Signature bypass, timing manipulation | ★★★★★ |
| [06 - Multi-Vector Chains](06-multi-vector.md) | Combined attack scenarios, red team ops | ★★★★★ |
| [07 - Custom Exploit Dev](07-exploit-development.md) | Scapy, 802.11 fuzzing, driver bugs | ★★★★★ |

## Prerequisites

- Completed [Beginner](../beginner/README.md) and [Intermediate](../intermediate/README.md) tiers
- Strong Python and/or C programming skills
- Understanding of RF fundamentals
- Familiarity with Scapy for packet crafting

## Key Tools at This Level

```
scapy            → Python packet crafting library
hackrf-tools     → SDR transmission and capture
gnuradio         → Signal processing framework
hostapd (custom) → Modified AP for research
iw / nl80211     → Low-level wireless config
mdk4             → Advanced frame flooding
wifuzz           → 802.11 protocol fuzzer
```

## Goals for This Level

After completing this tier you should be able to:

- [ ] Explain the DragonBlood SAE side-channel attack mathematically
- [ ] Use HackRF to perform selective deauth without a WiFi adapter
- [ ] Craft custom 802.11 frames using Scapy
- [ ] Enumerate and attack 802.11s mesh routing protocols
- [ ] Bypass a commercial WIDS system during an authorized test
- [ ] Build a multi-vector attack chain and document it in a red team report

---

← [Intermediate](../intermediate/README.md)
