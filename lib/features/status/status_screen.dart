import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/p2p_data_channel.dart';
import '../../shared/theme/hermes_theme.dart';

class StatusScreen extends ConsumerStatefulWidget {
  const StatusScreen({super.key});

  @override
  ConsumerState<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends ConsumerState<StatusScreen> {
  int _bytesSent = 0;
  int _bytesReceived = 0;
  double _latency = 0;
  int _packetLoss = 0;
  Timer? _statsTimer;

  @override
  void initState() {
    super.initState();
    _startStatsSimulation();
  }

  @override
  void dispose() {
    _statsTimer?.cancel();
    super.dispose();
  }

  void _startStatsSimulation() {
    _statsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _bytesSent += (100 + (DateTime.now().millisecondsSinceEpoch % 500));
        _bytesReceived += (200 + (DateTime.now().millisecondsSinceEpoch % 800));
        _latency = 15 + (DateTime.now().millisecondsSinceEpoch % 30).toDouble();
        _packetLoss = (DateTime.now().millisecondsSinceEpoch % 3);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStateProvider);

    return Scaffold(
      backgroundColor: HermesTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: HermesTheme.backgroundBlack,
        title: const Text('Status'),
        actions: [
          IconButton(
            onPressed: _refreshStats,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection Overview Card
            _ConnectionOverviewCard(state: connectionState),
            const SizedBox(height: 16),

            // Real-time Stats
            const Text(
              'Network Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.upload_rounded,
                    label: 'Sent',
                    value: _formatBytes(_bytesSent),
                    color: HermesTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.download_rounded,
                    label: 'Received',
                    value: _formatBytes(_bytesReceived),
                    color: HermesTheme.successGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.speed_rounded,
                    label: 'Latency',
                    value: '${_latency.toStringAsFixed(1)}ms',
                    color: HermesTheme.warningAmber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.warning_amber_rounded,
                    label: 'Packet Loss',
                    value: '${_packetLoss}%',
                    color: _packetLoss > 1 ? HermesTheme.errorRed : HermesTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Security Info
            const Text(
              'Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _SecurityInfoCard(),
            const SizedBox(height: 24),

            // ICE Candidates Info
            const Text(
              'ICE Candidates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _IceCandidatesCard(),
            const SizedBox(height: 24),

            // Activity Log
            const Text(
              'Activity Log',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _ActivityLogCard(),
          ],
        ),
      ),
    );
  }

  void _refreshStats() {
    setState(() {
      _bytesSent = 0;
      _bytesReceived = 0;
    });
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class _ConnectionOverviewCard extends StatelessWidget {
  final ConnectionState state;

  const _ConnectionOverviewCard({required this.state});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (state) {
      case ConnectionState.connected:
      case ConnectionState.authenticated:
        statusColor = HermesTheme.successGreen;
        statusText = 'Active';
        statusIcon = Icons.check_circle_rounded;
        break;
      case ConnectionState.connecting:
        statusColor = HermesTheme.warningAmber;
        statusText = 'Connecting';
        statusIcon = Icons.sync_rounded;
        break;
      case ConnectionState.error:
        statusColor = HermesTheme.errorRed;
        statusText = 'Failed';
        statusIcon = Icons.error_rounded;
        break;
      default:
        statusColor = HermesTheme.textSecondary;
        statusText = 'Disconnected';
        statusIcon = Icons.link_off_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withOpacity(0.15),
            statusColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state == ConnectionState.connected
                          ? 'Peer: hermes-agent-001'
                          : 'No active connection',
                      style: const TextStyle(
                        fontSize: 13,
                        color: HermesTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (state == ConnectionState.connected ||
              state == ConnectionState.authenticated) ...[
            const SizedBox(height: 20),
            const Divider(color: HermesTheme.surfaceOverlay),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniStat(label: 'Session ID', value: 'hcs-7f8a2b'),
                _MiniStat(label: 'Uptime', value: '2h 34m'),
                _MiniStat(label: 'Protocol', value: 'v1.0'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: HermesTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: HermesTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _SecurityRow(
            icon: Icons.lock_rounded,
            label: 'Encryption',
            value: 'AES-256-GCM',
            enabled: true,
          ),
          const Divider(color: HermesTheme.surfaceOverlay, height: 24),
          _SecurityRow(
            icon: Icons.key_rounded,
            label: 'Key Exchange',
            value: 'Curve25519',
            enabled: true,
          ),
          const Divider(color: HermesTheme.surfaceOverlay, height: 24),
          _SecurityRow(
            icon: Icons.compress_rounded,
            label: 'Compression',
            value: 'Zstandard',
            enabled: true,
          ),
          const Divider(color: HermesTheme.surfaceOverlay, height: 24),
          _SecurityRow(
            icon: Icons.verified_user_rounded,
            label: 'Message Auth',
            value: 'Poly1305 MAC',
            enabled: true,
          ),
          const Divider(color: HermesTheme.surfaceOverlay, height: 24),
          _SecurityRow(
            icon: Icons.sync_alt_rounded,
            label: 'Transport',
            value: 'WebRTC DTLS',
            enabled: true,
          ),
        ],
      ),
    );
  }
}

class _SecurityRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool enabled;

  const _SecurityRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: enabled ? HermesTheme.successGreen : HermesTheme.textSecondary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: HermesTheme.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: enabled ? Colors.white : HermesTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          enabled ? Icons.check_circle : Icons.cancel,
          color: enabled ? HermesTheme.successGreen : HermesTheme.errorRed,
          size: 18,
        ),
      ],
    );
  }
}

class _IceCandidatesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _IceCandidateRow(
            type: 'srflx',
            detail: '203.0.113.1:54321',
            status: 'Active',
          ),
          const SizedBox(height: 12),
          _IceCandidateRow(
            type: 'host',
            detail: '192.168.1.100:45678',
            status: 'Active',
          ),
          const SizedBox(height: 12),
          _IceCandidateRow(
            type: 'relay',
            detail: 'turn.example.com:3478',
            status: 'Active',
          ),
        ],
      ),
    );
  }
}

class _IceCandidateRow extends StatelessWidget {
  final String type;
  final String detail;
  final String status;

  const _IceCandidateRow({
    required this.type,
    required this.detail,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color typeColor;
    switch (type) {
      case 'host':
        typeColor = HermesTheme.primaryBlue;
        break;
      case 'srflx':
        typeColor = HermesTheme.successGreen;
        break;
      case 'relay':
        typeColor = HermesTheme.warningAmber;
        break;
      default:
        typeColor = HermesTheme.textSecondary;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            type.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: typeColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            detail,
            style: HermesTheme.codeStyle.copyWith(fontSize: 12),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: HermesTheme.successGreen.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: HermesTheme.successGreen,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityLogCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _LogEntry(
            time: '14:32:01',
            event: 'Connection established',
            type: LogType.success,
          ),
          const SizedBox(height: 8),
          _LogEntry(
            time: '14:32:00',
            event: 'ICE gathering complete',
            type: LogType.info,
          ),
          const SizedBox(height: 8),
          _LogEntry(
            time: '14:31:58',
            event: 'Authentication successful',
            type: LogType.success,
          ),
          const SizedBox(height: 8),
          _LogEntry(
            time: '14:31:55',
            event: 'Key exchange completed',
            type: LogType.info,
          ),
          const SizedBox(height: 8),
          _LogEntry(
            time: '14:31:50',
            event: 'DTLS handshake complete',
            type: LogType.info,
          ),
        ],
      ),
    );
  }
}

class _LogEntry extends StatelessWidget {
  final String time;
  final String event;
  final LogType type;

  const _LogEntry({
    required this.time,
    required this.event,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (type) {
      case LogType.success:
        color = HermesTheme.successGreen;
        icon = Icons.check_circle_outline;
        break;
      case LogType.warning:
        color = HermesTheme.warningAmber;
        icon = Icons.warning_amber_outlined;
        break;
      case LogType.error:
        color = HermesTheme.errorRed;
        icon = Icons.error_outline;
        break;
      case LogType.info:
      default:
        color = HermesTheme.accentCyan;
        icon = Icons.info_outline;
    }

    return Row(
      children: [
        Text(
          time,
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'JetBrainsMono',
            color: HermesTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            event,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

enum LogType { info, success, warning, error }
