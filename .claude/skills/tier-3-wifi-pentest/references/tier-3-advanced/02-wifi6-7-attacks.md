# 02 — Wi-Fi 6 / 7 (802.11ax/be) Attacks

## OFDMA and MU-MIMO

802.11ax introduces OFDMA: subcarrier allocation to multiple STAs.
- Target Wake Time (TWT): Power save scheduling, spoof for DoS
- BSS Coloring: Spatial reuse, spoof to force retransmissions
- Trigger Frames: UL MU scheduling, inject to corrupt UL burst

## Wi-Fi 7 (802.11be) Features

- Multi-Link Operation (MLO): Simultaneous operation on multiple bands
- Multi-Resource Unit (MRU): Flexible channel allocation
- 320 MHz channels, 4096-QAM, 16 spatial streams

## Attack Vectors

### MLO Downgrade
Force client to single link by jamming primary link.
```bash
# Jam primary 5 GHz link, client falls back to 2.4 GHz with weaker security
sudo python3 jammer.py --freq 5180 --mode narrow --duration 10
```

### OFDMA Resource Unit Exhaustion
Send crafted trigger frames to exhaust RU allocation.

## Defensive Application

- Enable MLD authentication and key derivation
- Monitor for OFDMA trigger anomalies
- Validate BSS coloring consistency
