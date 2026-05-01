# Tier 1: Fundamental — Home / Personal Wi-Fi

Modules covering consumer-grade wireless security assessment, from 802.11 protocol fundamentals through password recovery and protocol-level attacks.

## Modules

1. [01-fundamentals.md](01-fundamentals.md) — 802.11 frames, encryption, 4-way handshake
2. [02-tooling.md](02-tooling.md) — Adapter selection, monitor mode, tool installation
3. [03-reconnaissance.md](03-reconnaissance.md) — Scanning, hidden SSID discovery, 6 GHz enumeration
4. [04-wpa2-attacks.md](04-wpa2-attacks.md) — Handshake capture, deauthentication, PMKID
5. [05-wps-attacks.md](05-wps-attacks.md) — Reaver, Bully, Pixie Dust, null PIN
6. [06-password-recovery.md](06-password-recovery.md) — hashcat, wordlists, masks, rules
7. [07-protocol-attacks.md](07-protocol-attacks.md) — KRACK, KR00K, FragAttacks, WPS-PBC
8. [08-enterprise-basics.md](08-enterprise-basics.md) — WPA2-Enterprise vs Personal, captive portals, certificates
9. [09-krack-practical.md](09-krack-practical.md) — Practical KRACK exploitation with vanhoefm scripts
10. [10-fragattacks-practical.md](10-fragattacks-practical.md) — Practical FragAttacks exploitation (A-MSDU injection)
11. [11-wardriving.md](11-wardriving.md) — GPS integration, Kismet, Wigle, directional antennas

## Scripts

Located in `scripts/`:
- `auto-recon.sh` — Automated full-spectrum scan
- `handshake-capture.sh` — Automated 4-way handshake capture with retry
- `wps-attack.sh` — Automated WPS Pixie Dust + brute-force
- `auto-crack.sh` — Progressive wordlist → rules → mask pipeline

## Synthetic Materials

Located in `synth/tier-1/`:
- Sample capture files (.cap, .pcapng)
- hc22000 hash files
- PIN databases
- Practice wordlists
