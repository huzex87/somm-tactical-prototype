import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:somm_prototype/core/crypto/noise_protocol.dart';

void main() {
  final noise = NoiseProtocol();

  group('Cryptographic Primitives', () {
    test('ChaCha20-Poly1305 Roundtrip', () async {
      final key = Uint8List(32); // All zeros for testing
      final nonce = Uint8List(12);
      final plaintext = Uint8List.fromList('SECRET MESSAGE'.codeUnits);

      final ciphertext = await noise.encryptMessage(plaintext, key, nonce);
      expect(ciphertext, isNot(equals(plaintext)));

      final decrypted = await noise.decryptMessage(ciphertext, key, nonce);
      expect(String.fromCharCodes(decrypted), equals('SECRET MESSAGE'));
    });

    test('HKDF Key Derivation', () async {
      final ikm = Uint8List.fromList([1, 2, 3]);
      final salt = Uint8List.fromList([4, 5, 6]);

      final key1 = await noise.deriveKey(ikm, salt);
      final key2 = await noise.deriveKey(ikm, salt);

      expect(key1, equals(key2));
      expect(key1.length, equals(32));
    });
  });

  group('Handshake Scenarios', () {
    test('Noise XX Static Key Generation', () async {
      final keyPair = await noise.generateKeyPair();
      final privateKey = await keyPair.extractPrivateKeyBytes();
      final publicKey = (await keyPair.extractPublicKey()).bytes;

      expect(privateKey.length, equals(32));
      expect(publicKey.length, equals(32));
    });
  });
}
