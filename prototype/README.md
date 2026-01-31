# SOMM Laboratory Prototype

> [!CAUTION]
> **LAB-ONLY SYSTEM**: Do not deploy this prototype to operational environments. It is intended for functional validation and security auditing in a controlled laboratory setting.

## Overview
This prototype demonstrates the core mechanics of the Secure Offline Mesh Messaging (SOMM) system.
- **Handshake**: Mutual authentication via Noise XX Pattern.
- **Encryption**: ChaCha20-Poly1305 with HKDF key-ratcheting.
- **Mesh**: Simulated store-and-forward gossip protocol.
- **Hardware**: Integration points for Android StrongBox and iOS Secure Enclave.

## Directory Structure
- `lib/core/crypto/`: Cryptographic primitives and handshake state machine.
- `lib/core/mesh/`: Decentralized routing and simulation logic.
- `lib/domain/models/`: Immutable data structures for messages and signals.
- `test/`: Deterministic test vectors and scenario-based validation.

## Running Tests
To verify the cryptographic implementation against known test vectors:
```bash
flutter test
```

## Running the Prototype (Simulation)
Ensure you have a Flutter environment set up.
```bash
flutter run
```

## Audit Gates
1. [ ] **Noise XX Handshake**: Verified against deterministic vectors in `test/crypto_test.dart`.
2. [ ] **Ephemerality**: Verified that session keys are held only in RAM and zeroized on session close.
3. [ ] **Metadata**: Verified that all PII (Sender/Receiver IDs) are encrypted within the Noise payload.
