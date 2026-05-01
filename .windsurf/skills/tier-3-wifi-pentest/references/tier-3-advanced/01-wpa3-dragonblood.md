# 01 — WPA3 & Dragonblood

## WPA3-SAE Vulnerabilities

Dragonblood (2019): SAE handshake side-channels.
- CVE-2019-9494: SAE cache attack
- CVE-2019-9495: SAE timing side-channel
- CVE-2019-9496: EAP-pwd side-channel
- CVE-2019-9497: Denial of service
- CVE-2019-9498: EAP-pwd reflection attack
- CVE-2019-9499: EAP-pwd invalid curve attack

## SAE Side-Channel Attacks

Cache attack: Extract password from SAE state machine timing.

```bash
# Dragonblood reference implementation
# https://github.com/vanhoefm/dragonblood
python3 dragonblood.py --target-ssid WPA3-Network --interface wlan0
```

## Transition Mode Attacks

WPA2/WPA3 mixed mode: Downgrade to WPA2, exploit legacy.

```bash
# Clone AP with WPA2 beacon, force clients to downgrade
hostapd /etc/hostapd/wpa2-downgrade.conf
```

## Defensive Application

- Disable WPA2 transition mode, use pure WPA3
- Apply SAE caching patches
- Monitor for downgrade attempts
