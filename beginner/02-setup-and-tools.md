# Module 02 — Lab Setup & Tools

## 2.1 Operating System

**Kali Linux** is the standard for WiFi pentesting. It ships with the full aircrack-ng suite, hashcat, and driver support for common chipsets.

```bash
# Download from kali.org (official only)
# Minimum specs: 4GB RAM, 20GB disk, dedicated GPU for cracking

# Update everything first
sudo apt update && sudo apt full-upgrade -y
```

**Alternatives:**
- Parrot OS Security — lighter than Kali
- BlackArch — Arch-based, more cutting-edge packages
- Ubuntu + manual tool install — for experienced users

---

## 2.2 Hardware — WiFi Adapters

Your built-in laptop card almost certainly **does not support monitor mode or packet injection.** You need an external adapter.

### Adapter Requirements
- **Monitor mode** — required for passive capture
- **Packet injection** — required for active attacks (deauth, fake frames)
- **Band support** — 2.4 GHz minimum; dual-band for 5 GHz targets

### Recommended Adapters

| Adapter | Chipset | Band | Injection | Notes |
|---------|---------|------|-----------|-------|
| Alfa AWUS036ACM | MediaTek MT7612U | 2.4+5 GHz | ✓ | Best all-rounder |
| Alfa AWUS036ACH | Realtek RTL8812AU | 2.4+5 GHz | ✓ | High power output |
| Alfa AWUS036NH | Ralink RT3070 | 2.4 GHz | ✓ | Budget, reliable |
| TP-Link TL-WN722N **v1 only** | Atheros AR9271 | 2.4 GHz | ✓ | v2/v3 do NOT support injection |
| Panda PAU09 | Ralink RT5572 | 2.4+5 GHz | ✓ | Good Linux support |

> **Warning on TP-Link TL-WN722N:** The v1 uses AR9271 (supported). Versions v2 and v3 use RTL8188EUS which has **no injection support** in mainline kernels. Check the hardware version before buying.

### Verifying Your Adapter

```bash
# List wireless adapters
iw dev

# Check supported modes
iw list | grep -A 10 "Supported interface modes:"

# Expected output for a good adapter:
# Supported interface modes:
#   * IBSS
#   * managed
#   * AP
#   * AP/VLAN
#   * monitor      <--- this is what you need
#   * mesh point
#   * P2P-client
#   * P2P-GO

# Test packet injection
sudo aireplay-ng --test wlan0
# Look for: "Injection is working!"
```

---

## 2.3 Driver Issues & Fixes

### RTL8812AU (Alfa AWUS036ACH)

The mainline kernel driver often has poor injection support. Use the patched driver:

```bash
sudo apt install dkms git
git clone https://github.com/aircrack-ng/rtl8812au.git
cd rtl8812au
make dkms_install
```

### MT7612U (Alfa AWUS036ACM)

Usually works out of the box on Kali 2023+:

```bash
# Check if module is loaded
lsmod | grep mt76
# Should show: mt76x2u, mt76x2_common, mt76x02_lib, mt76_usb, mt76
```

---

## 2.4 Installing Required Tools

```bash
# Core aircrack-ng suite
sudo apt install -y aircrack-ng

# Password cracking
sudo apt install -y hashcat

# Advanced capture tools
sudo apt install -y hcxdumptool hcxtools

# Network scanning
sudo apt install -y nmap masscan

# WPS attacks
sudo apt install -y reaver bully

# Traffic analysis
sudo apt install -y wireshark tshark

# Python tools
sudo apt install -y python3 python3-pip
pip3 install scapy

# Check versions
airmon-ng --help 2>&1 | head -3
hashcat --version
hcxdumptool --version
```

---

## 2.5 Setting Up Monitor Mode

Monitor mode lets your adapter capture ALL 802.11 frames on the channel, not just those addressed to you.

```bash
# Method 1: airmon-ng (recommended for beginners)
sudo airmon-ng check kill    # Kill NetworkManager and wpa_supplicant
sudo airmon-ng start wlan0   # Creates wlan0mon
iwconfig                      # Verify: Mode:Monitor

# Method 2: iw (manual, more control)
sudo ip link set wlan0 down
sudo iw dev wlan0 set type monitor
sudo ip link set wlan0 up
iwconfig wlan0

# Method 3: iwconfig (legacy)
sudo ifconfig wlan0 down
sudo iwconfig wlan0 mode monitor
sudo ifconfig wlan0 up

# Lock to specific channel
sudo iwconfig wlan0mon channel 6
# or
sudo iw dev wlan0mon set channel 6

# Restore to managed mode when done
sudo airmon-ng stop wlan0mon
sudo service NetworkManager start
```

> **Why `check kill`?** NetworkManager and wpa_supplicant constantly send probe requests, disrupting captures. Kill them before testing.

---

## 2.6 Wordlists for Password Cracking

```bash
# rockyou.txt — classic wordlist (14M passwords)
ls /usr/share/wordlists/rockyou.txt.gz
gunzip /usr/share/wordlists/rockyou.txt.gz

# Install additional wordlists
sudo apt install -y wordlists
ls /usr/share/wordlists/

# Download large wordlist collections
# SecLists (GitHub) — comprehensive collection
sudo apt install -y seclists
ls /usr/share/seclists/Passwords/

# Download WiFi-specific wordlists
wget https://raw.githubusercontent.com/kennyn510/wpa2-wordlists/master/Wordlists/WPA2/WPA-PSK-WORDLIST.gz
```

---

## 2.7 Lab Environment Options

### Option A: Home Lab (Recommended)
- Use an old router you own
- Create a test network with a known weak password
- Practice on your own equipment legally

### Option B: Virtual Lab
- **GNS3** with wireless emulation (limited)
- **Wireless Lab VMs** — specialized VMs with pre-configured vulnerable APs

### Option C: CTF Competitions
- HackTheBox, TryHackMe have WiFi challenges
- NullCon, DEF CON CTF often include wireless
- Safe, legal, and challenging

### Setup Script

```bash
# scripts/beginner-setup.sh verifies your environment is ready
chmod +x scripts/beginner-setup.sh
sudo ./scripts/beginner-setup.sh
```

---

## 2.8 Verification Checklist

Before proceeding, verify each item:

```bash
# 1. Adapter detected
iw dev | grep Interface

# 2. Monitor mode works
sudo airmon-ng start wlan0
iwconfig wlan0mon | grep "Mode:Monitor"

# 3. Injection works
sudo aireplay-ng --test wlan0mon
# Should print: Injection is working!

# 4. airodump-ng captures frames
sudo airodump-ng wlan0mon
# Should show nearby APs within seconds

# 5. hashcat runs
hashcat --benchmark -m 22000
```

---

[← Fundamentals](01-fundamentals.md) | [Next: Reconnaissance →](03-reconnaissance.md)
