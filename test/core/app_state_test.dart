import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_console/core/models/models.dart';
import 'package:hermes_console/core/state/app_state.dart';

void main() {
  late AppStateNotifier notifier;

  setUp(() {
    notifier = AppStateNotifier();
  });

  group('AppState — Seed', () {
    test('initial state is seeded with real local data', () {
      final state = notifier.state;

      expect(state.memories, isNotEmpty);
      expect(state.mcpServers, isNotEmpty);
      expect(state.cronTasks, isNotEmpty);
      expect(state.gatewayChannels, isNotEmpty);
      expect(state.notifications, isNotEmpty);
      expect(state.profile, isNotNull);
    });
  });

  group('AppState — Memory Management', () {
    test('addMemory appends an item', () {
      final before = notifier.state.memories.length;
      final memory = MemoryItem(
        id: 'mem-test',
        title: 'Test Memory',
        content: 'Test content',
        category: 'test',
        timestamp: DateTime.now(),
        importance: 3,
      );

      notifier.addMemory(memory);

      expect(notifier.state.memories.length, equals(before + 1));
      expect(notifier.state.memories.last.content, equals('Test content'));
    });

    test('removeMemory deletes an item by id', () {
      notifier.addMemory(MemoryItem(
        id: 'mem-del',
        title: 'To delete',
        content: 'C',
        category: 'test',
        timestamp: DateTime.now(),
        importance: 1,
      ));
      expect(notifier.state.memories.length, greaterThan(0));

      notifier.removeMemory('mem-del');

      expect(
        notifier.state.memories.any((m) => m.id == 'mem-del'),
        isFalse,
      );
    });

    test('removeMemory is a no-op for unknown id', () {
      final before = notifier.state.memories.length;
      notifier.removeMemory('does-not-exist');
      expect(notifier.state.memories.length, equals(before));
    });

    test('updateMemory replaces an existing item', () {
      final memory = MemoryItem(
        id: 'mem-update',
        title: 'Original',
        content: 'Original content',
        category: 'test',
        timestamp: DateTime.now(),
        importance: 2,
      );
      notifier.addMemory(memory);

      notifier.updateMemory(
        memory.copyWith(title: 'Updated', importance: 5),
      );

      final updated =
          notifier.state.memories.firstWhere((m) => m.id == 'mem-update');
      expect(updated.title, equals('Updated'));
      expect(updated.importance, equals(5));
    });
  });

  group('AppState — MCP Servers', () {
    test('addMcpServer appends a server', () {
      final before = notifier.state.mcpServers.length;
      final server = McpServer(
        id: 'srv-1',
        name: 'Test Server',
        type: 'local',
        status: 'active',
        toolsCount: 0,
        lastUsed: DateTime.now(),
      );

      notifier.addMcpServer(server);

      expect(notifier.state.mcpServers.length, equals(before + 1));
      expect(notifier.state.mcpServers.last.name, equals('Test Server'));
    });

    test('McpServer.enabled mirrors active status', () {
      final server = McpServer(
        id: 'srv-active',
        name: 'Active',
        type: 'local',
        status: 'active',
        toolsCount: 0,
        lastUsed: DateTime.now(),
      );
      expect(server.enabled, isTrue);

      final inactive = McpServer(
        id: 'srv-inactive',
        name: 'Inactive',
        type: 'remote',
        status: 'inactive',
        toolsCount: 0,
        lastUsed: DateTime.now(),
      );
      expect(inactive.enabled, isFalse);
    });

    test('removeMcpServer deletes a server by id', () {
      notifier.addMcpServer(McpServer(
        id: 'srv-del',
        name: 'Delete',
        type: 'local',
        status: 'active',
        toolsCount: 0,
        lastUsed: DateTime.now(),
      ));

      notifier.removeMcpServer('srv-del');

      expect(
        notifier.state.mcpServers.any((s) => s.id == 'srv-del'),
        isFalse,
      );
    });

    test('restartMcpServer updates lastUsed', () async {
      notifier.addMcpServer(McpServer(
        id: 'srv-restart',
        name: 'Restart',
        type: 'local',
        status: 'active',
        toolsCount: 0,
        lastUsed: DateTime.now().subtract(const Duration(days: 1)),
      ));

      notifier.restartMcpServer('srv-restart');

      final restarted = notifier.state.mcpServers
          .firstWhere((s) => s.id == 'srv-restart');
      expect(
        restarted.lastUsed.isAfter(
          DateTime.now().subtract(const Duration(minutes: 1)),
        ),
        isTrue,
      );
    });
  });

  group('AppState — Tools', () {
    test('toggleToolEnabled flips a built-in tool by name', () {
      final target = notifier.state.builtInTools
          .firstWhere((t) => t.name == 'browser');
      expect(target.enabled, isFalse);

      notifier.toggleToolEnabled('browser', true);
      final toggled = notifier.state.builtInTools
          .firstWhere((t) => t.name == 'browser');
      expect(toggled.enabled, isTrue);
    });
  });

  group('AppState — Cron Tasks', () {
    test('addCronTask appends a task', () {
      final before = notifier.state.cronTasks.length;
      final task = CronTask(
        id: 'cron-1',
        name: 'Daily Backup',
        expression: '0 2 * * *',
        description: 'Backup',
        enabled: true,
      );

      notifier.addCronTask(task);

      expect(notifier.state.cronTasks.length, equals(before + 1));
      expect(notifier.state.cronTasks.last.name, equals('Daily Backup'));
    });

    test('toggleCronTask flips enabled state', () {
      notifier.addCronTask(CronTask(
        id: 'cron-toggle',
        name: 'Toggle',
        expression: '*/5 * * * *',
        description: 'T',
        enabled: true,
      ));

      notifier.toggleCronTask('cron-toggle', false);
      expect(
        notifier.state.cronTasks.firstWhere((t) => t.id == 'cron-toggle').enabled,
        isFalse,
      );
    });

    test('executeCronTask records a lastRun', () {
      notifier.addCronTask(CronTask(
        id: 'cron-exec',
        name: 'Exec',
        expression: '0 * * * *',
        description: 'E',
        enabled: true,
      ));

      notifier.executeCronTask('cron-exec');

      final executed = notifier.state.cronTasks
          .firstWhere((t) => t.id == 'cron-exec');
      expect(executed.lastRun, isNotNull);
    });
  });

  group('AppState — Notifications', () {
    test('pushNotification appends to the list', () {
      final before = notifier.state.notifications.length;
      final notification = AppNotification(
        id: 'notif-1',
        title: 'Test',
        body: 'Body',
        type: 'info',
        timestamp: DateTime.now(),
        read: false,
      );

      notifier.pushNotification(notification);

      expect(notifier.state.notifications.length, equals(before + 1));
    });

    test('markNotificationRead flips the read flag', () {
      notifier.pushNotification(AppNotification(
        id: 'notif-read',
        title: 'Unread',
        body: 'Body',
        type: 'warning',
        timestamp: DateTime.now(),
        read: false,
      ));

      notifier.markNotificationRead('notif-read');

      final marked = notifier.state.notifications
          .firstWhere((n) => n.id == 'notif-read');
      expect(marked.read, isTrue);
    });

    test('dismissNotification removes from the list', () {
      notifier.pushNotification(AppNotification(
        id: 'notif-dismiss',
        title: 'Dismiss',
        body: 'Body',
        type: 'info',
        timestamp: DateTime.now(),
        read: false,
      ));

      notifier.dismissNotification('notif-dismiss');

      expect(
        notifier.state.notifications.any((n) => n.id == 'notif-dismiss'),
        isFalse,
      );
    });

    test('clearNotifications removes all', () {
      for (var i = 0; i < 5; i++) {
        notifier.pushNotification(AppNotification(
          id: 'n$i',
          title: 'Title $i',
          body: 'Body',
          type: 'info',
          timestamp: DateTime.now(),
          read: false,
        ));
      }

      notifier.clearNotifications();

      expect(notifier.state.notifications, isEmpty);
    });
  });

  group('AppState — Profile', () {
    test('updateProfile replaces the profile', () {
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
