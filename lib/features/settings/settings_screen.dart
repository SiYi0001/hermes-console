import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/settings_service.dart';
import '../../core/storage/hive_init.dart';
import '../../shared/theme/hermes_theme.dart';

/// Settings screen.
///
/// Fully backed by [settingsProvider]: every toggle writes through
/// [SettingsNotifier] and is persisted to Hive immediately, so changes
/// survive app restarts. Dark-mode changes also flow to the app theme via
/// [themeModeProvider] consumed in [HermesConsoleApp].
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const String appVersion = '2.4.0';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);

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
            const _SectionHeader(title: 'Security'),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _SwitchTile(
                  icon: Icons.lock_rounded,
                  title: 'End-to-End Encryption',
                  subtitle: 'AES-256-GCM encryption for all data',
                  value: s.enableEncryption,
                  onChanged: (value) =>
                      ref.read(settingsProvider.notifier).setEncryption(value),
                ),
                const Divider(color: HermesTheme.surfaceOverlay, height: 1),
                _SwitchTile(
                  icon: Icons.sync_alt_rounded,
                  title: 'Auto Reconnect',
                  subtitle: 'Automatically reconnect on disconnect',
                  value: s.autoReconnect,
                  onChanged: (value) =>
                      ref.read(settingsProvider.notifier).setAutoReconnect(value),
                ),
                const Divider(color: HermesTheme.surfaceOverlay, height: 1),
                _ActionTile(
                  icon: Icons.timer_outlined,
                  title: 'Connection Timeout',
                  subtitle: '${s.connectionTimeoutSeconds} seconds',
                  onTap: () => _showTimeoutPicker(context, ref, s.connectionTimeoutSeconds),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Network Section
            const _SectionHeader(title: 'Network'),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _ActionTile(
                  icon: Icons.dns_rounded,
                  title: 'STUN Servers',
                  subtitle: '${s.stunServers.length} configured',
                  onTap: () => _showServerSheet(
                    context,
                    ref,
                    title: 'STUN Servers',
                    servers: s.stunServers,
                    onChanged: (list) =>
                        ref.read(settingsProvider.notifier).setStunServers(list),
                  ),
                ),
                const Divider(color: HermesTheme.surfaceOverlay, height: 1),
                _ActionTile(
                  icon: Icons.vpn_lock_rounded,
                  title: 'TURN Servers',
                  subtitle: '${s.turnServers.length} configured',
                  onTap: () => _showServerSheet(
                    context,
                    ref,
                    title: 'TURN Servers',
                    servers: s.turnServers,
                    onChanged: (list) =>
                        ref.read(settingsProvider.notifier).setTurnServers(list),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Compression Section
            const _SectionHeader(title: 'Data'),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _SwitchTile(
                  icon: Icons.compress_rounded,
                  title: 'Data Compression',
                  subtitle: 'Zstandard compression for transfers',
                  value: s.enableCompression,
                  onChanged: (value) =>
                      ref.read(settingsProvider.notifier).setCompression(value),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Firewall Section
            const _SectionHeader(title: 'Firewall'),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _SwitchTile(
                  icon: Icons.shield_rounded,
                  title: 'IP Whitelist',
                  subtitle: 'Only allow connections from whitelist',
                  value: s.ipWhitelistEnabled,
                  onChanged: (value) =>
                      ref.read(settingsProvider.notifier).setIpWhitelist(value),
                ),
                const Divider(color: HermesTheme.surfaceOverlay, height: 1),
                _ActionTile(
                  icon: Icons.format_list_numbered_rounded,
                  title: 'Whitelist Rules',
                  subtitle: s.ipWhitelistEnabled ? '0 rules configured' : 'Disabled',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Appearance Section
            const _SectionHeader(title: 'Appearance'),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _SwitchTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Dark Mode',
                  subtitle: 'Recommended for OLED screens',
                  value: s.themeMode == ThemeMode.dark,
                  onChanged: (value) =>
                      ref.read(settingsProvider.notifier).setDarkMode(value),
                ),
                const Divider(color: HermesTheme.surfaceOverlay, height: 1),
                _ActionTile(
                  icon: Icons.text_fields_rounded,
                  title: 'Terminal Font Size',
                  subtitle: '${s.consoleFontSize.toInt()}px',
                  onTap: () => _showFontPicker(context, ref, s.consoleFontSize),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // About Section
            const _SectionHeader(title: 'About'),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                const _InfoTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Version',
                  value: appVersion,
                ),
                const Divider(color: HermesTheme.surfaceOverlay, height: 1),
                const _InfoTile(
                  icon: Icons.code_rounded,
                  title: 'Protocol',
                  value: 'Hermes v2.0.0',
                ),
                const Divider(color: HermesTheme.surfaceOverlay, height: 1),
                _ActionTile(
                  icon: Icons.description_outlined,
                  title: 'Licenses',
                  subtitle: 'Open source licenses',
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'HermesConsole',
                    applicationVersion: appVersion,
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Danger Zone
            const _SectionHeader(title: 'Danger Zone', isDestructive: true),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _ActionTile(
                  icon: Icons.delete_forever_rounded,
                  title: 'Clear All Data',
                  subtitle: 'Remove all sessions and settings',
                  isDestructive: true,
                  onTap: () => _confirmClearData(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showTimeoutPicker(
    BuildContext context,
    WidgetRef ref,
    int currentValue,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TimeoutPickerSheet(
        currentValue: currentValue,
        options: const [10, 15, 30, 60, 120],
        onChanged: (value) {
          ref.read(settingsProvider.notifier).setConnectionTimeout(value);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showFontPicker(
    BuildContext context,
    WidgetRef ref,
    double currentValue,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TimeoutPickerSheet(
        currentValue: currentValue.toInt(),
        options: const [10, 12, 14, 16, 18, 20],
        label: 'px',
        onChanged: (value) {
          ref.read(settingsProvider.notifier).setConsoleFontSize(value.toDouble());
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showServerSheet(
    BuildContext context,
    WidgetRef ref,
    {
    required String title,
    required List<String> servers,
    required ValueChanged<List<String>> onChanged,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesTheme.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ServerListSheet(
        title: title,
        servers: servers,
        onChanged: (list) {
          onChanged(list);
        },
      ),
    );
  }

  void _confirmClearData(BuildContext context, WidgetRef ref) {
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
              await ref.read(settingsProvider.notifier).resetToDefaults();
              if (context.mounted) {
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
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
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
              color: HermesTheme.primaryBlue.withValues(alpha: 0.15),
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
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
            onChanged: onChanged,
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
                    .withValues(alpha: 0.15),
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
              color: HermesTheme.textSecondary.withValues(alpha: 0.5),
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
              color: HermesTheme.textSecondary.withValues(alpha: 0.15),
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
  final List<int> options;
  final String label;
  final ValueChanged<int> onChanged;

  const _TimeoutPickerSheet({
    required this.currentValue,
    required this.options,
    this.label = 'seconds',
    required this.onChanged,
  });

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
          Text(
            label == 'px' ? 'Terminal Font Size' : 'Connection Timeout',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          RadioGroup<int>(
            groupValue: currentValue,
            onChanged: (v) => onChanged(v!),
            child: Column(
              children: options.map((value) => RadioListTile<int>(
                value: value,
                title: Text(
                  '$value $label',
                  style: const TextStyle(color: Colors.white),
                ),
                activeColor: HermesTheme.primaryBlue,
              )).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ServerListSheet extends StatefulWidget {
  final String title;
  final List<String> servers;
  final ValueChanged<List<String>> onChanged;

  const _ServerListSheet({
    required this.title,
    required this.servers,
    required this.onChanged,
  });

  @override
  State<_ServerListSheet> createState() => _ServerListSheetState();
}

class _ServerListSheetState extends State<_ServerListSheet> {
  late List<String> _servers;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _servers = List<String>.from(widget.servers);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add(String server) {
    if (server.isEmpty) return;
    setState(() => _servers.add(server));
    widget.onChanged(List.unmodifiable(_servers));
    _controller.clear();
  }

  void _remove(String server) {
    setState(() => _servers.remove(server));
    widget.onChanged(List.unmodifiable(_servers));
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
                  decoration: const InputDecoration(
                    hintText: 'stun:stun.example.com:3478',
                    isDense: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: _add,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _add(_controller.text),
                child: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: _servers.length,
              itemBuilder: (context, index) {
                final server = _servers[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    server,
                    style: HermesTheme.codeStyle.copyWith(fontSize: 12),
                  ),
                  trailing: IconButton(
                    onPressed: () => _remove(server),
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
