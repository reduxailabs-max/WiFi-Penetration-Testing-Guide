# WiFi Penetration Testing Guide

A comprehensive technical reference for wireless security assessment across three operational tiers: consumer-grade personal networks, enterprise institutional deployments, and high-security classified installations.

---

## Tier Overview

| Tier | Target | Modules | Focus |
|------|--------|---------|-------|
| **Tier 1: Fundamental** | Home / Personal Wi-Fi | 8 | WPA2-Personal, WPS, reconnaissance, password recovery |
| **Tier 2: Intermediate** | Enterprise / University | 7 | 802.1X/EAP, rogue AP, PMKID, client attacks, post-exploitation |
| **Tier 3: Advanced** | Banking / Government / Military | 8 | WPA3, Wi-Fi 6/7, SDR, mesh poisoning, WIDS evasion, exploit development |

---

## Quick Navigation

- [Tier 1: Fundamental](tier-1-beginner/README.md)
- [Tier 2: Intermediate](tier-2-intermediate/README.md)
- [Tier 3: Advanced](tier-3-advanced/README.md)
- [Command Quick Reference](QUICKREF.md)
- [Attack Chain Map](CHAIN-MAP.md)
- [Primary Sources](REFERENCES.md)

---

## Prerequisites

- Kali Linux 2024.x, Parrot OS Security Edition, or Arch Linux + BlackArch
- Compatible wireless adapter with monitor mode and frame injection
- SDR hardware for Tier 3 (HackRF One, LimeSDR Mini, or PlutoSDR)

---

## Structure

```
tier-1-beginner/          # 8 modules + scripts + synthetic materials
tier-2-intermediate/      # 7 modules + scripts + synthetic materials
tier-3-advanced/          # 8 modules + scripts + synthetic materials
synth/                    # Practice files for all tiers
```

Every module contains exact commands, verbatim output samples, dual-use offensive/defensive sections, and automation scripts.
