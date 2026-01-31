import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:somm_prototype/core/mesh/mesh_simulator.dart';
import 'package:somm_prototype/domain/models/somm_message.dart';

final meshSimulatorProvider = ChangeNotifierProvider((ref) => MeshSimulator());

final meshMessagesProvider = Provider((ref) {
  final simulator = ref.watch(meshSimulatorProvider);
  return List<SommMessage>.from(simulator.globalLog);
});

final meshPeersProvider = Provider((ref) {
  final simulator = ref.watch(meshSimulatorProvider);
  return simulator.nodes;
});
