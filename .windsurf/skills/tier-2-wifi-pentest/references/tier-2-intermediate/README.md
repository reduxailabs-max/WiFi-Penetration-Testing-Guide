# Tier 2: Intermediate — Enterprise & Advanced Attacks

Modules for WPA2-Enterprise, rogue AP deployment, EAP attacks, and post-exploitation.

## Modules

1. 01-enterprise-architecture.md — RADIUS, EAP methods, certificate auth
2. 02-eap-attacks.md — MSCHAPv2 relay, credential harvesting
3. 03-rogue-ap.md — Karma, mana, Evil Twin
4. 04-rsn-ie-advanced.md — PMKID, Fast BSS Transition
5. 05-client-side.md — Hotspot portals, downgrade attacks
6. [06-post-exploitation.md](06-post-exploitation.md) — Pivoting, lateral movement, exfiltration, persistence
7. [07-radius-deep.md](07-radius-deep.md) — RADIUS shared secret cracking, EAP-SIM/AKA, amplification
8. [08-pmf-bypass.md](08-pmf-bypass.md) — 802.11w PMF downgrade, null-frame attacks, bypass techniques
9. [09-iot-wifi.md](09-iot-wifi.md) — ESP8266/ESP32 attacks, Tasmota backdoors, MQTT exploitation
10. [10-wifi-direct-p2p.md](10-wifi-direct-p2p.md) — Wi-Fi Direct attacks, P2P group hijacking, Miracast exploitation
11. [11-passpoint-deep.md](11-passpoint-deep.md) — Hotspot 2.0 ANQP attacks, OSU rogue server, realm downgrade

## Scripts

- rogue-ap-deploy.sh — Hostapd-mana deployment
- eaphammer-auto.sh — Automated EAP credential harvest
- pmkid-harvest.sh — Enterprise PMKID capture
- vlan-pivot.sh — VLAN hopping automation
