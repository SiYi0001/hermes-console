import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/connection_state.dart';

/// Optimized Connection State Provider
/// Uses selective rebuilds to minimize widget tree rebuilds
final connectionStateProvider =
    StateNotifierProvider<ConnectionNotifier, ConnectionState>((ref) {
  return ConnectionNotifier();
});

/// Selective provider for connection status only (avoids rebuild on latency change)
final connectionStatusProvider = Provider<ConnectionStatus>((ref) {
  return ref.watch(connectionStateProvider.select((s) => s.status));
});

/// Selective provider for latency (avoids rebuild on status change)
final connectionLatencyProvider = Provider<int>((ref) {
  return ref.watch(connectionStateProvider.select((s) => s.latency));
});

class ConnectionNotifier extends StateNotifier<ConnectionState> {
  ConnectionNotifier() : super(ConnectionState.disconnected());

  void connect(String nodeId) {
    state = ConnectionState(
      status: ConnectionStatus.connecting,
      nodeId: nodeId,
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && state.status == ConnectionStatus.connecting) {
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
    // Selective update - only trigger rebuild for latency watchers
    state = ConnectionState(
      status: state.status,
      nodeId: state.nodeId,
      nodeName: state.nodeName,
      connectedAt: state.connectedAt,
      latency: latency,
      bandwidthUpload: state.bandwidthUpload,
      bandwidthDownload: state.bandwidthDownload,
      errorMessage: state.errorMessage,
    );
  }

  void updateBandwidth(double upload, double download) {
    state = state.copyWith(
      bandwidthUpload: upload,
      bandwidthDownload: download,
    );
  }
}

/// Optimized Session History Provider with lazy loading
final sessionHistoryProvider =
    StateNotifierProvider<SessionHistoryNotifier, List<SessionInfo>>((ref) {
  return SessionHistoryNotifier();
});

/// Paginated session history for performance
final sessionHistoryPageProvider =
    FutureProvider.family<List<SessionInfo>, int>((ref, page) async {
  final sessions = ref.watch(sessionHistoryProvider);
  
  // Simulate lazy loading
  await Future.delayed(const Duration(milliseconds: 100));
  
  const pageSize = 20;
  final start = page * pageSize;
  if (start >= sessions.length) return [];
  
  return sessions.sublist(
    start,
    (start + pageSize).clamp(0, sessions.length),
  );
});

class SessionHistoryNotifier extends StateNotifier<List<SessionInfo>> {
  SessionHistoryNotifier() : super(_cachedSessions);

  static final List<SessionInfo> _cachedSessions = [
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
  ];

  void addSession(SessionInfo session) {
    state = [session, ...state];
  }

  void clearHistory() {
    state = [];
  }
}

/// Optimized Notifications Provider with debouncing
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier();
});

/// Selective unread count provider - only rebuilds when count changes
final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider.select((s) => s.unreadCount));
});

/// Cached notifications list
final notificationsListProvider = Provider<List<NotificationItem>>((ref) {
  return ref.watch(notificationsProvider).notifications;
});

class NotificationsState {
  final List<NotificationItem> notifications;
  final int _lastReadCount;

  NotificationsState({
    required this.notifications,
    int? lastReadCount,
  }) : _lastReadCount = lastReadCount ?? notifications.where((n) => !n.isRead).length;

  int get unreadCount => _lastReadCount;
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier() : super(NotificationsState(notifications: _initialNotifications));

  static final List<NotificationItem> _initialNotifications = [
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
  ];

  int get unreadCount => state.notifications.where((n) => !n.isRead).length;

  void addNotification(NotificationItem notification) {
    state = NotificationsState(
      notifications: [notification, ...state.notifications],
    );
  }

  void markAsRead(String id) {
    state = NotificationsState(
      notifications: state.notifications.map((n) {
        if (n.id == id && !n.isRead) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList(),
    );
  }

  void markAllAsRead() {
    state = NotificationsState(
      notifications: state.notifications.map((n) => n.copyWith(isRead: true)).toList(),
    );
  }

  void removeNotification(String id) {
    state = NotificationsState(
      notifications: state.notifications.where((n) => n.id != id).toList(),
    );
  }

  void clearAll() {
    state = NotificationsState(notifications: []);
  }
}

/// Optimized Memory Provider with search caching
final memoryProvider =
    StateNotifierProvider<MemoryNotifier, MemoryState>((ref) {
  return MemoryNotifier();
});

/// Memory search provider with caching
final memorySearchProvider = Provider.family<List<MemoryItem>, String>((ref, query) {
  final state = ref.watch(memoryProvider);
  if (query.isEmpty) return state.memories;
  
  final lowerQuery = query.toLowerCase();
  return state.memories.where((m) =>
    m.title.toLowerCase().contains(lowerQuery) ||
    m.content.toLowerCase().contains(lowerQuery)
  ).toList();
});

/// Memory categories provider
final memoryCategoriesProvider = Provider<List<String>>((ref) {
  final memories = ref.watch(memoryProvider).memories;
  return memories.map((m) => m.category).toSet().toList();
});

class MemoryState {
  final List<MemoryItem> memories;
  
  MemoryState({required this.memories});
}

class MemoryNotifier extends StateNotifier<MemoryState> {
  MemoryNotifier() : super(MemoryState(memories: _initialMemories));

  static final List<MemoryItem> _initialMemories = [
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
  ];

  void addMemory(MemoryItem memory) {
    state = MemoryState(memories: [memory, ...state.memories]);
  }

  void updateMemory(MemoryItem memory) {
    state = MemoryState(
      memories: state.memories.map((m) => m.id == memory.id ? memory : m).toList(),
    );
  }

  void deleteMemory(String id) {
    state = MemoryState(
      memories: state.memories.where((m) => m.id != id).toList(),
    );
  }
}

/// Optimized Skills Provider with lazy initialization
final skillsProvider =
    StateNotifierProvider<SkillsNotifier, SkillsState>((ref) {
  return SkillsNotifier();
});

/// Enabled skills only provider
final enabledSkillsProvider = Provider<List<SkillItem>>((ref) {
  return ref.watch(skillsProvider.select((s) => 
    s.skills.where((skill) => skill.isEnabled).toList()
  ));
});

/// Skills by category provider
final skillsByCategoryProvider = Provider<Map<String, List<SkillItem>>>((ref) {
  final skills = ref.watch(skillsProvider).skills;
  final Map<String, List<SkillItem>> grouped = {};
  
  for (final skill in skills) {
    grouped.putIfAbsent(skill.category, () => []).add(skill);
  }
  
  return grouped;
});

class SkillsState {
  final List<SkillItem> skills;
  final Set<String> _enabledCategories;
  
  SkillsState({
    required this.skills,
    Set<String>? enabledCategories,
  }) : _enabledCategories = enabledCategories ?? skills
            .where((s) => s.isEnabled)
            .map((s) => s.category)
            .toSet();

  List<SkillItem> get enabledSkills => 
      skills.where((s) => s.isEnabled).toList();
  
  int get totalUsageCount => 
      skills.fold(0, (sum, s) => sum + s.usageCount);
}

class SkillsNotifier extends StateNotifier<SkillsState> {
  SkillsNotifier() : super(SkillsState(skills: _initialSkills));

  static final List<SkillItem> _initialSkills = [
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
  ];

  void toggleSkill(String id) {
    state = SkillsState(
      skills: state.skills.map((s) {
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
      }).toList(),
    );
  }

  void incrementUsage(String id) {
    state = SkillsState(
      skills: state.skills.map((s) {
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
      }).toList(),
    );
  }
}

/// Optimized Cron Tasks Provider
final cronTasksProvider =
    StateNotifierProvider<CronTasksNotifier, CronTasksState>((ref) {
  return CronTasksNotifier();
});

/// Active cron tasks only
final activeCronTasksProvider = Provider<List<CronTask>>((ref) {
  return ref.watch(cronTasksProvider.select((s) =>
    s.tasks.where((t) => t.isEnabled).toList()
  ));
});

/// Cron task statistics
final cronTaskStatsProvider = Provider<CronTaskStats>((ref) {
  final tasks = ref.watch(cronTasksProvider).tasks;
  
  return CronTaskStats(
    totalTasks: tasks.length,
    activeTasks: tasks.where((t) => t.isEnabled).length,
    totalRuns: tasks.fold(0, (sum, t) => sum + t.totalRuns),
    successRate: tasks.isEmpty ? 0 :
        tasks.fold(0.0, (sum, t) => sum + t.successRate) / tasks.length,
  );
});

class CronTaskStats {
  final int totalTasks;
  final int activeTasks;
  final int totalRuns;
  final double successRate;
  
  CronTaskStats({
    required this.totalTasks,
    required this.activeTasks,
    required this.totalRuns,
    required this.successRate,
  });
}

class CronTasksState {
  final List<CronTask> tasks;
  
  CronTasksState({required this.tasks});
}

class CronTasksNotifier extends StateNotifier<CronTasksState> {
  CronTasksNotifier() : super(CronTasksState(tasks: _initialTasks));

  static final List<CronTask> _initialTasks = [
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
  ];

  void addTask(CronTask task) {
    state = CronTasksState(tasks: [...state.tasks, task]);
  }

  void toggleTask(String id) {
    state = CronTasksState(
      tasks: state.tasks.map((t) {
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
      }).toList(),
    );
  }

  void deleteTask(String id) {
    state = CronTasksState(
      tasks: state.tasks.where((t) => t.id != id).toList(),
    );
  }

  void runNow(String id) {
    state = CronTasksState(
      tasks: state.tasks.map((t) {
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
      }).toList(),
    );
  }
}

/// Lightweight settings provider for common settings
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

/// Quick access settings selectors
final quickSettingsProvider = Provider<QuickSettings>((ref) {
  final settings = ref.watch(settingsProvider);
  return QuickSettings(
    notificationsEnabled: settings.notificationsEnabled,
    compressionEnabled: settings.compressionEnabled,
    encryptionEnabled: settings.encryptionEnabled,
  );
});

class QuickSettings {
  final bool notificationsEnabled;
  final bool compressionEnabled;
  final bool encryptionEnabled;
  
  QuickSettings({
    required this.notificationsEnabled,
    required this.compressionEnabled,
    required this.encryptionEnabled,
  });
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(_defaultSettings);

  static final AppSettings _defaultSettings = AppSettings(
    darkMode: true,
    notificationsEnabled: true,
    hapticFeedback: true,
    soundEnabled: true,
    autoConnect: true,
    compressionEnabled: true,
    encryptionEnabled: true,
  );

  void updateSettings(AppSettings settings) {
    state = settings;
  }

  void toggleSetting(String key, bool value) {
    switch (key) {
      case 'darkMode':
        state = state.copyWith(darkMode: value);
        break;
      case 'notificationsEnabled':
        state = state.copyWith(notificationsEnabled: value);
        break;
      case 'compressionEnabled':
        state = state.copyWith(compressionEnabled: value);
        break;
      case 'encryptionEnabled':
        state = state.copyWith(encryptionEnabled: value);
        break;
      case 'autoConnect':
        state = state.copyWith(autoConnect: value);
        break;
      case 'hapticFeedback':
        state = state.copyWith(hapticFeedback: value);
        break;
      case 'soundEnabled':
        state = state.copyWith(soundEnabled: value);
        break;
    }
  }
}
