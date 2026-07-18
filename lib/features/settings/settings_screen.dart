import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/hive_init.dart';
import '../../shared/theme/hermes_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _encryptionEnabled = true;
  bool _compressionEnabled = true;
  bool _autoReconnect = true;
  int _connectionTimeout = 30;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _encryptionEnabled = SettingsStorage.encryptionEnabled;
      _compressionEnabled = SettingsStorage.compressionEnabled;
      _autoReconnect = SettingsStorage.autoReconnect;
      _connectionTimeout = SettingsStorage.connectionTimeout;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HermesTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: HermesTheme.backgroundBlack,
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Section
            _SectionHeader(title: 'Security'),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _SwitchTile(
                  icon: Icons.lock_rounded,
                  title: 'End-to-End Encryption',
                  subtitle: 'AES-256-GCM encryption for all data',
                  value: _encryptionEnabled,
                  onChanged: (value) async {
                    await SettingsStorage.setEncryptionEnabled(value);
                    setState(() => _encryptionEnabled = value);
                  },
                ),
                const Divider(color: HermesTheme.surfaceOverlay, height: 1),
                _SwitchTile(
                  icon: Icons.sync_alt_rounded,
                  title: 'Auto Reconnect',
                  subtitle: 'Automatically reconnect on disconnect',
                  value: _autoReconnect,
                  onChanged: (value) async {
                    await SettingsStorage.setAutoReconnect(value);
                    setState(() => _autoReconnect = value);
                  },
                ),
                const Divider(color: HermesTheme.surfaceOverlay, height: 1),
                _ActionTile(
                  icon: Icons.timer_outlined,
                  title: 'Connection Timeout',
                  subtitle: '$_connectionTimeout seconds',
                  onTap: _showTimeoutPicker,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Network Section
            _SectionHeader(title: 'Network'),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _ActionTile(
                  icon: Icons.dns_rounded,
                  title: 'STUN Servers',
                  subtitle: '${SettingsStorage.stunServers.length} configured',
                  onTap: _showStunServers,
                ),
                const Divider(color: HermesTheme.surfaceOverlay, height: 1),
                _ActionTile(
                  icon: Icons.vpn_lock_rounded,
                  title: 'TURN Servers',
                  subtitle: '${SettingsStorage.turnServers.length} configured',
                  onTap: _showTurnServers,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Compression Section
            _SectionHeader(title: 'Data'),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _SwitchTile(
                  icon: Icons.compress_rounded,
                  title: 'Data Compression',
                  subtitle: 'Zstandard compression for transfers',
                  value: _compressionEnabled,
                  onChanged: (value) async {
                    await SettingsStorage.setCompressionEnabled(value);
                    setState(() => _compressionEnabled = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Firewall Section
            _SectionHeader(title: 'Firewall'),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _SwitchTile(
                  icon: Icons.shield_rounded,
                  title: 'IP Whitelist',
                  subtitle: 'Only allow connections from whitelist',
                  value: false,
                  onChanged: (value) {},
                ),
                const Divider(color: HermesTheme.surfaceOverlay, height: 1),
                _ActionTile(
                  icon: Icons.format_list_numbered_rounded,
                  title: 'Whitelist Rules',
                  subtitle: '0 rules configured',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Appearance Section
            _SectionHeader(title: 'Appearance'),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _SwitchTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Dark Mode',
                  subtitle: 'Always on (recommended)',
                  value: true,
                  enabled: false,
                  onChanged: (value) {},
                ),
                const Divider(color: HermesTheme.surfaceOverlay, height: 1),
                _ActionTile(
                  icon: Icons.text_fields_rounded,
                  title: 'Terminal Font Size',
                  subtitle: '14px',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // About Section
            _SectionHeader(title: 'About'),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _InfoTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Version',
                  value: '1.0.0',
                ),
                const Divider(color: HermesTheme.surfaceOverlay, height: 1),
                _InfoTile(
                  icon: Icons.code_rounded,
                  title: 'Protocol',
                  value: 'Hermes v1.0.0',
                ),
                const Divider(color: HermesTheme.surfaceOverlay, height: 1),
                _ActionTile(
                  icon: Icons.description_outlined,
                  title: 'Licenses',
                  subtitle: 'Open source licenses',
                  onTap: () => _showLicenses(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Danger Zone
            _SectionHeader(title: 'Danger Zone', isDestructive: true),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _ActionTile(
                  icon: Icons.delete_forever_rounded,
                  title: 'Clear All Data',
                  subtitle: 'Remove all sessions and settings',
                  isDestructive: true,
                  onTap: _confirmClearData,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showTimeoutPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TimeoutPickerSheet(
        currentValue: _connectionTimeout,
        onChanged: (value) async {
          await SettingsStorage.setConnectionTimeout(value);
          setState(() => _connectionTimeout = value);
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _showStunServers() {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesTheme.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ServerListSheet(
        title: 'STUN Servers',
        servers: SettingsStorage.stunServers,
        onAdd: (server) async {
          final current = SettingsStorage.stunServers;
          await SettingsStorage.setStunServers([...current, server]);
          setState(() {});
        },
        onRemove: (server) async {
          final current = SettingsStorage.stunServers;
          await SettingsStorage.setStunServers(
            current.where((s) => s != server).toList(),
          );
          setState(() {});
        },
      ),
    );
  }

  void _showTurnServers() {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesTheme.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ServerListSheet(
        title: 'TURN Servers',
        servers: SettingsStorage.turnServers,
        onAdd: (server) async {
          final current = SettingsStorage.turnServers;
          await SettingsStorage.setTurnServers([...current, server]);
          setState(() {});
        },
        onRemove: (server) async {
          final current = SettingsStorage.turnServers;
          await SettingsStorage.setTurnServers(
            current.where((s) => s != server).toList(),
          );
          setState(() {});
        },
      ),
    );
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: 'HermesConsole',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: HermesTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.terminal_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  void _confirmClearData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HermesTheme.surfaceDark,
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all saved sessions, history, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await HiveInit.clearAll();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: HermesTheme.errorRed,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDestructive;

  const _SectionHeader({
    required this.title,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDestructive ? HermesTheme.errorRed : HermesTheme.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.enabled = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: HermesTheme.primaryBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: HermesTheme.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: enabled ? Colors.white : HermesTheme.textSecondary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: HermesTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDestructive;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDestructive ? HermesTheme.errorRed : HermesTheme.primaryBlue)
                    .withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDestructive ? HermesTheme.errorRed : HermesTheme.primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? HermesTheme.errorRed : Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: HermesTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: HermesTheme.textSecondary.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: HermesTheme.textSecondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: HermesTheme.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: HermesTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeoutPickerSheet extends StatelessWidget {
  final int currentValue;
  final ValueChanged<int> onChanged;

  const _TimeoutPickerSheet({
    required this.currentValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = [10, 15, 30, 60, 120];

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
            'Connection Timeout',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ...options.map((seconds) => RadioListTile<int>(
            value: seconds,
            groupValue: currentValue,
            onChanged: (value) => onChanged(value!),
            title: Text(
              '$seconds seconds',
              style: const TextStyle(color: Colors.white),
            ),
            activeColor: HermesTheme.primaryBlue,
          )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ServerListSheet extends StatefulWidget {
  final String title;
  final List<String> servers;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const _ServerListSheet({
    required this.title,
    required this.servers,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<_ServerListSheet> createState() => _ServerListSheetState();
}

class _ServerListSheetState extends State<_ServerListSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: HermesTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'stun:stun.example.com:3478',
                    isDense: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    widget.onAdd(_controller.text);
                    _controller.clear();
                  }
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: widget.servers.length,
              itemBuilder: (context, index) {
                final server = widget.servers[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    server,
                    style: HermesTheme.codeStyle.copyWith(fontSize: 12),
                  ),
                  trailing: IconButton(
                    onPressed: () => widget.onRemove(server),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: HermesTheme.errorRed,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
