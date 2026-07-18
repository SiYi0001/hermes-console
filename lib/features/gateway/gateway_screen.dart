import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            _GatewayStatusCard(),
            const SizedBox(height: 24),
            const Text(
              'Connected Platforms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _PlatformGrid(),
            const SizedBox(height: 24),
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _RecentActivityList(),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _GatewaySettingsSheet(),
    );
  }
}

class _GatewayStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HermesTheme.successGreen.withOpacity(0.15),
            HermesTheme.primaryBlue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: HermesTheme.successGreen.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: HermesTheme.successGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.hub,
                  color: HermesTheme.successGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Gateway Active',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: HermesTheme.successGreen,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: HermesTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'All integrations operational',
                      style: TextStyle(
                        fontSize: 13,
                        color: HermesTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _GatewayStat(
                icon: Icons.link,
                value: '5',
                label: 'Connected',
                color: HermesTheme.successGreen,
              ),
              Container(
                width: 1,
                height: 30,
                color: HermesTheme.surfaceOverlay,
              ),
              _GatewayStat(
                icon: Icons.message,
                value: '1.2K',
                label: 'Messages',
                color: HermesTheme.primaryBlue,
              ),
              Container(
                width: 1,
                height: 30,
                color: HermesTheme.surfaceOverlay,
              ),
              _GatewayStat(
                icon: Icons.schedule,
                value: '99.9%',
                label: 'Uptime',
                color: HermesTheme.successGreen,
              ),
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

  const _GatewayStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: HermesTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PlatformGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final platforms = [
      _Platform(
        name: 'WeChat',
        icon: Icons.chat,
        color: const Color(0xFF07C160),
        status: 'connected',
        unread: 3,
      ),
      _Platform(
        name: 'QQ',
        icon: Icons.alternate_email,
        color: const Color(0xFF12B7F5),
        status: 'connected',
        unread: 0,
      ),
      _Platform(
        name: 'Telegram',
        icon: Icons.send,
        color: const Color(0xFF0088CC),
        status: 'connected',
        unread: 12,
      ),
      _Platform(
        name: 'Discord',
        icon: Icons.discord,
        color: const Color(0xFF5865F2),
        status: 'inactive',
        unread: 0,
      ),
      _Platform(
        name: 'Slack',
        icon: Icons.tag,
        color: const Color(0xFF4A154B),
        status: 'disconnected',
        unread: 0,
      ),
      _Platform(
        name: 'Feishu',
        icon: Icons.business,
        color: const Color(0xFF3370FF),
        status: 'connected',
        unread: 5,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: platforms.length,
      itemBuilder: (context, index) {
        return _PlatformCard(platform: platforms[index]);
      },
    );
  }
}

class _PlatformCard extends StatelessWidget {
  final _Platform platform;

  const _PlatformCard({required this.platform});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: platform.status == 'connected'
            ? Border.all(color: platform.color.withOpacity(0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: platform.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  platform.icon,
                  color: platform.status == 'connected'
                      ? platform.color
                      : HermesTheme.textSecondary,
                  size: 20,
                ),
              ),
              const Spacer(),
              _StatusBadge(status: platform.status),
            ],
          ),
          const Spacer(),
          Text(
            platform.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: platform.status == 'connected'
                  ? Colors.white
                  : HermesTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (platform.unread > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: HermesTheme.errorRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${platform.unread}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                platform.status == 'connected' ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 11,
                  color: platform.status == 'connected'
                      ? HermesTheme.successGreen
                      : HermesTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case 'connected':
        color = HermesTheme.successGreen;
        icon = Icons.check_circle;
        break;
      case 'inactive':
        color = HermesTheme.warningAmber;
        icon = Icons.pause_circle;
        break;
      default:
        color = HermesTheme.textSecondary;
        icon = Icons.cancel;
    }

    return Icon(icon, color: color, size: 18);
  }
}

class _RecentActivityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final activities = [
      _Activity(
        platform: 'WeChat',
        icon: Icons.chat,
        color: const Color(0xFF07C160),
        message: 'Received: "帮我检查代码"',
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        status: 'processed',
      ),
      _Activity(
        platform: 'Telegram',
        icon: Icons.send,
        color: const Color(0xFF0088CC),
        message: 'Sent: Daily report generated',
        time: DateTime.now().subtract(const Duration(minutes: 15)),
        status: 'success',
      ),
      _Activity(
        platform: 'Feishu',
        icon: Icons.business,
        color: const Color(0xFF3370FF),
        message: 'Webhook received from automation',
        time: DateTime.now().subtract(const Duration(hours: 1)),
        status: 'success',
      ),
      _Activity(
        platform: 'QQ',
        icon: Icons.alternate_email,
        color: const Color(0xFF12B7F5),
        message: 'Command executed: /status',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'success',
      ),
    ];

    return Column(
      children: activities.map((a) => _ActivityCard(activity: a)).toList(),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final _Activity activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activity.icon,
              color: activity.color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.platform,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  activity.message,
                  style: const TextStyle(
                    fontSize: 11,
                    color: HermesTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(activity.time),
                style: const TextStyle(
                  fontSize: 10,
                  color: HermesTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                activity.status == 'success' || activity.status == 'processed'
                    ? Icons.check_circle
                    : Icons.error,
                size: 14,
                color: activity.status == 'success' || activity.status == 'processed'
                    ? HermesTheme.successGreen
                    : HermesTheme.errorRed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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
                decoration: BoxDecoration(
                  color: HermesTheme.surfaceOverlay,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Gateway Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Auto Reply',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Automatically reply to messages',
                style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary),
              ),
              value: _autoReply,
              onChanged: (value) => setState(() => _autoReply = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Push Notifications',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Receive notifications for new messages',
                style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary),
              ),
              value: _notifications,
              onChanged: (value) => setState(() => _notifications = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Typing Indicator',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Show when agent is typing',
                style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary),
              ),
              value: _typingIndicator,
              onChanged: (value) => setState(() => _typingIndicator = value),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.portrait, color: HermesTheme.primaryBlue),
              title: const Text('Default Identity', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Configure default persona',
                  style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.block, color: HermesTheme.warningAmber),
              title: const Text('Block List', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Manage blocked users',
                  style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Models
class _Platform {
  final String name;
  final IconData icon;
  final Color color;
  final String status;
  final int unread;

  _Platform({
    required this.name,
    required this.icon,
    required this.color,
    required this.status,
    required this.unread,
  });
}

class _Activity {
  final String platform;
  final IconData icon;
  final Color color;
  final String message;
  final DateTime time;
  final String status;

  _Activity({
    required this.platform,
    required this.icon,
    required this.color,
    required this.message,
    required this.time,
    required this.status,
  });
}
