# Primary Sources & References

## Standards & Specifications

- **IEEE 802.11-2020**: Wireless LAN Medium Access Control (MAC) and Physical Layer (PHY) Specifications
- **IEEE 802.11ax-2021**: Enhancements for High-Efficiency (Wi-Fi 6)
- **IEEE 802.11be-2024**: Extreme High Throughput (Wi-Fi 7)
- **IEEE 802.11r-2008**: Fast BSS Transition
- **IEEE 802.11s-2011**: Mesh Networking
- **IEEE 802.11w-2009**: Management Frame Protection
- **IETF RFC 3748**: Extensible Authentication Protocol (EAP)
- **IETF RFC 4187**: EAP-AKA
- **IETF RFC 5448**: EAP-AKA'
- **IETF RFC 6614**: RADIUS over TLS (RadSec)
- **IETF RFC 8110**: Opportunistic Wireless Encryption (OWE)

## Key CVEs

| CVE | Description | CVSS | Affected |
|-----|-------------|------|----------|
| CVE-2017-13077 | KRACK: 4-way handshake nonce reuse | 8.1 | All WPA2 |
| CVE-2017-13078 | KRACK: Group Key reinstall | 8.1 | All WPA2 |
| CVE-2017-9417 | Broadpwn: Broadcom Wi-Fi SoC heap overflow | 9.8 | Broadcom chips |
| CVE-2019-9494 | Dragonblood: SAE cache attack | 6.5 | WPA3-SAE |
| CVE-2019-9495 | Dragonblood: SAE timing side-channel | 5.3 | WPA3-SAE |
| CVE-2019-9496 | Dragonblood: EAP-pwd side-channel | 5.3 | EAP-pwd |
| CVE-2019-15126 | WEP key recovery via TKIP QoS frames | 6.5 | TKIP |
| CVE-2020-24588 | FragAttacks: Aggregation + fragmentation | 6.5 | All Wi-Fi |
| CVE-2020-26145 | FragAttack: Frame injection via fragmentation | 7.5 | All Wi-Fi |
| CVE-2020-26144 | FragAttack: Accept non-SPP A-MSDU | 7.5 | All Wi-Fi |
| CVE-2021-41508 | WPA2 4-way handshake downgrade | 5.3 | WPA2 |
| CVE-2022-47551 | PMKID race condition | 4.3 | Multi-AP WPA2 |

## Research Papers

1. Vanhoef, M. & Piessens, F. (2017). "Key Reinstallation Attacks: Forcing Nonce Reuse in WPA2." CCS 2017.
2. Vanhoef, M. & Ronen, E. (2019). "Dragonblood: A Security Analysis of WPA3's SAE." USENIX Security 2020.
3. Vanhoef, M. (2021). "Fragment and Forge: Breaking Wi-Fi Through Frame Aggregation and Fragmentation." USENIX Security 2021.
4. Basinger, J. et al. (2019). "Why MAC Randomization is Not Enough." AsiaCCS 2019.
5. Paverd, M. et al. (2014). "On the Feasibility of Low-Resource Man-in-the-Middle Attacks on EAP-TLS." ARES 2014.

## Tools

| Tool | Purpose | Repository |
|------|---------|------------|
| Aircrack-ng | WPA/WEP cracking suite | https://github.com/aircrack-ng |
| Hashcat | GPU-accelerated hash cracking | https://github.com/hashcat/hashcat |
| hostapd-mana | Rogue AP with EAP harvesting | https://github.com/sensepost/hostapd-mana |
| EAPHammer | Automated Evil Twin | https://github.com/s0lst1c3/eaphammer |
| hcxdumptool | PMKID capture | https://github.com/ZerBea/hcxdumptool |
| Reaver | WPS PIN attack | https://github.com/t6x/reaver-wps-fork |
| Bully | WPS brute-force | https://github.com/aanarchyy/bully |
| MDK4 | 802.11 DoS attacks | https://github.com/aircrack-ng/mdk4 |
| Kismet | Wireless IDS/monitor | https://github.com/kismetwireless |
| Scapy | Packet manipulation | https://github.com/secdev/scapy |
| Dragonblood | WPA3 SAE attacks | https://github.com/vanhoefm/dragonblood |
| Bettercap | MITM framework | https://github.com/bettercap/bettercap |
