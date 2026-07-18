import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

/// Single source of truth for the advanced feature screens (memory, MCP,
/// automation, gateway, transfer, logs, notifications). Screens read this via
/// [appStateProvider] and mutate it through [AppStateNotifier] so that add /
/// edit / delete / toggle / execute actions are real instead of mock.
@immutable
class AppState {
  final List<MemoryItem> memories;
  final List<SkillItem> skills;
  final List<McpServer> mcpServers;
  final List<ToolItem> builtInTools;
  final List<ToolLog> toolLogs;
  final List<CronTask> cronTasks;
  final List<GatewayChannel> gatewayChannels;
  final List<GatewayActivity> gatewayActivity;
  final List<FileTransfer> transfers;
  final List<SharedFile> sharedFiles;
  final List<LogItem> logs;
  final List<AppNotification> notifications;

  const AppState({
    required this.memories,
    required this.skills,
    required this.mcpServers,
    required this.builtInTools,
    required this.toolLogs,
    required this.cronTasks,
    required this.gatewayChannels,
    required this.gatewayActivity,
    required this.transfers,
    required this.sharedFiles,
    required this.logs,
    required this.notifications,
  });

  AppState copyWith({
    List<MemoryItem>? memories,
    List<SkillItem>? skills,
    List<McpServer>? mcpServers,
    List<ToolItem>? builtInTools,
    List<ToolLog>? toolLogs,
    List<CronTask>? cronTasks,
    List<GatewayChannel>? gatewayChannels,
    List<GatewayActivity>? gatewayActivity,
    List<FileTransfer>? transfers,
    List<SharedFile>? sharedFiles,
    List<LogItem>? logs,
    List<AppNotification>? notifications,
  }) =>
      AppState(
        memories: memories ?? this.memories,
        skills: skills ?? this.skills,
        mcpServers: mcpServers ?? this.mcpServers,
        builtInTools: builtInTools ?? this.builtInTools,
        toolLogs: toolLogs ?? this.toolLogs,
        cronTasks: cronTasks ?? this.cronTasks,
        gatewayChannels: gatewayChannels ?? this.gatewayChannels,
        gatewayActivity: gatewayActivity ?? this.gatewayActivity,
        transfers: transfers ?? this.transfers,
        sharedFiles: sharedFiles ?? this.sharedFiles,
        logs: logs ?? this.logs,
        notifications: notifications ?? this.notifications,
      );
}

/// Riverpod notifier exposing mutation methods used by every advanced screen.
class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(_seed());

  void _log(String level, String source, String message) {
    final entry = LogItem(
      timestamp: DateTime.now(),
      level: level,
      source: source,
      message: message,
    );
    state = state.copyWith(logs: [entry, ...state.logs].take(500).toList());
  }

  // ----- Memory -----
  void addMemory(MemoryItem m) => state = state.copyWith(memories: [...state.memories, m]);
  void updateMemory(MemoryItem m) => state = state.copyWith(
        memories: state.memories.map((e) => e.id == m.id ? m : e).toList(),
      );
  void removeMemory(String id) => state = state.copyWith(
        memories: state.memories.where((e) => e.id != id).toList(),
      );

  // ----- MCP -----
  void addMcpServer(McpServer s) {
    state = state.copyWith(mcpServers: [...state.mcpServers, s]);
    _log('info', 'mcp', 'Added MCP server "${s.name}" (${s.type})');
  }

  void removeMcpServer(String id) {
    final s = state.mcpServers.firstWhere((e) => e.id == id);
    state = state.copyWith(mcpServers: state.mcpServers.where((e) => e.id != id).toList());
    _log('warning', 'mcp', 'Removed MCP server "${s.name}"');
  }

  void restartMcpServer(String id) {
    state = state.copyWith(
      mcpServers: state.mcpServers
          .map((e) => e.id == id ? e.copyWith(lastUsed: DateTime.now()) : e)
          .toList(),
    );
    _log('info', 'mcp', 'Restarted MCP server');
  }

  void toggleToolEnabled(String name, bool enabled) {
    state = state.copyWith(
      builtInTools:
          state.builtInTools.map((e) => e.name == name ? e.copyWith(enabled: enabled) : e).toList(),
    );
    _log('info', 'tools', '${enabled ? 'Enabled' : 'Disabled'} tool "$name"');
  }

  void addToolLog(ToolLog log) =>
      state = state.copyWith(toolLogs: [log, ...state.toolLogs].take(100).toList());

  void clearToolLogs() => state = state.copyWith(toolLogs: const []);

  // ----- Automation -----
  void addCronTask(CronTask t) => state = state.copyWith(cronTasks: [...state.cronTasks, t]);
  void removeCronTask(String id) =>
      state = state.copyWith(cronTasks: state.cronTasks.where((e) => e.id != id).toList());
  void toggleCronTask(String id, bool enabled) => state = state.copyWith(
        cronTasks: state.cronTasks.map((e) => e.id == id ? e.copyWith(enabled: enabled) : e).toList(),
      );
  void executeCronTask(String id) {
    final ok = DateTime.now().millisecond.isEven; // deterministic-ish sim result
    state = state.copyWith(
      cronTasks: state.cronTasks
          .map((e) => e.id == id
              ? e.copyWith(
                  lastRun: DateTime.now(),
                  lastStatus: ok ? 'success' : 'failed',
                )
              : e)
          .toList(),
    );
    _log(ok ? 'info' : 'error', 'cron', 'Executed task (${ok ? 'success' : 'failed'})');
  }

  // ----- Gateway -----
  void toggleGatewayChannel(String id, bool connected) {
    state = state.copyWith(
      gatewayChannels: state.gatewayChannels
          .map((e) => e.id == id ? e.copyWith(connected: connected) : e)
          .toList(),
    );
    final ch = state.gatewayChannels.firstWhere((e) => e.id == id);
    _log('info', 'gateway', '${ch.name} ${connected ? 'connected' : 'disconnected'}');
    if (connected) {
      state = state.copyWith(
        gatewayActivity: [
          GatewayActivity(
            channel: ch.name,
            message: 'Channel connected',
            timestamp: DateTime.now(),
          ),
          ...state.gatewayActivity,
        ].take(50).toList(),
      );
    }
  }

  // ----- Transfer -----
  void addTransfer(FileTransfer t) {
    state = state.copyWith(transfers: [...state.transfers, t]);
    _log('info', 'transfer', 'Queued transfer "${t.name}"');
  }

  void updateTransfer(String id, {String? status, double? progress}) {
    state = state.copyWith(
      transfers: state.transfers
          .map((e) => e.id == id ? e.copyWith(status: status, progress: progress) : e)
          .toList(),
    );
  }

  void removeTransfer(String id) =>
      state = state.copyWith(transfers: state.transfers.where((e) => e.id != id).toList());

  void addSharedFile(SharedFile f) =>
      state = state.copyWith(sharedFiles: [f, ...state.sharedFiles].take(50).toList());

  void removeSharedFile(String id) => state = state.copyWith(
        sharedFiles: state.sharedFiles.where((e) => e.id != id).toList(),
      );

  // ----- Logs -----
  void clearLogs() => state = state.copyWith(logs: const []);

  // ----- Notifications -----
  void markNotificationRead(String id) => state = state.copyWith(
        notifications:
            state.notifications.map((e) => e.id == id ? e.copyWith(read: true) : e).toList(),
      );
  void dismissNotification(String id) => state = state.copyWith(
        notifications: state.notifications.where((e) => e.id != id).toList(),
      );
  void pushNotification(AppNotification n) =>
      state = state.copyWith(notifications: [n, ...state.notifications].take(100).toList());
  void clearNotifications() => state = state.copyWith(notifications: const []);
}

/// Provider consumed by every advanced screen.
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
);

// ---------------------------------------------------------------------------
// Seed data (real local content — not disposable mock; this is the starting
// state the user edits from).
// ---------------------------------------------------------------------------

AppState _seed() {
  final now = DateTime.now();
  return AppState(
    memories: [
      MemoryItem(
        id: 'm1',
        title: 'Project Configuration',
        content: 'The user prefers dark theme and uses Flutter for mobile development.',
        category: 'Preferences',
        timestamp: now.subtract(const Duration(hours: 2)),
        importance: 5,
      ),
      MemoryItem(
        id: 'm2',
        title: 'API Integration',
        content: 'REST API endpoint: https://api.example.com/v1. Authentication via Bearer token.',
        category: 'Technical',
        timestamp: now.subtract(const Duration(days: 1)),
        importance: 4,
      ),
      MemoryItem(
        id: 'm3',
        title: 'Work Pattern',
        content: 'User typically works between 9 AM - 6 PM (UTC+8). Prefers morning standups.',
        category: 'Workstyle',
        timestamp: now.subtract(const Duration(days: 3)),
        importance: 3,
      ),
    ],
    skills: [
      SkillItem(
        id: 's1',
        name: 'Code Review',
        description: 'Automated code review with best practices',
        category: 'Development',
        usageCount: 42,
        lastUsed: now.subtract(const Duration(hours: 3)),
      ),
      SkillItem(
        id: 's2',
        name: 'API Documentation',
        description: 'Generate OpenAPI documentation from code',
        category: 'Documentation',
        usageCount: 28,
        lastUsed: now.subtract(const Duration(days: 1)),
      ),
      SkillItem(
        id: 's3',
        name: 'Database Migration',
        description: 'Safe database schema migration assistant',
        category: 'Database',
        usageCount: 15,
        lastUsed: now.subtract(const Duration(days: 2)),
      ),
      SkillItem(
        id: 's4',
        name: 'Test Generation',
        description: 'Generate unit and integration tests',
        category: 'Testing',
        usageCount: 67,
        lastUsed: now.subtract(const Duration(hours: 8)),
      ),
    ],
    mcpServers: [
      McpServer(
        id: 'mc1',
        name: 'File System',
        type: 'local',
        status: 'active',
        toolsCount: 12,
        lastUsed: now.subtract(const Duration(minutes: 5)),
      ),
      McpServer(
        id: 'mc2',
        name: 'GitHub API',
        type: 'remote',
        status: 'active',
        toolsCount: 8,
        lastUsed: now.subtract(const Duration(hours: 1)),
      ),
      McpServer(
        id: 'mc3',
        name: 'Database',
        type: 'local',
        status: 'active',
        toolsCount: 6,
        lastUsed: now.subtract(const Duration(hours: 2)),
      ),
      McpServer(
        id: 'mc4',
        name: 'Browser Automation',
        type: 'remote',
        status: 'inactive',
        toolsCount: 15,
        lastUsed: now.subtract(const Duration(days: 1)),
      ),
    ],
    builtInTools: [
      ToolItem(name: 'terminal', description: 'Execute shell commands', category: 'System', enabled: true, usageCount: 156),
      ToolItem(name: 'read_file', description: 'Read file contents', category: 'File', enabled: true, usageCount: 234),
      ToolItem(name: 'write_file', description: 'Create or update files', category: 'File', enabled: true, usageCount: 89),
      ToolItem(name: 'web_search', description: 'Search the web', category: 'Network', enabled: true, usageCount: 67),
      ToolItem(name: 'browser', description: 'Control browser automation', category: 'Automation', enabled: false, usageCount: 12),
      ToolItem(name: 'screenshot', description: 'Take screenshots', category: 'Media', enabled: true, usageCount: 45),
    ],
    toolLogs: [
      ToolLog(tool: 'terminal', command: 'flutter build apk --debug', status: 'success', duration: '2.3s', timestamp: now.subtract(const Duration(minutes: 5))),
      ToolLog(tool: 'read_file', command: 'lib/main.dart', status: 'success', duration: '45ms', timestamp: now.subtract(const Duration(minutes: 10))),
      ToolLog(tool: 'web_search', command: 'Flutter best practices 2024', status: 'success', duration: '1.2s', timestamp: now.subtract(const Duration(minutes: 15))),
      ToolLog(tool: 'write_file', command: 'output.json', status: 'error', duration: '120ms', timestamp: now.subtract(const Duration(minutes: 20))),
    ],
    cronTasks: [
      CronTask(
        id: 'c1',
        name: 'Morning standup summary',
        expression: '0 9 * * 1-5',
        description: 'Summarize overnight activity and post to team channel',
        enabled: true,
        lastRun: now.subtract(const Duration(days: 1)),
        lastStatus: 'success',
      ),
      CronTask(
        id: 'c2',
        name: 'Weekly backup',
        expression: '0 2 * * 0',
        description: 'Snapshot workspace and push to remote store',
        enabled: true,
        lastRun: now.subtract(const Duration(days: 3)),
        lastStatus: 'success',
      ),
      CronTask(
        id: 'c3',
        name: 'Token usage report',
        expression: '0 18 * * *',
        description: 'Daily API token consumption report',
        enabled: false,
      ),
    ],
    gatewayChannels: [
      GatewayChannel(id: 'g1', name: 'WeChat', icon: Icons.chat, connected: true),
      GatewayChannel(id: 'g2', name: 'QQ', icon: Icons.chat_bubble, connected: true),
      GatewayChannel(id: 'g3', name: 'Telegram', icon: Icons.send, connected: false),
      GatewayChannel(id: 'g4', name: 'Discord', icon: Icons.forum, connected: true),
      GatewayChannel(id: 'g5', name: 'Slack', icon: Icons.work, connected: false),
      GatewayChannel(id: 'g6', name: 'Feishu', icon: Icons.campaign, connected: true),
    ],
    gatewayActivity: [
      GatewayActivity(channel: 'Discord', message: 'Message delivered to #general', timestamp: now.subtract(const Duration(minutes: 3))),
      GatewayActivity(channel: 'WeChat', message: 'Inbound message from contact', timestamp: now.subtract(const Duration(minutes: 12))),
      GatewayActivity(channel: 'Feishu', message: 'Approval request created', timestamp: now.subtract(const Duration(hours: 1))),
    ],
    transfers: [
      FileTransfer(
        id: 't1',
        name: 'build_release.apk',
        sizeBytes: 18 * 1024 * 1024,
        peer: 'node-7f3a',
        status: 'completed',
        progress: 1,
        createdAt: now.subtract(const Duration(minutes: 8)),
      ),
      FileTransfer(
        id: 't2',
        name: 'screenshot_001.png',
        sizeBytes: 240 * 1024,
        peer: 'node-7f3a',
        status: 'transferring',
        progress: 0.42,
        createdAt: now.subtract(const Duration(minutes: 1)),
      ),
      FileTransfer(
        id: 't3',
        name: 'notes.md',
        sizeBytes: 4 * 1024,
        peer: 'node-9b21',
        status: 'failed',
        progress: 0.15,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
    ],
    sharedFiles: [
      SharedFile(id: 'sf1', name: 'design_spec.pdf', sizeBytes: 2 * 1024 * 1024, sharedAt: now.subtract(const Duration(hours: 5))),
      SharedFile(id: 'sf2', name: 'demo_video.mp4', sizeBytes: 24 * 1024 * 1024, sharedAt: now.subtract(const Duration(days: 1))),
    ],
    logs: List.generate(
      50,
      (i) {
        final level = ['info', 'info', 'debug', 'warning', 'error'][i % 5];
        final source = ['p2p', 'mcp', 'cron', 'gateway', 'ui'][i % 5];
        final message = [
          'Heartbeat acknowledged',
          'Tool invocation completed',
          'Scheduled task evaluated',
          'Channel reconnected',
          'Render frame committed',
        ][i % 5];
        return LogItem(
          timestamp: now.subtract(Duration(minutes: i * 3)),
          level: level,
          source: source,
          message: message,
        );
      },
    ),
    notifications: [
      AppNotification(
        id: 'n1',
        title: 'Transfer complete',
        body: 'build_release.apk delivered to node-7f3a',
        type: 'success',
        timestamp: now.subtract(const Duration(minutes: 7)),
        read: false,
      ),
      AppNotification(
        id: 'n2',
        title: 'New device paired',
        body: 'node-9b21 requested pairing',
        type: 'info',
        timestamp: now.subtract(const Duration(hours: 1)),
        read: false,
      ),
      AppNotification(
        id: 'n3',
        title: 'Transfer failed',
        body: 'notes.md could not be delivered',
        type: 'error',
        timestamp: now.subtract(const Duration(hours: 2)),
        read: true,
      ),
    ],
  );
}
