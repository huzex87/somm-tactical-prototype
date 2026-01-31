# SOMM Provisioning & Key Lifecycle Design

## 1. Offline Provisioning Authority (OPA)
The OPA is an air-gapped Linux workstation (e.g., Tails OS or hardened Debian) used to generate the Root of Trust and issue device identities.

### Root Key Generation
- **Root Secret ($SK_{root}$)**: 256-bit Ed25519 key generated via hardware RNG.
- **Root Certificate ($CERT_{root}$)**: Self-signed certificate containing the Root Public Key.

## 2. Device Enrollment
1.  **Key Generation**: Device generates a long-term identity pair $(SK_{id}, PK_{id})$ within its Hardware Keystore (TEE/SE).
2.  **Signing Request**: Device exports $PK_{id}$ and an Attestation Bolt (proving the key is in hardware).
3.  **Certification**: OPA verifies the attestation and signs $PK_{id}$ to create $CERT_{node}$.
4.  **Distribution**: $CERT_{node}$ and the Root Certificate are transferred back to the device via secure physical media.

## 3. Key Rotation & Revocation

### Session Keys (Ephemeral)
- Established via Noise XX Handshake.
- Ratcheted using HKDF for every message.
- Deleted immediately on session termination or application crash.

### Revocation (CRLs)
- **Compact Revocation Lists**: A bloom filter or bitset of revoked Certificate IDs.
- **Distribution**: Updated CRLs are "gossiped" through the mesh. When a device receives a signed CRL manifest from the OPA (delivered by any field node), it updates its local blacklist.

## 4. Disaster Recovery
- If a device is reported captured, its ID is added to the CRL manifest.
- All nodes in the mesh will refuse handshakes with the revoked device upon receiving the updated CRL.
