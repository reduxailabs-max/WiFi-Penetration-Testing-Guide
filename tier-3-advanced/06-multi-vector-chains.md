# 06 — Multi-Vector Attack Chains

## Kill Chain for Wi-Fi

1. Reconnaissance: Long-range AP discovery, client enumeration
2. Weaponization: Custom firmware, rogue AP payload
3. Delivery: Karma, mana, Evil Twin
4. Exploitation: EAP relay, credential harvest
5. Installation: Persistent rogue AP, VLAN bridge
6. C2: Covert channel via Wi-Fi management frames
7. Actions: Data exfiltration, lateral movement

## Example Chain: Corporate Breach

```
Day 1:   Passive reconnaissance, map SSIDs and EAP types
Day 2:   Deploy rogue AP with cloned CorpWiFi SSID
Day 3:   Harvest EAP credentials from mobile users in parking lot
Day 4:   Crack MSCHAPv2 hash, obtain valid AD credentials
Day 5:   Connect to real CorpWiFi with stolen creds, scan internal network
Day 6:   VLAN hop to finance segment, exfiltrate data via DNS over Wi-Fi
```

## Chained Exploits

Combine multiple low-severity issues into critical breach:
- Weak guest Wi-Fi → client isolation bypass → ARP poisoning on main network
- WPS enabled printer → Wi-Fi credential extraction → pivot to corporate SSID
- Legacy 802.11b AP → downgrade attack → WEP-equivalent exploitation
