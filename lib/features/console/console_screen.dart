import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/p2p_data_channel.dart';
import '../../shared/theme/hermes_theme.dart';

class ConsoleScreen extends ConsumerStatefulWidget {
  const ConsoleScreen({super.key});

  @override
  ConsumerState<ConsoleScreen> createState() => _ConsoleScreenState();
}

class _ConsoleScreenState extends ConsumerState<ConsoleScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  final List<ConsoleEntry> _entries = [];
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    _entries.addAll([
      ConsoleEntry(
        type: ConsoleEntryType.system,
        content: '╔══════════════════════════════════════════╗',
        timestamp: DateTime.now(),
      ),
      ConsoleEntry(
        type: ConsoleEntryType.system,
        content: '║    HermesConsole v1.0.0                 ║',
        timestamp: DateTime.now(),
      ),
      ConsoleEntry(
        type: ConsoleEntryType.system,
        content: '║    Secure Agent Control Terminal       ║',
        timestamp: DateTime.now(),
      ),
      ConsoleEntry(
        type: ConsoleEntryType.system,
        content: '╚══════════════════════════════════════════╝',
        timestamp: DateTime.now(),
      ),
      ConsoleEntry(
        type: ConsoleEntryType.info,
        content: 'Type "help" for available commands',
        timestamp: DateTime.now(),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStateProvider);

    return Scaffold(
      backgroundColor: HermesTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: HermesTheme.surfaceDark,
        title: const Text('Console'),
        actions: [
          IconButton(
            onPressed: _clearConsole,
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Clear',
          ),
          IconButton(
            onPressed: _copyHistory,
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copy History',
          ),
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection Status Bar
          _ConnectionStatusBar(state: connectionState),

          // Terminal Output
          Expanded(
            child: Container(
              color: const Color(0xFF0D0D0D),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  return _ConsoleEntryWidget(entry: _entries[index]);
                },
              ),
            ),
          ),

          // Input Area
          _ConsoleInputArea(
            controller: _inputController,
            focusNode: _focusNode,
            onSubmit: _executeCommand,
            isConnected: connectionState == ConnectionState.connected ||
                connectionState == ConnectionState.authenticated,
          ),
        ],
      ),
    );
  }

  void _executeCommand(String command) {
    if (command.trim().isEmpty) return;

    setState(() {
      _entries.add(ConsoleEntry(
        type: ConsoleEntryType.input,
        content: '\$ $command',
        timestamp: DateTime.now(),
      ));

      // Process command
      _processCommand(command);
    });

    _inputController.clear();
    _scrollToBottom();
    _focusNode.requestFocus();
  }

  void _processCommand(String command) {
    final cmd = command.trim().toLowerCase();

    switch (cmd) {
      case 'help':
        _entries.add(ConsoleEntry(
          type: ConsoleEntryType.output,
          content: '''
Available Commands:
  help          Show this help message
  status        Show connection status
  info          Show system information
  clear         Clear terminal screen
  connect       Connect to peer
  disconnect    Disconnect from peer
  ping          Test connection latency
  history       Show command history
  config        Show current configuration
''',
          timestamp: DateTime.now(),
        ));
        break;

      case 'status':
        final state = ref.read(connectionStateProvider);
        final m = ref.read(connectionMetricsProvider);
        final buffer = StringBuffer(
            'Connection Status: ${state.name.toUpperCase()}');
        if (state == ConnectionState.connected ||
            state == ConnectionState.authenticated) {
          final up = m.uptime;
          buffer.write('\n  Peer:       ${m.peerName ?? m.peerId ?? '-'}');
          buffer.write('\n  Session:    ${m.sessionId}');
          buffer.write('\n  Latency:    ${m.latencyMs}ms');
          buffer.write('\n  Sent/Recv:  ${m.bytesSent}B / ${m.bytesReceived}B');
          buffer.write('\n  Loss:       ${m.packetLossPct}%');
          if (up != null) {
            buffer.write('\n  Uptime:     ${up.inSeconds}s');
          }
        }
        _entries.add(ConsoleEntry(
          type: ConsoleEntryType.output,
          content: buffer.toString(),
          timestamp: DateTime.now(),
        ));
        break;

      case 'connect':
        final state = ref.read(connectionStateProvider);
        if (state == ConnectionState.connected ||
            state == ConnectionState.connecting ||
            state == ConnectionState.authenticated) {
          _entries.add(ConsoleEntry(
            type: ConsoleEntryType.warning,
            content: 'Already ${state.name}. Run "disconnect" first.',
            timestamp: DateTime.now(),
          ));
        } else {
          ref
              .read(connectionStateProvider.notifier)
              .connect('console-peer', peerName: 'Console Session');
          _entries.add(ConsoleEntry(
            type: ConsoleEntryType.info,
            content: 'Connecting to console-peer...',
            timestamp: DateTime.now(),
          ));
        }
        break;

      case 'disconnect':
        final state = ref.read(connectionStateProvider);
        if (state == ConnectionState.disconnected) {
          _entries.add(ConsoleEntry(
            type: ConsoleEntryType.warning,
            content: 'Not connected.',
            timestamp: DateTime.now(),
          ));
        } else {
          ref.read(connectionStateProvider.notifier).disconnect();
          _entries.add(ConsoleEntry(
            type: ConsoleEntryType.info,
            content: 'Disconnected.',
            timestamp: DateTime.now(),
          ));
        }
        break;

      case 'info':
        _entries.add(ConsoleEntry(
          type: ConsoleEntryType.output,
          content: '''
System Information:
  Protocol Version: 1.0.0
  Encryption: AES-256-GCM
  Key Exchange: Curve25519
  Compression: Zstandard
  Transport: WebRTC DataChannel
''',
          timestamp: DateTime.now(),
        ));
        break;

      case 'clear':
        _entries.clear();
        break;

      case 'ping':
        _entries.add(ConsoleEntry(
          type: ConsoleEntryType.info,
          content: 'Pinging...',
          timestamp: DateTime.now(),
        ));
        ref.read(connectionStateProvider.notifier).ping().then((latency) {
          if (!mounted) return;
          setState(() {
            _entries.add(ConsoleEntry(
              type: latency < 0
                  ? ConsoleEntryType.error
                  : ConsoleEntryType.output,
              content: latency < 0
                  ? 'Not connected. Run "connect" first.'
                  : 'Pong! Latency: ${latency}ms',
              timestamp: DateTime.now(),
            ));
          });
          _scrollToBottom();
        });
        break;

      case 'history':
        // Show last 10 commands
        final inputs = _entries
            .where((e) => e.type == ConsoleEntryType.input)
            .take(10)
            .toList();
        for (final input in inputs) {
          _entries.add(ConsoleEntry(
            type: ConsoleEntryType.output,
            content: input.content,
            timestamp: DateTime.now(),
          ));
        }
        break;

      case 'config':
        _entries.add(ConsoleEntry(
          type: ConsoleEntryType.output,
          content: '''
Current Configuration:
  encryption: true
  compression: true
  autoReconnect: true
  timeout: 30s
  stunServers: 2
  turnServers: 0
''',
          timestamp: DateTime.now(),
        ));
        break;

      default:
        _entries.add(ConsoleEntry(
          type: ConsoleEntryType.error,
          content: 'Command not found: $cmd\nType "help" for available commands',
          timestamp: DateTime.now(),
        ));
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

  void _clearConsole() {
    setState(() {
      _entries.clear();
      _addWelcomeMessage();
    });
  }

  void _copyHistory() {
    final history = _entries.map((e) => e.content).join('\n');
    Clipboard.setData(ClipboardData(text: history));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('History copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ConsoleSettingsSheet(),
    );
  }
}

class _ConnectionStatusBar extends StatelessWidget {
  final ConnectionState state;

  const _ConnectionStatusBar({required this.state});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (state) {
      case ConnectionState.connected:
      case ConnectionState.authenticated:
        statusColor = HermesTheme.successGreen;
        statusText = 'CONNECTED';
        break;
      case ConnectionState.connecting:
        statusColor = HermesTheme.warningAmber;
        statusText = 'CONNECTING...';
        break;
      case ConnectionState.error:
        statusColor = HermesTheme.errorRed;
        statusText = 'ERROR';
        break;
      default:
        statusColor = HermesTheme.textSecondary;
        statusText = 'DISCONNECTED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: HermesTheme.surfaceDark,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          if (state == ConnectionState.connected ||
              state == ConnectionState.authenticated) ...[
            _StatusChip(icon: Icons.lock, label: 'Encrypted'),
            const SizedBox(width: 8),
            _StatusChip(icon: Icons.compress, label: 'Compressed'),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: HermesTheme.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: HermesTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsoleEntryWidget extends StatelessWidget {
  final ConsoleEntry entry;

  const _ConsoleEntryWidget({required this.entry});

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color? bgColor;

    switch (entry.type) {
      case ConsoleEntryType.input:
        textColor = HermesTheme.primaryBlue;
        break;
      case ConsoleEntryType.output:
        textColor = HermesTheme.textPrimary;
        break;
      case ConsoleEntryType.error:
        textColor = HermesTheme.errorRed;
        break;
      case ConsoleEntryType.info:
        textColor = HermesTheme.accentCyan;
        break;
      case ConsoleEntryType.system:
        textColor = HermesTheme.secondaryPurple;
        break;
      case ConsoleEntryType.warning:
        textColor = HermesTheme.warningAmber;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SelectableText(
        entry.content,
        style: HermesTheme.codeStyle.copyWith(color: textColor),
      ),
    );
  }
}

class _ConsoleInputArea extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSubmit;
  final bool isConnected;

  const _ConsoleInputArea({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        border: Border(
          top: BorderSide(
            color: HermesTheme.surfaceOverlay,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isConnected
                    ? HermesTheme.successGreen.withOpacity(0.15)
                    : HermesTheme.errorRed.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '\$',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isConnected
                      ? HermesTheme.successGreen
                      : HermesTheme.errorRed,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: isConnected,
                decoration: InputDecoration(
                  hintText: isConnected
                      ? 'Enter command...'
                      : 'Not connected',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintStyle: TextStyle(
                    color: HermesTheme.textSecondary.withOpacity(0.5),
                  ),
                ),
                style: HermesTheme.codeStyle,
                onSubmitted: onSubmit,
              ),
            ),
            IconButton(
              onPressed: isConnected
                  ? () => onSubmit(controller.text)
                  : null,
              icon: Icon(
                Icons.send_rounded,
                color: isConnected
                    ? HermesTheme.primaryBlue
                    : HermesTheme.textSecondary.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsoleSettingsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
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
            'Terminal Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _SettingsTile(
            icon: Icons.text_fields,
            title: 'Font Size',
            subtitle: '14px',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.history,
            title: 'Command History',
            subtitle: '1000 entries',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.animation,
            title: 'Cursor Blink',
            subtitle: 'On',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
            ),
          ),
          _SettingsTile(
            icon: Icons.wrap_text,
            title: 'Word Wrap',
            subtitle: 'On',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: HermesTheme.primaryBlue),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: HermesTheme.textSecondary),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: HermesTheme.textSecondary),
      onTap: onTap,
    );
  }
}

enum ConsoleEntryType {
  input,
  output,
  error,
  info,
  system,
  warning,
}

class ConsoleEntry {
  final ConsoleEntryType type;
  final String content;
  final DateTime timestamp;

  ConsoleEntry({
    required this.type,
    required this.content,
    required this.timestamp,
  });
}
