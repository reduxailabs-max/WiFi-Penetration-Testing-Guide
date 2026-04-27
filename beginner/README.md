# Beginner WiFi Penetration Testing

> **Legal Notice:** All techniques here are for authorized security testing, CTF labs, and educational environments only. Never test networks you don't own or have explicit written permission to test.

## Learning Path

| Module | Topic | Difficulty |
|--------|-------|-----------|
| [01 - Fundamentals](01-fundamentals.md) | WiFi concepts, 802.11 standards, encryption | ★☆☆☆☆ |
| [02 - Lab Setup](02-setup-and-tools.md) | Kali Linux, hardware, tool installation | ★★☆☆☆ |
| [03 - Reconnaissance](03-reconnaissance.md) | Scanning, enumeration, target selection | ★★☆☆☆ |
| [04 - WPA2 Attacks](04-wpa2-attacks.md) | Handshake capture, deauth, cracking | ★★★☆☆ |
| [05 - WPS Attacks](05-wps-attacks.md) | Pixie Dust, brute force, reaver | ★★★☆☆ |
| [06 - Password Cracking](06-password-cracking.md) | Hashcat, wordlists, rules | ★★★☆☆ |

## Prerequisites

- Basic Linux command line knowledge
- A computer running Kali Linux (or similar)
- A WiFi adapter that supports monitor mode and packet injection
- A lab environment (home router or dedicated test network)

## Quick Start

```bash
# Verify your adapter supports monitor mode
iw list | grep -A 10 "Supported interface modes"

# Check if injection works
sudo aireplay-ng --test wlan0

# Run the beginner lab setup script
chmod +x scripts/beginner-setup.sh
sudo ./scripts/beginner-setup.sh
```

## Goals for This Level

After completing this tier you should be able to:

- [ ] Explain WPA2 4-way handshake from memory
- [ ] Set up a wireless adapter in monitor mode without errors
- [ ] Capture a WPA2 handshake from an authorized network
- [ ] Run hashcat against a captured hash file
- [ ] Explain why WPS PIN attacks work and how to mitigate them
- [ ] Write a one-page pentest report covering findings

---

Continue to [Intermediate →](../intermediate/README.md) when you're comfortable with these concepts.
