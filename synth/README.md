# Synthetic Practice Materials

This directory contains synthetic sample files for practice without attacking live networks.

## Structure

```
synth/
  tier-1/          # Beginner practice materials
    sample-handshakes/     # Pre-captured WPA2 handshakes
    sample-wps-captures/   # WPS exchange captures
    sample-pmkid/          # PMKID hash files
    sample-wordlists/      # Test wordlists with known passwords
  tier-2/          # Intermediate practice
    sample-radius/         # RADIUS capture samples
    sample-eap-peap/       # EAP-PEAP handshake captures
    sample-rogue-ap/       # Rogue AP configuration templates
  tier-3/          # Advanced practice
    sample-sae-exchange/   # WPA3-SAE commit/confirm captures
    sample-mlo-capture/    # Wi-Fi 7 MLO beacon/action captures
    sample-ftm-exchange/   # FTM request/response captures
```

## Usage

All sample files are generated synthetically with known passwords/credentials for self-testing.

### Tier 1: Crack These

| File | Expected Password | Hashcat Mode |
|------|-------------------|-------------|
| `tier-1/sample-handshakes/home-wpa2.hc22000` | `password123` | 22000 |
| `tier-1/sample-handshakes/coffee-shop.hc22000` | `StarBucks2023!` | 22000 |
| `tier-1/sample-pmkid/router-pmkid.hc22000` | `admin12345` | 22001 |
| `tier-1/sample-wps-captures/linksys-wps.pcap` | WPS PIN: `12345670` | reaver |

### Tier 2: Analyze These

| File | Task |
|------|------|
| `tier-2/sample-eap-peap/corp-eap-peap.pcap` | Extract MSCHAPv2 challenge-response |
| `tier-2/sample-radius/radius-auth.pcap` | Identify RADIUS shared secret |
| `tier-2/sample-rogue-ap/mana-creds.log` | Parse harvested EAP credentials |

### Tier 3: Reverse These

| File | Task |
|------|------|
| `tier-3/sample-sae-exchange/wpa3-sae.pcapng` | Analyze SAE commit/confirm timing |
| `tier-3/sample-mlo-capture/mlo-beacon.pcapng` | Extract MLD parameters from EHT IE |
| `tier-3/sample-ftm-exchange/ftm-measurement.pcapng` | Calculate RTT from FTM timestamps |

## Generating New Samples

```bash
# Generate synthetic WPA2 handshake with known password
./scripts/gen-handshake.py --ssid "TestNet" --password "TestPass123" -o test.hc22000

# Generate synthetic EAP-PEAP capture
./scripts/gen-eap-peap.py --identity "user@corp.com" --password "CorpPass2024" -o eap.pcap

# Generate synthetic SAE exchange
./scripts/gen-sae.py --ssid "WPA3Net" --password "SecurePass456" -o sae.pcapng
```
