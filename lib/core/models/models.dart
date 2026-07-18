import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

/// Shared domain models for the advanced feature screens.
///
/// These are the single source of truth for memory, MCP, automation, gateway,
/// transfer, logs and notifications. Screens no longer hard-code mock lists;
/// they read/write [AppState] via [appStateProvider].

const _uuid = Uuid();

String _newId() => _uuid.v4().substring(0, 8);

// ---------------------------------------------------------------------------
// Memory
// ---------------------------------------------------------------------------

class MemoryItem {
  final String id;
  final String title;
  final String content;
  final String category;
  final DateTime timestamp;
  final int importance;

  const MemoryItem({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.timestamp,
    required this.importance,
  });

  MemoryItem copyWith({
    String? title,
    String? content,
    String? category,
    DateTime? timestamp,
    int? importance,
  }) =>
      MemoryItem(
        id: id,
        title: title ?? this.title,
        content: content ?? this.content,
        category: category ?? this.category,
        timestamp: timestamp ?? this.timestamp,
        importance: importance ?? this.importance,
      );

  factory MemoryItem.create({
    required String title,
    required String content,
    required String category,
    required int importance,
  }) =>
      MemoryItem(
        id: _newId(),
        title: title,
        content: content,
        category: category,
        timestamp: DateTime.now(),
        importance: importance,
      );
}

class SkillItem {
  final String id;
  final String name;
  final String description;
  final String category;
  final int usageCount;
  final DateTime lastUsed;

  const SkillItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.usageCount,
    required this.lastUsed,
  });
}

// ---------------------------------------------------------------------------
// MCP
// ---------------------------------------------------------------------------

class McpServer {
  final String id;
  final String name;
  final String type; // 'local' | 'remote'
  final String status; // 'active' | 'inactive'
  final int toolsCount;
  final DateTime lastUsed;

  const McpServer({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.toolsCount,
    required this.lastUsed,
  });

  McpServer copyWith({
    String? name,
    String? status,
    DateTime? lastUsed,
  }) =>
      McpServer(
        id: id,
        name: name ?? this.name,
        type: type,
        status: status ?? this.status,
        toolsCount: toolsCount,
        lastUsed: lastUsed ?? this.lastUsed,
      );

  factory McpServer.create({
    required String name,
    required String type,
  }) =>
      McpServer(
        id: _newId(),
        name: name,
        type: type,
        status: 'active',
        toolsCount: 0,
        lastUsed: DateTime.now(),
      );
}

class ToolItem {
  final String name;
  final String description;
  final String category;
  final bool enabled;
  final int usageCount;

  const ToolItem({
    required this.name,
    required this.description,
    required this.category,
    required this.enabled,
    required this.usageCount,
  });

  ToolItem copyWith({bool? enabled}) => ToolItem(
        name: name,
        description: description,
        category: category,
        enabled: enabled ?? this.enabled,
        usageCount: usageCount,
      );
}

class ToolLog {
  final String tool;
  final String command;
  final String status; // 'success' | 'error'
  final String duration;
  final DateTime timestamp;

  const ToolLog({
    required this.tool,
    required this.command,
    required this.status,
    required this.duration,
    required this.timestamp,
  });
}

// ---------------------------------------------------------------------------
// Automation (Cron)
// ---------------------------------------------------------------------------

class CronTask {
  final String id;
  final String name;
  final String expression;
  final String description;
  final bool enabled;
  final DateTime? lastRun;
  final String? lastStatus;

  const CronTask({
    required this.id,
    required this.name,
    required this.expression,
    required this.description,
    required this.enabled,
    this.lastRun,
    this.lastStatus,
  });

  CronTask copyWith({
    String? name,
    String? expression,
    String? description,
    bool? enabled,
    DateTime? lastRun,
    String? lastStatus,
  }) =>
      CronTask(
        id: id,
        name: name ?? this.name,
        expression: expression ?? this.expression,
        description: description ?? this.description,
        enabled: enabled ?? this.enabled,
        lastRun: lastRun ?? this.lastRun,
        lastStatus: lastStatus ?? this.lastStatus,
      );

  factory CronTask.create({
    required String name,
    required String expression,
    required String description,
  }) =>
      CronTask(
        id: _newId(),
        name: name,
        expression: expression,
        description: description,
        enabled: true,
      );
}

// ---------------------------------------------------------------------------
// Gateway
// ---------------------------------------------------------------------------

class GatewayChannel {
  final String id;
  final String name;
  final IconData icon;
  final bool connected;

  const GatewayChannel({
    required this.id,
    required this.name,
    required this.icon,
    required this.connected,
  });

  GatewayChannel copyWith({bool? connected}) => GatewayChannel(
        id: id,
        name: name,
        icon: icon,
        connected: connected ?? this.connected,
      );
}

class GatewayActivity {
  final String channel;
  final String message;
  final DateTime timestamp;

  const GatewayActivity({
    required this.channel,
    required this.message,
    required this.timestamp,
  });
}

// ---------------------------------------------------------------------------
// Transfer
// ---------------------------------------------------------------------------

class FileTransfer {
  final String id;
  final String name;
  final int sizeBytes;
  final String peer;
  final String status; // 'pending' | 'transferring' | 'completed' | 'failed' | 'canceled'
  final double progress; // 0..1
  final DateTime createdAt;

  const FileTransfer({
    required this.id,
    required this.name,
    required this.sizeBytes,
    required this.peer,
    required this.status,
    required this.progress,
    required this.createdAt,
  });

  FileTransfer copyWith({
    String? status,
    double? progress,
  }) =>
      FileTransfer(
        id: id,
        name: name,
        sizeBytes: sizeBytes,
        peer: peer,
        status: status ?? this.status,
        progress: progress ?? this.progress,
        createdAt: createdAt,
      );

  factory FileTransfer.create({
    required String name,
    required int sizeBytes,
    required String peer,
  }) =>
      FileTransfer(
        id: _newId(),
        name: name,
        sizeBytes: sizeBytes,
        peer: peer,
        status: 'pending',
        progress: 0,
        createdAt: DateTime.now(),
      );
}

class SharedFile {
  final String id;
  final String name;
  final int sizeBytes;
  final DateTime sharedAt;

  const SharedFile({
    required this.id,
    required this.name,
    required this.sizeBytes,
    required this.sharedAt,
  });
}

// ---------------------------------------------------------------------------
// Logs & Notifications (shared)
// ---------------------------------------------------------------------------

class LogItem {
  final DateTime timestamp;
  final String level; // 'info' | 'warning' | 'error' | 'debug'
  final String source;
  final String message;

  const LogItem({
    required this.timestamp,
    required this.level,
    required this.source,
    required this.message,
  });
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type; // 'info' | 'success' | 'warning' | 'error'
  final DateTime timestamp;
  final bool read;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    required this.read,
  });

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        timestamp: timestamp,
        read: read ?? this.read,
      );

  factory AppNotification.create({
    required String title,
    required String body,
    required String type,
  }) =>
      AppNotification(
        id: _newId(),
        title: title,
        body: body,
        type: type,
        timestamp: DateTime.now(),
        read: false,
      );
}
