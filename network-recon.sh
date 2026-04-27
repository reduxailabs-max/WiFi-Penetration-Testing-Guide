#!/bin/bash
################################################################################
# NETWORK RECONNAISSANCE - Systematic Discovery
# Run on target authorized network to generate data for documentation
################################################################################

set -euo pipefail

OUTPUT_DIR="network-recon-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                    NETWORK RECONNAISSANCE TOOLKIT                           ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo "[*] Output: $OUTPUT_DIR"
echo ""

################################################################################
# PHASE 1: LOCAL HOST INVENTORY
################################################################################
phase1_local() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "PHASE 1: LOCAL HOST CONFIGURATION"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    {
        echo "=== HOSTNAME ==="
        hostname
        hostname -f 2>/dev/null || hostname
        
        echo ""
        echo "=== INTERFACE LIST ==="
        ip link show
        
        echo ""
        echo "=== IP CONFIGURATION ==="
        ip -4 addr show
        
        echo ""
        echo "=== IPV6 CONFIGURATION ==="
        ip -6 addr show 2>/dev/null || echo "No IPv6"
        
        echo ""
        echo "=== ROUTING TABLE ==="
        ip route show
        
        echo ""
        echo "=== IPV6 ROUTES ==="
        ip -6 route show 2>/dev/null || echo "No IPv6 routes"
        
        echo ""
        echo "=== ARP TABLE ==="
        ip neigh show
        
        echo ""
        echo "=== DNS CONFIGURATION ==="
        cat /etc/resolv.conf 2>/dev/null || echo "No resolv.conf"
        
        echo ""
        echo "=== HOSTS FILE ==="
        cat /etc/hosts 2>/dev/null | head -20
        
    } > "$OUTPUT_DIR/phase1-local.txt"
    
    echo "[+] Saved: phase1-local.txt"
}

################################################################################
# PHASE 2: WIRELESS DISCOVERY
################################################################################
phase2_wireless() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "PHASE 2: WIRELESS NETWORK DISCOVERY"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    {
        echo "=== WIRELESS INTERFACES ==="
        iw dev 2>/dev/null || echo "iw not available"
        
        echo ""
        echo "=== WIRELESS PHYSICAL ==="
        iw phy 2>/dev/null | head -50 || echo "iw not available"
        
        echo ""
        echo "=== CONNECTION STATUS ==="
        iw dev 2>/dev/null | grep -A 10 "Interface" || echo "iw not available"
        
        echo ""
        echo "=== WPA_SUPPLICANT ==="
        wpa_cli status 2>/dev/null || echo "wpa_cli not available"
        
    } > "$OUTPUT_DIR/phase2-wireless.txt"
    
    # Attempt monitor mode scan if aircrack-ng available
    if command -v airmon-ng &>/dev/null; then
        echo "[*] Running wireless scan (requires monitor mode)..."
        timeout 15 bash -c '
            airmon-ng check kill 2>/dev/null
            airmon-ng start wlan0 2>/dev/null || true
            timeout 12 airodump-ng wlan0mon --band abg -w '"$OUTPUT_DIR/phase2-scan"' --output-format csv 2>/dev/null || true
            airmon-ng stop wlan0mon 2>/dev/null || true
        ' 2>/dev/null || echo "[!] Wireless scan failed (expected if no monitor mode support)"
    else
        echo "[!] aircrack-ng not installed"
    fi
    
    echo "[+] Saved: phase2-wireless.txt, phase2-scan*.csv (if scan succeeded)"
}

################################################################################
# PHASE 3: NETWORK SEGMENTATION DISCOVERY
################################################################################
phase3_segmentation() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "PHASE 3: NETWORK SEGMENTATION & VLAN DISCOVERY"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    {
        echo "=== CDP/LLDP DISCOVERY ==="
        # Check for CDP/LLDP packets
        if command -v tcpdump &>/dev/null; then
            echo "[*] Attempting CDP/LLDP capture (5 seconds)..."
            timeout 5 tcpdump -i any -nn -v "cdp or lldp" 2>&1 | head -30 || echo "No CDP/LLDP detected or tcpdump failed"
        fi
        
        echo ""
        echo "=== 802.1Q VLAN CHECK ==="
        # Check if interface is VLAN tagged
        cat /proc/net/vlan/config 2>/dev/null || echo "No kernel VLAN configured"
        
        echo ""
        echo "=== INTERFACE STATISTICS ==="
        cat /proc/net/dev
        
        echo ""
        echo "=== BRIDGE CONFIGURATION ==="
        ip -d link show type bridge 2>/dev/null || echo "No bridges"
        
        echo ""
        echo "=== NETWORK NAMESPACES ==="
        ip netns list 2>/dev/null || echo "No network namespaces"
        
        echo ""
        echo "=== IPTABLES RULES ==="
        iptables -L -n -v 2>/dev/null | head -50 || echo "iptables not available"
        
        echo ""
        echo "=== IPTABLES NAT ==="
        iptables -t nat -L -n -v 2>/dev/null | head -30 || echo "iptables not available"
        
    } > "$OUTPUT_DIR/phase3-segmentation.txt"
    
    echo "[+] Saved: phase3-segmentation.txt"
}

################################################################################
# PHASE 4: ACTIVE RECON - GATEWAY & DHCP
################################################################################
phase4_active() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "PHASE 4: ACTIVE DISCOVERY (GATEWAY, DHCP, UPSTREAM)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    {
        echo "=== GATEWAY DISCOVERY ==="
        local gateway
        gateway=$(ip route | grep default | awk '{print $3}' | head -1)
        echo "Default Gateway: $gateway"
        
        if [[ -n "$gateway" ]]; then
            echo ""
            echo "[*] Gateway fingerprint:"
            timeout 3 bash -c "arp -a $gateway" 2>/dev/null || ip neigh show to "$gateway" 2>/dev/null
            
            echo ""
            echo "[*] Gateway port scan (top 20):"
            timeout 10 nmap -sT --top-ports 20 --open "$gateway" 2>/dev/null || 
                timeout 5 bash -c "</dev/tcp/$gateway/80" 2>/dev/null && echo "Port 80 open" || echo "Port scan unavailable"
            
            echo ""
            echo "[*] Web interface check:"
            curl -sI "http://$gateway" 2>/dev/null | head -5 || echo "No HTTP response"
        fi
        
        echo ""
        echo "=== DHCP INFORMATION ==="
        # DHCP lease info
        cat /var/lib/dhcp/dhclient.*.leases 2>/dev/null | grep -E "(server|router|dns|subnet|domain)" | sort -u ||
            cat /var/lib/dhcpcd/*.lease 2>/dev/null | head -20 ||
            echo "No DHCP leases found"
        
        echo ""
        echo "=== UPSTREAM DNS ==="
        dig +short dns.google.com @$(cat /etc/resolv.conf | grep nameserver | head -1 | awk '{print $2}') 2>/dev/null ||
            echo "dig not available"
            
        echo ""
        echo "=== TRACEROUTE ==="