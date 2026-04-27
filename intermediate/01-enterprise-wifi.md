# Module 01 — Enterprise WiFi Architecture

## 1.1 802.1X/EAP Framework

### Authentication Flow

```
Client (Supplicant)    AP (Authenticator)    RADIUS Server
        |                      |                     |
        |----- EAPOL-Start --->|                     |
        |                      |                     |
        |<---- EAP-Request ----|                     |
        |    (Identity)        |                     |
        |                      |                     |
        |----- EAP-Response --->|                     |
        |    (Identity)        |                     |
        |                      |---- RADIUS Access-Request ->|
        |                      |                     |
        |                      |<- RADIUS Access-Challenge -|
        |<---- EAP-Request ----|                     |
        |    (Method Specific) |                     |
        |                      |                     |
        |----- EAP-Response --->|                     |
        |                      |---- RADIUS Access-Request ->|
        |                      |                     |
        |                      |<- RADIUS Access-Accept ---|
        |<---- EAP-Success -----|                     |
        |                      |                     |
        |===== Encrypted ======|====== Traffic =====>
```

---

## 1.2 EAP Methods Comparison

| Method | Tunnel | Credential Type | Vulnerability |
|--------|--------|-----------------|---------------|
| PEAP-MSCHAPv2 | TLS | Password | Offline crackable |
| EAP-TTLS-PAP | TLS | Password | Cleartext in tunnel |
| EAP-TTLS-CHAP | TLS | Password | CHAP hash capture |
| EAP-TLS | None | Certificate | Secure (if validated) |
| EAP-FAST | TLS (PAC) | Password | PAC cloning |
| EAP-PEAP-GTC | TLS | Token/OTP | Phishable |

### PEAP-MSCHAPv2 Vulnerability

**Mechanism**: Challenge-response authentication inside TLS tunnel
**Attack**: Rogue AP captures challenge/response, offline brute-force
**Tool**: asleap, john, hashcat

```
MSCHAPv2 Challenge-Response:
Challenge (16 bytes) + Password -> Response (24 bytes)

Attack: Response = DES(SessionHash, NtPasswordHash)
Offline brute-force possible with captured:
- Username
- Challenge
- Response
```

---

## 1.3 RADIUS Protocol Deep Dive

### Packet Structure

```
RADIUS Access-Request (Code 1):
- Authenticator (16 bytes random)
- Attributes:
  * User-Name (Type 1)
  * NAS-IP-Address (Type 4)
  * Calling-Station-Id (Type 31) - Client MAC
  * Called-Station-Id (Type 30) - AP MAC + SSID
  * NAS-Identifier (Type 32)

RADIUS Access-Accept (Code 2):
- Attributes:
  * Session-Timeout (Type 27)
  * Tunnel-Pvt-Group-ID (Type 81) - VLAN assignment
  * Filter-Id (Type 11) - ACL
```

### Key Derivation

```
PMK = PRF(Master-Key, "Client EAP encryption" | 
          AAA-Key | client_random | server_random)

Where:
- Master-Key = TLS master secret (PEAP/TTLS)
- AAA-Key = RADIUS session key
- client_random = TLS client random
- server_random = TLS server random
```

---

## 1.4 Certificate Validation

### Certificate Chain Verification

```
Client validates server certificate:
1. Certificate not expired
2. Certificate chain to trusted CA
3. Certificate matches server identity
4. Certificate not revoked (CRL/OCSP)

Attack Vector: If client skips validation:
- Attacker presents self-signed cert
- Client accepts and sends credentials
```

### Common Validation Failures

| Check | Attack When Skipped |
|-------|---------------------|
| Expiration | Use expired cert |
| Chain | Self-signed CA injection |
| Identity | Any valid cert accepted |
| Revocation | Compromised cert reuse |

---

## 1.5 Detection: Enterprise Attack Signatures

### Rogue RADIUS Detection

```bash
# Monitor for unexpected RADIUS servers
sudo tcpdump -i eth0 port 1812 or port 1813

# Check RADIUS server certificate changes
openssl s_client -connect radius.corp.com:1812 -showcerts
```

### WIDS Enterprise Signatures

| Alert | Trigger |
|-------|---------|
| Rogue EAP Server | Mismatched RADIUS cert hash |
| EAP Method Downgrade | PEAP requested, TLS offered |
| Fast Reconnect Abuse | Rapid PAC reuse |
| Tunnel Downgrade | TLS 1.0 vs 1.3 negotiation |

---

## 1.6 Defense: Enterprise Hardening

### Recommended Configuration

```
EAP Method Priority:
1. EAP-TLS (certificate-based)
2. EAP-PEAP with certificate validation
3. EAP-TTLS with strong inner auth

Never Allow:
- EAP-MD5 (cleartext equivalent)
- EAP-LEAP (Cisco proprietary, weak)
- PEAP without cert validation

Required Client Settings:
- Validate server certificate: ENABLED
- Connect to specific servers: CONFIGURED
- Do not prompt for new servers: ENABLED
- Trusted root CA: CORPORATE-CA-ONLY
```

### Server-Side Controls

| Control | Implementation |
|---------|----------------|
| Certificate Pinning | Client config with server cert hash |
| Network Access Control | MACsec + 802.1X |
| RADIUS Accounting | Log all authentication attempts |
| VLAN Segmentation | Dynamic VLAN per user group |

---

## 1.7 PoC: EAP Handshake Analysis

```bash
#!/bin/bash
# eap-analyzer.sh - Extract EAP credentials from capture

capture=$1

echo "[+] Analyzing EAP handshake: $capture"

# Extract EAP Identity
echo "[+] Identities found:"
tshark -r "$capture" -Y "eap" -T fields -e eap.identity 2>/dev/null | sort | uniq -c

# Extract TLS certificate info
echo "[+] TLS certificates:"
tshark -r "$capture" -Y "ssl.handshake.certificate" -T fields -e x509sat.Utf8String 2>/dev/null

# Check for MSCHAPv2
echo "[+] MSCHAPv2 challenge/response pairs:"
tshark -r "$capture" -Y "mschap" -T fields -e mschap.challenge -e mschap.response 2>/dev/null
```

---

**Next**: [Module 02 — EAP Attacks](02-eap-attacks.md)
