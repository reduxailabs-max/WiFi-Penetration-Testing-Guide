#!/bin/bash
# auto-crack.sh - Progressive password cracking pipeline
# Usage: ./auto-crack.sh <hash-file.hc22000>

HASH_FILE=$1

if [ -z "$HASH_FILE" ]; then
    echo "Usage: $0 <hash-file.hc22000>"
    exit 1
fi

if [ ! -f "$HASH_FILE" ]; then
    echo "[!] Hash file not found: $HASH_FILE"
    exit 1
fi

echo "========================================"
echo "Stage 1: Quick Wordlist"
echo "========================================"
head -1000 /usr/share/wordlists/rockyou.txt 2>/dev/null > /tmp/top1000.txt
echo "[+] Testing top 1000 passwords..."
hashcat -a 0 -m 22000 "$HASH_FILE" /tmp/top1000.txt -O --force 2>/dev/null

if hashcat -a 0 -m 22000 "$HASH_FILE" --show 2>/dev/null | grep -q ":"; then
    echo "[+] FOUND!"
    hashcat -a 0 -m 22000 "$HASH_FILE" --show
    exit 0
fi

echo ""
echo "========================================"
echo "Stage 2: Full Wordlist + Rules"
echo "========================================"
echo "[+] Running with rules..."
hashcat -a 0 -m 22000 "$HASH_FILE" /usr/share/wordlists/rockyou.txt -r /usr/share/hashcat/rules/best64.rule -O 2>/dev/null

if hashcat -a 0 -m 22000 "$HASH_FILE" --show 2>/dev/null | grep -q ":"; then
    echo "[+] FOUND!"
    hashcat -a 0 -m 22000 "$HASH_FILE" --show
    exit 0
fi

echo ""
echo "[!] Wordlist attacks failed. Try mask attack:"
echo "hashcat -a 3 -m 22000 $HASH_FILE '?d?d?d?d?d?d?d?d'"
