# 11 - Wardriving Methodology

## Overview

Wardriving is the act of searching for Wi-Fi networks by driving around with a mobile setup. It combines GPS logging, wireless scanning, and data analysis to map wireless infrastructure over a geographic area.

## Hardware Setups

### Basic Setup (Budget)

| Component | Recommendation | Cost |
|-----------|---------------|------|
| SBC | Raspberry Pi 4 (4GB) | ~$55 |
| Wi-Fi Adapter | Alfa AWUS036ACM | ~$40 |
| GPS | u-blox NEO-6M USB GPS | ~$15 |
| Power | Anker PowerCore 10000 | ~$25 |
| Antenna | Stock omni + optional directional | ~$0-50 |
| **Total** | | **~$135** |

### Advanced Setup

| Component | Recommendation | Cost |
|-----------|---------------|------|
| Laptop | ThinkPad T480 + Kali | ~$300 |
| Primary Adapter | Alfa AWUS036ACH + 9dBi omni | ~$65 |
| Secondary Adapter | AWUS036ACM (5 GHz + injection) | ~$40 |
| GPS | Globalsat BU-353-S4 (SiRF IV) | ~$35 |
| Directional | TP-Link TL-ANT2424B 24dBi grid | ~$50 |
| Yagi | Alfa AYA-0001 16dBi Yagi | ~$35 |
| Amplifier | Alfa APA-M04 4W bi-directional | ~$60 |
| Cantenna | DIY Pringles can + N-type | ~$10 |
| Drone | DJI Mini 3 Pro + custom mount | ~$500 |
| **Total** | | **~$1,095** |

## Software Configuration

### Kismet + GPSD

```bash
# Install dependencies
apt-get install -y kismet gpsd gpsd-clients

# Configure GPSD
cat > /etc/default/gpsd << 'EOF'
START_DAEMON="true"
GPSD_OPTIONS="-n"
DEVICES="/dev/ttyUSB0"
USBAUTO="true"
EOF

# Start GPSD
systemctl restart gpsd
gpsmon  # Verify GPS lock

# Start Kismet with GPS logging
kismet -c wlan0mon --log-types json,gpsxml,pcapng

# Output files:
# Kismet-YYYYMMDD-HH-MM-SS.gpsxml   - GPS track
# Kismet-YYYYMMDD-HH-MM-SS.kismet   - SQLite database
# Kismet-YYYYMMDD-HH-MM-SS.pcapng   - Raw packets
```

### Airodump-ng + GPSD Integration

```bash
# airodump-ng does not natively log GPS, but gpspipe can tag captures
gpspipe -w -n 10 > /tmp/gps_track.json &
GPS_PID=$!

airodump-ng wlan0mon --gpsd --output-format csv,gps -w wardrive_session

kill $GPS_PID
```

### Wigle.net Upload

```bash
# Convert Kismet output to Wigle WiFi CSV
# Wigle accepts: WiGLE WiFi Wardriving format

# Or upload directly via Wigle API (requires account)
curl -X POST -F "file=@Kismet-20240101-00-00-00.kismet" \
  -H "Authorization: Basic <base64_auth>" \
  https://api.wigle.net/api/v2/file/upload
```

## Directional Antenna Calculations

### Free-Space Path Loss

```
FSPL(dB) = 20*log10(d) + 20*log10(f) + 32.44

Where:
  d = distance in km
  f = frequency in MHz

Example: 2.4 GHz at 1 km
FSPL = 20*log10(1) + 20*log10(2400) + 32.44 = 0 + 67.6 + 32.44 = 100 dB

Link Budget:
Received Power = TX Power + TX Gain + RX Gain - FSPL - Margin
```

### Practical Range Examples

| Setup | TX Power | Antenna | Estimated Range (LOS) |
|-------|----------|---------|----------------------|
| Stock laptop + AP | 20 dBm | 2 dBi | ~100m |
| Alfa + 9dBi omni | 30 dBm | 9 dBi | ~500m |
| Alfa + 24dBi grid | 30 dBm | 24 dBi | ~5 km |
| Alfa + amp + 24dBi | 36 dBm | 24 dBi | ~15 km |
| Cantenna + amp | 36 dBm | 12 dBi | ~3 km |

## Warflying (Drone-Based)

```bash
# Raspberry Pi Zero 2 W + Alfa AWUS036ACM + GPS on DJI Mini 3
# Mount under drone belly, power via drone USB

# Pre-flight: start logging
ssh pi@drone-pi 'kismet -c wlan0mon --daemonize'

# Post-flight: download logs
scp pi@drone-pi:/var/log/kismet/*.kismet ./
```

## Legal Considerations

- **Passive scanning**: Legal in most jurisdictions (receive-only)
- **GPS logging**: Legal (public satellite signals)
- **Data upload to Wigle**: Legal (public SSID broadcasts)
- **Deauth/Injection**: Illegal without explicit authorization (most jurisdictions)
- **Drone regulations**: Vary by country (FAA Part 107 in US, EASA in EU)

## Defensive Application

- **Wardriving detection**: Deploy honeypot APs with unique SSIDs, monitor Wigle for uploads
- **SSID rotation**: Change corporate SSIDs periodically (inconvenient but effective)
- **Indoor-only propagation**: Lower TX power, directional antennas pointing inward
- **Physical security**: Locate APs centrally, away from windows/external walls

## Data Analysis

```bash
# Analyze Kismet SQLite database
sqlite3 Kismet-*.kismet "SELECT devmac, strongest_signal_lat, strongest_signal_lon, ssid FROM devices WHERE type='Wi-Fi AP';"

# Generate heatmap from GPS data
# Use: https://www.wigle.net/ or custom Python with folium
```
