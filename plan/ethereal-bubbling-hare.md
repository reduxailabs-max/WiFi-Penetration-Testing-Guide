# Plan: WiFi Penetration Testing Tutorial — Complete All Three Tiers

## Context

The user is building a GitHub-hosted WiFi penetration testing tutorial in three skill tiers:
**Beginner**, **Intermediate**, and **Advanced**. The goal is a comprehensive, well-structured
repository that demonstrates expertise and boosts professional reputation.

**Current state:**
- Root `README.md` exists but describes old flat structure — needs rewrite
- `wifi-pentest-guide.md` — monolithic reference file (truncated at line 205), will keep as legacy reference
- `network-recon.sh`, `pentest-methodology.sh`, `diagram-generator.sh` — working scripts, keep
- `beginner/README.md` ✓ complete
- `beginner/01-fundamentals.md` ✓ complete (802.11 standards, encryption, 4-way handshake)
- `beginner/02-setup-and-tools.md` ✓ complete (adapters, monitor mode, tool install)
- `intermediate/README.md` ✓ complete
- `advanced/README.md` ✓ complete

## Files to Create

### Beginner (4 modules + 1 script)

| File | Content |
|------|---------|
| `beginner/03-reconnaissance.md` | airodump-ng syntax, reading output columns, target selection, hidden SSID discovery |
| `beginner/04-wpa2-attacks.md` | 4-way handshake capture step-by-step, deauth attack, verifying capture quality |
| `beginner/05-wps-attacks.md` | WPS PIN theory, Pixie Dust attack, brute force, reaver & bully commands |
| `beginner/06-password-cracking.md` | hashcat modes, rockyou, mask attacks, rules, john fallback, verify results |
| `beginner/scripts/beginner-setup.sh` | Environment check script: verifies adapter, monitor mode, injection, tools |

### Intermediate (6 modules + 2 scripts)

| File | Content |
|------|---------|
| `intermediate/01-enterprise-wifi.md` | 802.1X architecture, EAP method taxonomy (PEAP/EAP-TLS/EAP-TTLS/EAP-FAST), RADIUS flow |
| `intermediate/02-eap-attacks.md` | PEAP MSCHAPv2 credential capture, freeradius-wpe, certificate spoofing, cracking NTLMv2 |
| `intermediate/03-evil-twin.md` | hostapd-mana setup, eaphammer walkthrough, captive portal with dnsmasq |
| `intermediate/04-pmkid-attack.md` | hcxdumptool full workflow, filter by BSSID, hcxtools conversion, hashcat 22000 |
| `intermediate/05-client-attacks.md` | KARMA attack theory, probe request harvesting, bettercap KARMA, credential harvesting |
| `intermediate/06-post-exploitation.md` | Network pivoting, reconnaissance after access, lateral movement, pentest report template |
| `intermediate/scripts/setup-rogue-ap.sh` | Automated hostapd-mana + dnsmasq rogue AP launcher |
| `intermediate/scripts/pmkid-capture.sh` | PMKID capture with filtering + conversion to hashcat format |

### Advanced (7 modules + 1 script)

| File | Content |
|------|---------|
| `advanced/01-wpa3-dragonblood.md` | SAE handshake math, timing side-channel, cache side-channel (CVE-2019-9494/9496), dragonslayer tool |
| `advanced/02-wifi6-attacks.md` | 802.11ax OFDMA, BSS Coloring attacks, TWT exploitation, WPA3 Transition Mode downgrade |
| `advanced/03-sdr-attacks.md` | HackRF/RTL-SDR setup, GNURadio basics, deauth via SDR, signal jamming theory, selective jamming |
| `advanced/04-mesh-networks.md` | 802.11s standard, HWMP routing protocol, topology poisoning, mesh node impersonation |
| `advanced/05-wids-evasion.md` | Commercial WIDS signatures, MAC rotation timing, channel hopping, beacon manipulation |
| `advanced/06-multi-vector.md` | Full red team scenario: recon → PMKID → crack → evil twin → EAP harvest → pivot chain |
| `advanced/07-exploit-development.md` | Scapy 802.11 frame crafting, fuzzing with wifuzz, driver CVE research methodology |
| `advanced/scripts/scapy-deauth.py` | Python Scapy script for targeted deauthentication |

### Root

| File | Change |
|------|--------|
| `README.md` | Full rewrite as professional GitHub landing page with: badges, description, tier navigation table, tool requirements, legal disclaimer, contributing guide |

## Content Style Guidelines

Every module follows this structure:
1. **Theory section** — explains WHY before HOW
2. **Diagram/ASCII art** — visual of the attack or concept
3. **Step-by-step commands** — runnable bash blocks with inline comments
4. **Common errors & fixes** — what beginners get wrong
5. **Knowledge check** — 3-5 questions at the end
6. **Navigation links** — prev/next module

## File Naming & Organization

```
WiFi-Penetration-Testing-Guide/
├── README.md                          ← rewrite
├── wifi-pentest-guide.md              ← keep (legacy reference)
├── network-recon.sh                   ← keep
├── pentest-methodology.sh             ← keep
├── diagram-generator.sh               ← keep
├── beginner/
│   ├── README.md                      ✓ done
│   ├── 01-fundamentals.md             ✓ done
│   ├── 02-setup-and-tools.md          ✓ done
│   ├── 03-reconnaissance.md           ← create
│   ├── 04-wpa2-attacks.md             ← create
│   ├── 05-wps-attacks.md              ← create
│   ├── 06-password-cracking.md        ← create
│   └── scripts/
│       └── beginner-setup.sh          ← create
├── intermediate/
│   ├── README.md                      ✓ done
│   ├── 01-enterprise-wifi.md          ← create
│   ├── 02-eap-attacks.md              ← create
│   ├── 03-evil-twin.md                ← create
│   ├── 04-pmkid-attack.md             ← create
│   ├── 05-client-attacks.md           ← create
│   ├── 06-post-exploitation.md        ← create
│   └── scripts/
│       ├── setup-rogue-ap.sh          ← create
│       └── pmkid-capture.sh           ← create
└── advanced/
    ├── README.md                      ✓ done
    ├── 01-wpa3-dragonblood.md         ← create
    ├── 02-wifi6-attacks.md            ← create
    ├── 03-sdr-attacks.md              ← create
    ├── 04-mesh-networks.md            ← create
    ├── 05-wids-evasion.md             ← create
    ├── 06-multi-vector.md             ← create
    ├── 07-exploit-development.md      ← create
    └── scripts/
        └── scapy-deauth.py            ← create
```

## Execution Order

1. Finish beginner tier (03 → 04 → 05 → 06 → script)
2. Write intermediate tier (01 → 02 → 03 → 04 → 05 → 06 → scripts)
3. Write advanced tier (01 → 02 → 03 → 04 → 05 → 06 → 07 → script)
4. Rewrite root README.md
5. Git commit all files
6. Git push to GitHub remote (origin main)

## Verification

- All markdown files render correctly (no broken links in navigation)
- All bash scripts have `#!/bin/bash` and are `chmod +x`able
- Root README navigation links point to correct files
- Legal disclaimers present in every tier README
- Push confirmed with `git push origin main`
