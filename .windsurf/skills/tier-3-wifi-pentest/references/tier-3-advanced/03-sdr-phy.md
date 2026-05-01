# 03 — SDR/PHY Layer Attacks

## Hardware

- HackRF One (1 MHz – 6 GHz)
- LimeSDR (100 kHz – 3.8 GHz)
- BladeRF 2.0 xA4 (47 MHz – 6 GHz)

## Jamming and Interference

### Reactive Jamming
Jam only when target frame detected.
```python
from gnuradio import gr, digital, blocks
# Detect frame type from preamble, jam with noise burst
```

### Smart Jamming
Jam ACK frames selectively to maximize retransmission DoS.

## Packet Injection with SDR

```bash
# Using gr-ieee802-11 with HackRF
gnuradio-companion gr-ieee802-11/transmitter.grc
```

## Spectrum Analysis

```bash
# Real-time waterfall
hackrf_sweep -f 2400:2500 -w 1000000

# Wi-Fi channel energy detection
gr-scan --start-frequency 2.4e9 --stop-frequency 2.5e9
```

## Defensive Application

- Directional antennas to reduce interference
- Spectrum monitoring for anomaly detection
- Adaptive frequency hopping (AFH) where supported
