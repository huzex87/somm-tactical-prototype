# SOMM Threat Model & Mitigations

## Threat Matrix

| Threat Category | Specific Threat | Control / Mitigation | Residual Risk |
| :--- | :--- | :--- | :--- |
| **Physical** | Device Capture / Key Theft | Hardware Keystore (TEE/SE) for identity keys; ephemeral session keys in RAM only; "Purge" command. | Low (Hardware dependent) |
| **Network** | Message Injection | Noise XX mutual authentication; all messages signed/MACed with session keys. | Negligible |
| **Network** | Message Replay | Sequential nonces per session; relay nodes cache seen message hashes. | Negligible |
| **Privacy** | Traffic Analysis | Uniform packet padding; minimal plaintext metadata (only SessionID visible to relays). | Moderate (Timing attacks possible) |
| **Protocol** | Sybil Attack | Identity certificates issued by Offline Authority; nodes only peer with valid cert holders. | Low |
| **Availability** | RF Jamming | Multi-transport fallback (BLE to Wi-Fi Direct); Store-and-forward persistence. | High (Nature of RF) |

## Mitigations Detail

### 1. Device Capture
In the event of capture, the long-term identity key $SK_{id}$ remains locked in the Secure Enclave and cannot be exported. If the device is unlocked, the application's secure memory containing session keys can be wiped remotely (if signaled) or locally via a tamper trigger.

### 2. Message Injection & Spoofing
The Noise XX pattern ensures that a node cannot complete a handshake without a private key corresponding to a certificate signed by the Root Authority. Unauthorized nodes cannot inject validly encrypted payloads.

### 3. Traffic Analysis
While metadata is minimized, the frequency of transmissions can reveal activity. Future versions should implement cover traffic (chaff) to obfuscate operational spikes.
