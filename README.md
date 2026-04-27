# WiFi Penetration Testing Materials

Comprehensive toolkit for authorized wireless network security assessments.

---

## Quick Start

1. **Discovery Phase** - Run on target network:   ```bash   ./network-recon.sh   ```   This creates timestamped output directory with reconnaissance data.

2. **Diagram Generation** - After reconnaissance:   ```bash   ./diagram-generator.sh network-recon-<timestamp>   ```   Generates `network-diagram.md` with topology visualization.

3. **Pentest Execution** - If authorized for testing:   ```bash   sudo ./pentest-methodology.sh wlan0   ```

---

## File Structure

```
wifi/
├── wifi-pentest-guide.md      # Complete WiFi pentest theory & reference
├── network-recon.sh           # Systematic network enumeration script
├── pentest-methodology.sh     # Full pentest methodology script
├── diagram-generator.sh       # Analyzes recon data, creates diagrams
└── README.md                  # This file
```

---

## Modules

### 1. wifi-pentest-guide.md
Core reference covering:
- **802.11 Frame Types**: Management, Control, Data frames
- **Attack Vectors**: Network, Client, Protocol, Physical layers
- **Tool Arsenal**: aircrack-ng, hashcat, reaver, etc.
- **Methodologies**: WPA2/3, WPS, PMKID attack chains

### 2. network-recon.sh
5-phase systematic discovery:
| Phase | Focus | Output |
|-------|-------|----------|
| 1 | Local host config | `phase1-local.txt` |
| 2 | Wireless discovery | `phase2-wireless.txt`, `phase2-scan*.csv` |
| 3 | VLAN/segmentation | `phase3-segmentation.txt` |
| 4 | Gateway/DHCP | `phase4-gateway.txt` |
| 5 | Service discovery | `phase5-services.txt` |

### 3. pentest-methodology.sh
Complete authorized pentest workflow:
- Environment preparation
- Monitor mode activation
- Network discovery
- Router/gateway discovery
- Attack execution (requires explicit authorization)
- Documentation generation

### 4. diagram-generator.sh
Consumes reconnaissance output and generates:
- ASCII topology diagrams
- Interface inventory tables
- Wireless AP catalog
- VLAN analysis
- Attack surface mapping

---

## Legal Notice

**These tools are for authorized security testing only.**

Required before use:
1. Written authorization from network owner
2. Defined scope and IP ranges
3. Approved testing window
4. Acknowledgment of safety implications

Unauthorized access to computer networks is illegal under most jurisdictions including the Computer Fraud and Abuse Act (US), Computer Misuse Act (UK), and similar statutes worldwide.

---

## Generated Diagrams

After running `./network-recon.sh`, the following visualizations are created:

- **Network Topology**: Hierarchical view of uplink → gateway → switches → clients
- **VLAN Layout**: Discovered broadcast domains and segmentation
- **Wireless Map**: AP locations, channels, encryption types
- **Attack Surface**: Identified vulnerabilities mapped to targets

---

## For Router Discovery (Your Original Request)

To systematically find the "hidden" router:

```bash
# Step 1: Basic gateway discovery
ip route | grep default

# Step 2: ARP enumeration
ip neigh show

# Step 3: Layer 2 discovery
sudo arp-scan -l

# Step 4: Full reconnaissance
sudo ./network-recon.sh
```

The router is typically at:
- Default gateway IP from `ip route`
- Lowest MAC in ARP table (often x:x:x:00:01 pattern)
- DHCP server IP from lease file

---

## Hardware Requirements

| Tool | Required Hardware |
|------|-------------------|
| Passive scanning | Any WiFi interface |
| Monitor mode | USB adapters with supported chipsets |
| Packet injection | Alfa AWUS036ACM/ACH, TP-Link TL-WN722N v1 |
| WPS attacks | Same as above |
| Deauth attacks | Injection-capable adapter required |

Recommended chipsets: MT76x2u, RTL8812AU, AR9271

---

## Dependencies

```bash
# Core tools
sudo apt update
sudo apt install -y aircrack-ng nftables iproute2

# Optional but recommended
sudo apt install -y nmap tcpdump wireshark

# For cracking
sudo apt install -y hashcat john hcxtools
```

---

## Workflow

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│ 1. Run recon    │ ──► │ 2. Generate      │ ──► │ 3. Analyze      │
│    script       │     │    diagrams      │     │    topology     │
└─────────────────┘     └──────────────────┘     └─────────────────┘
         │                                               │
         ▼                                               ▼
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│ 4. Identify     │ ──► │ 5. Execute       │ ──► │ 6. Document     │
│    targets      │     │    pentest       │     │    findings     │
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

---

## Notes

- All scripts include safety checks and require explicit flags for destructive actions
- Output is sanitized (no raw passwords in logs)
- Diagram generator works on partial reconnaissance data

## References
- wifi-pentest-guide.md: Complete technical reference
- 802.11 standards documentation
- aircrack-ng documentation
