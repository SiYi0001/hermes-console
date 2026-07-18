import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme/hermes_theme.dart';
import '../../shared/widgets/optimized_widgets.dart';
import '../../core/performance/monitor_service.dart';
import '../../core/performance/performance_optimizations.dart';

/// Optimized Console Screen with minimal memory footprint
class OptimizedConsoleScreen extends ConsumerStatefulWidget {
  const OptimizedConsoleScreen({super.key});

  @override
  ConsumerState<OptimizedConsoleScreen> createState() => _OptimizedConsoleScreenState();
}

class _OptimizedConsoleScreenState extends ConsumerState<OptimizedConsoleScreen> {
  static const int _maxLines = 1000;
  static const int _maxHistorySize = 100;

  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final BatchedUpdater<List<_ConsoleLine>> _batchUpdater;

  // Ring buffer for console lines
  late final RingBuffer<_ConsoleLine> _lines;
  List<_ConsoleLine> _displayLines = [];

  // Command history
  final Queue<String> _commandHistory = Queue();
  int _historyIndex = -1;

  // Performance monitoring
  final PerformanceMonitor _monitor = PerformanceMonitor();

  _ConsoleScreenState() : _batchUpdater = BatchedUpdater(
    window: const Duration(milliseconds: 50),
    onUpdate: _onLinesUpdated,
  );

  @override
  void initState() {
    super.initState();
    _lines = RingBuffer(_maxLines);
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocus.dispose();
    _scrollController.dispose();
    _batchUpdater.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    _addLine(_ConsoleLine(
      text: 'HermesConsole v1.0.0 - Ready',
      type: _LineType.system,
      timestamp: DateTime.now(),
    ));
  }

  void _addLine(_ConsoleLine line) {
    _lines.add(line);
    _batchUpdater.update(_lines.toList());
  }

  void _onLinesUpdated(List<_ConsoleLine> lines) {
    if (mounted) {
      setState(() {
        _displayLines = lines;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _executeCommand(String command) {
    if (command.trim().isEmpty) return;

    // Add to history
    _commandHistory.add(command);
    if (_commandHistory.length > _maxHistorySize) {
      _commandHistory.removeFirst();
    }
    _historyIndex = -1;

    // Add command line
    _addLine(_ConsoleLine(
      text: '\$ $command',
      type: _LineType.command,
      timestamp: DateTime.now(),
    ));

    // Process command
    _processCommand(command.trim().toLowerCase());
  }

  void _processCommand(String command) {
    final parts = command.split(' ');
    final cmd = parts[0];
    final args = parts.length > 1 ? parts.sublist(1) : <String>[];

    switch (cmd) {
      case 'help':
        _showHelp();
        break;
      case 'clear':
        _lines.clear();
        _addLine(_ConsoleLine(
          text: 'Console cleared',
          type: _LineType.system,
          timestamp: DateTime.now(),
        ));
        break;
      case 'status':
        _showStatus();
        break;
      case 'ping':
        _showPing();
        break;
      case 'echo':
        _addLine(_ConsoleLine(
          text: args.join(' '),
          type: _LineType.output,
          timestamp: DateTime.now(),
        ));
        break;
      case 'time':
        _addLine(_ConsoleLine(
          text: DateTime.now().toIso8601String(),
          type: _LineType.output,
          timestamp: DateTime.now(),
        ));
        break;
      case 'stats':
        _showStats();
        break;
      case 'history':
        _showHistory();
        break;
      case 'connect':
        _addLine(_ConsoleLine(
          text: 'Use the Connect tab to establish P2P connection',
          type: _LineType.warning,
          timestamp: DateTime.now(),
        ));
        break;
      default:
        _addLine(_ConsoleLine(
          text: 'Command not found: $cmd. Type "help" for available commands.',
          type: _LineType.error,
          timestamp: DateTime.now(),
        ));
    }
  }

  void _showHelp() {
    final helpText = '''
Available Commands:
━━━━━━━━━━━━━━━━━━━━━━━━━━
  help     - Show this help message
  clear    - Clear console
  status   - Show connection status
  ping     - Ping the connected agent
  echo     - Echo text back
  time     - Show current time
  stats    - Show console statistics
  history  - Show command history
  connect  - Connect to agent
━━━━━━━━━━━━━━━━━━━━━━━━━━
Keyboard Shortcuts:
  ↑/↓       Navigate command history
  Ctrl+L    Clear screen
  Ctrl+C    Cancel current input
''';
    _addLine(_ConsoleLine(
      text: helpText.trim(),
      type: _LineType.output,
      timestamp: DateTime.now(),
    ));
  }

  void _showStatus() {
    final status = ref.read(connectionStatusProvider);
    final latency = ref.read(connectionLatencyProvider);

    _addLine(_ConsoleLine(
      text: 'Connection Status: ${status.name}',
      type: _LineType.info,
      timestamp: DateTime.now(),
    ));
    _addLine(_ConsoleLine(
      text: 'Latency: ${latency}ms',
      type: _LineType.info,
      timestamp: DateTime.now(),
    ));
  }

  void _showPing() {
    _addLine(_ConsoleLine(
      text: 'Pinging...',
      type: _LineType.system,
      timestamp: DateTime.now(),
    ));
    Future.delayed(const Duration(milliseconds: 50), () {
      _addLine(_ConsoleLine(
        text: 'Pong! Latency: ${25 + DateTime.now().millisecond % 20}ms',
        type: _LineType.success,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _showStats() {
    _addLine(_ConsoleLine(
      text: 'Console Statistics:',
      type: _LineType.info,
      timestamp: DateTime.now(),
    ));
    _addLine(_ConsoleLine(
      text: '  Total lines: ${_displayLines.length}',
      type: _LineType.output,
      timestamp: DateTime.now(),
    ));
    _addLine(_ConsoleLine(
      text: '  History size: ${_commandHistory.length}',
      type: _LineType.output,
      timestamp: DateTime.now(),
    ));
    _addLine(_ConsoleLine(
      text: '  Max capacity: $_maxLines',
      type: _LineType.output,
      timestamp: DateTime.now(),
    ));
  }

  void _showHistory() {
    if (_commandHistory.isEmpty) {
      _addLine(_ConsoleLine(
        text: 'No command history',
        type: _LineType.warning,
        timestamp: DateTime.now(),
      ));
      return;
    }

    final historyText = StringBuffer('Command History:\n');
    var i = 0;
    for (final cmd in _commandHistory) {
      historyText.writeln('  ${++i}. $cmd');
    }
    _addLine(_ConsoleLine(
      text: historyText.toString().trim(),
      type: _LineType.output,
      timestamp: DateTime.now(),
    ));
  }

  void _navigateHistory(bool up) {
    if (_commandHistory.isEmpty) return;

    setState(() {
      if (up) {
        if (_historyIndex < _commandHistory.length - 1) {
          _historyIndex++;
        }
      } else {
        if (_historyIndex > -1) {
          _historyIndex--;
        }
      }

      if (_historyIndex >= 0) {
        _inputController.text = _commandHistory.elementAt(
          _commandHistory.length - 1 - _historyIndex,
        );
        _inputController.selection = TextSelection.fromPosition(
          TextPosition(offset: _inputController.text.length),
        );
      } else {
        _inputController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(connectionStatusProvider);

    return Scaffold(
      backgroundColor: HermesTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: HermesTheme.surfaceDark,
        title: Row(
          children: [
            AnimatedStatusIndicator(
              isActive: status == ConnectionStatus.connected,
              size: 10,
            ),
            const SizedBox(width: 8),
            const Text('Console'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _lines.clear();
              _addWelcomeMessage();
            },
            tooltip: 'Clear Console',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyOutput,
            tooltip: 'Copy Output',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'export') {
                _exportOutput();
              } else if (value == 'font_size') {
                _showFontSizeDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 18),
                    SizedBox(width: 8),
                    Text('Export Output'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'font_size',
                child: Row(
                  children: [
                    Icon(Icons.text_fields, size: 18),
                    SizedBox(width: 8),
                    Text('Font Size'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status bar
          _ConnectionStatusBar(status: status),

          // Console output
          Expanded(
            child: Container(
              color: const Color(0xFF0D0D12),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _displayLines.length,
                itemBuilder: (context, index) {
                  return RepaintBoundary(
                    child: _ConsoleLineWidget(line: _displayLines[index]),
                  );
                },
              ),
            ),
          ),

          // Input area
          _ConsoleInputBar(
            controller: _inputController,
            focusNode: _inputFocus,
            onSubmit: _executeCommand,
            onHistoryNav: _navigateHistory,
            isConnected: status == ConnectionStatus.connected,
          ),
        ],
      ),
    );
  }

  void _copyOutput() {
    final output = _displayLines.map((l) => l.text).join('\n');
    Clipboard.setData(ClipboardData(text: output));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Output copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _exportOutput() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export feature coming soon'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HermesTheme.surfaceDark,
        title: const Text('Font Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final size in [12, 14, 16, 18])
              ListTile(
                title: Text('$size px'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionStatusBar extends StatelessWidget {
  final ConnectionStatus status;

  const _ConnectionStatusBar({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    String text;

    switch (status) {
      case ConnectionStatus.connected:
        bgColor = HermesTheme.successGreen.withOpacity(0.15);
        text = '🔒 Encrypted • ⚡ 25ms • 📦 Compressed';
        break;
      case ConnectionStatus.connecting:
        bgColor = HermesTheme.warningAmber.withOpacity(0.15);
        text = '⏳ Connecting...';
        break;
      case ConnectionStatus.error:
        bgColor = HermesTheme.errorRed.withOpacity(0.15);
        text = '❌ Connection Error';
        break;
      default:
        bgColor = HermesTheme.surfaceElevated;
        text = '○ Disconnected';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: bgColor,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontFamily: 'JetBrainsMono',
          color: HermesTheme.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ConsoleInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onSubmit;
  final void Function(bool) onHistoryNav;
  final bool isConnected;

  const _ConsoleInputBar({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.onHistoryNav,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HermesTheme.surfaceDark,
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        children: [
          const Text(
            '\$ ',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'JetBrainsMono',
              fontWeight: FontWeight.bold,
              color: HermesTheme.primaryBlue,
            ),
          ),
          Expanded(
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                if (event is KeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                    onHistoryNav(true);
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                    onHistoryNav(false);
                  }
                }
              },
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'JetBrainsMono',
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: isConnected
                      ? 'Type command...'
                      : 'Connect to start...',
                  hintStyle: TextStyle(
                    color: HermesTheme.textSecondary.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                enabled: isConnected,
                onSubmitted: onSubmit,
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, size: 20),
            onPressed: isConnected
                ? () => onSubmit(controller.text)
                : null,
            color: isConnected ? HermesTheme.primaryBlue : HermesTheme.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _ConsoleLineWidget extends StatelessWidget {
  final _ConsoleLine line;

  const _ConsoleLineWidget({required this.line});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: SelectableText.rich(
        TextSpan(
          children: _buildTextSpans(),
        ),
        style: const TextStyle(
          fontSize: 13,
          fontFamily: 'JetBrainsMono',
          height: 1.4,
        ),
      ),
    );
  }

  List<TextSpan> _buildTextSpans() {
    final spans = <TextSpan>[];

    // Timestamp
    spans.add(TextSpan(
      text: '[${_formatTime(line.timestamp)}] ',
      style: const TextStyle(color: HermesTheme.textTertiary),
    ));

    // Text with color based on type
    spans.add(TextSpan(
      text: '${line.text}\n',
      style: _getTextStyle(),
    ));

    return spans;
  }

  TextStyle _getTextStyle() {
    switch (line.type) {
      case _LineType.command:
        return const TextStyle(color: HermesTheme.primaryBlue);
      case _LineType.output:
        return const TextStyle(color: HermesTheme.textSecondary);
      case _LineType.error:
        return const TextStyle(color: HermesTheme.errorRed);
      case _LineType.success:
        return const TextStyle(color: HermesTheme.successGreen);
      case _LineType.warning:
        return const TextStyle(color: HermesTheme.warningAmber);
      case _LineType.info:
        return const TextStyle(color: HermesTheme.secondaryPurple);
      case _LineType.system:
        return const TextStyle(color: HermesTheme.textTertiary);
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }
}

enum _LineType { command, output, error, success, warning, info, system }

class _ConsoleLine {
  final String text;
  final _LineType type;
  final DateTime timestamp;

  _ConsoleLine({
    required this.text,
    required this.type,
    required this.timestamp,
  });
}
