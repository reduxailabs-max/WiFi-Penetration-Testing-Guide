# 06 — Password Recovery & Hash Cracking

## WPA2 Hash Cracking Workflow

```bash
# Step 1: Convert cap to hashcat format (hc22000 unified format)
hcxpcapngtool -o capture.hc22000 capture.cap

# Step 2: Dictionary attack (mode 22000 covers WPA2/WPA3 handshakes)
hashcat -m 22000 -a 0 capture.hc22000 wordlist.txt

# Step 3: Rule-based attack
hashcat -m 22000 -a 0 capture.hc22000 wordlist.txt -r rules/best64.rule

# Step 4: Brute-force (mask)
hashcat -m 22000 -a 3 capture.hc22000 ?a?a?a?a?a?a?a?a

# Step 5: PMKID-only (mode 22001, or 22000 with WPA*01 prefix)
hashcat -m 22001 pmkid.hc22000 wordlist.txt
```

## Password Lists & Rules

- `/usr/share/wordlists/rockyou.txt` — 14M common passwords
- `cewl` — Generate target-specific wordlists from websites
- `crunch` — Generate custom character-set wordlists
- `hashcat` rules: `best64.rule`, `d3ad0ne.rule`, `Hybrid.rule`

## WPS PIN Recovery

```bash
# Reaver (online brute-force WPS)
reaver -i wlan0mon -b 00:11:22:33:44:55 -vv

# Bully (faster alternative)
bully wlan0mon -b 00:11:22:33:44:55 -e TargetAP
```

## Enterprise Hash Cracking

```bash
# Asleap (LEAP/MSCHAPv2)
asleap -r leapdump.dat -w wordlist.txt

# John the Ripper (EAP-MD5, EAP-LEAP)
john --format=netntlm hashes.txt
```
