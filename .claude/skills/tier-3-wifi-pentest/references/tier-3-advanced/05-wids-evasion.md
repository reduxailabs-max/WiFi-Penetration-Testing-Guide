# 05 — WIDS/WIPS Evasion

## Commercial WIDS Detection Methods

- Signature-based: Known attack frame patterns
- Behavioral: Statistical anomalies in frame rates
- Spectrum analysis: Detect non-Wi-Fi interference
- Distributed sensors: Multiple vantage points

## Evasion Techniques

### Frame Fragmentation
Split attack across multiple fragments to evade signature.
```bash
aireplay-ng -7 -b 00:11:22:33:44:55 wlan0mon  # fragmentation attack
```

### Channel Hopping Synchronization
Hop channels in sync with WIDS blind intervals.

### Low-and-Slow
Execute attack over hours to stay below behavioral thresholds.

### Encapsulation
Tunnel 802.11 frames inside allowed protocols (DNS, ICMP).

## WIPS Countermeasures

- Nullification: WIPS sends deauth to attacker
- Containment: Rogue AP isolation via coordinated deauth
- Spectrum jamming of rogue devices

## Defensive Application

- Deploy WIDS sensors at all perimeter locations
- Combine with wired NAC for complete visibility
- Regular red team testing of WIDS coverage
