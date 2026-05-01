# Lab Setup Guide

## Minimal Lab Topology

```
Internet
   |
Router/AP (192.168.1.1)
   |
+--------+--------+--------+
|        |        |        |
Kali    Target  Client  RADIUS
Attacker  AP    Laptop  Server
```

## Hardware Options

### Option A: Laptop + 2 USB Wi-Fi Adapters
- Laptop with Kali Linux
- 2x USB Wi-Fi adapters (Alfa AWUS036ACM recommended)
- 1x targets any consumer router with WPA2
- Cost: ~$150

### Option B: Virtual Machines
- Host machine with VirtualBox/VMware
- VM1: Kali Linux (attacker)
- VM2: OpenWRT router image (target AP)
- VM3: Windows/Linux (victim client)
- USB Wi-Fi adapter passed to Kali VM
- Cost: Free (existing hardware)

### Option C: Dedicated Lab
- Raspberry Pi 4 (OpenWRT target AP)
- Raspberry Pi 4 (Kali attacker)
- Old laptop (client)
- Cost: ~$200

## Target AP Configuration (OpenWRT)

```bash
# Install OpenWRT on router or use image builder
# Configure Wi-Fi interface
uci set wireless.radio0=wifi-device
uci set wireless.radio0.type=mac80211
uci set wireless.radio0.channel=6
uci set wireless.radio0.hwmode=11g
uci set wireless.radio0.htmode=HT20

uci set wireless.@wifi-iface[0]=wifi-iface
uci set wireless.@wifi-iface[0].device=radio0
uci set wireless.@wifi-iface[0].mode=ap
uci set wireless.@wifi-iface[0].ssid=LabTarget
uci set wireless.@wifi-iface[0].encryption=psk2
uci set wireless.@wifi-iface[0].key=LabPassword123

uci commit wireless
wifi reload
```

## Enterprise Lab Setup

### FreeRADIUS Server

```bash
# Install on separate VM or Pi
apt-get install -y freeradius freeradius-utils

# Configure client (AP)
cat >> /etc/freeradius/3.0/clients.conf << 'EOF'
client lab_ap {
    ipaddr = 192.168.1.2
    secret = testing123
}
EOF

# Configure user
cat >> /etc/freeradius/3.0/users << 'EOF'
labuser   Cleartext-Password := "labpassword"
EOF

# Start
systemctl start freeradius
radtest labuser labpassword 192.168.1.2 0 testing123
```

### AP Configuration for WPA2-Enterprise

```bash
# hostapd config
cat > /tmp/enterprise.conf << 'EOF'
interface=wlan0
ssid=LabEnterprise
wpa=2
wpa_key_mgmt=WPA-EAP
rsn_pairwise=CCMP
ieee8021x=1
eapol_key_index_workaround=0
auth_server_addr=192.168.1.10
auth_server_port=1812
auth_server_shared_secret=testing123
EOF
hostapd /tmp/enterprise.conf
```

## Isolation and Safety

- Use dedicated Wi-Fi channels (1, 6, 11) far from production networks
- Power off when not in use
- Faraday cage or RF shielding for sensitive environments
- No internet access for target network
- Document all configurations

## Captured Sample Files

Generate synthetic captures for practice:

```bash
# Generate WPA2 handshake with known password
./scripts/gen-handshake.py --ssid LabTarget --password LabPassword123 -o lab-handshake.pcapng

# Generate EAP-PEAP capture
./scripts/gen-eap-peap.py --identity labuser --password labpassword -o lab-eap.pcapng
```
