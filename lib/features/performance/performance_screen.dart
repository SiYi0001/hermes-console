import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme/hermes_theme.dart';

/// Performance Monitoring Screen
class PerformanceScreen extends ConsumerStatefulWidget {
  const PerformanceScreen({super.key});

  @override
  ConsumerState<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends ConsumerState<PerformanceScreen> {
  Timer? _refreshTimer;
  
  // Simulated metrics
  double _cpuUsage = 0;
  double _memoryUsage = 0;
  double _networkUsage = 0;
  int _activeConnections = 0;
  double _avgLatency = 0;

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
        _cpuUsage = 15 + (DateTime.now().millisecondsSinceEpoch % 30).toDouble();
        _memoryUsage = 45 + (DateTime.now().millisecondsSinceEpoch % 20).toDouble();
        _networkUsage = 2 + (DateTime.now().millisecondsSinceEpoch % 5).toDouble();
        _activeConnections = 3 + (DateTime.now().millisecondsSinceEpoch % 2);
        _avgLatency = 20 + (DateTime.now().millisecondsSinceEpoch % 15).toDouble();
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
            onSelected: (value) {
              if (value == 'export') {
                _exportMetrics();
              } else if (value == 'alerts') {
                _configureAlerts();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 18),
                    SizedBox(width: 8),
                    Text('Export Metrics'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'alerts',
                child: Row(
                  children: [
                    Icon(Icons.notifications, size: 18),
                    SizedBox(width: 8),
                    Text('Configure Alerts'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _OverviewCard(
              cpuUsage: _cpuUsage,
              memoryUsage: _memoryUsage,
              networkUsage: _networkUsage,
              connections: _activeConnections,
              latency: _avgLatency,
            ),
            const SizedBox(height: 24),
            _ResourceCard(
              title: 'CPU Usage',
              value: _cpuUsage,
              maxValue: 100,
              unit: '%',
              color: HermesTheme.primaryBlue,
              icon: Icons.memory,
              history: _generateHistory(30),
            ),
            const SizedBox(height: 16),
            _ResourceCard(
              title: 'Memory Usage',
              value: _memoryUsage,
              maxValue: 100,
              unit: '%',
              color: HermesTheme.successGreen,
              icon: Icons.storage,
              history: _generateHistory(30),
            ),
            const SizedBox(height: 16),
            _ResourceCard(
              title: 'Network Bandwidth',
              value: _networkUsage,
              maxValue: 10,
              unit: 'MB/s',
              color: HermesTheme.warningAmber,
              icon: Icons.network_check,
              history: _generateHistory(30),
            ),
            const SizedBox(height: 24),
            _ConnectionsCard(connections: _activeConnections),
            const SizedBox(height: 24),
            _LatencyCard(latency: _avgLatency),
            const SizedBox(height: 24),
            _SystemInfoCard(),
          ],
        ),
      ),
    );
  }

  List<double> _generateHistory(int count) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return List.generate(count, (i) {
      return 30 + (now % 50) + (i * 0.5);
    });
  }

  void _exportMetrics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting metrics...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _configureAlerts() {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _AlertSettingsSheet(),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final double cpuUsage;
  final double memoryUsage;
  final double networkUsage;
  final int connections;
  final double latency;

  const _OverviewCard({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.networkUsage,
    required this.connections,
    required this.latency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HermesTheme.primaryBlue.withOpacity(0.15),
            HermesTheme.secondaryPurple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: HermesTheme.primaryBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: HermesTheme.primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: HermesTheme.primaryBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Performance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Real-time monitoring',
                      style: TextStyle(
                        fontSize: 13,
                        color: HermesTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: HermesTheme.successGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: HermesTheme.successGreen,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Healthy',
                      style: TextStyle(
                        fontSize: 12,
                        color: HermesTheme.successGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _OverviewStat(
                label: 'CPU',
                value: '${cpuUsage.toStringAsFixed(1)}%',
                color: HermesTheme.primaryBlue,
              ),
              Container(
                width: 1,
                height: 40,
                color: HermesTheme.surfaceOverlay,
              ),
              _OverviewStat(
                label: 'Memory',
                value: '${memoryUsage.toStringAsFixed(1)}%',
                color: HermesTheme.successGreen,
              ),
              Container(
                width: 1,
                height: 40,
                color: HermesTheme.surfaceOverlay,
              ),
              _OverviewStat(
                label: 'Latency',
                value: '${latency.toStringAsFixed(0)}ms',
                color: HermesTheme.warningAmber,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _OverviewStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: HermesTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

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
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    
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
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '${value.toStringAsFixed(1)}$unit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: HermesTheme.surfaceElevated,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: CustomPaint(
              size: const Size(double.infinity, 40),
              painter: _SparklinePainter(
                data: history,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal;

    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.3),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();
    
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - minVal) / range) * size.height;
      
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ConnectionsCard extends StatelessWidget {
  final int connections;

  const _ConnectionsCard({required this.connections});

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
              const Text(
                'Active Connections',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: HermesTheme.primaryBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$connections active',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: HermesTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ConnectionRow(
            name: 'P2P DataChannel',
            type: 'WebRTC',
            status: 'Connected',
            latency: '25ms',
            isActive: true,
          ),
          const SizedBox(height: 8),
          _ConnectionRow(
            name: 'STUN Server',
            type: 'STUN',
            status: 'Active',
            latency: '15ms',
            isActive: true,
          ),
          const SizedBox(height: 8),
          _ConnectionRow(
            name: 'Gateway',
            type: 'HTTPS',
            status: 'Online',
            latency: '45ms',
            isActive: connections > 2,
          ),
        ],
      ),
    );
  }
}

class _ConnectionRow extends StatelessWidget {
  final String name;
  final String type;
  final String status;
  final String latency;
  final bool isActive;

  const _ConnectionRow({
    required this.name,
    required this.type,
    required this.status,
    required this.latency,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? HermesTheme.successGreen : HermesTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 11,
                    color: HermesTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? HermesTheme.successGreen : HermesTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            latency,
            style: const TextStyle(
              fontSize: 12,
              color: HermesTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LatencyCard extends StatelessWidget {
  final double latency;

  const _LatencyCard({required this.latency});

  @override
  Widget build(BuildContext context) {
    Color latencyColor;
    String latencyStatus;
    
    if (latency < 30) {
      latencyColor = HermesTheme.successGreen;
      latencyStatus = 'Excellent';
    } else if (latency < 60) {
      latencyColor = HermesTheme.warningAmber;
      latencyStatus = 'Good';
    } else {
      latencyColor = HermesTheme.errorRed;
      latencyStatus = 'Poor';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: latencyColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.speed,
              color: latencyColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Average Latency',
                  style: TextStyle(
                    fontSize: 14,
                    color: HermesTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${latency.toStringAsFixed(0)} ms',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: latencyColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: latencyColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              latencyStatus,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: latencyColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemInfoCard extends StatelessWidget {
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
          const Text(
            'System Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Platform', value: 'Android 14'),
          const SizedBox(height: 8),
          _InfoRow(label: 'Flutter', value: '3.19.0'),
          const SizedBox(height: 8),
          _InfoRow(label: 'App Version', value: '1.0.0'),
          const SizedBox(height: 8),
          _InfoRow(label: 'Uptime', value: '4h 32m'),
          const SizedBox(height: 8),
          _InfoRow(label: 'Region', value: 'US-West'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: HermesTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Alert Settings Sheet
class _AlertSettingsSheet extends StatefulWidget {
  const _AlertSettingsSheet();

  @override
  State<_AlertSettingsSheet> createState() => _AlertSettingsSheetState();
}

class _AlertSettingsSheetState extends State<_AlertSettingsSheet> {
  bool _cpuAlert = true;
  double _cpuThreshold = 80;
  bool _memoryAlert = true;
  double _memoryThreshold = 90;
  bool _latencyAlert = true;
  double _latencyThreshold = 100;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: HermesTheme.surfaceOverlay,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Performance Alerts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('CPU Alert', style: TextStyle(color: Colors.white)),
              subtitle: Text(
                'Alert when CPU > ${_cpuThreshold.toInt()}%',
                style: const TextStyle(fontSize: 12, color: HermesTheme.textSecondary),
              ),
              value: _cpuAlert,
              onChanged: (value) => setState(() => _cpuAlert = value),
            ),
            if (_cpuAlert)
              Slider(
                value: _cpuThreshold,
                min: 50,
                max: 100,
                divisions: 10,
                label: '${_cpuThreshold.toInt()}%',
                onChanged: (value) => setState(() => _cpuThreshold = value),
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Memory Alert', style: TextStyle(color: Colors.white)),
              subtitle: Text(
                'Alert when Memory > ${_memoryThreshold.toInt()}%',
                style: const TextStyle(fontSize: 12, color: HermesTheme.textSecondary),
              ),
              value: _memoryAlert,
              onChanged: (value) => setState(() => _memoryAlert = value),
            ),
            if (_memoryAlert)
              Slider(
                value: _memoryThreshold,
                min: 50,
                max: 100,
                divisions: 10,
                label: '${_memoryThreshold.toInt()}%',
                onChanged: (value) => setState(() => _memoryThreshold = value),
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Latency Alert', style: TextStyle(color: Colors.white)),
              subtitle: Text(
                'Alert when Latency > ${_latencyThreshold.toInt()}ms',
                style: const TextStyle(fontSize: 12, color: HermesTheme.textSecondary),
              ),
              value: _latencyAlert,
              onChanged: (value) => setState(() => _latencyAlert = value),
            ),
            if (_latencyAlert)
              Slider(
                value: _latencyThreshold,
                min: 50,
                max: 200,
                divisions: 15,
                label: '${_latencyThreshold.toInt()}ms',
                onChanged: (value) => setState(() => _latencyThreshold = value),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
