# Module 01 — WPA3 & DragonBlood

## 1.1 SAE Handshake

### Simultaneous Authentication of Equals

```
Commit Phase:
Client → AP: scalar_C, element_C
AP → Client: scalar_AP, element_AP

Confirm Phase:
Client → AP: confirm_C
AP → Client: confirm_AP
```

---

## 1.2 DragonBlood Vulnerabilities

### CVE-2019-9494: Timing Side-Channel

**Attack**: Measure SAE commit response times to derive password
**Tool**: dragonforce, DragonBlood PoC

```bash
# Clone PoC
git clone https://github.com/drabkin/dragonblood-poc.git

# Requires specific AP firmware versions vulnerable to timing
```

### CVE-2019-9494: Cache Side-Channel

**Attack**: Monitor CPU cache during SAE operations
**Impact**: Password recovery from timing differences

---

## 1.3 SAE-PK Downgrade

### Transition Mode Attack

```
WPA3-Transition Mode: Supports both WPA2 and WPA3

Attack: Force downgrade to WPA2
Tool: hostapd with SAE-PK downgrade
```

---

## 1.4 Detection & Defense

### WPA3-Only Mode

```
Disable transition mode
Require SAE-PK (Public Key) authentication
Use strong passwords (20+ chars)
```

**Next**: [Module 02 — Wi-Fi 6/6E Attacks](02-wifi6-attacks.md)
