#!/bin/bash
# auto-recon.sh - Automated wireless reconnaissance
# Usage: sudo ./auto-recon.sh <interface> [duration_seconds]

set -e

INTERFACE=${1:-wlan0mon}
DURATION=${2:-300}
OUTPUT_DIR="recon-$(date +%Y%m%d-%H%M%S)"

print_banner() {
    echo "========================================"
    echo "  WiFi Auto-Reconnaissance Tool"
    echo "========================================"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "[!] This script must be run as root"
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

run_recon() {
    mkdir -p "$OUTPUT_DIR"
    echo "[+] Output directory: $OUTPUT_DIR"
    echo "[+] Duration: $DURATION seconds"
    echo "[+] Starting scan on $INTERFACE..."
    echo ""
    
    # Full spectrum scan
    timeout "$DURATION" airodump-ng --band abg -0 -w "$OUTPUT_DIR/survey" "$INTERFACE" 2>/dev/null || true
}

analyze_results() {
    echo ""
    echo "[+] Analyzing results..."
    
    if [ ! -f "$OUTPUT_DIR/survey-01.csv" ]; then
        echo "[!] No scan results found"
        exit 1
    fi
    
    echo ""
    echo "=== HIGH-VALUE TARGETS (WPA2-PSK, Signal > -70) ==="
    printf "%-17s %3s %4s %-5s %-6s %-4s %s\n" "BSSID" "CH" "PWR" "ENC" "CIPHER" "AUTH" "ESSID"
    echo "-------------------------------------------------------------------"
    
    awk -F',' '
    NR>2 && $6 ~ /WPA2/ && $8 ~ /PSK/ && $4 > -70 && $4 != "" {
        printf "%-17s %3s %4s %-5s %-6s %-4s %s\n", $1, $5, $4, $6, $7, $8, $14
    }' "$OUTPUT_DIR/survey-01.csv" 2>/dev/null | head -15
    
    echo ""
    echo "=== WPS-ENABLED TARGETS ==="
    printf "%-17s %3s %4s %s\n" "BSSID" "CH" "PWR" "WPS"
    echo "-------------------------------------------"
    
    if [ -f "$OUTPUT_DIR/survey-01.kismet.csv" ]; then
        grep -v "^BSSID" "$OUTPUT_DIR/survey-01.kismet.csv" 2>/dev/null | \
        awk -F';' '$10 != "" {printf "%-17s %3s %4s %s\n", $1, $6, $5, $10}' | head -10
    fi
    
    echo ""
    echo "[+] Full results saved to: $OUTPUT_DIR/survey-01.csv"
    echo "[+] To analyze: cat $OUTPUT_DIR/survey-01.csv | less"
}

print_summary() {
    echo ""
    echo "========================================"
    echo "  Reconnaissance Complete"
    echo "========================================"
    echo "Files saved in: $OUTPUT_DIR/"
    echo ""
    echo "Next steps:"
    echo "1. Review survey-01.csv for targets"
    echo "2. Select target meeting criteria:"
    echo "   - WPA2-PSK encryption"
    echo "   - Signal > -70 dBm"
    echo "   - WPS enabled (optional)"
    echo "3. Proceed to handshake capture"
}

main() {
    print_banner
    check_root
    check_monitor_mode
    run_recon
    analyze_results
    print_summary
}

main "$@"
