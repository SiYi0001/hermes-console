import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/app_state.dart';
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

  List<String> get _levels => ['all', 'info', 'debug', 'warning', 'error'];

  @override
  Widget build(BuildContext context) {
    final allLogs = ref.watch(appStateProvider).logs;
    final notifier = ref.read(appStateProvider.notifier);

    final logs = allLogs.where((l) {
      final levelOk = _selectedLevel == 'all' || l.level == _selectedLevel;
      final queryOk = _searchQuery.isEmpty ||
          l.message.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.source.toLowerCase().contains(_searchQuery.toLowerCase());
      return levelOk && queryOk;
    }).toList();

    return Scaffold(
      backgroundColor: HermesTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: HermesTheme.backgroundBlack,
        title: Text('Logs & Audit (${allLogs.length})'),
        actions: [
          IconButton(
            onPressed: _exportLogs,
            icon: const Icon(Icons.download),
            tooltip: 'Export Logs',
          ),
          IconButton(
            onPressed: () => _clearLogs(notifier),
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Logs',
          ),
        ],
      ),
      body: Column(
        children: [
          _LogsHeader(
            selectedLevel: _selectedLevel,
            autoScroll: _autoScroll,
            onLevelChanged: (level) => setState(() => _selectedLevel = level),
            onAutoScrollChanged: (v) => setState(() => _autoScroll = v),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: logs.isEmpty
                ? const Center(child: Text('No logs match the filter.', style: TextStyle(color: HermesTheme.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: logs.length,
                    itemBuilder: (context, index) => _LogEntry(log: logs[index]),
                  ),
          ),
        ],
      ),
    );
  }

  void _exportLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting logs...'), behavior: SnackBarBehavior.floating),
    );
  }

  void _clearLogs(AppStateNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HermesTheme.surfaceDark,
        title: const Text('Clear Logs'),
        content: const Text('Are you sure you want to clear all logs?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              notifier.clearLogs();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logs cleared'), behavior: SnackBarBehavior.floating),
              );
            },
            style: TextButton.styleFrom(foregroundColor: HermesTheme.errorRed),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _LogsHeader extends StatelessWidget {
  final String selectedLevel;
  final bool autoScroll;
  final ValueChanged<String> onLevelChanged;
  final ValueChanged<bool> onAutoScrollChanged;

  const _LogsHeader({
    required this.selectedLevel,
    required this.autoScroll,
    required this.onLevelChanged,
    required this.onAutoScrollChanged,
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
                decoration: BoxDecoration(color: HermesTheme.primaryBlue.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.article, color: HermesTheme.primaryBlue, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('System Logs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Real-time audit trail', style: TextStyle(fontSize: 13, color: HermesTheme.textSecondary)),
                  ],
                ),
              ),
              Row(
                children: [
                  const Text('Auto-scroll', style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
                  Switch(value: autoScroll, onChanged: onAutoScrollChanged),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _LevelChip(label: 'All', isSelected: selectedLevel == 'all', onTap: () => onLevelChanged('all')),
                _LevelChip(label: 'INFO', isSelected: selectedLevel == 'info', color: HermesTheme.primaryBlue, onTap: () => onLevelChanged('info')),
                _LevelChip(label: 'DEBUG', isSelected: selectedLevel == 'debug', color: HermesTheme.textSecondary, onTap: () => onLevelChanged('debug')),
                _LevelChip(label: 'WARN', isSelected: selectedLevel == 'warn', color: HermesTheme.warningAmber, onTap: () => onLevelChanged('warn')),
                _LevelChip(label: 'ERROR', isSelected: selectedLevel == 'error', color: HermesTheme.errorRed, onTap: () => onLevelChanged('error')),
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

  const _LevelChip({required this.label, required this.isSelected, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? HermesTheme.primaryBlue;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected ? activeColor.withOpacity(0.2) : HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: isSelected ? Border.all(color: activeColor, width: 1) : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? activeColor : HermesTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogEntry extends StatelessWidget {
  final LogItem log;
  const _LogEntry({required this.log});

  @override
  Widget build(BuildContext context) {
    final level = log.level.toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: log.level == 'error'
            ? Border.all(color: HermesTheme.errorRed.withOpacity(0.3))
            : log.level == 'warning'
                ? Border.all(color: HermesTheme.warningAmber.withOpacity(0.2))
                : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_formatTime(log.timestamp), style: HermesTheme.codeStyle.copyWith(fontSize: 11, color: HermesTheme.textTertiary)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: _getLevelColor(log.level).withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
            child: Text(level, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _getLevelColor(log.level))),
          ),
          const SizedBox(width: 8),
          Text(log.source, style: const TextStyle(fontSize: 11, color: HermesTheme.secondaryPurple, fontWeight: FontWeight.w500)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(log.message, style: const TextStyle(fontSize: 12, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          Icon(_getLevelIcon(log.level), size: 14, color: _getLevelColor(log.level)),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'error':
        return HermesTheme.errorRed;
      case 'warning':
        return HermesTheme.warningAmber;
      case 'debug':
        return HermesTheme.textSecondary;
      default:
        return HermesTheme.primaryBlue;
    }
  }

  IconData _getLevelIcon(String level) {
    switch (level) {
      case 'error':
        return Icons.error_outline;
      case 'warning':
        return Icons.warning_amber;
      case 'debug':
        return Icons.bug_report;
      default:
        return Icons.info_outline;
    }
  }

  String _formatTime(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
}
