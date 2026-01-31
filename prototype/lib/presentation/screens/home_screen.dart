import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:somm_prototype/core/mesh/mesh_provider.dart';
import 'package:somm_prototype/core/mesh/mesh_simulator.dart';
import 'package:somm_prototype/domain/models/somm_message.dart';
import 'package:somm_prototype/presentation/theme/somm_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(meshMessagesProvider);
    final peers = ref.watch(meshPeersProvider);
    final simulator = ref.watch(meshSimulatorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOMM TACTICAL'),
        actions: [
          IconButton(
            onPressed: () {
              _showTacticalNotice(context);
            },
            icon: const Icon(Icons.security_rounded, color: SommTheme.primaryColor),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusBanner(simulator),
          if (simulator.isBursting)
            LinearProgressIndicator(
              value: simulator.burstProgress,
              backgroundColor: Colors.white10,
              color: SommTheme.primaryColor,
              minHeight: 2,
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  _buildTacticalHub(context, simulator, peers.length),
                  const SizedBox(height: 40),
                  _buildQuickActions(context, simulator),
                  const SizedBox(height: 40),
                  _buildRecentActivityTicker(messages),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildTacticalOverlay(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, simulator),
    );
  }

  Widget _buildTacticalHub(BuildContext context, MeshSimulator simulator, int peerCount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SommTheme.surfaceColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white10, width: 1),
        boxShadow: [
          BoxShadow(
            color: SommTheme.primaryColor.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'TACTICAL HUB',
            style: TextStyle(
              letterSpacing: 4,
              fontSize: 14,
              color: Colors.white38,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHubStat('PEERS', peerCount.toString(), Icons.wifi_tethering),
              const SizedBox(width: 40),
              _buildHubStat('LATENCY', '42ms', Icons.timer_outlined),
            ],
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _runSystemCheck(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.05),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user, size: 18, color: SommTheme.primaryColor),
                SizedBox(width: 12),
                Text('SYSTEM INTEGRITY: OPTIMAL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHubStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: SommTheme.primaryColor, size: 28),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -1)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, MeshSimulator simulator) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'QUICK CHAT',
            Icons.bolt,
            SommTheme.primaryColor,
            () {
              simulator.broadcastMessage(SommMessage(
                id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
                senderId: 'NG-S-7721',
                recipientId: 'BROADCAST',
                payload: 'STATUS REPORT: ALL CLEAR',
                timestamp: DateTime.now(),
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Status Broadcast Sent'), behavior: SnackBarBehavior.floating),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            'DATA BURST',
            Icons.speed,
            SommTheme.accentColor,
            () => simulator.simulateBurstData(),
            isLoading: simulator.isBursting,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap, {bool isLoading = false}) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3), width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              if (isLoading)
                const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              else
                Icon(icon, color: color, size: 30),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityTicker(List<SommMessage> messages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RECENT ACTIVITY',
          style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.white24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (messages.isEmpty)
          const Text('LISTENING FOR BROADCASTS...', style: TextStyle(color: Colors.white10, fontSize: 12))
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.radio, color: SommTheme.primaryColor, size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    messages.first.payload,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ),
                Text(
                  '${messages.first.timestamp.hour}:${messages.first.timestamp.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 10, color: Colors.white24),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showTacticalNotice(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SommTheme.surfaceColor,
        title: const Text('SECURITY STATUS'),
        content: const Text('All cryptographic modules are operational. Noise XX Handshake active. 256-bit ephemeral keys in use.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ACKNOWLEDGE'),
          ),
        ],
      ),
    );
  }

  void _runSystemCheck(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Integrity Check: PASS | Crypto: PASS | Battery: 88%'),
        duration: Duration(seconds: 2),
        backgroundColor: SommTheme.accentColor,
      ),
    );
  }

  Widget _buildStatusBanner(MeshSimulator simulator) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusIndicator('MESH', true),
          _buildStatusIndicator('BLE', true),
          _buildStatusIndicator('GATEWAY', simulator.gatewayLinkActive),
          _buildStatusIndicator('KEYS', true),
          _buildStatusIndicator('GPS', false),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String label, bool active) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? SommTheme.primaryColor : SommTheme.errorColor,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSystemCard(BuildContext context, int peerCount) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dns_rounded, color: SommTheme.accentColor),
                const SizedBox(width: 8),
                Text(
                  'NODE ID: NG-S-7721',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PEERS', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    Text('$peerCount Active', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LATENCY', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    Text('42ms', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BATTERY', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    Text('88%', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(String sender, String text, String time, bool isUrgent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: isUrgent ? SommTheme.errorColor.withAlpha(51) : SommTheme.surfaceColor,
            child: Text(sender[0], style: TextStyle(color: isUrgent ? SommTheme.errorColor : Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(sender, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(time, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(text, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTacticalOverlay() {
    return Container(
      height: 120,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SommTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SommTheme.primaryColor.withAlpha(76)),
      ),
      child: Stack(
        children: [
          const Center(
            child: Opacity(
              opacity: 0.1,
              child: Icon(Icons.radar, size: 80, color: SommTheme.primaryColor),
            ),
          ),
          Center(
            child: Text(
              'SCANNING MESH...',
              style: TextStyle(
                color: SommTheme.primaryColor.withAlpha(153),
                fontSize: 10,
                letterSpacing: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, MeshSimulator simulator) {
    return BottomAppBar(
      color: SommTheme.surfaceColor,
      height: 70,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {
              _showCommsLog(context, simulator.globalLog);
            },
            icon: const Icon(Icons.chat_bubble_outline),
          ),
          IconButton(
            onPressed: () {
              _showPeersList(context, simulator.nodes);
            },
            icon: const Icon(Icons.people_outline),
          ),
          FloatingActionButton.small(
            onPressed: () {
              print('SOMM: Broadcasting Test Message');
              simulator.broadcastMessage(SommMessage(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                senderId: 'NG-S-7721',
                recipientId: 'BROADCAST',
                payload: 'TEST BROADCAST: ALL UNITS REPORT STATUS',
                timestamp: DateTime.now(),
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tactical Broadcast Sent'),
                  backgroundColor: SommTheme.primaryColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            backgroundColor: SommTheme.primaryColor,
            child: const Icon(Icons.bolt, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              _showMap(context);
            },
            icon: const Icon(Icons.map_outlined),
          ),
          IconButton(
            onPressed: () {
              _showSettings(context, simulator);
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
    );
  }

  void _showCommsLog(BuildContext context, List<SommMessage> logs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SommTheme.surfaceColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('TACTICAL COMMS LOG', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(logs[index].senderId, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(logs[index].payload),
                  trailing: Text('${logs[index].timestamp.hour}:${logs[index].timestamp.minute}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPeersList(BuildContext context, List<MeshNode> nodes) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SommTheme.surfaceColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('ACTIVE MESH NODES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: nodes.length,
                itemBuilder: (context, index) => ListTile(
                  leading: const Icon(Icons.radio_button_checked, color: SommTheme.primaryColor),
                  title: Text(nodes[index].id),
                  subtitle: const Text('CONNECTED | NOISE-XX'),
                  trailing: const Text('42ms'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SommTheme.surfaceColor,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('REGION MAP (OFFLINE)', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 100, color: Colors.white24),
                    Text('Topo Map Loaded (NG-NE-04)', style: TextStyle(color: Colors.white24)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context, MeshSimulator simulator) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SommTheme.surfaceColor,
      builder: (context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('SYSTEM SETTINGS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.key),
            title: const Text('Simulate Hardware Key Attestation'),
            subtitle: const Text('Verify TEE/Secure Enclave Status'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hardware Key Valid: IS_STRONG_BOX_BACKED = TRUE')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.emergency_share),
            title: const Text('Simulate Tactical Movement'),
            subtitle: const Text('Simulate Multi-Node Radio Traffic'),
            onTap: () {
              Navigator.pop(context);
              simulator.triggerScenario('tactical_movement');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_input_antenna),
            title: const Text('Toggle Shadow Gateway'),
            subtitle: const Text('Long-Range VHF/UHF Link'),
            trailing: Switch(
              value: simulator.gatewayLinkActive,
              onChanged: (val) {
                simulator.toggleGateway(val);
                Navigator.pop(context);
              },
              activeColor: SommTheme.primaryColor,
            ),
            onTap: () {
              simulator.toggleGateway(!simulator.gatewayLinkActive);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.wifi_tethering),
            title: const Text('Mesh Power Level'),
            trailing: const Text('High'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: SommTheme.errorColor),
            title: const Text('PURGE ALL DATA', style: TextStyle(color: SommTheme.errorColor)),
            subtitle: const Text('Wipe all messages and session keys'),
            onTap: () {
              Navigator.pop(context);
              simulator.clearLogs();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ALL TACTICAL DATA PURGED'),
                  backgroundColor: SommTheme.errorColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
