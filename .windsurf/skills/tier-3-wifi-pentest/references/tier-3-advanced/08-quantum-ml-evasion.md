# 08 — Quantum & ML Evasion

## Quantum-Safe Wi-Fi Security

Current WPA3 relies on RSA/DH/ECC, vulnerable to Shor's algorithm.
- NIST PQC finalists: CRYSTALS-Kyber, CRYSTALS-Dilithium
- 802.11-2024: Framework for post-quantum AKMs

## ML-Based WIDS Evasion

Adversarial machine learning against Wi-Fi intrusion detection:
- GAN-generated fake normal traffic patterns
- Adversarial perturbation of attack signatures
- Poisoning of training data with false negatives

```python
# Simple adversarial frame timing perturbation
import numpy as np
def add_jitter(pkt_stream, epsilon=0.01):
    jitter = np.random.normal(0, epsilon, len(pkt_stream))
    return [t + j for t, j in zip(pkt_stream, jitter)]
```

## ML-Assisted Attack Optimization

- Reinforcement learning for optimal channel selection
- Neural network prediction of WIDS sensor locations
- Genetic algorithms for credential mutation rules

## Defensive Application

- Implement post-quantum AKMs in WPA3-Enterprise
- Deploy ensemble ML models resistant to adversarial inputs
- Continuous model retraining with adversarial examples
