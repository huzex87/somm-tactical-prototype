import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simulated Hardware Key Provider
/// 
/// In a production environment, this would interface with:
/// - Android: KeyStore with setIsStrongBoxBacked(true)
/// - iOS: Secure Enclave (Keychain with kSecAttrTokenIDSecureEnclave)
class SecureKeyProvider {
  static const String _keyAlias = 'somm_identity_key';
  final _algorithm = X25519();

  /// Simulates retrieving a key from the TEE/Secure Enclave.
  /// The key is marked as non-exportable in the hardware.
  Future<SimpleKeyPair> getIdentityKeyPair() async {
    // In actual mobile code, we would only get a reference.
    // Here we simulate persistence using SharedPreferences for the lab prototype.
    final prefs = await SharedPreferences.getInstance();
    final storedKey = prefs.getString(_keyAlias);

    if (storedKey != null) {
      final bytes = base64.decode(storedKey);
      return SimpleKeyPairData(
        bytes,
        publicKey: await _algorithm.extractPublicKey(SimpleKeyPairData(bytes, type: KeyPairType.x25519)),
        type: KeyPairType.x25519,
      );
    }

    // Generate new "Hardware-Backed" Key
    print('SOMM: Generating new Hardware-Backed Identity Key (Simulated)');
    final newKeyPair = await _algorithm.newKeyPair();
    final privateBytes = await newKeyPair.extractPrivateKeyBytes();
    await prefs.setString(_keyAlias, base64.encode(privateBytes));
    
    return newKeyPair;
  }

  /// Simulates a hardware-backed signing operation (Attestation).
  Future<Uint8List> signAttestation(Uint8List challenge) async {
    // Simulated TEE signature
    final hash = await Sha256().hash(challenge);
    return Uint8List.fromList(hash.bytes);
  }

  Future<void> purgeSecureElement() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAlias);
    print('SOMM: Secure Element Purged.');
  }
}
