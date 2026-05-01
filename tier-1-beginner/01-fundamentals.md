# 01 — 802.11 Fundamentals and Encryption

## 802.11 Frame Structure

IEEE 802.11 operates at Layer 2. Every frame contains:

- **Frame Control** (2 bytes): Protocol version, type, subtype, flags
- **Duration/ID** (2 bytes): NAV or association ID
- **Address 1-4** (6 bytes each): MAC addresses depending on frame type
- **Sequence Control** (2 bytes): Fragment number, sequence number
- **Frame Body** (0-2312 bytes): Payload
- **FCS** (4 bytes): Frame Check Sequence (CRC-32)

### Frame Types

| Type | Subtype | Purpose |
|------|---------|---------|
| Management | 0x00 | Association Request |
| Management | 0x01 | Association Response |
| Management | 0x04 | Probe Request |
| Management | 0x05 | Probe Response |
| Management | 0x08 | Beacon |
| Management | 0x0A | Disassociation |
| Management | 0x0B | Authentication |
| Management | 0x0C | Deauthentication |
| Control | 0x1B | Request to Send (RTS) |
| Control | 0x1C | Clear to Send (CTS) |
| Control | 0x1D | Acknowledgment (ACK) |
| Data | 0x20 | Data |
| Data | 0x28 | QoS Data |

## 802.11 State Machine

A client transitions through states:

1. **Unauthenticated/Unassociated** → Sends Authentication frame
2. **Authenticated/Unassociated** → Sends Association Request
3. **Authenticated/Associated** → 4-way handshake begins
4. **Authenticated/Associated/Connected** — Port authorized, data flows

## Encryption Evolution

### WEP (Wired Equivalent Privacy)

- **Algorithm**: RC4 stream cipher
- **Key Length**: 64-bit (40-bit IV + 24-bit key) or 128-bit (104-bit IV + 24-bit key)
- **IV Space**: 24 bits = 16,777,216 unique IVs
- **Flaw**: IV reuse (birthday paradox means collision after ~5,000 packets). FMS attack and KoreK chopchop recover key.

```
WEP Ciphertext = plaintext XOR RC4(IV || key)
```

### WPA (Wi-Fi Protected Access)

- **Algorithm**: TKIP (Temporal Key Integrity Protocol)
- **Key**: 128-bit temporal key derived from PMK
- **Features**: Per-packet key mixing, MIC (Message Integrity Check), 48-bit IV (sequence counter)
- **Flaw**: MIC failure exploits (Beck-Tews attack), chopchop on QoS frames

### WPA2 (802.11i)

- **Algorithm**: CCMP (Counter Mode with Cipher Block Chaining Message Authentication Code Protocol)
- **Cipher**: AES-128 in CCM mode
- **Key Hierarchy**: PMK → PTK (Pairwise Transient Key) → GTK (Group Temporal Key)
- **Flaw**: KRACK (Key Reinstallation Attack), KR00K (all-zero TK vulnerability)

### WPA3-Personal

- **Algorithm**: SAE (Simultaneous Authentication of Equals) — Dragonfly Key Exchange
- **Cipher**: GCMP-128 or CCMP
- **Features**: Forward secrecy, protected management frames (PMF mandatory)
- **Flaw**: Dragonblood side-channels (timing, cache), downgrade to WPA2

## The 4-Way Handshake

The 4-way handshake derives the PTK from the PMK without transmitting the PMK.

### Key Derivation

```
PMK = PBKDF2-SHA1(PSK, SSID, 4096 iterations, 256 bits)
PTK = PRF(PMK, "Pairwise key expansion", Min(AA,SA) || Max(AA,SA) || Min(ANonce,SNonce) || Max(ANonce,SNonce))
```

PTK is 512 bits, split into:
- KCK (128 bits) — Key Confirmation Key
- KEK (128 bits) — Key Encryption Key
- TK (128 bits) — Temporal Key
- MIC AP (64 bits) + MIC STA (64 bits) — Message Integrity Code keys

### Message Flow

| Step | Sender | Content | Nonce / Key Data |
|------|--------|---------|-----------------|
| 1 | AP | ANonce, replay counter | Authenticator nonce |
| 2 | STA | SNonce, MIC, RSN IE | Supplicant nonce, KCK-signed |
| 3 | AP | GTK, MIC, replay counter | KEK-encrypted GTK, install PTK |
| 4 | STA | MIC, replay counter | Acknowledgment, install PTK |

### Vulnerable Points

- **Message 3 retransmission**: AP retransmits Message 3 if no Message 4 received. Attacker blocks Message 4, AP reinstalls PTK with nonce reset → KRACK.
- **All-zero TK**: If handshake interrupted after Message 1, some chipsets (Broadcom, Cypress) use all-zero TK → KR00K.

## EAPOL (Extensible Authentication Protocol over LAN)

The 4-way handshake uses EAPOL-Key frames:

- **Descriptor Type**: 0x02 (Key Descriptor)
- **Key Information**: Key Type (1=PTK, 0=GTK), Install, ACK, MIC, Secure, Error, Request, Encrypted
- **Key Length**: 16 bytes (CCMP) or 32 bytes (GCMP-256)
- **Replay Counter**: 64-bit, incremented per handshake
- **Nonce**: 32 bytes (ANonce or SNonce)
- **Key IV**: 16 bytes
- **Key RSC**: 8 bytes (receive sequence counter)
- **Key ID**: 8 bytes
- **Key Data**: Variable length, contains RSN IE or GTK

## Offensive Application

- **Passive capture**: Monitor mode capture of Beacon, Probe Response, Authentication, Association frames reveals SSID, encryption type, supported rates, vendor.
- **Handshake capture**: Extract ANonce, SNonce, MIC to derive PTK offline if PSK known, or brute-force PSK from captured handshake.
- **Deauthentication**: Forced reconnection triggers new handshake capture.
- **KRACK exploitation**: Block Message 4 → AP reinstalls PTK with nonce=0 → decrypt/replay captured frames.

## Defensive Application

- **PMF (Protected Management Frames)**: Cryptographically protects Deauth/Disassoc frames (802.11w). Prevents deauth floods but not all bypasses.
- **Nonce tracking**: Log EAPOL replay counters. Alert on counter reuse or reset.
- **Firmware patching**: Update Broadcom/Cypress chipsets against KR00K (CVE-2019-15126, CVE-2020-24588).
