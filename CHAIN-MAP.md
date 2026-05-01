# Attack Chain Map

## Tier 1: Personal Wi-Fi

```
Recon → Deauth → Handshake → Crack → Access
  │         │          │          │        │
  ▼         ▼          ▼          ▼        ▼
airodump  aireplay   .cap      hashcat   network
wash     -0 5      hccapx    rockyou   access
```

### WPS Chain
```
WPS Scan → PIN Attack → PSK Recovery → Access
   │            │              │            │
   ▼            ▼              ▼            ▼
  wash      reaver/bully    derive PSK   connect
```

## Tier 2: Enterprise Wi-Fi

```
Recon → Rogue AP → EAP Harvest → Crack MSCHAPv2 → Authenticate → Pivot
  │         │            │              │                │           │
  ▼         ▼            ▼              ▼                ▼           ▼
airodump  hostapd    mana creds     hashcat -m 5500   WPA2-Ent    VLAN hop
EAP enum  mana      eaphammer      asleap            connect     lateral
```

### PMKID Chain
```
PMKID Capture → Convert → Crack → Access
      │             │          │        │
      ▼             ▼          ▼        ▼
  hcxdumptool  hcxpcapng   hashcat   connect
               -m 22001
```

## Tier 3: High-Security

```
Recon → WPA3 Downgrade → SAE Side-Channel → Key Recovery → Access
  │            │                  │                │           │
  ▼            ▼                  ▼                ▼           ▼
passive    transition mode    dragonblood     offline      network
SDR scan   force WPA2        timing attack   crack        access
```

### Multi-Vector Red Team Chain
```
Day 1: Passive recon (SDR spectrum, airodump)
Day 2: Rogue AP deployment (mana + karma)
Day 3: EAP credential harvest (parking lot)
Day 4: MSCHAPv2 crack → AD credentials
Day 5: Authenticate to real network
Day 6: VLAN pivot + data exfiltration (DNS tunnel)
```

### SDR + WIDS Evasion Chain
```
SDR Recon → Identify WIDS sensors → Craft evasion → Execute attack
     │              │                     │               │
     ▼              ▼                     ▼               ▼
  spectrum      detect sensor        low-and-slow     frame
  analysis      locations            timing jitter    injection
```
