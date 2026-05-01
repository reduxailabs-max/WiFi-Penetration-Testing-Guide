#!/usr/bin/env python3
"""802.11 Frame Fuzzer using Scapy."""
from scapy.all import *
import random, sys

iface = sys.argv[1] if len(sys.argv) > 1 else "wlan0mon"
target = sys.argv[2] if len(sys.argv) > 2 else "ff:ff:ff:ff:ff:ff"

def fuzz_beacon():
    ssid = bytes([random.randint(1, 254) for _ in range(random.randint(0, 32))])
    return RadioTap() / Dot11(addr1=target, addr2=RandMAC(), addr3=RandMAC()) / \
           Dot11Beacon(cap=0x3104) / Dot11Elt(ID="SSID", info=ssid) / \
           Dot11Elt(ID="Rates", info=b'\x82\x84\x8b\x96\x0c\x12\x18\x24')

print(f"[*] Fuzzing beacons on {iface} toward {target}")
while True:
    try:
        sendp(fuzz_beacon(), iface=iface, verbose=0)
    except Exception as e:
        print(f"[!] Error: {e}")
