# WiFi Penetration Testing Guide

> **The most comprehensive, practical WiFi security testing tutorial available.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Stars](https://img.shields.io/github/stars/yourusername/WiFi-Penetration-Testing-Guide)](https://github.com/yourusername/WiFi-Penetration-Testing-Guide/stargazers)

A complete, three-tier tutorial for wireless network security assessment. From beginner fundamentals to advanced exploitation techniques - with synthetic practice materials for hands-on learning without live targets.

---

## 🎯 What's Inside

### Three Complete Learning Tracks

| Tier | Modules | Focus | Time |
|------|---------|-------|------|
| **Beginner** | 6 modules | WPA2, WPS, basic reconnaissance | 2-3 weeks |
| **Intermediate** | 6 modules | Enterprise WiFi, EAP attacks, PMKID | 3-4 weeks |
| **Advanced** | 7 modules | WPA3 DragonBlood, WiFi 6/7, SDR attacks | 4-6 weeks |

### Key Features

- ✅ **Zero History** - Purely practical, no historical fluff
- ✅ **Maximum Detail** - Every command with all flags documented
- ✅ **Black & White Hat** - Both attack and defense perspectives
- ✅ **Synthetic Materials** - Practice without hardware or live targets
- ✅ **PoC Scripts** - Ready-to-use automation scripts
- ✅ **CVE Coverage** - Latest vulnerabilities included (2024-2025)

---

## 📚 Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/WiFi-Penetration-Testing-Guide.git
cd WiFi-Penetration-Testing-Guide

# Choose your path:
cat beginner/README.md      # Start here if new
cat intermediate/README.md  # If you know aircrack-ng
cat advanced/README.md      # For security professionals
```

---

## 🗂️ Repository Structure

```
WiFi-Penetration-Testing-Guide/
├── beginner/                    # Foundation tier
│   ├── 01-fundamentals.md      # 802.11 standards, frame types
│   ├── 02-setup-and-tools.md   # Hardware, Kali, adapter setup
│   ├── 03-reconnaissance.md    # airodump-ng, target selection
│   ├── 04-wpa2-attacks.md      # Handshake capture, deauth
│   ├── 05-wps-attacks.md       # Pixie Dust, reaver
│   ├── 06-password-cracking.md # hashcat, wordlists, rules
│   ├── README.md
│   └── scripts/
│       ├── auto-recon.sh       # Automated network survey
│       ├── handshake-capture.sh # WPA2 handshake automation
│       ├── wps-attack.sh       # WPS vulnerability test
│       └── auto-crack.sh       # Progressive hashcat pipeline
│
├── intermediate/               # Enterprise tier
│   ├── 01-enterprise-wifi.md   # 802.1X, RADIUS, EAP
│   ├── 02-eap-attacks.md       # PEAP-MSCHAPv2, rogue AP
│   ├── 03-evil-twin.md         # hostapd-mana, KARMA
│   ├── 04-pmkid-attack.md      # Clientless capture
│   ├── 05-client-attacks.md    # Probe requests, KARMA
│   ├── 06-post-exploitation.md # Pivoting, reporting
│   ├── README.md
│   └── scripts/
│
├── advanced/                     # Expert tier
│   ├── 01-wpa3-dragonblood.md  # SAE side-channels
│   ├── 02-wifi6-attacks.md     # 802.11ax exploitation
│   ├── 03-sdr-attacks.md       # HackRF, jamming
│   ├── 04-mesh-networks.md     # 802.11s attacks
│   ├── 05-wids-evasion.md      # Signature bypass
│   ├── 06-multi-vector.md      # Red team chains
│   ├── 07-exploit-development.md # Scapy fuzzing
│   └── README.md
│
├── synth/                        # Synthetic practice materials
│   ├── beginner/
│   ├── intermediate/
│   └── advanced/
│
├── network-recon.sh            # Full network reconnaissance
├── pentest-methodology.sh      # Complete pentest workflow
├── diagram-generator.sh        # Topology visualization
└── README.md                   # This file
```

---

## 🔒 Legal Notice

**These tools and techniques are for authorized security testing only.**

### Requirements Before Use

1. ✅ Written authorization from network owner
2. ✅ Defined scope and target IP ranges
3. ✅ Approved testing window
4. ✅ Acknowledgment of legal implications

Unauthorized access to computer networks is illegal under:
- Computer Fraud and Abuse Act (US)
- Computer Misuse Act (UK)
- Similar statutes worldwide

---

## 🛠️ Hardware Requirements

### Essential

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| OS | Kali Linux | Kali Linux latest |
| RAM | 4 GB | 8+ GB |
| Storage | 20 GB | 50+ GB |
| WiFi Adapter | Monitor mode capable | Alfa AWUS036ACM |

### Recommended Adapters

| Adapter | Chipset | Bands | Injection |
|---------|---------|-------|-----------|
| Alfa AWUS036ACM | MT7612U | 2.4/5 GHz | ✅ |
| Alfa AWUS036ACH | RTL8812AU | 2.4/5 GHz | ✅ |
| TP-Link TL-WN722N v1 | AR9271 | 2.4 GHz | ✅ |

---

## 📊 Learning Path

### Beginner Track (Start Here)

```
01-fundamentals.md → 02-setup-and-tools.md → 03-reconnaissance.md → 
04-wpa2-attacks.md → 05-wps-attacks.md → 06-password-cracking.md
```

**Goal**: Capture WPA2 handshake, crack with hashcat, understand WPS vulnerabilities

### Intermediate Track

```
01-enterprise-wifi.md → 02-eap-attacks.md → 03-evil-twin.md → 
04-pmkid-attack.md → 05-client-attacks.md → 06-post-exploitation.md
```

**Goal**: Attack enterprise WiFi, set up rogue APs, capture PMKID

### Advanced Track

```
01-wpa3-dragonblood.md → 02-wifi6-attacks.md → 03-sdr-attacks.md → 
04-mesh-networks.md → 05-wids-evasion.md → 06-multi-vector.md → 07-exploit-development.md
```

**Goal**: WPA3 side-channels, WiFi 6 exploitation, custom tool development

---

## 🧪 Synthetic Practice Materials

Practice without live targets using our synthetic materials:

```bash
# Use sample wordlists
cat synth/beginner/wordlists/top-100-wifi.txt

# Practice hashcat on synthetic hashes
hashcat -a 0 -m 22000 synth/beginner/hashes/practice-target.hc22000 wordlist.txt

# Analyze sample captures
tshark -r synth/intermediate/captures/sample-eap.pcap
```

---

## 🤝 Contributing

Contributions welcome! Areas needing help:

- Additional PoC scripts
- New CVE writeups
- Translations
- Bug fixes

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## 📜 License

MIT License - See [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

- aircrack-ng team for the foundational tools
- hashcat team for GPU cracking
- hostapd-mana and eaphammer contributors
- Security researchers publishing WiFi vulnerabilities

---

## 📞 Support

- Open an issue for bugs
- Discussions for questions
- No support for illegal activities

---

**Start learning**: [Beginner Tier →](beginner/README.md)
