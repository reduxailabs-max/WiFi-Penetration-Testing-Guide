# Module 01 — WiFi Fundamentals

## 1.1 The 802.11 Standard

WiFi is governed by the IEEE 802.11 family of standards. Each revision improves speed, range, or security:

| Standard | Band | Max Speed | Common Name |
|----------|------|-----------|-------------|
| 802.11b | 2.4 GHz | 11 Mbps | Wi-Fi 1 |
| 802.11a | 5 GHz | 54 Mbps | Wi-Fi 2 |
| 802.11g | 2.4 GHz | 54 Mbps | Wi-Fi 3 |
| 802.11n | 2.4/5 GHz | 600 Mbps | Wi-Fi 4 |
| 802.11ac | 5 GHz | 3.5 Gbps | Wi-Fi 5 |
| 802.11ax | 2.4/5/6 GHz | 9.6 Gbps | Wi-Fi 6/6E |
| 802.11be | 2.4/5/6 GHz | 46 Gbps | Wi-Fi 7 |

> **Security note:** The standard version does not determine security. A device can use 802.11ac (Wi-Fi 5) with WPA3, or 802.11b with WEP. Security is a separate negotiation.

---

## 1.2 Frequency Bands

### 2.4 GHz
- 14 channels (most countries allow 1–13; US allows 1–11)
- Only 3 non-overlapping channels: **1, 6, 11**
- Longer range, better wall penetration
- More crowded (microwaves, Bluetooth, baby monitors)

### 5 GHz
- 24+ non-overlapping channels (varies by country)
- Shorter range, higher throughput
- Less congested

### 6 GHz (Wi-Fi 6E / 7)
- Entirely new spectrum, no legacy devices
- 59 non-overlapping 20 MHz channels
- Lowest interference, highest throughput

```
Channel Layout (2.4 GHz)
Ch:  1    2    3    4    5    6    7    8    9   10   11
    ████ ████ ████ ████ ████
              ████ ████ ████ ████ ████
                             ████ ████ ████ ████ ████
     ^non-overlap^            ^non-overlap^    ^non-overlap^
```

---

## 1.3 Key Identifiers

| Term | Meaning | Example |
|------|---------|---------|
| **SSID** | Service Set Identifier — network name | `HomeNetwork_5G` |
| **BSSID** | Basic SSID — MAC address of the AP | `AA:BB:CC:DD:EE:FF` |
| **ESSID** | Extended SSID — logical name across multiple APs | Same as SSID in most cases |
| **Channel** | Frequency channel the AP operates on | `6` |
| **Signal (dBm)** | Signal strength (closer to 0 = stronger) | `-65 dBm = good` |

---

## 1.4 WiFi Security Protocols

### WEP (Wired Equivalent Privacy) — **Broken**
- Released: 1997
- Uses RC4 stream cipher with static keys
- IVs (Initialization Vectors) are too short (24-bit), repeat in ~5000 packets
- A WEP network can be cracked in **under 60 seconds** with modern tools
- **Status: Do not use. Deprecated by IEEE in 2004.**

### WPA (Wi-Fi Protected Access) — **Weak**
- Released: 2003 as emergency patch
- TKIP (Temporal Key Integrity Protocol) — still RC4 under the hood
- Vulnerable to TKIP attacks, Michael MIC attacks
- **Status: Avoid. Deprecated.**

### WPA2-Personal (PSK) — **Common, attackable**
- Released: 2004
- AES-CCMP encryption (strong)
- Vulnerability: the 4-way handshake can be captured and the Pre-Shared Key cracked offline
- Also vulnerable to PMKID attack (no clients needed)
- **Status: Widely deployed. Use strong passphrases (20+ chars) to resist cracking.**

### WPA2-Enterprise — **Stronger**
- Uses 802.1X/EAP for authentication
- Each user gets unique credentials (no shared password)
- Requires a RADIUS server
- Vulnerable to rogue AP attacks if clients don't validate certificates
- **Status: Recommended for organizations.**

### WPA3-Personal (SAE) — **Current standard**
- Simultaneous Authentication of Equals (SAE) replaces PSK
- Forward secrecy — past sessions can't be decrypted if key is later compromised
- Resistant to offline dictionary attacks
- Vulnerable to DragonBlood (side-channel) attacks in some implementations
- **Status: Recommended. Enable if hardware supports it.**

---

## 1.5 The WPA2 4-Way Handshake (Critical Concept)

Understanding the handshake is essential because **this is what you capture and crack.**

```
CLIENT (Supplicant)          ACCESS POINT (Authenticator)
       |                              |
       |<------ Message 1: ANonce ----|  AP sends random nonce
       |                              |
       |------- Message 2: SNonce --->|  Client sends own nonce
       |        + MIC (integrity)     |  MIC proves client knows PSK
       |                              |
       |<------ Message 3: GTK -------|  AP sends Group Temporal Key
       |        + MIC                 |  MIC proves AP knows PSK too
       |                              |
       |------- Message 4: ACK ------>|  Client confirms
       |                              |
       |     [Encrypted comms begin]  |
```

**What you capture:** Messages 1+2 or 2+3 (the nonces and MICs)

**What you crack:** The MIC is computed using `HMAC-SHA1(PTK, ...)` where `PTK` is derived from the PSK. If you guess the PSK, you can verify whether it produces the correct MIC.

```
PSK + SSID → PBKDF2-SHA1 → PMK (256-bit)
PMK + ANonce + SNonce + MACs → PRF → PTK
PTK → MIC key → verify captured MIC
```

> This is why capture + cracking works: you don't break AES. You guess the password and mathematically verify it against the handshake.

---

## 1.6 Key Terms Glossary

| Term | Definition |
|------|-----------|
| **Monitor Mode** | NIC mode that captures all 802.11 frames, not just those addressed to your MAC |
| **Managed Mode** | Normal WiFi mode — only processes frames for your MAC |
| **Packet Injection** | Ability to transmit arbitrary 802.11 frames |
| **PMK** | Pairwise Master Key — derived from passphrase + SSID |
| **PTK** | Pairwise Transient Key — session key derived from PMK + nonces |
| **GTK** | Group Temporal Key — used for multicast/broadcast frames |
| **Beacon** | Management frame sent by AP every ~100ms advertising the network |
| **Deauth** | Management frame that disconnects a client from the AP |
| **Probe Request** | Frame sent by client scanning for known networks |
| **PMKID** | Hash in the first EAPOL frame that can be captured without a client connecting |

---

## Knowledge Check

Before moving to the next module, answer these:

1. What are the 3 non-overlapping channels on 2.4 GHz?
2. Why is WEP insecure? (hint: IV length)
3. In the 4-way handshake, which message contains the client's SNonce?
4. What two things does hashcat need to crack a WPA2 handshake?
5. What is the difference between a BSSID and an SSID?

---

[← README](README.md) | [Next: Lab Setup →](02-setup-and-tools.md)
