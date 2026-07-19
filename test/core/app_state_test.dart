import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_console/core/state/app_state.dart';

void main() {
  late AppStateNotifier notifier;

  setUp(() {
    notifier = AppStateNotifier();
  });

  group('AppState — Default Values', () {
    test('initial state has empty lists and default settings', () {
      final state = notifier.state;

      expect(state.memories, isEmpty);
      expect(state.mcpServers, isEmpty);
      expect(state.cronTasks, isEmpty);
      expect(state.toolLogs, isEmpty);
      expect(state.gatewayChannels, isEmpty);
      expect(state.transfers, isEmpty);
      expect(state.sharedFiles, isEmpty);
      expect(state.notifications, isEmpty);
    });

    test('default settings has sensible values', () {
      final settings = notifier.state.settings;

      expect(settings.darkMode, isTrue);
      expect(settings.encryptionEnabled, isTrue);
      expect(settings.compressionEnabled, isTrue);
      expect(settings.autoReconnect, isTrue);
      expect(settings.language, equals('zh'));
    });
  });

  group('AppState — Settings', () {
    test('updateSettings replaces all settings', () {
      final newSettings = AppSettings(
        darkMode: false,
        language: 'en',
        encryptionEnabled: false,
        compressionEnabled: false,
        autoReconnect: false,
        connectionTimeoutSeconds: 60,
        stunServers: ['stun:custom.example.com:19302'],
        turnServers: [],
        ipWhitelistEnabled: true,
      );

      notifier.updateSettings(newSettings);

      expect(notifier.state.settings.darkMode, isFalse);
      expect(notifier.state.settings.language, equals('en'));
      expect(notifier.state.settings.encryptionEnabled, isFalse);
    });

    test('updateSettings preserves unmodified fields', () {
      final original = notifier.state.settings;
      notifier.updateSettings(original.copyWith(language: 'ja'));

      expect(notifier.state.settings.darkMode, equals(original.darkMode));
      expect(notifier.state.settings.encryptionEnabled,
          equals(original.encryptionEnabled));
      expect(notifier.state.settings.language, equals('ja'));
    });
  });

  group('AppState — Memory Management', () {
    test('addMemory adds item to list', () {
      final memory = SharedMemory(
        id: 'mem-1',
        content: 'Test memory',
        category: 'test',
        tags: ['unit-test'],
        createdAt: DateTime.now(),
        lastAccessed: DateTime.now(),
        accessCount: 0,
        pinned: false,
      );

      notifier.addMemory(memory);

      expect(notifier.state.memories.length, equals(1));
      expect(notifier.state.memories.first.content, equals('Test memory'));
    });

    test('deleteMemory removes item by id', () {
      final memory = SharedMemory(
        id: 'mem-del',
        content: 'To be deleted',
        category: 'test',
        tags: [],
        createdAt: DateTime.now(),
        lastAccessed: DateTime.now(),
        accessCount: 0,
        pinned: false,
      );

      notifier.addMemory(memory);
      expect(notifier.state.memories.length, equals(1));

      notifier.deleteMemory('mem-del');
      expect(notifier.state.memories, isEmpty);
    });

    test('deleteMemory does nothing for non-existent id', () {
      notifier.addMemory(SharedMemory(
        id: 'mem-1',
        content: 'Memory',
        category: 'test',
        tags: [],
        createdAt: DateTime.now(),
        lastAccessed: DateTime.now(),
        accessCount: 0,
        pinned: false,
      ));

      notifier.deleteMemory('non-existent-id');
      expect(notifier.state.memories.length, equals(1));
    });

    test('updateMemory modifies existing item', () {
      final memory = SharedMemory(
        id: 'mem-update',
        content: 'Original',
        category: 'test',
        tags: [],
        createdAt: DateTime.now(),
        lastAccessed: DateTime.now(),
        accessCount: 0,
        pinned: false,
      );

      notifier.addMemory(memory);
      notifier.updateMemory(memory.copyWith(content: 'Updated', pinned: true));

      final updated = notifier.state.memories.first;
      expect(updated.content, equals('Updated'));
      expect(updated.pinned, isTrue);
    });

    test('clearMemories removes all memories', () {
      notifier.addMemory(SharedMemory(
        id: 'm1', content: 'C1', category: 'test',
        tags: [], createdAt: DateTime.now(),
        lastAccessed: DateTime.now(), accessCount: 0, pinned: false,
      ));
      notifier.addMemory(SharedMemory(
        id: 'm2', content: 'C2', category: 'test',
        tags: [], createdAt: DateTime.now(),
        lastAccessed: DateTime.now(), accessCount: 0, pinned: false,
      ));

      notifier.clearMemories();

      expect(notifier.state.memories, isEmpty);
    });
  });

  group('AppState — MCP Servers', () {
    test('addMcpServer adds server', () {
      final server = McpServer(
        id: 'srv-1',
        name: 'Test Server',
        url: 'http://localhost:8080',
        enabled: false,
        tools: [],
        lastSync: DateTime.now(),
      );

      notifier.addMcpServer(server);

      expect(notifier.state.mcpServers.length, equals(1));
      expect(notifier.state.mcpServers.first.name, equals('Test Server'));
    });

    test('toggleMcpServer flips enabled state', () {
      final server = McpServer(
        id: 'srv-toggle',
        name: 'Toggle Test',
        url: 'http://localhost:8081',
        enabled: false,
        tools: [],
        lastSync: DateTime.now(),
      );

      notifier.addMcpServer(server);
      expect(notifier.state.mcpServers.first.enabled, isFalse);

      notifier.toggleMcpServer('srv-toggle', true);
      expect(notifier.state.mcpServers.first.enabled, isTrue);

      notifier.toggleMcpServer('srv-toggle', false);
      expect(notifier.state.mcpServers.first.enabled, isFalse);
    });

    test('removeMcpServer deletes server and its tools', () {
      final server = McpServer(
        id: 'srv-del',
        name: 'Delete Test',
        url: 'http://localhost:8082',
        enabled: true,
        tools: [
          McpTool(
            id: 'tool-1', name: 'tool', description: 't',
            inputSchema: {}, serverId: 'srv-del',
          ),
        ],
        lastSync: DateTime.now(),
      );

      notifier.addMcpServer(server);
      notifier.removeMcpServer('srv-del');

      expect(notifier.state.mcpServers, isEmpty);
    });
  });

  group('AppState — Cron Tasks', () {
    test('addCronTask adds task', () {
      final task = CronTask(
        id: 'cron-1',
        name: 'Daily Backup',
        cronExpression: '0 2 * * *',
        command: 'backup.sh',
        args: {},
        enabled: true,
        lastRun: null,
        nextRun: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
      );

      notifier.addCronTask(task);

      expect(notifier.state.cronTasks.length, equals(1));
      expect(notifier.state.cronTasks.first.name, equals('Daily Backup'));
    });

    test('toggleCronTask toggles enabled state', () {
      final task = CronTask(
        id: 'cron-toggle',
        name: 'Toggle Test',
        cronExpression: '*/5 * * * *',
        command: 'test.sh',
        args: {},
        enabled: true,
        lastRun: null,
        nextRun: DateTime.now(),
        createdAt: DateTime.now(),
      );

      notifier.addCronTask(task);
      notifier.toggleCronTask('cron-toggle', false);

      expect(notifier.state.cronTasks.first.enabled, isFalse);
    });

    test('executeCronTask updates lastRun', () {
      final task = CronTask(
        id: 'cron-exec',
        name: 'Exec Test',
        cronExpression: '0 * * * *',
        command: 'hourly.sh',
        args: {},
        enabled: true,
        lastRun: null,
        nextRun: DateTime.now(),
        createdAt: DateTime.now(),
      );

      notifier.addCronTask(task);
      final runTime = DateTime.now();
      notifier.executeCronTask('cron-exec');

      expect(notifier.state.cronTasks.first.lastRun, isNotNull);
    });
  });

  group('AppState — Notifications', () {
    test('addNotification appends to list', () {
      final notification = AppNotification(
        id: 'notif-1',
        title: 'Test Title',
        body: 'Test Body',
        type: 'info',
        read: false,
        createdAt: DateTime.now(),
      );

      notifier.addNotification(notification);

      expect(notifier.state.notifications.length, equals(1));
    });

    test('markNotificationRead updates read flag', () {
      final notification = AppNotification(
        id: 'notif-read',
        title: 'Unread',
        body: 'Body',
        type: 'warning',
        read: false,
        createdAt: DateTime.now(),
      );

      notifier.addNotification(notification);
      notifier.markNotificationRead('notif-read');

      expect(notifier.state.notifications.first.read, isTrue);
    });

    test('dismissNotification removes from list', () {
      final notification = AppNotification(
        id: 'notif-dismiss',
        title: 'Dismiss Me',
        body: 'Body',
        type: 'info',
        read: false,
        createdAt: DateTime.now(),
      );

      notifier.addNotification(notification);
      notifier.dismissNotification('notif-dismiss');

      expect(notifier.state.notifications, isEmpty);
    });

    test('clearNotifications removes all', () {
      for (var i = 0; i < 5; i++) {
        notifier.addNotification(AppNotification(
          id: 'n$i',
          title: 'Title $i',
          body: 'Body $i',
          type: 'info',
          read: false,
          createdAt: DateTime.now(),
        ));
      }

      notifier.clearNotifications();

      expect(notifier.state.notifications, isEmpty);
    });
  });

  group('AppState — Profile', () {
    test('updateProfile replaces profile', () {
      final newProfile = AgentProfile(
        id: 'new-id',
        name: 'Updated Agent',
        email: 'agent@hermes.test',
        membership: 'pro',
        sessions: 999,
        commands: 888,
        skills: 10,
        apiCalls: 7777,
        storageMb: 2048,
        bandwidthGb: 50,
        storageMaxMb: 5120,
        bandwidthMaxGb: 100,
      );

      notifier.updateProfile(newProfile);

      expect(notifier.state.profile.name, equals('Updated Agent'));
      expect(notifier.state.profile.membership, equals('pro'));
    });
  });
}
