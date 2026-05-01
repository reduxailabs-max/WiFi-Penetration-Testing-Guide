# 07 — RADIUS Deep Dive

## RADIUS Protocol Analysis

RADIUS uses UDP ports 1812 (auth) and 1813 (acct). Packet structure:
- **Code**: Access-Request(1), Access-Accept(2), Access-Reject(3), Access-Challenge(11)
- **Identifier**: 1-byte sequence matching request/response
- **Authenticator**: 16-byte MD5-based hash
- **Attributes**: Type-Length-Value triplets

## Shared Secret Cracking

The RADIUS Request Authenticator is computed as `MD5(Code + Identifier + Length + 16 zero bytes + Attributes + shared_secret)`. This is plain MD5, not HMAC-MD5. Given a known plaintext packet, the shared secret can be brute-forced.

```bash
# Capture RADIUS traffic
tcpdump -i eth0 port 1812 -w radius.pcap

# Extract and crack with john or custom script
# radius2john.py radius.pcap > radius.hashes
# john --format=md5 radius.hashes
# Or: hashcat -m 500 radius.hashes wordlist.txt
```

## EAP-SIM / EAP-AKA Attacks

Common in university networks with cellular authentication:
- **IMSI extraction**: EAP-SIM exposes IMSI in outer identity
- **Downgrade to EAP-SIM**: Weaker than EAP-AKA/AKA'
- **Replay attacks**: Reuse authentication vectors

```bash
# Rogue AP with EAP-SIM support
# Requires USIM card reader for full exploitation
# Or downgrade to EAP-AKA' with weaker key derivation
```

## ePDG (Evolved Packet Data Gateway)

Wi-Fi Calling tunnels voice/SMS via ePDG using IKEv2 + ESP:
- **Call/SMS hijack**: Intercept ePDG tunnel
- **IMSI catch via ePDG**: Extract IMSI from IKEv2 identity

```bash
# Capture IKEv2 negotiation
tcpdump -i eth0 port 500 or port 4500 -w epdg.pcap

# StrongSwan IKEv2 analysis
ipsec statusall
```

## RADIUS Amplification

RADIUS Access-Challenge can be used for DDoS amplification when source IP is spoofed.

## Defensive Application

- **RadSec (RADIUS over TLS)**: Encrypt all RADIUS traffic (RFC 6614)
- **DTLS for EAP**: Encrypt EAP method exchanges
- **EAP-AKA' with stronger keys**: Replace EAP-SIM
- **RADIUS over TCP**: Prevent amplification via connection tracking
