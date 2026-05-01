#!/usr/bin/env python3
"""SDR Frame Injection stub (GNU Radio companion required)."""
import os, sys

def main():
    print("[*] SDR Injector stub")
    print("[!] Requires: HackRF + gr-ieee802-11")
    print("[*] Run: gnuradio-companion gr-ieee802-11/transmitter.grc")
    print("[*] Or: osmocom_fft -f 2.437e9 -s 2e6")

if __name__ == "__main__":
    main()
