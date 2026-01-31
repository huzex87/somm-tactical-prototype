import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

enum HandshakeState { idle, initiating, responding, completed, failed }

class HandshakeResult {
  final Uint8List rxKey;
  final Uint8List txKey;
  final Uint8List remoteStaticKey;

  HandshakeResult(this.rxKey, this.txKey, this.remoteStaticKey);
}

class NoiseProtocol {
  final _x25519 = X25519();
  final _chacha = Chacha20.poly1305Aead();
  final _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

  // Noise XX Handshake
  // -> e
  // <- e, ee, s, es
  // -> s, se

  Future<SimpleKeyPair> generateKeyPair() async {
    return await _x25519.newKeyPair();
  }

  Future<Uint8List> encryptMessage(
    Uint8List plaintext,
    Uint8List key,
    Uint8List nonce,
  ) async {
    final secretBox = await _chacha.encrypt(
      plaintext,
      secretKey: SecretKey(key),
      nonce: nonce,
    );
    return Uint8List.fromList(secretBox.concatenation());
  }

  Future<Uint8List> decryptMessage(
    Uint8List ciphertext,
    Uint8List key,
    Uint8List nonce,
  ) async {
    final secretBox = SecretBox.fromConcatenation(
      ciphertext,
      nonceLength: 12,
      macLength: 16,
    );
    final decrypted = await _chacha.decrypt(
      secretBox,
      secretKey: SecretKey(key),
    );
    return Uint8List.fromList(decrypted);
  }

  Future<Uint8List> mixHash(Uint8List h, Uint8List data) async {
    final sink = Sha256().newHashSink();
    sink.add(h);
    sink.add(data);
    sink.close();
    final hash = await sink.hash();
    return Uint8List.fromList(hash.bytes);
  }

  Future<List<Uint8List>> mixKey(Uint8List ck, Uint8List inputKeyMaterial) async {
    final output = await _hkdf.deriveKey(
      secretKey: SecretKey(inputKeyMaterial),
      nonce: ck,
    );
    final bytes = await output.extractBytes();
    // In real Noise, HKDF produces 2 or 3 outputs. Simplified for prototype.
    return [Uint8List.fromList(bytes.sublist(0, 16)), Uint8List.fromList(bytes.sublist(16, 32))];
  }

  // State machine logic would go here in a production system.
  // For this lab prototype, we provide the primitive tools to simulate the steps.
}
