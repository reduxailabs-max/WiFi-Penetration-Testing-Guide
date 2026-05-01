# 05 — Client-Side Attacks

## Wi-Fi Auto-Connect Exploitation

Most devices auto-connect to known SSIDs. Exploit with Karma/mana:
- **Windows**: Preferred networks list via `netsh wlan show profiles`
- **macOS**: `/Library/Preferences/SystemConfiguration/` plist
- **Android**: `wpa_supplicant.conf` on rooted devices

## Hotspot 2.0 / Passpoint

ANQP-based network discovery. Attack vectors:
- **Rogue OSU server**: Fake Online Sign-Up server for credential theft
- **ANQP injection**: Advertise false venue/roaming information
- **OSU downgrade**: Force HTTP (no TLS) OSU signup

```bash
# Hostapd with Hotspot 2.0
interworking=1
hs20=1
hs20_oper_friendly_name=eng:FreeWiFi
osu_ssid=FreeWiFi-OSU
osu_server_uri=https://osu.example.com/
```

## Downgrade Attacks

Force client to use weaker protocols:
- **WPA3→WPA2**: Transition mode downgrade
- **WPA2→WEP**: Legacy client fallback
- **EAP method**: GTC/LEAP downgrade

```bash
# Downgrade via cloned AP with weaker RSN IE
python3 downgrade-ap.py --ssid CorpWiFi --force-wpa2-psk
```

## Client Credential Theft

- **Captive portal phishing**: Fake login page mimicking corporate portal
- **Browser auto-fill**: Exploit saved credentials via crafted portal
- **TLS stripping**: Strip HTTPS on captive portal redirect

## Defensive Application

- Disable auto-connect for sensitive networks
- Use Hotspot 2.0 with certificate-based OSU
- Enforce WPA3-only on managed devices
- Deploy device certificates (EAP-TLS)
