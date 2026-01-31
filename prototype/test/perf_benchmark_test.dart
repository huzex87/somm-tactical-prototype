import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:somm_prototype/core/mesh/mesh_simulator.dart';
import 'package:somm_prototype/domain/models/somm_message.dart';

void main() {
  group('Performance Benchmarks', () {
    test('Message Delivery Latency (Simulated)', () async {
      final simulator = MeshSimulator();
      final startTime = DateTime.now();
      
      final msg = SommMessage(
        id: 'BENCH-1',
        senderId: simulator.nodes[0].id,
        recipientId: 'BROADCAST',
        payload: 'BENCHMARK',
        timestamp: startTime,
      );
      
      simulator.broadcastMessage(msg);
      
      // Wait for propagation to reaching at least 5 nodes
      int reachedNodes = 0;
      int attempts = 0;
      while (reachedNodes < 5 && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        reachedNodes = simulator.nodes.where((n) => n.receivedMessages.contains(msg.id)).length;
        attempts++;
      }
      
      final endTime = DateTime.now();
      final latency = endTime.difference(startTime).inMilliseconds;
      
      print('--- PERF BENCHMARK ---');
      print('Reached $reachedNodes nodes in ${latency}ms');
      print('Avg Mesh Hop Delay: ${latency / max(1, reachedNodes)}ms');
      print('--- END BENCHMARK ---');
      
      expect(reachedNodes, greaterThanOrEqualTo(1));
    });
  });
}
