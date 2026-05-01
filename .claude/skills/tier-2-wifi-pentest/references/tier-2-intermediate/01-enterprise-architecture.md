# 01 — Enterprise Wi-Fi Architecture

## WPA2/WPA3-Enterprise Components

- **Authentication Server (AS)**: RADIUS server (FreeRADIUS, NPS, ISE)
- **Supplicant**: Client device (Windows, iOS, Android)
- **Authenticator**: Access Point (authenticates via RADIUS)
- **EAP Method**: Authentication protocol (PEAP, EAP-TLS, EAP-TTLS)

## EAP Authentication Flow

1. Client associates with AP (open auth)
2. AP sends EAP-Request/Identity
3. Client responds with EAP-Response/Identity (outer identity)
4. AP forwards to RADIUS server
5. EAP method negotiation (PEAP, TTLS, etc.)
6. Inner authentication (MSCHAPv2, GTC, PAP)
7. RADIUS Access-Accept → client authorized
8. WPA2/4-way handshake with derived PMK

## Certificate Validation

EAP-TLS and PEAP require server certificate validation:
- **Proper validation**: Client checks CA, hostname, certificate chain
- **Common misconfig**: Client accepts any certificate → trivial rogue AP attack

## RADIUS Dictionary & Attributes

Key attributes:
- `User-Name (1)`: Outer identity
- `NAS-IP-Address (4)`: AP IP address
- `Framed-IP-Address (8)`: Assigned client IP
- `Calling-Station-Id (31)`: Client MAC address
- `Called-Station-Id (30)`: AP MAC + SSID
