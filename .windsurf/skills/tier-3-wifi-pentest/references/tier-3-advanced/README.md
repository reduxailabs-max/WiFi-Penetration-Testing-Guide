# Tier 3: Advanced — High-Security Networks

Modules covering banking, government, military, and classified Wi-Fi security assessment.

## Modules

1. [01-wpa3-dragonblood.md](01-wpa3-dragonblood.md) — SAE side-channels, Dragonblood, transition mode
2. [02-wifi6-7-attacks.md](02-wifi6-7-attacks.md) — 802.11ax/be, OFDMA, MLO, Wi-Fi 7
3. [03-sdr-phy.md](03-sdr-phy.md) — HackRF, LimeSDR, jamming, PHY injection
4. [04-mesh-poisoning.md](04-mesh-poisoning.md) — 802.11s, OLSR, HWMP routing attacks
5. [05-wids-evasion.md](05-wids-evasion.md) — Commercial WIPS bypass, low-and-slow
6. [06-multi-vector-chains.md](06-multi-vector-chains.md) — Attack chaining, red team kill chains
7. [07-exploit-dev.md](07-exploit-dev.md) — Scapy frame crafting, driver fuzzing, firmware RE
8. [08-quantum-ml-evasion.md](08-quantum-ml-evasion.md) — Post-quantum AKMs, adversarial ML WIDS evasion
9. [09-wifi6e-deep.md](09-wifi6e-deep.md) — 6 GHz security, AFC poisoning, TWT abuse, PSC manipulation
10. [10-wifi7-mlo-deep.md](10-wifi7-mlo-deep.md) — MLO key derivation, link removal, STR interference, MRU manipulation
11. [11-awdl-attacks.md](11-awdl-attacks.md) — Apple AWDL DoS, AirDrop harvesting, Sidecar hijacking
12. [12-80211az-rtt.md](12-80211az-rtt.md) — FTM privacy exposure, RTT spoofing, positioning manipulation
13. [13-sae-pk.md](13-sae-pk.md) — WPA3-SAE-PK downgrade, DPP brute-force, PK fingerprint attacks
14. [14-wpa3-192bit.md](14-wpa3-192bit.md) — CNSA Suite compliance, GCMP-256 nonce reuse, TLS 1.3 0-RTT replay
15. [15-bt-coexistence.md](15-bt-coexistence.md) — Bluetooth-Wi-Fi PTA attacks, AFH manipulation, cross-protocol DoS

## Scripts

- `scripts/scapy-fuzzer.py` — 802.11 frame fuzzing
- `scripts/sdr-injector.py` — SDR frame injection stub
- `scripts/mesh-mapper.sh` — 802.11s mesh topology enumeration
- `scripts/wids-tester.py` — WIDS signature testing
- `scripts/chain-attack.sh` — Multi-vector chain automation
- `scripts/driver-fuzz.sh` — Driver fuzzing harness

## Hardware Requirements

- HackRF One or LimeSDR for SDR modules
- Multiple wireless adapters for mesh testing
- GPU for hash cracking (recommended)
