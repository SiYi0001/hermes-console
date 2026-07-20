import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../shared/theme/hermes_theme.dart';

/// Gateway / Integrations Screen
class GatewayScreen extends ConsumerStatefulWidget {
  const GatewayScreen({super.key});

  @override
  ConsumerState<GatewayScreen> createState() => _GatewayScreenState();
}

class _GatewayScreenState extends ConsumerState<GatewayScreen> {
  @override
  Widget build(BuildContext context) {
    final channels = ref.watch(appStateProvider).gatewayChannels;
    final activity = ref.watch(appStateProvider).gatewayActivity;
    final notifier = ref.read(appStateProvider.notifier);
    final connectedCount = channels.where((c) => c.connected).length;

    return Scaffold(
      backgroundColor: HermesTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: HermesTheme.backgroundBlack,
        title: const Text('Gateway & Integrations'),
        actions: [
          IconButton(
            onPressed: _setupGateway,
            icon: const Icon(Icons.settings),
            tooltip: 'Gateway Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GatewayStatusCard(connectedCount: connectedCount, total: channels.length),
            const SizedBox(height: 24),
            const Text('Connected Platforms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            _PlatformGrid(channels: channels, notifier: notifier),
            const SizedBox(height: 24),
            const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            _RecentActivityList(activity: activity),
          ],
        ),
      ),
    );
  }

  void _setupGateway() {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesTheme.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const _GatewaySettingsSheet(),
    );
  }
}

class _GatewayStatusCard extends StatelessWidget {
  final int connectedCount;
  final int total;
  const _GatewayStatusCard({required this.connectedCount, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HermesTheme.successGreen.withValues(alpha: 0.15), HermesTheme.primaryBlue.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HermesTheme.successGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: HermesTheme.successGreen.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.hub, color: HermesTheme.successGreen, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('Gateway Active', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: HermesTheme.successGreen)),
                        SizedBox(width: 8),
                        Icon(Icons.circle, size: 8, color: HermesTheme.successGreen),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(connectedCount == total ? 'All integrations operational' : '$connectedCount of $total platforms connected',
                        style: const TextStyle(fontSize: 13, color: HermesTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _GatewayStat(icon: Icons.link, value: '$connectedCount', label: 'Connected', color: HermesTheme.successGreen),
              Container(width: 1, height: 30, color: HermesTheme.surfaceOverlay),
              _GatewayStat(icon: Icons.message, value: '${total * 200}', label: 'Messages', color: HermesTheme.primaryBlue),
              Container(width: 1, height: 30, color: HermesTheme.surfaceOverlay),
              const _GatewayStat(icon: Icons.schedule, value: '99.9%', label: 'Uptime', color: HermesTheme.successGreen),
            ],
          ),
        ],
      ),
    );
  }
}

class _GatewayStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _GatewayStat({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: HermesTheme.textSecondary)),
        ],
      );
}

class _PlatformGrid extends StatelessWidget {
  final List<GatewayChannel> channels;
  final AppStateNotifier notifier;
  const _PlatformGrid({required this.channels, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: channels.length,
      itemBuilder: (context, index) => _PlatformCard(channel: channels[index], notifier: notifier),
    );
  }
}

class _PlatformCard extends StatelessWidget {
  final GatewayChannel channel;
  final AppStateNotifier notifier;
  const _PlatformCard({required this.channel, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final color = _platformColor(channel.name);
    final status = channel.connected ? 'connected' : 'disconnected';
    return GestureDetector(
      onTap: () => notifier.toggleGatewayChannel(channel.id, !channel.connected),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: HermesTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: channel.connected ? Border.all(color: color.withValues(alpha: 0.3)) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Icon(channel.icon, color: channel.connected ? color : HermesTheme.textSecondary, size: 20),
                ),
                const Spacer(),
                _StatusBadge(status: status),
              ],
            ),
            const Spacer(),
            Text(channel.name,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: channel.connected ? Colors.white : HermesTheme.textSecondary)),
            const SizedBox(height: 4),
            Text(channel.connected ? 'Online' : 'Offline',
                style: TextStyle(fontSize: 11, color: channel.connected ? HermesTheme.successGreen : HermesTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Color _platformColor(String name) {
    switch (name) {
      case 'WeChat':
        return const Color(0xFF07C160);
      case 'QQ':
        return const Color(0xFF12B7F5);
      case 'Telegram':
        return const Color(0xFF0088CC);
      case 'Discord':
        return const Color(0xFF5865F2);
      case 'Slack':
        return const Color(0xFF4A154B);
      case 'Feishu':
        return const Color(0xFF3370FF);
      default:
        return HermesTheme.secondaryPurple;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final connected = status == 'connected';
    return Icon(connected ? Icons.check_circle : Icons.cancel,
        color: connected ? HermesTheme.successGreen : HermesTheme.textSecondary, size: 18);
  }
}

class _RecentActivityList extends StatelessWidget {
  final List<GatewayActivity> activity;
  const _RecentActivityList({required this.activity});

  @override
  Widget build(BuildContext context) {
    if (activity.isEmpty) {
      return const Center(child: Text('No recent activity.', style: TextStyle(color: HermesTheme.textSecondary)));
    }
    return Column(children: activity.map((a) => _ActivityCard(activity: a)).toList());
  }
}

class _ActivityCard extends StatelessWidget {
  final GatewayActivity activity;
  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final color = _platformColor(activity.channel);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: HermesTheme.surfaceDark, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.campaign, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.channel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                Text(activity.message, style: const TextStyle(fontSize: 11, color: HermesTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(activity.timestamp.relativeTime, style: const TextStyle(fontSize: 10, color: HermesTheme.textTertiary)),
        ],
      ),
    );
  }

  Color _platformColor(String name) {
    switch (name) {
      case 'WeChat':
        return const Color(0xFF07C160);
      case 'QQ':
        return const Color(0xFF12B7F5);
      case 'Telegram':
        return const Color(0xFF0088CC);
      case 'Discord':
        return const Color(0xFF5865F2);
      case 'Slack':
        return const Color(0xFF4A154B);
      case 'Feishu':
        return const Color(0xFF3370FF);
      default:
        return HermesTheme.secondaryPurple;
    }
  }
}

/// Gateway Settings Sheet
class _GatewaySettingsSheet extends StatefulWidget {
  const _GatewaySettingsSheet();

  @override
  State<_GatewaySettingsSheet> createState() => _GatewaySettingsSheetState();
}

class _GatewaySettingsSheetState extends State<_GatewaySettingsSheet> {
  bool _autoReply = true;
  bool _notifications = true;
  bool _typingIndicator = true;

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
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: HermesTheme.surfaceOverlay, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Gateway Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto Reply', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Automatically reply to messages', style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
              value: _autoReply,
              onChanged: (v) => setState(() => _autoReply = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Push Notifications', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Receive notifications for new messages', style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
              value: _notifications,
              onChanged: (v) => setState(() => _notifications = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Typing Indicator', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Show when agent is typing', style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
              value: _typingIndicator,
              onChanged: (v) => setState(() => _typingIndicator = v),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.portrait, color: HermesTheme.primaryBlue),
              title: const Text('Default Identity', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Configure default persona', style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.block, color: HermesTheme.warningAmber),
              title: const Text('Block List', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Manage blocked users', style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
