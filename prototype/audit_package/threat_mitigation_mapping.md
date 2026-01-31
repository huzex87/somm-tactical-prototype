# Threat Mitigation Mapping: SOMM System

This document maps the tactical threats identified in `threat_model.md` to specific technical controls implemented in the prototype.

| Threat ID | Tactical Threat | Technical Control (Code/Module) | Implementation Detail |
| :--- | :--- | :--- | :--- |
| **T-01** | **Device Capture** (Data exposure) | `lib/core/crypto/secure_key_provider.dart` | Ephemeral session keys in RAM; simulated non-exportable hardware-backed identity keys. |
| **T-02** | **Traffic Analysis** (Metadata) | `lib/domain/models/somm_message.dart` | Minimization of plaintext headers. Identities are derived from short-lived sessions. |
| **T-03** | **Message Injection** (Sybil) | `lib/core/crypto/noise_protocol.dart` | Mandatory Mutual Authentication via Noise XX handshake. |
| **T-04** | **Replay Attack** | `lib/core/mesh/mesh_simulator.dart` | Message ID deduplication in `MeshNode` and monotonic timestamps. |
| **T-05** | **Interception** (Man-in-the-Middle) | `lib/core/crypto/handshake_manager.dart` | End-to-End Encryption (E2EE) using X25519 and ChaCha20-Poly1305. |
| **T-06** | **Active Jamming** (Denial of Service) | `lib/core/mesh/mesh_simulator.dart` | Store-and-forward mesh gossip with automatic retransmission upon local connectivity recovery. |

## Audit Methodology
1. **Cryptographic Validation**: Verify `NoiseProtocol` against deterministic test vectors.
2. **Key Material Handling**: Confirm identity keys are never serialized to world-readable storage.
3. **Logic Flow**: Audit the state machine in `HandshakeManager` to ensure sessions are never established without mutual proof of possession.

---
> [!NOTE]
> This mapping is provided to assist third-party auditors in validating the system's security assertions.
