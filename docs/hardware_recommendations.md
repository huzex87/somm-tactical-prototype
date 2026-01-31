# SOMM Hardware Recommendations

To support the security requirements of SOMM (Hardware Keystore, Attestation, and TEE), the following device profiles are recommended for Nigerian security forces.

## 1. Android Devices (StrongBox Support)
Devices must support **Android StrongBox Keymaster** to ensure keys are stored in dedicated hardware (Secure Element).

| Model | OS Version | Security Features |
| :--- | :--- | :--- |
| **Google Pixel 6/7/8** | Android 12+ | Titan M2 Security Chip, StrongBox, Remote Attestation. |
| **Samsung Galaxy S22+ (Enterprise)** | Android 12+ | Knox Vault, EAL5+ Secure Element. |
| **Nokia XR21 (Rugged)** | Android 13+ | Trusted Execution Environment (TEE), hardened for field use. |

## 2. iOS Devices (Secure Enclave)
All modern iPhones support the **Secure Enclave Processor (SEP)**.

| Model | Security Features | Note |
| :--- | :--- | :--- |
| **iPhone 13 / 14 / 15** | Secure Enclave, FaceID/TouchID backing for keys. | High security, but restricted ecosystem. |

## 3. Peripheral Hardware (Gatways/Relays)
For static relay nodes or gateways to satellite/VHF:

- **Raspberry Pi 4/5 + OPTIGA™ Trust M**: Adds a hardware security module (HSM) to the Pi.
- **nRF52840 Dongle**: For low-power dedicated BLE mesh relaying.

## 4. Minimum Requirements Summary
- **Primary Transport**: BLE 5.0+ (Long Range support preferred).
- **Security**: Hardware-backed Keystore with support for non-exportable keys.
- **Biometrics**: Mandatory for local device unlock and key usage authorization.
- **Durability**: IP68 and MIL-STD-810H recommended for forest environments.
