# CTF Scenarios

## Tier 1

### CTF 1.1 — Crack the Coffee Shop
**Task**: Crack WPA2 PSK. File: `coffee-haus.hc22000`. Hint: coffee terms + leet.
**Solution**: `hashcat -m 22000 coffee-haus.hc22000 rockyou.txt`

### CTF 1.2 — WPS PIN Hunt
**Task**: Extract PIN from MAC-derived algorithm. BSSID: `00:11:22:33:44:55`.
**Solution**: `python3 -c "print(f'{int('001122',16)%10000000:07d}')"`

### CTF 1.3 — Hidden SSID
**Task**: Find hidden SSID from capture. BSSID: `AA:BB:CC:DD:EE:FF`.
**Solution**: `tshark -r capture.pcapng -Y "wlan.fc.type_subtype==0x00" -T fields -e wlan.ssid`

## Tier 2

### CTF 2.1 — MSCHAPv2 Cracking
**Task**: Extract and crack PEAP-MSCHAPv2 from EAP capture.
**Solution**: `hcxpcapngtool -o hash file.pcapng && hashcat -m 5600 hash rockyou.txt`

### CTF 2.2 — RADIUS Secret
**Task**: Crack RADIUS shared secret from capture.
**Solution**: `hashcat -m 500 radius.hash wordlist.txt`

### CTF 2.3 — VLAN Hop
**Task**: Hop from guest VLAN to VLAN 10.
**Solution**: Double-tagging with Scapy `Dot1Q(vlan=100)/Dot1Q(vlan=10)`

## Tier 3

### CTF 3.1 — SAE Timing Side-Channel
**Task**: Analyze SAE commit timing to extract password length.
**Solution**: Statistical analysis of response time vs password entropy.

### CTF 3.2 — MLO Key Derivation
**Task**: Given PMK-R0 and link parameters, derive PTK for link 2.
**Solution**: `PTK = KDF-384(PMK-R0, "Multi-Link PTK", ...)`

### CTF 3.3 — FTM Position Spoof
**Task**: Forge FTM measurements to make device appear at coordinates (0,0).
**Solution**: Pre-compute FTM responses with manipulated t1/t4 timestamps.
