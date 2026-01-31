import 'dart:convert';
import 'dart:io';
import 'package:cryptography/cryptography.dart';

Future<void> main() async {
  final algorithm = X25519();
  final chacha = Chacha20.poly1305Aead();
  
  // Initiator Data
  final iStatic = await algorithm.newKeyPairFromSeed(List.filled(32, 1));
  final iEphemeral = await algorithm.newKeyPairFromSeed(List.filled(32, 2));
  
  // Responder Data
  final rStatic = await algorithm.newKeyPairFromSeed(List.filled(32, 3));
  final rEphemeral = await algorithm.newKeyPairFromSeed(List.filled(32, 4));

  final vectors = {
    'protocol': 'Noise_XX_25519_ChaChaPoly_SHA256',
    'initiator': {
      'static_pub': base64.encode((await iStatic.extractPublicKey()).bytes),
      'ephemeral_pub': base64.encode((await iEphemeral.extractPublicKey()).bytes),
    },
    'responder': {
      'static_pub': base64.encode((await rStatic.extractPublicKey()).bytes),
      'ephemeral_pub': base64.encode((await rEphemeral.extractPublicKey()).bytes),
    },
    'test_message': {
      'plaintext': 'SECURE TACTICAL BROADCAST',
      'key': base64.encode(List.filled(32, 9)),
      'nonce': base64.encode(List.filled(12, 0)),
    }
  };

  final file = File('audit_package/vectors/test_vectors.json');
  await file.writeAsString(json.encode(vectors));
  print('Audit vectors generated.');
}
