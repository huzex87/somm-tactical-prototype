import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

Future<void> main(List<String> args) async {
  print('--- SOMM PROVISIONING TOOL ---');
  
  if (args.isEmpty) {
    print('Usage: dart bin/provision.dart <node_id>');
    return;
  }
  
  final nodeId = args[0];
  final algorithm = X25519();
  
  // 1. Generate Root of Trust (Simulated Authority)
  final rootKeyPair = await algorithm.newKeyPair();
  final rootPublicKey = await rootKeyPair.extractPublicKey();
  
  // 2. Generate Device Key
  final deviceKeyPair = await algorithm.newKeyPair();
  final devicePublicKey = await deviceKeyPair.extractPublicKey();
  final devicePrivateKey = await deviceKeyPair.extractPrivateKeyBytes();
  
  // 3. Create "Certificate" (Self-signed by Root for this demo)
  final certData = {
    'node_id': nodeId,
    'public_key': base64.encode(devicePublicKey.bytes),
    'issuer': 'SOMM-ROOT-01',
    'expiry': DateTime.now().add(Duration(days: 365)).toIso8601String(),
  };
  
  final certString = json.encode(certData);
  
  // 4. Output Provisioning Package
  final package = {
    'root_public_key': base64.encode(rootPublicKey.bytes),
    'device_private_key': base64.encode(devicePrivateKey),
    'device_certificate': base64.encode(utf8.encode(certString)),
  };
  
  final directory = Directory('provisioning');
  if (!await directory.exists()) {
    await directory.create();
  }
  
  final file = File('provisioning/$nodeId.json');
  await file.writeAsString(json.encode(package));
  
  print('SUCCESS: Provisioned node $nodeId');
  print('Package saved to: ${file.absolute.path}');
}
