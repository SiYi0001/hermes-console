import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../shared/theme/hermes_theme.dart';

/// Profile & Account Screen — bound to AppState.profile, skills, settings
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _twoFactorEnabled = false;
  bool _loginAlertsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final profile = state.profile;

    return Scaffold(
      backgroundColor: HermesTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: HermesTheme.backgroundBlack,
        title: const Text('Profile & Account'),
        actions: [
          IconButton(
            onPressed: () => _showEditSheet(context, profile),
            icon: const Icon(Icons.edit),
            tooltip: 'Edit profile',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: HermesTheme.surfaceElevated,
            onSelected: (v) {
              if (v == 'export') _exportProfile(profile);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'export', child: Row(children: [Icon(Icons.download, size: 18), SizedBox(width: 8), Text('Export Profile')])),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileHeader(profile: profile),
          const SizedBox(height: 20),
          _UsageStatsCard(profile: profile, skillCount: state.skills.length, serverCount: state.mcpServers.length),
          const SizedBox(height: 20),
          _StorageCard(profile: profile),
          const SizedBox(height: 20),
          _IdentitiesCard(
            channels: state.gatewayChannels.where((c) => c.connected).toList(),
            servers: state.mcpServers.where((s) => s.enabled).toList(),
          ),
          const SizedBox(height: 20),
          _SecurityCard(
            twoFactorEnabled: _twoFactorEnabled,
            loginAlertsEnabled: _loginAlertsEnabled,
            onToggle2FA: (v) => setState(() => _twoFactorEnabled = v),
            onToggleLoginAlerts: (v) => setState(() => _loginAlertsEnabled = v),
          ),
          const SizedBox(height: 20),
          _DangerZoneCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, AgentProfile profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesTheme.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _EditProfileSheet(initialProfile: profile),
    );
  }

  void _exportProfile(AgentProfile profile) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting profile for ${profile.name}…'), behavior: SnackBarBehavior.floating),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final AgentProfile profile;
  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HermesTheme.primaryBlue.withValues(alpha: 0.12), HermesTheme.secondaryPurple.withValues(alpha: 0.08)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HermesTheme.primaryBlue.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: HermesTheme.surfaceElevated,
                child: Text(
                  profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: HermesTheme.primaryBlue),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: HermesTheme.primaryBlue, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(profile.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(profile.email, style: const TextStyle(fontSize: 14, color: HermesTheme.textSecondary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [HermesTheme.primaryBlue, HermesTheme.secondaryPurple]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.workspace_premium, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(profile.membership, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Usage Stats Card ─────────────────────────────────────────────────────────

class _UsageStatsCard extends StatelessWidget {
  final AgentProfile profile;
  final int skillCount;
  final int serverCount;

  const _UsageStatsCard({required this.profile, required this.skillCount, required this.serverCount});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Usage Statistics',
      icon: Icons.insights,
      child: Column(
        children: [
          _StatRow(label: 'Active Sessions', value: '${profile.sessions}', icon: Icons.terminal, color: HermesTheme.primaryBlue),
          _StatRow(label: 'Commands Executed', value: '${profile.commands}', icon: Icons.code, color: HermesTheme.successGreen),
          _StatRow(label: 'API Calls', value: '${profile.apiCalls}', icon: Icons.api, color: HermesTheme.warningAmber),
          _StatRow(label: 'Skills Installed', value: '$skillCount', icon: Icons.extension, color: HermesTheme.secondaryPurple),
          _StatRow(label: 'MCP Servers', value: '$serverCount', icon: Icons.dns, color: HermesTheme.primaryBlue),
          _StatRow(label: 'Commands / Session', value: (profile.sessions > 0 ? (profile.commands / profile.sessions).toStringAsFixed(1) : '—'), icon: Icons.speed, color: HermesTheme.errorRed),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatRow({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: HermesTheme.textSecondary, fontSize: 13))),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}

// ─── Storage Card ─────────────────────────────────────────────────────────────

class _StorageCard extends StatelessWidget {
  final AgentProfile profile;
  const _StorageCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final storageUsed = profile.storageMb;
    final storageTotal = profile.storageMaxMb;
    final storagePct = storageTotal > 0 ? storageUsed / storageTotal : 0.0;

    final bwUsed = profile.bandwidthGb;
    final bwTotal = profile.bandwidthMaxGb;
    final bwPct = bwTotal > 0 ? bwUsed / bwTotal : 0.0;

    return _Card(
      title: 'Storage & Bandwidth',
      icon: Icons.cloud,
      child: Column(
        children: [
          _ProgressRow(label: 'Storage', used: storageUsed, total: storageTotal, unit: 'MB', progress: storagePct, color: HermesTheme.primaryBlue),
          const SizedBox(height: 16),
          _ProgressRow(label: 'Bandwidth', used: bwUsed, total: bwTotal, unit: 'GB', progress: bwPct, color: HermesTheme.secondaryPurple),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final int used;
  final int total;
  final String unit;
  final double progress;
  final Color color;

  const _ProgressRow({required this.label, required this.used, required this.total, required this.unit, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            Text('$used / $total $unit', style: const TextStyle(color: HermesTheme.textSecondary, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: progress.clamp(0, 1), backgroundColor: HermesTheme.surfaceOverlay, color: color, minHeight: 6),
        ),
      ],
    );
  }
}

// ─── Identities Card ──────────────────────────────────────────────────────────

class _IdentitiesCard extends StatelessWidget {
  final List<GatewayChannel> channels;
  final List<McpServer> servers;

  const _IdentitiesCard({required this.channels, required this.servers});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Connected Identities',
      icon: Icons.fingerprint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Messaging Platforms', style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          if (channels.isEmpty)
            const Text('No platforms connected', style: TextStyle(color: HermesTheme.textSecondary, fontSize: 13))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: channels.map((c) => _IdentityChip(label: c.name, icon: _channelIcon(c.name), color: _platformColor(c.name))).toList(),
            ),
          const SizedBox(height: 16),
          const Text('MCP Servers', style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          if (servers.isEmpty)
            const Text('No MCP servers active', style: TextStyle(color: HermesTheme.textSecondary, fontSize: 13))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: servers.map((s) => _IdentityChip(label: s.name, icon: Icons.dns, color: HermesTheme.secondaryPurple)).toList(),
            ),
        ],
      ),
    );
  }

  IconData _channelIcon(String name) {
    switch (name.toLowerCase()) {
      case 'wechat':
        return Icons.chat;
      case 'qq':
        return Icons.chat_bubble;
      case 'telegram':
        return Icons.send;
      case 'discord':
        return Icons.forum;
      case 'slack':
        return Icons.work;
      case 'feishu':
        return Icons.campaign;
      default:
        return Icons.public;
    }
  }

  Color _platformColor(String name) {
    switch (name.toLowerCase()) {
      case 'discord':
        return const Color(0xFF5865F2);
      case 'slack':
        return const Color(0xFF4A154B);
      case 'telegram':
        return const Color(0xFF0088CC);
      case 'feishu':
        return const Color(0xFF4254A6);
      default:
        return HermesTheme.primaryBlue;
    }
  }
}

class _IdentityChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _IdentityChip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}

// ─── Security Card ────────────────────────────────────────────────────────────

class _SecurityCard extends StatelessWidget {
  final bool twoFactorEnabled;
  final bool loginAlertsEnabled;
  final void Function(bool) onToggle2FA;
  final void Function(bool) onToggleLoginAlerts;

  const _SecurityCard({
    required this.twoFactorEnabled,
    required this.loginAlertsEnabled,
    required this.onToggle2FA,
    required this.onToggleLoginAlerts,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Security',
      icon: Icons.security,
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.phonelink_lock,
            title: 'Two-Factor Authentication',
            subtitle: 'Require 2FA for all logins',
            trailing: Switch(value: twoFactorEnabled, onChanged: onToggle2FA, activeThumbColor: HermesTheme.primaryBlue),
          ),
          const Divider(color: HermesTheme.surfaceOverlay, height: 1),
          _SettingsTile(
            icon: Icons.login,
            title: 'Login Alerts',
            subtitle: 'Get notified on new login attempts',
            trailing: Switch(value: loginAlertsEnabled, onChanged: onToggleLoginAlerts, activeThumbColor: HermesTheme.primaryBlue),
          ),
          const Divider(color: HermesTheme.surfaceOverlay, height: 1),
          _SettingsTile(
            icon: Icons.key,
            title: 'API Keys',
            subtitle: 'Manage API keys and tokens',
            trailing: const Icon(Icons.chevron_right, color: HermesTheme.textSecondary),
            onTap: () => _showApiKeySheet(context),
          ),
          const Divider(color: HermesTheme.surfaceOverlay, height: 1),
          _SettingsTile(
            icon: Icons.history,
            title: 'Login History',
            subtitle: 'View recent login activity',
            trailing: const Icon(Icons.chevron_right, color: HermesTheme.textSecondary),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _showApiKeySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesTheme.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('API Keys', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.vpn_key, color: HermesTheme.successGreen),
              title: Text('Production Key', style: TextStyle(color: Colors.white)),
              subtitle: Text('sk-prod-••••••••3f8a', style: TextStyle(color: HermesTheme.textSecondary, fontSize: 12)),
              trailing: Icon(Icons.copy, color: HermesTheme.textSecondary),
            ),
            ListTile(
              leading: Icon(Icons.vpn_key, color: HermesTheme.warningAmber),
              title: Text('Development Key', style: TextStyle(color: Colors.white)),
              subtitle: Text('sk-dev-••••••••1b2c', style: TextStyle(color: HermesTheme.textSecondary, fontSize: 12)),
              trailing: Icon(Icons.copy, color: HermesTheme.textSecondary),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, required this.title, required this.subtitle, required this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: HermesTheme.primaryBlue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: HermesTheme.primaryBlue, size: 20),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(color: HermesTheme.textSecondary, fontSize: 12)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

// ─── Danger Zone ──────────────────────────────────────────────────────────────

class _DangerZoneCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Danger Zone',
      icon: Icons.warning,
      titleColor: HermesTheme.errorRed,
      child: Column(
        children: [
          _DangerTile(
            icon: Icons.logout,
            title: 'Sign Out All Devices',
            subtitle: 'Sign out from all connected devices',
            buttonLabel: 'Sign Out All',
            onTap: () => _confirmSignOut(context),
          ),
          const Divider(color: HermesTheme.surfaceOverlay, height: 1),
          _DangerTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            subtitle: 'Permanently delete account and all data',
            buttonLabel: 'Delete Account',
            buttonColor: HermesTheme.errorRed,
            onTap: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HermesTheme.surfaceDark,
        title: const Text('Sign Out All Devices', style: TextStyle(color: Colors.white)),
        content: const Text('This will sign out from all connected devices. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: HermesTheme.errorRed),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HermesTheme.surfaceDark,
        title: const Text('Delete Account', style: TextStyle(color: HermesTheme.errorRed)),
        content: const Text('This action is irreversible. All your data will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: HermesTheme.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _DangerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final Color buttonColor;
  final VoidCallback onTap;

  const _DangerTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    this.buttonColor = HermesTheme.warningAmber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: buttonColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                Text(subtitle, style: const TextStyle(color: HermesTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: buttonColor,
              side: BorderSide(color: buttonColor),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: Text(buttonLabel, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ─── Edit Profile Sheet ───────────────────────────────────────────────────────

class _EditProfileSheet extends ConsumerStatefulWidget {
  final AgentProfile initialProfile;

  const _EditProfileSheet({required this.initialProfile});

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialProfile.name);
    _emailController = TextEditingController(text: widget.initialProfile.email);
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: HermesTheme.surfaceOverlay, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 24),
            const Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: HermesTheme.surfaceElevated,
                  child: Text(
                    _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: HermesTheme.primaryBlue),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: HermesTheme.primaryBlue, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)),
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Bio', prefixIcon: Icon(Icons.info_outline), alignLabelWithHint: true),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final updated = widget.initialProfile.copyWith(
      name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : widget.initialProfile.name,
      email: _emailController.text.trim(),
    );
    ref.read(appStateProvider.notifier).updateProfile(updated);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated'), behavior: SnackBarBehavior.floating));
  }
}

// ─── Shared Card ─────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color titleColor;
  final Widget child;

  const _Card({required this.title, required this.icon, this.titleColor = HermesTheme.primaryBlue, required this.child});

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
              Icon(icon, color: titleColor, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
