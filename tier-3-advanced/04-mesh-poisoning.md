# 04 — Mesh Network Poisoning (802.11s)

## 802.11s Mesh Basics

- Mesh BSS: Self-forming, self-healing network
- Mesh Peering Management protocol
- Hybrid Wireless Mesh Protocol (HWMP) for routing

## Path Selection Poisoning

Inject fake PREQ/ PREP frames to reroute traffic.
```bash
# Forge PREQ with lower metric
scapy> sendp(RadioTap()/Dot11(type=0,subtype=11)/mesh_data, iface=wlan0)
```

## Mesh Gate Impersonation

Advertise as mesh gate to intercept inter-network traffic.

## OLSR / Batman-adv Attacks

- Link state spoofing in OLSR
- Batman-adv originator impersonation

## Defensive Application

- Secure mesh peering with SAE/802.1X
- Cryptographic routing protocol authentication
- HWMP proactive path validation
