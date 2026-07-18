import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme/hermes_theme.dart';

/// Logs Viewer Screen
class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key});

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  String _selectedLevel = 'all';
  String _searchQuery = '';
  bool _autoScroll = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HermesTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: HermesTheme.backgroundBlack,
        title: const Text('Logs & Audit'),
        actions: [
          IconButton(
            onPressed: _exportLogs,
            icon: const Icon(Icons.download),
            tooltip: 'Export Logs',
          ),
          IconButton(
            onPressed: _clearLogs,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Logs',
          ),
        ],
      ),
      body: Column(
        children: [
          _LogsHeader(
            selectedLevel: _selectedLevel,
            onLevelChanged: (level) => setState(() => _selectedLevel = level),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search logs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: HermesTheme.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 50,
              itemBuilder: (context, index) {
                return _LogEntry(
                  log: _LogItem(
                    timestamp: DateTime.now().subtract(Duration(minutes: index * 3)),
                    level: _getRandomLevel(index),
                    source: _getRandomSource(index),
                    message: _getRandomMessage(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _exportLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting logs...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HermesTheme.surfaceDark,
        title: const Text('Clear Logs'),
        content: const Text('Are you sure you want to clear all logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logs cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: HermesTheme.errorRed),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  String _getRandomLevel(int index) {
    final levels = ['INFO', 'DEBUG', 'WARN', 'ERROR'];
    return levels[index % levels.length];
  }

  String _getRandomSource(int index) {
    final sources = ['hermes-core', 'p2p-network', 'crypto-service', 'storage', 'gateway'];
    return sources[index % sources.length];
  }

  String _getRandomMessage(int index) {
    final messages = [
      'Connection established with peer node-001',
      'Encrypted message sent successfully (256 bytes)',
      'Heartbeat received from gateway',
      'File transferred: document.pdf (1.2 MB)',
      'Authentication successful for user admin',
      'Memory sync completed: 15 items updated',
      'Skill "code-review" executed in 1.2s',
      'MCP tool "read_file" called for lib/main.dart',
      'Cron task "daily-report" triggered',
      'Compression ratio: 68% (100KB -> 32KB)',
    ];
    return messages[index % messages.length];
  }
}

class _LogsHeader extends StatelessWidget {
  final String selectedLevel;
  final ValueChanged<String> onLevelChanged;

  const _LogsHeader({
    required this.selectedLevel,
    required this.onLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: HermesTheme.primaryBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.article,
                  color: HermesTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'System Logs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Real-time audit trail',
                      style: TextStyle(
                        fontSize: 13,
                        color: HermesTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Text(
                    'Auto-scroll',
                    style: TextStyle(
                      fontSize: 12,
                      color: HermesTheme.textSecondary,
                    ),
                  ),
                  Switch(
                    value: true,
                    onChanged: (value) {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _LevelChip(
                  label: 'All',
                  isSelected: selectedLevel == 'all',
                  onTap: () => onLevelChanged('all'),
                ),
                _LevelChip(
                  label: 'INFO',
                  isSelected: selectedLevel == 'info',
                  color: HermesTheme.primaryBlue,
                  onTap: () => onLevelChanged('info'),
                ),
                _LevelChip(
                  label: 'DEBUG',
                  isSelected: selectedLevel == 'debug',
                  color: HermesTheme.textSecondary,
                  onTap: () => onLevelChanged('debug'),
                ),
                _LevelChip(
                  label: 'WARN',
                  isSelected: selectedLevel == 'warn',
                  color: HermesTheme.warningAmber,
                  onTap: () => onLevelChanged('warn'),
                ),
                _LevelChip(
                  label: 'ERROR',
                  isSelected: selectedLevel == 'error',
                  color: HermesTheme.errorRed,
                  onTap: () => onLevelChanged('error'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _LevelChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected
            ? (color ?? HermesTheme.primaryBlue).withOpacity(0.2)
            : HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? Border.all(
                      color: color ?? HermesTheme.primaryBlue,
                      width: 1,
                    )
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? (color ?? HermesTheme.primaryBlue)
                    : HermesTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogEntry extends StatelessWidget {
  final _LogItem log;

  const _LogEntry({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: log.level == 'ERROR'
            ? Border.all(color: HermesTheme.errorRed.withOpacity(0.3))
            : log.level == 'WARN'
                ? Border.all(color: HermesTheme.warningAmber.withOpacity(0.2))
                : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatTime(log.timestamp),
            style: HermesTheme.codeStyle.copyWith(
              fontSize: 11,
              color: HermesTheme.textTertiary,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getLevelColor(log.level).withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              log.level,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _getLevelColor(log.level),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            log.source,
            style: const TextStyle(
              fontSize: 11,
              color: HermesTheme.secondaryPurple,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              log.message,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            _getLevelIcon(log.level),
            size: 14,
            color: _getLevelColor(log.level),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'ERROR':
        return HermesTheme.errorRed;
      case 'WARN':
        return HermesTheme.warningAmber;
      case 'DEBUG':
        return HermesTheme.textSecondary;
      default:
        return HermesTheme.primaryBlue;
    }
  }

  IconData _getLevelIcon(String level) {
    switch (level) {
      case 'ERROR':
        return Icons.error_outline;
      case 'WARN':
        return Icons.warning_amber;
      case 'DEBUG':
        return Icons.bug_report;
      default:
        return Icons.info_outline;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }
}

// Models
class _LogItem {
  final DateTime timestamp;
  final String level;
  final String source;
  final String message;

  _LogItem({
    required this.timestamp,
    required this.level,
    required this.source,
    required this.message,
  });
}
