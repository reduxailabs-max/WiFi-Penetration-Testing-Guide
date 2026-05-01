# 02 — Tooling and Environment Setup

## Compatible Wireless Adapters

### Primary Recommendations

| Adapter | Chipset | Bands | Injection | Price | Notes |
|---------|---------|-------|-----------|-------|-------|
| Alfa AWUS036ACM | MT7612U | 2.4/5 GHz | Full | ~$40 | Plug-and-play on Kali |
| Alfa AWUS036ACH | RTL8812AU | 2.4/5 GHz | Full | ~$50 | High gain, compile driver |
| TP-Link Archer T4U Plus | RTL8812AU | 2.4/5 GHz | Full | ~$35 | Reliable |

### Adapter Configuration

```bash
# Identify wireless interface
iwconfig
# Expected output shows wlan0, wlan1, etc.

# Enable monitor mode (airmon-ng method)
airmon-ng check kill
airmon-ng start wlan0
# Output: monitor mode enabled on wlan0mon

# Verify monitor mode
iwconfig wlan0mon
# Expected: Mode:Monitor

# Test frame injection
aireplay-ng -9 wlan0mon
# Expected: Injection is working
```

### Alternative: Manual Monitor Mode

```bash
ip link set wlan0 down
iw dev wlan0 set type monitor
ip link set wlan0 up
iwconfig wlan0
# Mode:Monitor
```

## Core Tools Installation

```bash
# Aircrack-ng suite
apt-get install -y aircrack-ng

# Reaver (WPS attack)
apt-get install -y reaver

# Bully (WPS attack, faster)
apt-get install -y bully

# hcxtools (PMKID capture, conversion)
apt-get install -y hcxtools

# hashcat (GPU password cracking)
apt-get install -y hashcat

# Verify versions
aircrack-ng --version  # 1.7+
reaver -h              # 1.6.6+
hcxdumptool -h         # 6.3.4+
hashcat --version      # 6.2.6+
```

## Defensive Application

- **Hardware inventory**: Track authorized adapter MACs. Alert on unknown monitor-mode devices.
- **Monitor mode detection**: Some enterprise APs detect management frame patterns indicative of monitor mode.
- **Driver integrity**: Verify kernel module signatures to detect modified injection-capable drivers.
