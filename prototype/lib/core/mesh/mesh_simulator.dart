import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:somm_prototype/domain/models/somm_message.dart';

class MeshNode {
  final String id;
  final double x;
  final double y;
  final Set<String> receivedMessages = {};

  MeshNode({required this.id, required this.x, required this.y});
}

class MeshSimulator extends ChangeNotifier {
  final List<MeshNode> nodes = [];
  final List<SommMessage> globalLog = [];
  final double transmissionRange = 300.0;

  bool _gatewayLinkActive = false;
  bool get gatewayLinkActive => _gatewayLinkActive;

  double _burstProgress = 0.0;
  double get burstProgress => _burstProgress;
  bool _isBursting = false;
  bool get isBursting => _isBursting;

  MeshSimulator() {
    _initializeRandomNodes(10);
  }

  void _initializeRandomNodes(int count) {
    final random = Random();
    for (int i = 0; i < count; i++) {
      nodes.add(MeshNode(
        id: 'NODE-${1000 + i}',
        x: random.nextDouble() * 1000,
        y: random.nextDouble() * 1000,
      ));
    }
    notifyListeners();
  }

  void broadcastMessage(SommMessage message) {
    globalLog.insert(0, message);
    _propagate(message, message.senderId);
    notifyListeners();
  }

  void _propagate(SommMessage message, String currentSourceId) {
    if (message.ttl <= 0) return;

    final sourceNode = nodes.firstWhere((n) => n.id == currentSourceId);
    
    for (var neighbor in nodes) {
      if (neighbor.id == currentSourceId) continue;
      
      // Calculate distance
      final distance = sqrt(pow(neighbor.x - sourceNode.x, 2) + pow(neighbor.y - sourceNode.y, 2));
      
      if (distance <= transmissionRange) {
        if (!neighbor.receivedMessages.contains(message.id)) {
          neighbor.receivedMessages.add(message.id);
          
          // Relay with delay to simulate mesh hop
          Future.delayed(Duration(milliseconds: 200 + Random().nextInt(300)), () {
            final relayedMessage = message.copyWith(
              ttl: message.ttl - 1,
              relayHops: [...message.relayHops, neighbor.id],
            );
            _propagate(relayedMessage, neighbor.id);
            notifyListeners(); // Update UI to show "in-flight" mesh status if needed
          });
        }
      }
    }
  }

  /// Triggers a simulated tactical scenario (e.g., node movement, heavy traffic)
  void triggerScenario(String name) {
    print('SOMM: Triggering Scenario: $name');
    final now = DateTime.now();
    
    if (name == 'tactical_movement') {
      broadcastMessage(SommMessage(
        id: 'scenario-${now.millisecondsSinceEpoch}-1',
        senderId: 'HQ-CMD',
        recipientId: 'ALL-UNITS',
        payload: 'TACTICAL ALERT: ALL UNITS MOVE TO GRID-ALPHA',
        timestamp: now,
      ));
      
      // Simulate follow-up responses from different nodes
      Future.delayed(const Duration(seconds: 2), () {
        broadcastMessage(SommMessage(
          id: 'scenario-${now.millisecondsSinceEpoch}-2',
          senderId: 'NODE-1002',
          recipientId: 'HQ-CMD',
          payload: 'NODE-1002: ACKNOWLEDGED. EN ROUTE.',
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  void clearLogs() {
    globalLog.clear();
    for (var node in nodes) {
      node.receivedMessages.clear();
    }
    notifyListeners();
    print('SOMM: All tactical logs purged.');
  }

  void toggleGateway(bool active) {
    _gatewayLinkActive = active;
    notifyListeners();
    print('SOMM: Gateway Link ${active ? 'CONNECTED' : 'DISCONNECTED'}');
  }

  Future<void> simulateBurstData() async {
    if (_isBursting) return;
    _isBursting = true;
    _burstProgress = 0.0;
    notifyListeners();

    print('SOMM: Starting High-Speed Data Burst (Wi-Fi Direct Simulation)');
    
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 300));
      _burstProgress = i / 100.0;
      notifyListeners();
    }

    _isBursting = false;
    broadcastMessage(SommMessage(
      id: 'burst-${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'NG-S-7721',
      recipientId: 'ALL-UNITS',
      payload: 'DATA BURST COMPLETE: Tactical Map Update (v2.4) delivered via Wi-Fi Direct.',
      timestamp: DateTime.now(),
    ));
    print('SOMM: Data Burst Finished.');
  }
}
