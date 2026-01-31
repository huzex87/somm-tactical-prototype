# SOMM Protocol Specification v1.0 (Draft)

## 1. Message Framing
All messages transmitted over BLE/Wi-Fi are wrapped in a standard SOMM Frame.

| Field | Size (Bytes) | Description |
| :--- | :--- | :--- |
| Version | 1 | Protocol version (0x01) |
| Type | 1 | Handshake, Data, ACK, Sync |
| SessionID | 4 | Ephemeral session identifier |
| Nonce | 8 | Incremental nonce for ChaCha20 |
| Payload | Variable | Encrypted Noise payload |
| MAC | 16 | Poly1305 Authentication Tag |

## 2. Session Lifecycle
- **Initialization**: Nodes use Noise XX handshake to establish mutual authentication.
- **Maintenance**: Session keys are rotated every 100 messages or 1 hour, whichever comes first.
- **Termination**: Inactive sessions are purged from memory after 4 hours. No keys are persisted to disk.

## 3. Mesh Routing (Flood/Gossip)
- **TTL (Time To Live)**: Defaults to 5. Decremented at each hop.
- **Message IDs**: 8-byte hash of the ciphertext to detect duplicates.
- **Relay Rules**: Nodes cache Message IDs and only relay messages they haven't seen before.

## 4. Fragmentation & Retransmission
- **Fragmentation**: Messages larger than BLE MTU (typ. 185 bytes) are split into segments.
- **ACK Strategy**: Point-to-point ACKs for segments; E2E ACKs for complete messages.
- **Backoff**: Exponential backoff for retransmissions in congested mesh.

## 5. Metadata Minimization
- Sender and Receiver IDs are encrypted within the Noise payload.
- Mesh relaying nodes see only the SessionID and Nonce, which remain anonymous.
