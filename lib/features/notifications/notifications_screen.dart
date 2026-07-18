import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme/hermes_theme.dart';

/// Notifications & Alerts Screen
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _showRead = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HermesTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: HermesTheme.backgroundBlack,
        title: const Text('Notifications'),
        actions: [
          IconButton(
            onPressed: _markAllRead,
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear') {
                _clearAll();
              } else if (value == 'settings') {
                _openNotificationSettings();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 18),
                    SizedBox(width: 8),
                    Text('Notification Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18),
                    SizedBox(width: 8),
                    Text('Clear All'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _NotificationStats(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Recent Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _showRead,
                  onChanged: (value) => setState(() => _showRead = value),
                ),
                const Text(
                  'Show read',
                  style: TextStyle(
                    fontSize: 12,
                    color: HermesTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _NotificationsList(showRead: _showRead),
          ),
        ],
      ),
    );
  }

  void _markAllRead() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HermesTheme.surfaceDark,
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications?'),
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
                  content: Text('Notifications cleared'),
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

  void _openNotificationSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _NotificationSettingsSheet(),
    );
  }
}

class _NotificationStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatColumn(
            icon: Icons.mark_email_unread,
            value: '5',
            label: 'Unread',
            color: HermesTheme.errorRed,
          ),
          Container(
            width: 1,
            height: 40,
            color: HermesTheme.surfaceOverlay,
          ),
          _StatColumn(
            icon: Icons.auto_awesome,
            value: '12',
            label: 'Tasks',
            color: HermesTheme.warningAmber,
          ),
          Container(
            width: 1,
            height: 40,
            color: HermesTheme.surfaceOverlay,
          ),
          _StatColumn(
            icon: Icons.check_circle,
            value: '89',
            label: 'Processed',
            color: HermesTheme.successGreen,
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
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

class _NotificationsList extends StatelessWidget {
  final bool showRead;

  const _NotificationsList({required this.showRead});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      _NotificationItem(
        id: '1',
        title: 'Daily Report Ready',
        body: 'Your daily standup report has been generated and sent to Slack.',
        type: NotificationType.task,
        priority: NotificationPriority.high,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
        actions: ['View', 'Dismiss'],
      ),
      _NotificationItem(
        id: '2',
        title: 'Connection Lost',
        body: 'P2P connection to hermes-agent-001 was interrupted. Auto-reconnecting...',
        type: NotificationType.alert,
        priority: NotificationPriority.critical,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isRead: false,
        actions: ['Retry', 'Dismiss'],
      ),
      _NotificationItem(
        id: '3',
        title: 'Memory Sync Complete',
        body: '45 memories synced successfully. 3 new skills learned.',
        type: NotificationType.success,
        priority: NotificationPriority.low,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
        actions: ['View', 'Dismiss'],
      ),
      _NotificationItem(
        id: '4',
        title: 'New Skill Available',
        body: 'Code Review skill has been updated to version 2.0 with improved analysis.',
        type: NotificationType.update,
        priority: NotificationPriority.medium,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
        actions: ['Learn More', 'Dismiss'],
      ),
      _NotificationItem(
        id: '5',
        title: 'Cron Task Completed',
        body: 'Automated database backup completed successfully (45.2 MB).',
        type: NotificationType.task,
        priority: NotificationPriority.low,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: true,
        actions: ['View', 'Dismiss'],
      ),
      _NotificationItem(
        id: '6',
        title: 'File Transfer Complete',
        body: 'project_backup.zip has been uploaded to the agent.',
        type: NotificationType.success,
        priority: NotificationPriority.medium,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: true,
        actions: ['View', 'Dismiss'],
      ),
    ];

    final filtered = showRead
        ? notifications
        : notifications.where((n) => !n.isRead).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _NotificationCard(notification: filtered[index]);
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final _NotificationItem notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: notification.isRead
            ? null
            : Border.all(
                color: _getPriorityColor().withOpacity(0.3),
                width: 1,
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _markAsRead(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getTypeColor().withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getTypeIcon(),
                        color: _getTypeColor(),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: notification.isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (!notification.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getPriorityColor(),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(notification.timestamp),
                            style: const TextStyle(
                              fontSize: 11,
                              color: HermesTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: HermesTheme.textSecondary,
                        size: 20,
                      ),
                      color: HermesTheme.surfaceElevated,
                      onSelected: (value) {
                        if (value == 'mark_read') {
                          _markAsRead(context);
                        } else if (value == 'dismiss') {
                          _dismiss(context);
                        }
                      },
                      itemBuilder: (context) => [
                        if (!notification.isRead)
                          const PopupMenuItem(
                            value: 'mark_read',
                            child: Row(
                              children: [
                                Icon(Icons.check, size: 18),
                                SizedBox(width: 8),
                                Text('Mark as Read'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'dismiss',
                          child: Row(
                            children: [
                              Icon(Icons.close, size: 18),
                              SizedBox(width: 8),
                              Text('Dismiss'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  notification.body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: HermesTheme.textSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _PriorityBadge(priority: notification.priority),
                    const Spacer(),
                    ...notification.actions.map((action) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            action,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _markAsRead(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification marked as read'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _dismiss(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification dismissed'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  Color _getTypeColor() {
    switch (notification.type) {
      case NotificationType.alert:
        return HermesTheme.errorRed;
      case NotificationType.success:
        return HermesTheme.successGreen;
      case NotificationType.task:
        return HermesTheme.primaryBlue;
      case NotificationType.update:
        return HermesTheme.warningAmber;
      case NotificationType.message:
        return HermesTheme.secondaryPurple;
    }
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case NotificationType.alert:
        return Icons.warning_rounded;
      case NotificationType.success:
        return Icons.check_circle_rounded;
      case NotificationType.task:
        return Icons.task_alt_rounded;
      case NotificationType.update:
        return Icons.system_update;
      case NotificationType.message:
        return Icons.message_rounded;
    }
  }

  Color _getPriorityColor() {
    switch (notification.priority) {
      case NotificationPriority.critical:
        return HermesTheme.errorRed;
      case NotificationPriority.high:
        return HermesTheme.warningAmber;
      case NotificationPriority.medium:
        return HermesTheme.primaryBlue;
      case NotificationPriority.low:
        return HermesTheme.textSecondary;
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _PriorityBadge extends StatelessWidget {
  final NotificationPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (priority) {
      case NotificationPriority.critical:
        color = HermesTheme.errorRed;
        text = 'CRITICAL';
        break;
      case NotificationPriority.high:
        color = HermesTheme.warningAmber;
        text = 'HIGH';
        break;
      case NotificationPriority.medium:
        color = HermesTheme.primaryBlue;
        text = 'MEDIUM';
        break;
      case NotificationPriority.low:
        color = HermesTheme.textSecondary;
        text = 'LOW';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Notification Settings Sheet
class _NotificationSettingsSheet extends StatefulWidget {
  const _NotificationSettingsSheet();

  @override
  State<_NotificationSettingsSheet> createState() => _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<_NotificationSettingsSheet> {
  bool _taskNotifications = true;
  bool _alertNotifications = true;
  bool _updateNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _notificationLevel = 'all';

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
              'Notification Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Task Notifications',
                  style: TextStyle(color: Colors.white)),
              subtitle: const Text('Cron tasks, automation alerts',
                  style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
              value: _taskNotifications,
              onChanged: (value) => setState(() => _taskNotifications = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Alert Notifications',
                  style: TextStyle(color: Colors.white)),
              subtitle: const Text('Connection issues, errors',
                  style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
              value: _alertNotifications,
              onChanged: (value) => setState(() => _alertNotifications = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Update Notifications',
                  style: TextStyle(color: Colors.white)),
              subtitle: const Text('New skills, system updates',
                  style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
              value: _updateNotifications,
              onChanged: (value) => setState(() => _updateNotifications = value),
            ),
            const Divider(color: HermesTheme.surfaceOverlay, height: 32),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sound', style: TextStyle(color: Colors.white)),
              value: _soundEnabled,
              onChanged: (value) => setState(() => _soundEnabled = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Vibration', style: TextStyle(color: Colors.white)),
              value: _vibrationEnabled,
              onChanged: (value) => setState(() => _vibrationEnabled = value),
            ),
            const SizedBox(height: 16),
            const Text(
              'Notification Level',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _notificationLevel == 'all',
                  onSelected: (selected) {
                    if (selected) setState(() => _notificationLevel = 'all');
                  },
                ),
                ChoiceChip(
                  label: const Text('Important'),
                  selected: _notificationLevel == 'important',
                  onSelected: (selected) {
                    if (selected) setState(() => _notificationLevel = 'important');
                  },
                ),
                ChoiceChip(
                  label: const Text('None'),
                  selected: _notificationLevel == 'none',
                  onSelected: (selected) {
                    if (selected) setState(() => _notificationLevel = 'none');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Enums and Models
enum NotificationType { alert, success, task, update, message }

enum NotificationPriority { critical, high, medium, low }

class _NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime timestamp;
  final bool isRead;
  final List<String> actions;

  _NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    required this.timestamp,
    required this.isRead,
    required this.actions,
  });
}
