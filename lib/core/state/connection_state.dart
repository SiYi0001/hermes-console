import 'package:equatable/equatable.dart';

enum ConnectionStatus { disconnected, connecting, connected, error }

class ConnectionState extends Equatable {
  final ConnectionStatus status;
  final String? nodeId;
  final String? nodeName;
  final DateTime? connectedAt;
  final int latency;
  final double bandwidthUpload;
  final double bandwidthDownload;
  final String? errorMessage;

  const ConnectionState({
    required this.status,
    this.nodeId,
    this.nodeName,
    this.connectedAt,
    this.latency = 0,
    this.bandwidthUpload = 0,
    this.bandwidthDownload = 0,
    this.errorMessage,
  });

  factory ConnectionState.disconnected() {
    return const ConnectionState(status: ConnectionStatus.disconnected);
  }

  ConnectionState copyWith({
    ConnectionStatus? status,
    String? nodeId,
    String? nodeName,
    DateTime? connectedAt,
    int? latency,
    double? bandwidthUpload,
    double? bandwidthDownload,
    String? errorMessage,
  }) {
    return ConnectionState(
      status: status ?? this.status,
      nodeId: nodeId ?? this.nodeId,
      nodeName: nodeName ?? this.nodeName,
      connectedAt: connectedAt ?? this.connectedAt,
      latency: latency ?? this.latency,
      bandwidthUpload: bandwidthUpload ?? this.bandwidthUpload,
      bandwidthDownload: bandwidthDownload ?? this.bandwidthDownload,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isConnected => status == ConnectionStatus.connected;
  bool get isConnecting => status == ConnectionStatus.connecting;
  bool get isDisconnected => status == ConnectionStatus.disconnected;
  bool get hasError => status == ConnectionStatus.error;

  Duration? get connectionDuration {
    if (connectedAt == null) return null;
    return DateTime.now().difference(connectedAt!);
  }

  @override
  List<Object?> get props => [
        status,
        nodeId,
        nodeName,
        connectedAt,
        latency,
        bandwidthUpload,
        bandwidthDownload,
        errorMessage,
      ];
}

class SessionInfo extends Equatable {
  final String id;
  final String nodeId;
  final String nodeName;
  final DateTime connectedAt;
  final DateTime? disconnectedAt;
  final int commandsCount;
  final String dataTransferred;

  const SessionInfo({
    required this.id,
    required this.nodeId,
    required this.nodeName,
    required this.connectedAt,
    this.disconnectedAt,
    required this.commandsCount,
    required this.dataTransferred,
  });

  Duration get duration {
    final end = disconnectedAt ?? DateTime.now();
    return end.difference(connectedAt);
  }

  @override
  List<Object?> get props => [
        id,
        nodeId,
        nodeName,
        connectedAt,
        disconnectedAt,
        commandsCount,
        dataTransferred,
      ];
}

enum NotificationType { alert, success, task, update, message }

class NotificationItem extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [id, title, body, type, timestamp, isRead];
}

class MemoryItem extends Equatable {
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

  @override
  List<Object?> get props => [id, title, content, category, timestamp, importance];
}

class SkillItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final int usageCount;
  final DateTime lastUsed;
  final bool isEnabled;

  const SkillItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.usageCount,
    required this.lastUsed,
    required this.isEnabled,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        usageCount,
        lastUsed,
        isEnabled,
      ];
}

class CronTask extends Equatable {
  final String id;
  final String name;
  final String description;
  final String schedule;
  final String scheduleLabel;
  final bool isEnabled;
  final int totalRuns;
  final int successRuns;
  final int failedRuns;
  final DateTime? lastRun;

  const CronTask({
    required this.id,
    required this.name,
    required this.description,
    required this.schedule,
    required this.scheduleLabel,
    required this.isEnabled,
    required this.totalRuns,
    required this.successRuns,
    required this.failedRuns,
    this.lastRun,
  });

  double get successRate {
    if (totalRuns == 0) return 0;
    return (successRuns / totalRuns) * 100;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        schedule,
        scheduleLabel,
        isEnabled,
        totalRuns,
        successRuns,
        failedRuns,
        lastRun,
      ];
}

class AppSettings extends Equatable {
  final bool darkMode;
  final bool notificationsEnabled;
  final bool hapticFeedback;
  final bool soundEnabled;
  final bool autoConnect;
  final bool compressionEnabled;
  final bool encryptionEnabled;

  const AppSettings({
    required this.darkMode,
    required this.notificationsEnabled,
    required this.hapticFeedback,
    required this.soundEnabled,
    required this.autoConnect,
    required this.compressionEnabled,
    required this.encryptionEnabled,
  });

  AppSettings copyWith({
    bool? darkMode,
    bool? notificationsEnabled,
    bool? hapticFeedback,
    bool? soundEnabled,
    bool? autoConnect,
    bool? compressionEnabled,
    bool? encryptionEnabled,
  }) {
    return AppSettings(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      autoConnect: autoConnect ?? this.autoConnect,
      compressionEnabled: compressionEnabled ?? this.compressionEnabled,
      encryptionEnabled: encryptionEnabled ?? this.encryptionEnabled,
    );
  }

  @override
  List<Object?> get props => [
        darkMode,
        notificationsEnabled,
        hapticFeedback,
        soundEnabled,
        autoConnect,
        compressionEnabled,
        encryptionEnabled,
      ];
}

class McpServer extends Equatable {
  final String id;
  final String name;
  final String type;
  final bool isActive;
  final int toolsCount;
  final DateTime? lastUsed;

  const McpServer({
    required this.id,
    required this.name,
    required this.type,
    required this.isActive,
    required this.toolsCount,
    this.lastUsed,
  });

  @override
  List<Object?> get props => [id, name, type, isActive, toolsCount, lastUsed];
}

class ToolLog extends Equatable {
  final String id;
  final String tool;
  final String command;
  final String status;
  final Duration duration;
  final DateTime timestamp;

  const ToolLog({
    required this.id,
    required this.tool,
    required this.command,
    required this.status,
    required this.duration,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, tool, command, status, duration, timestamp];
}
