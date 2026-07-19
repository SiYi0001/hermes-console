import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../shared/theme/hermes_theme.dart';

/// Notifications & Alerts Screen — bound to AppState.notifications
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _showRead = false;

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(appStateProvider).notifications;
    final notifier = ref.read(appStateProvider.notifier);
    final unread = notifications.where((n) => !n.read).length;

    return Scaffold(
      backgroundColor: HermesTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: HermesTheme.backgroundBlack,
        title: const Text('Notifications'),
        actions: [
          IconButton(
            onPressed: () {
              for (final n in notifications) {
                if (!n.read) notifier.markNotificationRead(n.id);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read'), behavior: SnackBarBehavior.floating),
              );
            },
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: HermesTheme.surfaceElevated,
            onSelected: (value) {
              if (value == 'clear') {
                _clearAll(notifier);
              } else if (value == 'settings') {
                _openNotificationSettings();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'settings', child: Row(children: [Icon(Icons.settings, size: 18), SizedBox(width: 8), Text('Notification Settings')])),
              const PopupMenuItem(value: 'clear', child: Row(children: [Icon(Icons.delete_outline, size: 18), SizedBox(width: 8), Text('Clear All')])),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _NotificationStats(total: notifications.length, unread: unread),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Recent Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const Spacer(),
                Switch(value: _showRead, onChanged: (v) => setState(() => _showRead = v)),
                const Text('Show read', style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
              ],
            ),
          ),
          Expanded(
            child: _NotificationsList(
              notifications: _showRead ? notifications : notifications.where((n) => !n.read).toList(),
              onDismiss: (id) => notifier.dismissNotification(id),
              onMarkRead: (id) => notifier.markNotificationRead(id),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAll(AppStateNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HermesTheme.surfaceDark,
        title: const Text('Clear All Notifications', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to clear all notifications?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              notifier.clearNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications cleared'), behavior: SnackBarBehavior.floating),
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const _NotificationSettingsSheet(),
    );
  }
}

class _NotificationStats extends StatelessWidget {
  final int total;
  final int unread;
  const _NotificationStats({required this.total, required this.unread});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HermesTheme.primaryBlue.withOpacity(0.15), HermesTheme.secondaryPurple.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HermesTheme.primaryBlue.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatColumn(icon: Icons.mark_email_unread, value: '$unread', label: 'Unread', color: HermesTheme.errorRed),
          Container(width: 1, height: 40, color: HermesTheme.surfaceOverlay),
          _StatColumn(icon: Icons.auto_awesome, value: '$total', label: 'Total', color: HermesTheme.warningAmber),
          Container(width: 1, height: 40, color: HermesTheme.surfaceOverlay),
          _StatColumn(icon: Icons.check_circle, value: '${total - unread}', label: 'Read', color: HermesTheme.successGreen),
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
  const _StatColumn({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
        ],
      );
}

class _NotificationsList extends StatelessWidget {
  final List<AppNotification> notifications;
  final void Function(String id) onDismiss;
  final void Function(String id) onMarkRead;

  const _NotificationsList({required this.notifications, required this.onDismiss, required this.onMarkRead});

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const Center(child: Text('No notifications.', style: TextStyle(color: HermesTheme.textSecondary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: notifications.length,
      itemBuilder: (context, index) => _NotificationCard(notification: notifications[index], onDismiss: onDismiss, onMarkRead: onMarkRead),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final void Function(String id) onDismiss;
  final void Function(String id) onMarkRead;

  const _NotificationCard({required this.notification, required this.onDismiss, required this.onMarkRead});

  String _priorityText() {
    switch (notification.type) {
      case 'success':
        return 'Success';
      case 'warning':
        return 'Warning';
      case 'error':
        return 'Error';
      case 'info':
      default:
        return 'Info';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor();
    final icon = _typeIcon();
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: HermesTheme.errorRed.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete, color: HermesTheme.errorRed),
      ),
      onDismissed: (_) => onDismiss(notification.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: notification.read ? HermesTheme.surfaceDark.withOpacity(0.5) : HermesTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: notification.read ? null : Border.all(color: color.withOpacity(0.2)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(notification.title, style: TextStyle(fontSize: 14, fontWeight: notification.read ? FontWeight.normal : FontWeight.w600, color: Colors.white)),
              ),
              if (!notification.read)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(notification.body, style: const TextStyle(fontSize: 12, color: HermesTheme.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                    child: Text(_priorityText(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
                  ),
                  const SizedBox(width: 8),
                  Text(notification.timestamp.relativeTime, style: const TextStyle(fontSize: 10, color: HermesTheme.textTertiary)),
                  const Spacer(),
                  if (notification.read)
                    const SizedBox.shrink()
                  else
                    GestureDetector(
                      onTap: () => onMarkRead(notification.id),
                      child: const Text('Mark read', style: TextStyle(fontSize: 11, color: HermesTheme.primaryBlue)),
                    ),
                ],
              ),
            ],
          ),
          onTap: () => onMarkRead(notification.id),
        ),
      ),
    );
  }

  Color _typeColor() {
    switch (notification.type) {
      case 'error':
        return HermesTheme.errorRed;
      case 'success':
        return HermesTheme.successGreen;
      case 'warning':
        return HermesTheme.warningAmber;
      case 'alert':
        return HermesTheme.errorRed;
      default:
        return HermesTheme.primaryBlue;
    }
  }

  IconData _typeIcon() {
    switch (notification.type) {
      case 'error':
        return Icons.error_rounded;
      case 'success':
        return Icons.check_circle_rounded;
      case 'warning':
        return Icons.warning_rounded;
      case 'alert':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_rounded;
    }
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
            const Text('Notification Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Task Notifications', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Cron tasks, automation alerts', style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
              value: _taskNotifications,
              onChanged: (v) => setState(() => _taskNotifications = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Alert Notifications', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Connection issues, errors', style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
              value: _alertNotifications,
              onChanged: (v) => setState(() => _alertNotifications = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Update Notifications', style: TextStyle(color: Colors.white)),
              subtitle: const Text('New features and versions', style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
              value: _updateNotifications,
              onChanged: (v) => setState(() => _updateNotifications = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sound', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Play sound for new notifications', style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
              value: _soundEnabled,
              onChanged: (v) => setState(() => _soundEnabled = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Vibration', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Vibrate on new notifications', style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
              value: _vibrationEnabled,
              onChanged: (v) => setState(() => _vibrationEnabled = v),
            ),
            const SizedBox(height: 16),
            const Text('Notification Level', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(label: const Text('All'), selected: _notificationLevel == 'all', onSelected: (s) => s ? setState(() => _notificationLevel = 'all') : null),
                ChoiceChip(label: const Text('Important'), selected: _notificationLevel == 'important', onSelected: (s) => s ? setState(() => _notificationLevel = 'important') : null),
                ChoiceChip(label: const Text('None'), selected: _notificationLevel == 'none', onSelected: (s) => s ? setState(() => _notificationLevel = 'none') : null),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
