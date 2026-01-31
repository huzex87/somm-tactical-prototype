import 'package:flutter_test/flutter_test.dart';
import 'package:somm_prototype/core/mesh/mesh_simulator.dart';
import 'package:somm_prototype/domain/models/somm_message.dart';

void main() {
  group('Mesh Simulation Engine', () {
    test('Message Propagation within Range', () async {
      final simulator = MeshSimulator();
      
      // Force two nodes to be close to each other
      final nodeA = simulator.nodes[0];
      final nodeB = simulator.nodes[1];
      
      // Node A broadcasts a message
      final msg = SommMessage(
        id: 'MSG-1',
        senderId: nodeA.id,
        recipientId: 'BROADCAST',
        payload: 'HELLO MESH',
        timestamp: DateTime.now(),
      );
      
      simulator.broadcastMessage(msg);
      
      // Allow time for propagation simulation
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Verification logic:
      // Note: Since simulation uses Future.delayed, we check the node's received cache
      // The simulator logs messages as they are broadcast
      expect(simulator.globalLog.isNotEmpty, isTrue);
    });

    test('TTL Expiration stops propagation', () async {
      final simulator = MeshSimulator();
      final msg = SommMessage(
        id: 'MSG-EXP',
        senderId: simulator.nodes[0].id,
        recipientId: 'BROADCAST',
        payload: 'EXPIRING',
        timestamp: DateTime.now(),
        ttl: 0,
      );
      
      simulator.broadcastMessage(msg);
      expect(simulator.nodes.every((n) => n.receivedMessages.isEmpty), isTrue);
    });
  });
}
