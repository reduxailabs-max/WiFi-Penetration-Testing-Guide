# Module 03 — Reconnaissance

## 3.1 airodump-ng Command Reference

### Core Flags

| Flag | Function | Example |
|------|----------|---------|
| `-c` | Lock to channel | `-c 6` or `-c 1,6,11` |
| `-b` | Filter by BSSID | `-b AA:BB:CC:DD:EE:FF` |
| `-e` | Filter by SSID | `-e TargetNet` |
| `-w` | Write output prefix | `-w capture` |
| `-d` | Band selection | `-d abg` (all bands) |
| `-K` | Show manufacturer | `-K` |
| `-0` | Show WPS info | `-0` |
| `--output-format` | csv, pcap, ivs | `--output-format csv,pcap` |

### Essential Commands

```bash
# Basic 2.4 GHz scan
sudo airodump-ng wlan0mon

# Lock to specific channel (required for stable capture)
sudo airodump-ng -c 6 wlan0mon

# Target specific AP with file output
sudo airodump-ng -c 6 --bssid AA:BB:CC:DD:EE:FF -w target-capture wlan0mon

# 5 GHz scan
sudo airodump-ng --band a -w 5ghz-capture wlan0mon

# Both bands with WPS detection
sudo airodump-ng --band abg -0 -w full-survey wlan0mon
```

---

## 3.2 Output Interpretation

### AP Section Columns

| Column | Meaning | Target Indicators |
|--------|---------|-------------------|
| BSSID | AP MAC | Unique identifier |
| PWR | Signal (dBm) | -30 to -65 = attack viable |
| #Data | Data frames | >0 = active clients |
| CH | Channel | Must match for injection |
| ENC | Encryption | WPA2/PSK = primary target |
| CIPHER | Cipher type | TKIP < CCMP < GCMP |
| AUTH | Auth type | PSK = personal, MGT = enterprise |
| ESSID | Network name | `<length: 0>` = hidden |

### Station Section Columns

| Column | Meaning | Notes |
|--------|---------|-------|
| BSSID | Associated AP | `(not associated)` = probing |
| STATION | Client MAC | Target for deauth |
| PWR | Client signal | Weaker = farther from you |
| Rate | Data rates | High = close to AP |
| Lost | Dropped frames | High = interference/distance |

---

## 3.3 Signal Strength Analysis

### dBm to Distance (Indoor)

| dBm | Approx. Distance | Attack Feasibility |
|-----|------------------|-------------------|
| -30 | 1-2 meters | Excellent |
| -45 | 5-10 meters | Excellent |
| -60 | 20-30 meters | Good |
| -70 | 50-70 meters | Fair (retries needed) |
| -80 | 100+ meters | Poor (passive only) |

### Target Selection Criteria

**High Value:**
- WPA2-PSK with active clients (#Data > 0)
- WPS enabled (`WPS` column shows version)
- Strong signal (-30 to -65 dBm)
- TKIP cipher (weaker than CCMP)

**Avoid:**
- WPA3-SAE (uncrackable offline)
- WPA2-Enterprise (requires different attacks)
- Open networks (no security to test)

---

## 3.4 Channel Planning

### 2.4 GHz Channels

Non-overlapping: **1, 6, 11** (North America)

```
Ch 1:  ████████████████
Ch 6:          ████████████████
Ch 11:                 ████████████████
```

### 5 GHz UNII Bands

| Band | Channels | DFS | Use |
|------|----------|-----|-----|
| UNII-1 | 36, 40, 44, 48 | No | Preferred |
| UNII-2A | 52, 56, 60, 64 | Yes | Enterprise |
| UNII-2C | 100-144 | Yes | Extended |
| UNII-3 | 149, 153, 157, 161, 165 | No | General |

---

## 3.5 Hidden SSID Discovery

### Method 1: Client Association Monitoring

When clients connect, they reveal the hidden SSID:

```bash
# Terminal 1: Monitor target AP
sudo airodump-ng -c 6 --bssid AA:BB:CC:DD:EE:FF -w hidden-scan wlan0mon

# Terminal 2: Force client reconnection
sudo aireplay-ng -0 5 -a AA:BB:CC:DD:EE:FF -c 11:22:33:44:55:66 wlan0mon

# Watch ESSID column in Terminal 1 - SSID appears after successful connection
```

### Method 2: Probe Request Analysis

Clients probe for known networks:

```bash
# Capture probe requests
sudo airodump-ng --band abg -w probe-capture wlan0mon

# Extract probed SSIDs
tshark -r probe-capture-01.cap -Y "wlan.fc.type_subtype == 0x04" -T fields -e wlan.ssid | sort | uniq -c | sort -rn
```

---

## 3.6 Detection: How WIDS Systems See Reconnaissance

### Signatures Detected

| Activity | Signature | Detection Method |
|----------|-----------|------------------|
| Rapid channel hop | >5 ch/sec | Channel timing analysis |
| Broadcast probes | Null SSID probes | Frame inspection |
| Promiscuous mode | Non-local MAC data | BSSID whitelist |
| Beacon collection | Excessive beacons | Rate analysis |

### Commercial WIDS Capabilities

| System | Recon Detection |
|----------|-----------------|
| Aruba WIDS | Channel hopper signature |
| Cisco WIPS | Probe pattern analysis |
| Ruckus WIPS | Monitor mode detection |
| Kismet | Pattern matching |

### Evidence Left Behind

- Your MAC in probe request logs
- Association attempt logs
- Beacon frame reception patterns
- Data frame acknowledgments

---

## 3.7 Defense & Counter-Detection

### Attacker Evasion (Black Hat)

```bash
# Randomize MAC before scanning
sudo macchanger -r wlan0

# Slow channel hop to evade "rapid hopper" signature
sudo airodump-ng --cswitch 5 wlan0mon

# Targeted only - no broadcast probes
sudo airodump-ng -c 6 --bssid TARGET_BSSID wlan0mon
```

### Defender Detection (White Hat)

```bash
# Detect reconnaissance with tcpdump
sudo tcpdump -i wlan0 -e type mgt subtype probe-req

# Monitor for rogue clients
sudo kismet -c wlan0mon

# Analyze with Wireshark
# Display filter: wlan.fc.type_subtype == 0x04 (probe requests)
```

### Defense Recommendations

| Layer | Control | Implementation |
|-------|---------|----------------|
| Physical | Shielding | Faraday cage for sensitive areas |
| Network | Hidden SSID | Security through obscurity (weak) |
| MAC | Filtering | Whitelist authorized clients |
| 802.11w | PMF | Protected Management Frames |
| Monitoring | WIDS | Real-time anomaly detection |

---

## 3.8 Practical Exercise: Network Survey

### Objective
Perform comprehensive wireless reconnaissance and identify high-value targets.

### Steps

```bash
# 1. Prepare adapter
sudo airmon-ng check kill
sudo airmon-ng start wlan0

# 2. Full spectrum scan (2.4 + 5 GHz)
sudo timeout 300 airodump-ng --band abg -0 -w full-survey wlan0mon

# 3. Analyze results
cat full-survey-01.csv | grep -v "^BSSID" | awk -F',' '{print $1, $4, $6, $14}' | sort -k2 -n

# 4. Identify targets meeting criteria:
#    - ENC = WPA2
#    - AUTH = PSK  
#    - PWR > -70
#    - WPS = Yes (if available)

# 5. Deep scan high-value targets
sudo airodump-ng -c TARGET_CH --bssid TARGET_BSSID -w deep-target wlan0mon
```

### Expected Output

From analysis you should identify:
- 1-3 WPA2-PSK targets with strong signals
- WPS status of each target
- Active client counts
- Channel distribution for planning

---

## 3.9 PoC Script: Automated Target Discovery

```bash
#!/bin/bash
# auto-recon.sh - Automated reconnaissance with target ranking
# Usage: sudo ./auto-recon.sh <interface>

INTERFACE=${1:-wlan0mon}
DURATION=${2:-300}
OUTPUT_DIR="recon-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$OUTPUT_DIR"

echo "[+] Starting automated reconnaissance"
echo "[+] Duration: $DURATION seconds"
echo "[+] Output: $OUTPUT_DIR"

# Full scan
sudo timeout $DURATION airodump-ng --band abg -0 -w "$OUTPUT_DIR/survey" "$INTERFACE" 2>/dev/null

# Parse and rank targets
echo "[+] Analyzing results..."
echo ""
echo "High-Value Targets (WPA2-PSK, Signal > -70):"
echo "BSSID              CH  PWR  ENC   CIPHER  AUTH  ESSID"
echo "---------------------------------------------------"

awk -F',' '
NR>2 && $6 ~ /WPA2/ && $8 ~ /PSK/ && $4 > -70 {
    printf "%-17s %3s %4s %-5s %-6s %-4s %s\n", $1, $5, $4, $6, $7, $8, $14
}' "$OUTPUT_DIR/survey-01.csv" 2>/dev/null | head -10

echo ""
echo "[+] Full results saved to: $OUTPUT_DIR/survey-01.csv"
```

---

## 3.10 Knowledge Check

Before proceeding, verify you can:

1. Identify the 3 non-overlapping 2.4 GHz channels
2. Explain the difference between BSSID and ESSID
3. Read airodump-ng output to determine target viability
4. Execute a channel-locked scan for stable capture
5. Identify WPS-enabled targets
6. Explain how defenders detect reconnaissance

---

**Next**: [Module 04 — WPA2 Attacks](04-wpa2-attacks.md)
