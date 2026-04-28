# WiFi Penetration Testing Tutorial - Comprehensive Technical Plan

Revise the existing tutorial plan to eliminate all historical content, enforce absolute technical precision with exact commands and parameters, and establish dual-use (offensive/defensive) applicability across all skill tiers with a unified synthesis section for materials, hardware, and software configurations.

---

## Core Requirements

| Mandate | Implementation |
|---------|----------------|
| **Zero History** | No dates, evolution narratives, or legacy protocol references |
| **Technical Precision** | Exact commands with all flags, specific parameter values, verbatim outputs |
| **Dual-Use Design** | Every technique includes both attack execution and detection/defense |
| **No Ethical Framing** | Techniques presented without authorization qualifiers—applicable to any context |
| **Exhaustive Depth** | No conceptual gaps; every operation explained to bit-level precision |
| **Contemporary Stack** | 2024-2025 tool versions, current CVEs, modern hardware chipsets |
| **Flexible Hardware** | Alternative options provided for all equipment requirements |
| **Synthesis Section** | Centralized materials, hardware specs, software configs, resources |

---

## Skill Tier Structure

### Beginner Tier: Foundation Operations

**Module 01 — RF Environment & Monitor Mode**
- Physical layer fundamentals: frequency bands (2.4 GHz: 2412-2484 MHz, 5 GHz: 5150-5895 MHz, 6 GHz: 5925-7125 MHz)
- Channel numbering and bandwidth (20/40/80/160 MHz)
- Regulatory domain constraints (country code effects on txpower)
- Monitor mode vs managed mode frame handling differences
- Monitor mode activation: `iw dev wlan0 set type monitor` vs `airmon-ng start wlan0`
- Interface verification: `iw dev`, `iwconfig`, `ip link`
- Injection testing: `aireplay-ng -9 wlan0mon`
- Power control: `iw dev wlan0mon set txpower fixed 2000` (20 dBm)
- Detection: Monitor mode discovery via driver introspection, unusual frame patterns
- Defense: Driver-level monitor mode disable, signed firmware enforcement

**Module 02 — Reconnaissance & Enumeration**
- airodump-ng comprehensive syntax (all 47 flags with exact values)
- Channel hopping strategies: `-C 1,6,11` vs `-C 36,40,44,48,149,153,157,161`
- BSSID targeting: `--bssid 00:11:22:33:44:55 -c 6`
- Power interpretation: `-30 dBm` (0.001 mW, <1m) to `-90 dBm` (1 pW, >100m)
- Hidden SSID discovery: probe response analysis, association request timing
- Client enumeration: `-c` flag for station monitoring, `-w` for output files
- 5/6 GHz scanning: `-band abg` (2.4+5), `-band abgn` (all bands)
- Output formats: `.csv` (parseable), `.kismet.netxml` (geolocation), `.cap` (raw)
- Real-time analysis: `airodump-ng --write-interval 1 -w live wlan0mon`
- Detection: WIDS signature triggers (constant channel hopping, probe flood patterns)
- Defense: SSID broadcast suppression, probe response rate limiting, randomized MAC on AP

**Module 03 — WPA2-PSK Handshake Capture**
- 4-way handshake frame structure: ANonce, SNonce, MIC, GTK delivery
- Capture optimization: channel lock (`-c`), deauth timing, retry intervals
- Deauthentication attack mechanics: subtype 0x0C (class 3 frame from unassociated)
- Deauth frame construction: ` subtype=0x0C, reason code=0x0007 (class 3 frame from unassociated)`
- Active vs passive acquisition: targeted (`-0 5 -a BSSID -c CLIENT`) vs wait
- aircrack-ng hash extraction: `-j` (john), `-J` (hashcat), `-e ESSID`, `-b BSSID`
- Multi-handshake management: file rotation, mergecap for consolidation
- Detection: Excessive deauth frames (threshold >10/sec), MIC failure counter
- Defense: 802.11w (Protected Management Frames) mandatory, PMF-required mode

**Module 04 — WPS Exploitation**
- WPS PIN algorithm: 7-digit + 1 checksum, `checksum = (10 - ((3*(d1+d4+d7) + (d2+d5+d8)) % 10)) % 10`
- Reaver syntax: `-i wlan0mon -b <BSSID> -c <channel> -e <ESSID> -K 1 -vv -t 5 -d 1 -l 300`
- Bully alternative: `bully -b <BSSID> -c <channel> -e <ESSID> -v 3 -t 50 -F`
- Pixie Dust attack: E-Hash1/E-Hash2 extraction, PSK1/PSK2 derivation from WPS nonces
- Lockout detection: AP returning NACK with configuration error 0x0C/0x0F
- Null PIN attack: `-p ''` (empty string) against vulnerable implementations
- PBC social engineering: WPS button press window exploitation (120-second window)
- Detection: WPS attempt logging, PIN failure thresholds, lockout alarms
- Defense: WPS disable (GPIO/flash config), physical PBC button removal

**Module 05 — Password Recovery Operations**
- Hashcat mode 22000: `hashcat -m 22000 -a 0 capture.hc22000 wordlist.txt`
- GPU optimization: `-w 3` (aggressive), `-O` (optimized kernels), `-d 1` (device select)
- Wordlist construction: `crunch 8 12 abcdefghijklmnopqrstuvwxyz0123456789 -o wordlist.txt`
- Rule-based mutation: `-r /usr/share/hashcat/rules/best64.rule`
- Mask attacks: `-a 3 ?d?d?d?d?d?d?d?d` (8 digits), `?u?l?l?l?l?d?d?s` (pattern)
- Hybrid attacks: `-a 6 wordlist.txt ?d?d?d?d` (wordlist + 4 digits)
- Distributed cracking: Hashtopolis agent setup, chunk distribution
- Benchmark reference: RTX 4090 ~ 2.1 MH/s WPA2, RTX 3060 ~ 650 KH/s
- Detection: Failed authentication spike correlation, account lockouts
- Defense: 16+ character passphrases, RADIUS-based auth, certificate-based EAP

### Intermediate Tier: Enterprise Operations

**Module 01 — 802.1X/EAP Architecture**
- EAPOL frame flow: Start → Request/Identity → Response/Identity → Method negotiation → Success/Failure
- RADIUS packet structure: Code (1=Access-Request, 2=Access-Accept, 3=Access-Reject, 11=Access-Challenge)
- EAP-PEAP/MSCHAPv2: TLS tunnel establishment (Phase 1), MSCHAPv2 inside (Phase 2)
- EAP-TTLS/PAP: Outer TLS tunnel, inner cleartext credential transport
- EAP-TLS: Certificate-based mutual authentication, no password exposure
- RADIUS attributes: `Tunnel-Type=VLAN (13)`, `Tunnel-Medium-Type=IEEE-802 (6)`, `Tunnel-Private-Group-Id=<VLAN>`
- Machine auth vs user auth: `host/name@DOMAIN` vs `username@DOMAIN`
- Detection: Certificate validation failures, unusual EAP method negotiation
- Defense: EAP-TLS enforcement, certificate pinning, RADIUS server validation

**Module 02 — EAP Credential Harvesting**
- Rogue RADIUS setup: hostapd-mana with `enable_mana=1`, `mana_wpe=1`
- EAPhammer: `eaphammer -i wlan0 --channel 6 --auth wpa2-eap --creds` 
- Certificate cloning: `openssl x509 -in target.pem -out fake.pem`, CN matching
- Domain validation bypass: rogue CA injection, DNS redirection
- MSCHAPv2 capture: challenge/response extraction for `asleap -C <challenge> -R <response> -W wordlist`
- Credential relay: EAP-Success spoofing, session hijacking
- Detection: Unknown RADIUS servers, certificate mismatch alerts, CA validation failures
- Defense: RADIUS server allowlisting, certificate transparency logs, EAP-TLS only

**Module 03 — Rogue Access Point Operations**
- Evil twin vs rogue AP: BSSID matching (evil twin) vs new BSSID (rogue)
- hostapd-mana KARMA: `karma_loud=1` (respond to all directed probes)
- DNS redirection: dnsmasq `address=/#/192.168.1.1` (catch-all)
- Captive portal cloning: HTTP redirect to credential form, POST capture
- SSL stripping: `bettercap --eval "set hstshijack.ignore .*; hstshijack on"`
- Form harvesting: `sed -n 's/.*username=\([^&]*\).*/\1/p'` from access logs
- Detection: BSSID conflict (same MAC, different locations), portal fingerprinting
- Defense: 802.11k/v/r fast transition, certificate validation, HSTS preloading

**Module 04 — PMKID Clientless Attack**
- RSN IE structure: PMKID List field presence indicates caching
- PMKID calculation: `HMAC-SHA1-128(PMK, "PMK Name" || MAC_AP || MAC_STA)`
- hcxdumptool: `hcxdumptool -i wlan0mon -o capture.pcapng --enable_status=31 --filterlist=targets.txt --filtermode=2`
- hcxpcapngtool conversion: `hcxpcapngtool -o hash.hc22000 -E wordlist.txt capture.pcapng`
- Hash format compatibility: 16800 (legacy), 22000 (current), hccapx (deprecated)
- Clientless requirements: AP must enable PMK caching (802.11r FT disabled)
- Detection: Association without prior authentication, PMKID request patterns
- Defense: Disable PMK caching (`pmk_cache=0`), 802.11r FT disable

**Module 05 — Client-Side Exploitation**
- Probe request analysis: Preferred Network List (PNL) exposure
- KARMA attack: Respond to directed probes with matching SSID
- MANA attack: Loud mode responds to all probes with all known SSIDs
- Bettercap WiFi modules: `wifi.recon on`, `wifi.assoc all`, `wifi.deauth BSSID`
- WiFi Direct (P2P): GO negotiation, persistent group exploitation
- Client isolation bypass: ARP spoofing within subnet, multicast abuse
- Targeted DoS: Client-specific deauth, authentication flood
- Detection: Probe flood alerts, AP impersonation signatures, P2P anomaly
- Defense: MAC randomization, probe suppression (Windows 10+/macOS/iOS 14+), hidden SSID

**Module 06 — Post-Compromise Operations**
- Network pivoting: Compromised AP as layer-2 bridge to internal segment
- VLAN hopping: Double-tagging (802.1Q-in-Q), native VLAN abuse
- Lateral movement: Credential reuse (NTLM relay), Kerberos ticket harvesting
- Traffic analysis: `tcpdump -i br0 -w pivot.pcap`, Wireshark pivot filtering
- Report structure: Executive summary, technical findings, CVSS scoring, remediation
- CVSS calculation: Base (AV/AC/PR/UI/S/C/I/A), Temporal, Environmental
- Evidence preservation: SHA256 hashes, chain of custody documentation
- Detection: Lateral movement alerts, VLAN bridging anomalies
- Defense: NAC enforcement, 802.1X on all ports, microsegmentation

### Advanced Tier: Current Threat Landscape

**Module 01 — WPA3-SAE Attack Surface**
- SAE handshake: Commit/Confirm exchange, PWE (Password Element) derivation
- DragonBlood timing side-channel: `hash-to-curve` operation timing analysis (CVE-2019-9494)
- DragonBlood cache side-channel: ECC scalar multiplication cache analysis
- SAE-PK downgrade: AP configuration forcing SAE without PK (public key)
- Transition mode exploitation: WPA2/WPA3 mixed mode downgrade
- SAE group downgrade: MODP groups 22-24 (weak primes) vs 19-21 (EC)
- Current landscape: Most implementations patched; limited practical exploitation
- Detection: SAE timing anomalies, group negotiation failures
- Defense: SAE-PK mandatory (P-256 public key), strong group selection

**Module 02 — Wi-Fi 6/6E/7 Exploitation**
- 802.11ax frame changes: HE PHY headers, trigger-based access
- OFDMA targeting: RU (Resource Unit) assignment manipulation
- BSS Coloring spoofing: Override BSS color field to disable spatial reuse
- TWT manipulation: Target Wake Time agreement flooding, power consumption DoS
- 6 GHz spectrum: U-NII-5/6/7/8 bands (5925-7125 MHz), AFC requirements
- 802.11be (Wi-Fi 7): Preamble puncturing, 320 MHz channels, MLO (Multi-Link Operation)
- MU-MIMO interference: Beamforming null steering manipulation
- Tool gaps: Limited 802.11ax/11be frame injection support in standard tools
- Detection: OFDMA resource exhaustion, TWT anomaly monitoring
- Defense: 802.11ax management frame protection, beamforming authentication

**Module 03 — SDR-Based RF Operations**
- HackRF One setup: `hackrf_info`, `hackrf_transfer -r capture.raw -f 2412000000 -s 20000000`
- LimeSDR configuration: `LimeUtil --update`, `SoapySDRUtil --find`
- Carrier generation: 2.4/5/6 GHz CW transmission for jamming analysis
- Selective deauth: Packet crafting at PHY layer, timing precision
- Spectrum analysis: `hackrf_sweep -f 2400:2500 -w 100000 -l 40 -g 20`
- GNU Radio flowgraphs: 802.11 preamble detection, carrier sense bypass
- Custom waveform: Python + UHD/GNURadio for arbitrary frame injection
- Detection: Spectrum anomaly detection, interference source triangulation
- Defense: Frequency hopping, directional antennas, DFS enforcement

**Module 04 — Mesh Network Exploitation**
- 802.11s architecture: Mesh STA, mesh BSS, mesh gate
- OLSR: Link state advertisement, ETX metric manipulation
- HWMP: PREQ/PREP/PERR frame handling, proactive vs reactive path selection
- Peer link establishment: Beacon mesh ID matching, capability exchange
- Topology poisoning: Fake metric advertisement (low ETX), path redirection
- Gateway impersonation: Mesh gate advertisement hijacking
- Multi-hop interception: Traffic redirection through attacker node
- Detection: Path metric deviation, gateway advertisement anomalies
- Defense: Mesh authentication (SAE), encrypted management frames

**Module 05 — WIDS/WIPS Evasion**
- Commercial signatures: Cisco CleanAir, Aruba RFProtect, Ruckus SmartCell
- Deauth detection: Frame rate thresholds (5-10/sec), source MAC analysis
- Timing manipulation: Slow attacks (<1 frame/sec), burst patterns
- Frame fragmentation: Split deauth across fragments, reassembly evasion
- Rate limiting: Stay below WIDS thresholds (e.g., 4 deauths/sec)
- Channel hopping: Attack distribution across 2.4/5 GHz channels
- BSSID rotation: MAC address cycling every N frames
- Rogue AP mimicry: Clone legitimate BSSID/SSID/beacon interval exactly
- Detection: WIDS blind spot analysis, behavioral correlation
- Defense: Multi-sensor correlation, ML-based anomaly detection

**Module 06 — Multi-Vector Attack Chains**
- Chain architecture: Recon → Exploitation → Persistence → Exfiltration
- WiFi-to-internal pivot: Compromised client → lateral movement → domain compromise
- Combined attacks: Evil twin + phishing email synchronization
- Physical/wireless hybrid: AP physical access + wireless exploitation
- Social engineering: WPS PBC coaching, credential form pre-population
- Red team planning: Scope definition, stealth requirements, timeline
- Blue team challenges: Detection during low-and-slow operations
- Scenario walkthroughs: Full chain from recon to domain admin

**Module 07 — Custom Exploit Development**
- Scapy 802.11 layers: `RadioTap()`, `Dot11()`, `Dot11Beacon()`, `Dot11Elt()`
- Frame crafting: Management (beacon/probe), Control (RTS/CTS), Data (QoS)
- IE fuzzing: Iterate through all 802.11 IEs (0-255), malformed length fields
- Driver research: `modinfo iwlwifi`, `dmesg | grep -i firmware`, CVE tracking
- Firmware extraction: `binwalk -e firmware.bin`, JTAG/UART interface access
- Python/C tooling: `libpcap` integration, raw socket injection
- Proof-of-concept: CVE reproduction, crash analysis, exploit reliability
- Disclosure: Coordinated disclosure timeline, vendor communication

---

## Synthesis Section: Materials, Hardware & Software

### Required Hardware Specifications (Flexible)

**Primary Wireless Adapter Options** (at least one required):
- **Alfa AWUS036ACM**: MT7612U chipset, 2.4/5 GHz, monitor mode, injection capable (~$40)
- **Alfa AWUS036ACH**: RTL8812AU chipset, 2.4/5 GHz, high gain (~$50)
- **TP-Link Archer T4U Plus**: RTL8812AU chipset, external antenna (~$35)
- **Raspberry Pi 4 + Alfa AWUS036ACS**: Portable platform (~$60 total)

**Alternative/Secondary Options**:
- Internal Intel AX200/AX210: Monitor mode capable, no injection (reconnaissance only)
- Netgear A6210: MT7612U chipset, USB 3.0 (~$30)
- Generic MT7601U adapters: 2.4 GHz only, budget option (~$10)

**Enterprise/Lab Environment**:
- WiFi router with OpenWrt/DD-WRT for target AP (TP-Link Archer C7, Netgear R7800)
- Managed switch with VLAN support (TP-Link TL-SG108E, Netgear GS308E)
- Raspberry Pi 4/5 as RADIUS server target (hostapd + freeradius)

**Advanced Hardware Options**:
- HackRF One: 1 MHz - 6 GHz SDR (~$300, or Chinese clone ~$100)
- LimeSDR Mini: 10 MHz - 3.5 GHz, dual channel (~$300)
- PlutoSDR: ADALM-PLUTO, 325 MHz - 3.8 GHz (~$150)

### Software Configuration Stack

**Base Operating System**:
- Kali Linux 2024.x (rolling): `uname -a`, `cat /etc/os-release`
- Parrot OS Security Edition: Alternative with pre-installed tools
- Arch Linux + BlackArch repo: `pacman -S blackarch-wireless`

**Core Tool Installation (Exact Commands)**:
```bash
# Aircrack-ng suite
apt-get install -y aircrack-ng
# Verify: aircrack-ng --version (should show 1.7 or later)

# Reaver + Bully
apt-get install -y reaver bully
# Verify: reaver --version, bully --version

# Hashcat
apt-get install -y hashcat
# Verify: hashcat --version (should show v6.2.6+)
# GPU drivers: apt-get install -y nvidia-driver or amdgpu-pro

# hcxtools (PMKID)
apt-get install -y hcxtools
# Verify: hcxdumptool --version, hcxpcapngtool --version

# hostapd-mana
git clone https://github.com/sensepost/hostapd-mana.git
cd hostapd-mana
make
make install

# EAPHammer
git clone https://github.com/s0lst1c3/eaphammer.git
./eaphammer --cert-wizard

# Bettercap
apt-get install -y bettercap
# Verify: bettercap --version (should show v2.32.0+)

# SDR tools (advanced)
apt-get install -y hackrf libhackrf-dev gnuradio gr-osmosdr
# Verify: hackrf_info, gnuradio-companion --version
```

**Python Environment**:
```bash
pip3 install scapy pyshark hcxtools pwntools
# Verify: python3 -c "import scapy.all; print(scapy.__version__)"
```

### Synthetic Practice Materials

**Beginner Tier**:
| Filename | Description | Verification Command |
|----------|-------------|---------------------|
| `recon-sample-01.cap` | 50 AP scan sample | `airodump-ng -r recon-sample-01.cap` |
| `recon-sample-02.cap` | Hidden SSID scenario | `tshark -r recon-sample-02.cap -Y wlan.fc.type_subtype==0x05` |
| `wpa2-handshake-01.cap` | Valid 4-way (pass: `password123`) | `aircrack-ng wpa2-handshake-01.cap -w <(echo password123)` |
| `wpa2-hashcat.hc22000` | Pre-converted hash | `hashcat -m 22000 wpa2-hashcat.hc22000 rockyou.txt` |
| `wps-pixie-data-01.txt` | Pixie Dust output | `cat wps-pixie-data-01.txt | grep -i psk` |
| `crackme-01.hc22000` | 8-char lowercase | `hashcat -m 22000 -a 3 ?l?l?l?l?l?l?l?l` |

**Intermediate Tier**:
| Filename | Description | Usage |
|----------|-------------|-------|
| `eap-peap-capture.pcap` | Full PEAP exchange | `eapmd5pass -r eap-peap-capture.pcap` |
| `hostapd-mana.conf` | Working rogue AP config | `hostapd-mana hostapd-mana.conf` |
| `pmkid-22000.txt` | Hashcat 22000 format | `hashcat -m 22000 pmkid-22000.txt wordlist.txt` |
| `captive-portal-template/` | Full HTML/CSS/JS portal | `python3 -m http.server 80` |

**Advanced Tier**:
| Filename | Description | Usage |
|----------|-------------|-------|
| `sae-handshake.pcap` | DragonBlood test data | `dragonblood-analyzer sae-handshake.pcap` |
| `scapy-wifi-template.py` | Frame crafting starter | `python3 scapy-wifi-template.py` |
| `gnuradio-wifi-deauth.grc` | SDR flowgraph | `gnuradio-companion gnuradio-wifi-deauth.grc` |

### Supplementary Resources

**Wordlists**:
- `rockyou.txt`: `/usr/share/wordlists/rockyou.txt` (14M passwords)
- `crackstation.txt`: https://crackstation.net/files/crackstation.txt.gz (1.5B passwords)
- `wifi-specific.txt`: Custom curated list in `synth/beginner/top-1000-wifi-passwords.txt`

**Rule Sets**:
- `best64.rule`: `/usr/share/hashcat/rules/best64.rule`
- `d3ad0ne.rule`: `/usr/share/hashcat/rules/d3ad0ne.rule`
- `hob064.rule`: `/usr/share/hashcat/rules/hob064.rule`

**Mask Patterns**:
- 8-digit PIN: `?d?d?d?d?d?d?d?d`
- Common phone pattern: `?d?d?d?d?d?d?d?d?d?d`
- Mixed 10-char: `?a?a?a?a?a?a?a?a?a?a`

**CVE Reference List** (2024-2025 Active):
- CVE-2019-9494: WPA3 DragonBlood (timing/cache side-channels)
- CVE-2023-?????: Contemporary driver vulnerabilities (track latest)
- Wi-Fi Alliance security advisories: https://www.wi-fi.org/security

---

## Content Production Standards

### Technical Precision Mandate

Every module must contain:

1. **Exact Command Syntax**: Full command with every flag, no placeholders
   - Correct: `airodump-ng -i wlan0mon -c 6 --bssid 00:11:22:33:44:55 -w capture`
   - Incorrect: `airodump-ng -i <interface> -c <channel>`

2. **Verbatim Output Samples**: Copy-pasteable expected output
   ```
   CH  6 ][ Elapsed: 30s ][ 2024-01-15 14:32:15
   BSSID              PWR  Beacons    #Data, #/s  CH  MB   ENC CIPHER AUTH ESSID
   00:11:22:33:44:55  -45       50        0    0   6  54e. WPA2 CCMP   PSK  TargetNet
   ```

3. **Specific Parameter Values**: No ranges without exact defaults
   - Correct: `txpower 2000` (20 dBm = 100 mW)
   - Incorrect: `txpower <value>`

4. **Error Messages with Fixes**: Document exact error strings and resolutions
   ```
   Error: "SIOCSIFFLAGS: Operation not possible due to RF-kill"
   Fix: `rfkill unblock wifi && rfkill unblock all`
   ```

5. **Version Requirements**: Exact tool versions tested
   - aircrack-ng 1.7+
   - hashcat 6.2.6+
   - hcxdumptool 6.3.4+

### Dual-Use Section Template

Every technique must include:

```markdown
**Offensive Application**:
- Command/technique for attack execution
- Expected outcome (credential harvest, network access)
- Follow-on operations from successful exploitation

**Defensive Application**:
- Detection method (log analysis, signature, anomaly)
- Alert configuration (thresholds, trigger conditions)
- Prevention mechanism (configuration change, hardening)
- Forensic evidence preservation (log locations, pcap retention)
```

### Completion Checklist

- [ ] No historical references (zero tolerance)
- [ ] Every command has exact flags and values
- [ ] Expected output shown verbatim with timestamps
- [ ] All error conditions documented with fixes
- [ ] Offensive and defensive sections present
- [ ] No ethical authorization qualifiers in content
- [ ] Synthetic file referenced for hands-on practice
- [ ] Automation script provided where applicable
- [ ] Minimum 3000 words per module
- [ ] CVE references current (2024-2025)

---

## Execution Priority

1. **Synthesis Section First**: Compile hardware/software/materials as reference foundation
2. **Beginner Modules 03-06**: Complete remaining beginner tier to 100%
3. **Beginner Scripts + Synth**: Full automation and practice materials
4. **Intermediate Tier**: All 6 modules with enterprise focus
5. **Advanced Tier**: Current threat landscape (WPA3, Wi-Fi 7, SDR)
6. **Final Validation**: Cross-reference all commands against live testing

**Word Count Targets**:
- Beginner tier: 25,000+ words
- Intermediate tier: 25,000+ words
- Advanced tier: 30,000+ words
- Synthesis section: 5,000+ words
- **Total: 85,000+ words**

**Script Targets**: 5,000+ lines across all tiers
**Synthetic Files**: 40+ files for hands-on practice
