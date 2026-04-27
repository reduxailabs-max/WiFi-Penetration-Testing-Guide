# Intermediate WiFi Penetration Testing

> **Legal Notice:** All techniques here are for authorized security testing, CTF labs, and educational environments only. Enterprise attacks (EAP, RADIUS) require explicit written authorization from network owners.

## Learning Path

| Module | Topic | Difficulty |
|--------|-------|-----------|
| [01 - Enterprise WiFi](01-enterprise-wifi.md) | 802.1X, EAP methods, RADIUS architecture | ★★★☆☆ |
| [02 - EAP Attacks](02-eap-attacks.md) | PEAP, EAP-TTLS, certificate harvesting | ★★★★☆ |
| [03 - Evil Twin & Rogue AP](03-evil-twin.md) | hostapd-mana, eaphammer, captive portals | ★★★★☆ |
| [04 - PMKID Attack](04-pmkid-attack.md) | Clientless capture, hcxdumptool workflow | ★★★☆☆ |
| [05 - Client-Side Attacks](05-client-attacks.md) | KARMA, probe hijacking, credential harvesting | ★★★★☆ |
| [06 - Post-Exploitation](06-post-exploitation.md) | Pivoting, lateral movement, reporting | ★★★★☆ |

## Prerequisites

- Completed the [Beginner tier](../beginner/README.md)
- Comfortable with the aircrack-ng suite
- Understanding of TCP/IP networking
- Familiarity with 802.11 frame types

## Key Tools at This Level

```
hostapd-mana     → Enterprise rogue AP
eaphammer        → EAP credential capture
bettercap        → MITM and KARMA attacks  
hcxdumptool      → PMKID and advanced capture
hcxtools         → Hash conversion and analysis
freeradius-wpe   → RADIUS password interception
```

## Goals for This Level

After completing this tier you should be able to:

- [ ] Describe the difference between WPA2-Personal and WPA2-Enterprise
- [ ] Explain why PEAP MSCHAPv2 is vulnerable to offline cracking
- [ ] Stand up a rogue AP with certificate spoofing
- [ ] Capture RADIUS credentials using hostapd-mana
- [ ] Perform a PMKID capture without any connected clients
- [ ] Write an intermediate-level pentest report with CVSS scores

---

← [Beginner](../beginner/README.md) | [Advanced →](../advanced/README.md)
