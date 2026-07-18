import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/connection_state.dart';

// Connection state provider
final connectionStateProvider =
    StateNotifierProvider<ConnectionNotifier, ConnectionState>((ref) {
  return ConnectionNotifier();
});

class ConnectionNotifier extends StateNotifier<ConnectionState> {
  ConnectionNotifier() : super(ConnectionState.disconnected());

  void connect(String nodeId) {
    state = state.copyWith(
      status: ConnectionStatus.connecting,
      nodeId: nodeId,
    );

    // Simulate connection
    Future.delayed(const Duration(seconds: 2), () {
      if (state.status == ConnectionStatus.connecting) {
        state = state.copyWith(
          status: ConnectionStatus.connected,
          connectedAt: DateTime.now(),
          latency: 25,
        );
      }
    });
  }

  void disconnect() {
    state = ConnectionState.disconnected();
  }

  void updateLatency(int latency) {
    state = state.copyWith(latency: latency);
  }

  void updateBandwidth(double upload, double download) {
    state = state.copyWith(
      bandwidthUpload: upload,
      bandwidthDownload: download,
    );
  }
}

// Session history provider
final sessionHistoryProvider =
    StateNotifierProvider<SessionHistoryNotifier, List<SessionInfo>>((ref) {
  return SessionHistoryNotifier();
});

class SessionHistoryNotifier extends StateNotifier<List<SessionInfo>> {
  SessionHistoryNotifier()
      : super([
          SessionInfo(
            id: '1',
            nodeId: 'hermes-agent-001',
            nodeName: 'Production Server',
            connectedAt: DateTime.now().subtract(const Duration(hours: 2)),
            disconnectedAt: DateTime.now().subtract(const Duration(hours: 1)),
            commandsCount: 45,
            dataTransferred: '12.5 MB',
          ),
          SessionInfo(
            id: '2',
            nodeId: 'hermes-dev-002',
            nodeName: 'Development VM',
            connectedAt: DateTime.now().subtract(const Duration(days: 1)),
            disconnectedAt: DateTime.now().subtract(const Duration(days: 1)),
            commandsCount: 23,
            dataTransferred: '2.3 MB',
          ),
        ]);

  void addSession(SessionInfo session) {
    state = [session, ...state];
  }

  void clearHistory() {
    state = [];
  }
}

// Notifications provider
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationItem>>((ref) {
  return NotificationsNotifier();
});

class NotificationsNotifier extends StateNotifier<List<NotificationItem>> {
  NotificationsNotifier()
      : super([
          NotificationItem(
            id: '1',
            title: 'Daily Report Ready',
            body: 'Your daily standup report has been generated.',
            type: NotificationType.task,
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            isRead: false,
          ),
          NotificationItem(
            id: '2',
            title: 'Connection Lost',
            body: 'P2P connection was interrupted. Auto-reconnecting...',
            type: NotificationType.alert,
            timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
            isRead: false,
          ),
        ]);

  int get unreadCount => state.where((n) => !n.isRead).length;

  void addNotification(NotificationItem notification) {
    state = [notification, ...state];
  }

  void markAsRead(String id) {
    state = state.map((n) {
      if (n.id == id) {
        return NotificationItem(
          id: n.id,
          title: n.title,
          body: n.body,
          type: n.type,
          timestamp: n.timestamp,
          isRead: true,
        );
      }
      return n;
    }).toList();
  }

  void markAllAsRead() {
    state = state.map((n) => NotificationItem(
      id: n.id,
      title: n.title,
      body: n.body,
      type: n.type,
      timestamp: n.timestamp,
      isRead: true,
    )).toList();
  }

  void removeNotification(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void clearAll() {
    state = [];
  }
}

// Memory provider
final memoryProvider =
    StateNotifierProvider<MemoryNotifier, List<MemoryItem>>((ref) {
  return MemoryNotifier();
});

class MemoryNotifier extends StateNotifier<List<MemoryItem>> {
  MemoryNotifier()
      : super([
          MemoryItem(
            id: '1',
            title: 'Project Configuration',
            content: 'The user prefers dark theme.',
            category: 'Preferences',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            importance: 5,
          ),
          MemoryItem(
            id: '2',
            title: 'API Integration',
            content: 'REST API endpoint: https://api.example.com/v1',
            category: 'Technical',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            importance: 4,
          ),
        ]);

  void addMemory(MemoryItem memory) {
    state = [memory, ...state];
  }

  void updateMemory(MemoryItem memory) {
    state = state.map((m) => m.id == memory.id ? memory : m).toList();
  }

  void deleteMemory(String id) {
    state = state.where((m) => m.id != id).toList();
  }
}

// Skills provider
final skillsProvider =
    StateNotifierProvider<SkillsNotifier, List<SkillItem>>((ref) {
  return SkillsNotifier();
});

class SkillsNotifier extends StateNotifier<List<SkillItem>> {
  SkillsNotifier()
      : super([
          SkillItem(
            id: '1',
            name: 'Code Review',
            description: 'Automated code review with best practices',
            category: 'Development',
            usageCount: 42,
            lastUsed: DateTime.now().subtract(const Duration(hours: 3)),
            isEnabled: true,
          ),
          SkillItem(
            id: '2',
            name: 'API Documentation',
            description: 'Generate OpenAPI documentation',
            category: 'Documentation',
            usageCount: 28,
            lastUsed: DateTime.now().subtract(const Duration(days: 1)),
            isEnabled: true,
          ),
          SkillItem(
            id: '3',
            name: 'Database Migration',
            description: 'Safe database schema migration',
            category: 'Database',
            usageCount: 15,
            lastUsed: DateTime.now().subtract(const Duration(days: 2)),
            isEnabled: false,
          ),
        ]);

  void toggleSkill(String id) {
    state = state.map((s) {
      if (s.id == id) {
        return SkillItem(
          id: s.id,
          name: s.name,
          description: s.description,
          category: s.category,
          usageCount: s.usageCount,
          lastUsed: s.lastUsed,
          isEnabled: !s.isEnabled,
        );
      }
      return s;
    }).toList();
  }

  void incrementUsage(String id) {
    state = state.map((s) {
      if (s.id == id) {
        return SkillItem(
          id: s.id,
          name: s.name,
          description: s.description,
          category: s.category,
          usageCount: s.usageCount + 1,
          lastUsed: DateTime.now(),
          isEnabled: s.isEnabled,
        );
      }
      return s;
    }).toList();
  }
}

// Cron tasks provider
final cronTasksProvider =
    StateNotifierProvider<CronTasksNotifier, List<CronTask>>((ref) {
  return CronTasksNotifier();
});

class CronTasksNotifier extends StateNotifier<List<CronTask>> {
  CronTasksNotifier()
      : super([
          CronTask(
            id: '1',
            name: 'Daily Standup Report',
            description: 'Generate daily standup report',
            schedule: '0 9 * * *',
            scheduleLabel: 'Daily at 9:00 AM',
            isEnabled: true,
            totalRuns: 234,
            successRuns: 231,
            failedRuns: 3,
            lastRun: DateTime.now().subtract(const Duration(hours: 9)),
          ),
          CronTask(
            id: '2',
            name: 'Database Backup',
            description: 'Backup database to cloud storage',
            schedule: '0 2 * * *',
            scheduleLabel: 'Daily at 2:00 AM',
            isEnabled: true,
            totalRuns: 89,
            successRuns: 89,
            failedRuns: 0,
            lastRun: DateTime.now().subtract(const Duration(hours: 16)),
          ),
          CronTask(
            id: '3',
            name: 'Health Check',
            description: 'Check system health and send alerts',
            schedule: '*/15 * * * *',
            scheduleLabel: 'Every 15 minutes',
            isEnabled: false,
            totalRuns: 1245,
            successRuns: 1238,
            failedRuns: 7,
            lastRun: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ]);

  void addTask(CronTask task) {
    state = [...state, task];
  }

  void toggleTask(String id) {
    state = state.map((t) {
      if (t.id == id) {
        return CronTask(
          id: t.id,
          name: t.name,
          description: t.description,
          schedule: t.schedule,
          scheduleLabel: t.scheduleLabel,
          isEnabled: !t.isEnabled,
          totalRuns: t.totalRuns,
          successRuns: t.successRuns,
          failedRuns: t.failedRuns,
          lastRun: t.lastRun,
        );
      }
      return t;
    }).toList();
  }

  void deleteTask(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  void runNow(String id) {
    // Trigger immediate execution
    state = state.map((t) {
      if (t.id == id) {
        return CronTask(
          id: t.id,
          name: t.name,
          description: t.description,
          schedule: t.schedule,
          scheduleLabel: t.scheduleLabel,
          isEnabled: t.isEnabled,
          totalRuns: t.totalRuns + 1,
          successRuns: t.successRuns + 1,
          failedRuns: t.failedRuns,
          lastRun: DateTime.now(),
        );
      }
      return t;
    }).toList();
  }
}

// Settings provider
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier()
      : super(AppSettings(
          darkMode: true,
          notificationsEnabled: true,
          hapticFeedback: true,
          soundEnabled: true,
          autoConnect: true,
          compressionEnabled: true,
          encryptionEnabled: true,
        ));

  void updateSettings(AppSettings settings) {
    state = settings;
  }

  void toggleSetting(String key, dynamic value) {
    switch (key) {
      case 'darkMode':
        state = AppSettings(
          darkMode: value,
          notificationsEnabled: state.notificationsEnabled,
          hapticFeedback: state.hapticFeedback,
          soundEnabled: state.soundEnabled,
          autoConnect: state.autoConnect,
          compressionEnabled: state.compressionEnabled,
          encryptionEnabled: state.encryptionEnabled,
        );
        break;
      case 'notificationsEnabled':
        state = AppSettings(
          darkMode: state.darkMode,
          notificationsEnabled: value,
          hapticFeedback: state.hapticFeedback,
          soundEnabled: state.soundEnabled,
          autoConnect: state.autoConnect,
          compressionEnabled: state.compressionEnabled,
          encryptionEnabled: state.encryptionEnabled,
        );
        break;
      // Add more settings...
    }
  }
}
