import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme/hermes_theme.dart';
import '../../core/network/p2p_data_channel.dart';

/// Performance Monitoring Screen.
/// - System resource gauges (CPU/Memory/Network) use simulated real-time data
///   because full platform channel access requires native bindings.
/// - P2P connection metrics are fully bound to connectionMetricsProvider.
class PerformanceScreen extends ConsumerStatefulWidget {
  const PerformanceScreen({super.key});

  @override
  ConsumerState<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends ConsumerState<PerformanceScreen> {
  Timer? _refreshTimer;

  // Simulated system resource metrics (require native platform channels to be real)
  double _cpuUsage = 0;
  double _memoryUsage = 0;
  double _networkUsage = 0;

  // Ring-buffer history (last 60 samples)
  final List<double> _cpuHistory = [];
  final List<double> _memoryHistory = [];
  final List<double> _networkHistory = [];

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startMonitoring() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        final seed = DateTime.now().millisecondsSinceEpoch;
        _cpuUsage = (15 + (seed % 30)).toDouble();
        _memoryUsage = (45 + (seed % 20)).toDouble();
        _networkUsage = (2 + (seed % 5)).toDouble();

        _cpuHistory.add(_cpuUsage);
        if (_cpuHistory.length > 60) _cpuHistory.removeAt(0);
        _memoryHistory.add(_memoryUsage);
        if (_memoryHistory.length > 60) _memoryHistory.removeAt(0);
        _networkHistory.add(_networkUsage);
        if (_networkHistory.length > 60) _networkHistory.removeAt(0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HermesTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: HermesTheme.backgroundBlack,
        title: const Text('Performance'),
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: HermesTheme.surfaceElevated,
            onSelected: (v) {
              if (v == 'export') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting metrics…'), behavior: SnackBarBehavior.floating),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'export', child: Row(children: [Icon(Icons.download, size: 18), SizedBox(width: 8), Text('Export Metrics')])),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(title: 'P2P Connection', icon: Icons.hub),
            const SizedBox(height: 12),
            _P2POverviewCard(),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'System Resources', icon: Icons.memory),
            const SizedBox(height: 12),
            _ResourceCard(
              title: 'CPU Usage',
              value: _cpuUsage,
              maxValue: 100,
              unit: '%',
              color: HermesTheme.primaryBlue,
              icon: Icons.developer_board,
              history: List.from(_cpuHistory),
            ),
            const SizedBox(height: 16),
            _ResourceCard(
              title: 'Memory Usage',
              value: _memoryUsage,
              maxValue: 100,
              unit: '%',
              color: HermesTheme.successGreen,
              icon: Icons.storage,
              history: List.from(_memoryHistory),
            ),
            const SizedBox(height: 16),
            _ResourceCard(
              title: 'Network Bandwidth',
              value: _networkUsage,
              maxValue: 10,
              unit: 'MB/s',
              color: HermesTheme.warningAmber,
              icon: Icons.network_check,
              history: List.from(_networkHistory),
            ),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Data Transfer', icon: Icons.swap_vert),
            const SizedBox(height: 12),
            _DataTransferCard(),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Recent Activity', icon: Icons.history),
            const SizedBox(height: 12),
            _ActivityCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: HermesTheme.textSecondary, size: 18),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: HermesTheme.textSecondary)),
      ],
    );
  }
}

// ─── P2P Overview Card (Real) ────────────────────────────────────────────────

class _P2POverviewCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = ref.watch(connectionMetricsProvider);
    final connected = m.peerId != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HermesTheme.primaryBlue.withOpacity(0.12), HermesTheme.secondaryPurple.withOpacity(0.08)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HermesTheme.primaryBlue.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: connected ? HermesTheme.successGreen : HermesTheme.errorRed,
                ),
              ),
              const SizedBox(width: 8),
              Text(connected ? 'Connected' : 'Disconnected', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: connected ? HermesTheme.successGreen : HermesTheme.errorRed)),
              const Spacer(),
              Text('Session ${m.sessionId}', style: const TextStyle(fontSize: 11, color: HermesTheme.textTertiary)),
            ],
          ),
          if (connected) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _MiniMetric(label: 'Peer', value: m.peerName ?? m.peerId ?? '—', color: Colors.white)),
                Expanded(child: _MiniMetric(label: 'Latency', value: '${m.latencyMs}ms', color: _latencyColor(m.latencyMs))),
                Expanded(child: _MiniMetric(label: 'Pkt Loss', value: '${m.packetLossPct}%', color: _pktLossColor(m.packetLossPct))),
                Expanded(child: _MiniMetric(label: 'Uptime', value: _formatUptime(m.uptime), color: HermesTheme.successGreen)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _latencyColor(int ms) {
    if (ms < 50) return HermesTheme.successGreen;
    if (ms < 150) return HermesTheme.warningAmber;
    return HermesTheme.errorRed;
  }

  Color _pktLossColor(int pct) {
    if (pct < 1) return HermesTheme.successGreen;
    if (pct < 5) return HermesTheme.warningAmber;
    return HermesTheme.errorRed;
  }

  String _formatUptime(Duration? d) {
    if (d == null) return '—';
    if (d.inDays > 0) return '${d.inDays}d ${d.inHours.remainder(24)}h';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniMetric({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: HermesTheme.textSecondary)),
      ],
    );
  }
}

// ─── Data Transfer Card (Real) ─────────────────────────────────────────────────

class _DataTransferCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = ref.watch(connectionMetricsProvider);

    return _Card(
      title: 'Data Transfer',
      icon: Icons.swap_vert,
      child: Column(
        children: [
          _DataRow(label: 'Bytes Sent', value: _formatBytes(m.bytesSent), icon: Icons.upload, color: HermesTheme.primaryBlue),
          const SizedBox(height: 12),
          _DataRow(label: 'Bytes Received', value: _formatBytes(m.bytesReceived), icon: Icons.download, color: HermesTheme.successGreen),
          const SizedBox(height: 12),
          _DataRow(label: 'Total', value: _formatBytes(m.bytesSent + m.bytesReceived), icon: Icons.sync_alt, color: HermesTheme.secondaryPurple),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DataRow({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(color: HermesTheme.textSecondary, fontSize: 13))),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}

// ─── Activity Card (Real) ─────────────────────────────────────────────────────

class _ActivityCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(activityLogProvider);
    final recent = logs.take(10).toList();

    return _Card(
      title: 'Recent Activity',
      icon: Icons.history,
      child: recent.isEmpty
          ? const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('No recent activity', style: TextStyle(color: HermesTheme.textSecondary, fontSize: 13)))
          : Column(children: recent.map((log) => _ActivityRow(log: log)).toList()),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final ActivityLogEntry log;

  const _ActivityRow({required this.log});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(_levelIcon(log.level), size: 14, color: _levelColor(log.level)),
          const SizedBox(width: 8),
          Expanded(child: Text(log.event, style: const TextStyle(color: HermesTheme.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Text(_formatTime(log.time), style: const TextStyle(color: HermesTheme.textTertiary, fontSize: 11)),
        ],
      ),
    );
  }

  IconData _levelIcon(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.error: return Icons.error;
      case ActivityLevel.warning: return Icons.warning;
      case ActivityLevel.success: return Icons.check_circle;
      case ActivityLevel.info: return Icons.info;
    }
  }

  Color _levelColor(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.error: return HermesTheme.errorRed;
      case ActivityLevel.warning: return HermesTheme.warningAmber;
      case ActivityLevel.success: return HermesTheme.successGreen;
      case ActivityLevel.info: return HermesTheme.primaryBlue;
    }
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ─── Shared Card ──────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _Card({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HermesTheme.surfaceOverlay),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: HermesTheme.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ─── Resource Card (Simulated) ────────────────────────────────────────────────

class _ResourceCard extends StatelessWidget {
  final String title;
  final double value;
  final double maxValue;
  final String unit;
  final Color color;
  final IconData icon;
  final List<double> history;

  const _ResourceCard({
    required this.title,
    required this.value,
    required this.maxValue,
    required this.unit,
    required this.color,
    required this.icon,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (value / maxValue).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HermesTheme.surfaceOverlay),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              const Spacer(),
              Text('${value.toStringAsFixed(1)} $unit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: pct, backgroundColor: HermesTheme.surfaceOverlay, color: color, minHeight: 8),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: history.length < 2 ? const SizedBox.shrink() : CustomPaint(size: Size.infinite, painter: _SparklinePainter(history: history, color: color)),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> history;
  final Color color;

  _SparklinePainter({required this.history, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final maxVal = history.reduce((a, b) => a > b ? a : b);
    final minVal = history.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal;

    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < history.length; i++) {
      final x = (i / (history.length - 1)) * size.width;
      final y = range > 0 ? size.height - ((history[i] - minVal) / range * size.height) : size.height / 2;
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) => old.history != history;
}
