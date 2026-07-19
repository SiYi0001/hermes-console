# HermesConsole API 参考 / API Reference

> 本文档描述 HermesConsole 应用层的公开接口，适用于插件开发、Gateway 集成和外部调用。

---

## 目录 / Table of Contents

1. [Provider 接口](#1-provider-接口)
2. [Service 接口](#2-service-接口)
3. [存储接口](#3-存储接口)
4. [命令接口](#4-命令接口)
5. [事件流](#5-事件流)
6. [错误类型](#6-错误类型)

---

## 1. Provider 接口 / Provider Interfaces

### 1.1 连接状态 / Connection State

```dart
// 类型别名（位于 lib/core/network/p2p_data_channel.dart）
enum ConnectionState {
  disconnected,   // 未连接
  connecting,     // 连接中
  connected,      // 已连接
  reconnecting,   // 重连中
  error,          // 连接错误
}
```

### 1.2 核心 Providers

| Provider | 类型 | 说明 |
|----------|------|------|
| `appStateProvider` | `StateNotifierProvider<AppStateNotifier, AppState>` | 全局状态（settings/memory/mcp/automation/logs 等） |
| `connectionStateProvider` | `StateNotifierProvider<ConnectionStateNotifier, ConnectionState>` | P2P 连接状态 |
| `connectionMetricsProvider` | `StreamProvider<ConnectionMetrics>` | 连接指标流（latency/bytes/uptime） |
| `activityLogProvider` | `StreamProvider<List<ActivityLogEntry>>` | 活动日志流 |
| `settingsProvider` | `Provider<AppSettings>` | 只读设置快照 |
| `p2pManagerProvider` | `Provider<P2PManager>` | P2P 管理器实例 |

### 1.3 AppState 结构

```dart
class AppState {
  final AppSettings settings;                    // 全局设置
  final List<SharedMemory> memories;            // 长期记忆
  final List<McpServer> mcpServers;             // MCP 服务器
  final List<CronTask> cronTasks;               // Cron 定时任务
  final List<ToolLog> toolLogs;                 // 工具调用日志
  final List<GatewayChannel> gatewayChannels;   // 网关渠道
  final List<GatewayActivity> gatewayActivities;// 网关活动记录
  final List<FileTransfer> transfers;           // 文件传输记录
  final List<SharedFile> sharedFiles;           // 共享文件记录
  final List<AppNotification> notifications;    // 通知列表
  final AgentProfile profile;                   // Agent Profile
}
```

### 1.4 AppStateNotifier 方法

```dart
// 设置
void updateSettings(AppSettings s)

// 记忆
void addMemory(SharedMemory m)
void updateMemory(SharedMemory m)
void deleteMemory(String id)
void clearMemories()

// MCP
void addMcpServer(McpServer s)
void updateMcpServer(McpServer s)
void removeMcpServer(String id)
void toggleMcpServer(String id, bool enabled)
void addMcpTool(String serverId, McpTool t)
void removeMcpTool(String serverId, String toolId)

// 自动化
void addCronTask(CronTask t)
void updateCronTask(CronTask t)
void deleteCronTask(String id)
void toggleCronTask(String id, bool enabled)
void executeCronTask(String id)

// 日志
void addToolLog(ToolLog log)
void clearToolLogs()

// 网关
void addGatewayChannel(GatewayChannel c)
void updateGatewayChannel(GatewayChannel c)
void removeGatewayChannel(String id)
void toggleGatewayChannel(String id, bool enabled)
void addGatewayActivity(GatewayActivity a)

// 传输
void addTransfer(FileTransfer t)
void updateTransfer(FileTransfer t)
void removeTransfer(String id)
void addSharedFile(SharedFile f)
void removeSharedFile(String id)

// 通知
void addNotification(AppNotification n)
void dismissNotification(String id)
void markNotificationRead(String id)
void clearNotifications()

// Profile
void updateProfile(AgentProfile p)
```

---

## 2. Service 接口 / Service Interfaces

### 2.1 CryptoService

```dart
class CryptoService {
  /// 生成 Curve25519 密钥对
  Future<KeyPair> generateKeyPair();

  /// 执行 ECDH 密钥交换
  Uint8List deriveSharedSecret(
    Uint8List publicKey,
    Uint8List privateKey,
  );

  /// HKDF 密钥派生
  Uint8List hkdfDerive({
    required Uint8List ikm,
    required String info,
    required int length,
  });

  /// AES-256-GCM 加密
  Uint8List encryptAesGcm({
    required Uint8List plaintext,
    required Uint8List key,
    required Uint8List nonce,
    Uint8List? aad,
  });

  /// AES-256-GCM 解密
  Uint8List decryptAesGcm({
    required Uint8List ciphertext,
    required Uint8List key,
    required Uint8List nonce,
    Uint8List? aad,
  });

  /// 计算文件 SHA-256
  Future<String> computeFileSha256(String path);
}
```

### 2.2 CompressionService

```dart
class CompressionService {
  /// zstd 压缩
  Uint8List compress(Uint8List data, {int level = 3});

  /// zstd 解压
  Uint8List decompress(Uint8List compressed);

  /// 估算压缩后大小
  int预估Size(Uint8List data);
}
```

### 2.3 P2PManager

```dart
class P2PManager {
  /// 连接状态流
  Stream<ConnectionState> get stateStream;

  /// 连接指标流
  Stream<ConnectionMetrics> get metricsStream;

  /// 活动日志流
  Stream<ActivityLogEntry> get activityStream;

  /// 发起连接
  Future<void> connect({
    required String peerId,
    required String offer,
    RTCConfiguration? config,
  });

  /// 接受连接
  Future<void> accept({
    required String peerId,
    required String answer,
  });

  /// 断开连接
  Future<void> disconnect();

  /// 发送命令
  Future<String> sendCommand(String command, Map<String, dynamic> args);

  /// 获取连接指标
  ConnectionMetrics getMetrics();

  /// 获取活跃对等节点
  List<PeerInfo> getActivePeers();
}
```

---

## 3. 存储接口 / Storage Interfaces

### 3.1 HiveInit 公开 API

```dart
class HiveInit {
  /// 异步初始化（main.dart 启动时调用一次）
  static Future<void> initialize();

  /// 各类型存储 Box 访问器
  static Box get settingsBox;
  static Box get sessionsBox;
  static Box get historyBox;
  static Box get keysBox;       // 加密存储

  /// 清空所有数据（危险操作）
  static Future<void> clearAll();
}
```

### 3.2 SettingsStorage

```dart
class SettingsStorage {
  // 主题
  static bool get isDarkMode;
  static Future<void> setDarkMode(bool value);

  // 加密 / 压缩
  static bool get encryptionEnabled;
  static bool get compressionEnabled;

  // 自动重连
  static bool get autoReconnect;

  // 连接超时（秒）
  static int get connectionTimeout;

  // STUN/TURN 服务器
  static List<String> get stunServers;
  static List<String> get turnServers;
}
```

### 3.3 SessionStorage

```dart
class SessionStorage {
  static Future<void> saveSession(SessionData session);
  static List<SessionData> getAllSessions();
  static Future<void> deleteSession(String id);
  static Future<void> updateLastConnected(String id);
}
```

---

## 4. 命令接口 / Command Interface

### 4.1 HermesProtocol 发送命令

```dart
class HermesProtocol {
  /// 发送命令并等待响应
  Future<HermesResponse> sendCommand({
    required String command,
    Map<String, dynamic>? args,
    Duration timeout = const Duration(seconds: 30),
  });

  /// 发送原始帧（用于调试）
  Future<void> sendFrame(HermesFrame frame);

  /// 监听接收帧
  Stream<HermesFrame> get frameStream;
}
```

### 4.2 内置命令 / Built-in Commands

| 命令 | 参数 | 说明 | 示例 |
|------|------|------|------|
| `ping` | — | 存活检测 | `protocol.sendCommand("ping")` |
| `status` | — | 获取状态快照 | `protocol.sendCommand("status")` |
| `connect` | `peerId`, `offer` | 建立新 P2P 连接 | `protocol.sendCommand("connect", args: {...})` |
| `disconnect` | `peerId` | 断开指定连接 | `protocol.sendCommand("disconnect", args: {...})` |
| `exec` | `script`, `cwd` | 执行 shell 命令 | `protocol.sendCommand("exec", args: {...})` |
| `list_peers` | — | 列出活跃节点 | `protocol.sendCommand("list_peers")` |
| `get_metrics` | — | 获取连接指标 | `protocol.sendCommand("get_metrics")` |

---

## 5. 事件流 / Event Streams

### 5.1 全局事件总线

```dart
/// 位于 lib/core/monitoring/monitor_service.dart

enum AppEvent {
  connectionChanged,   // 连接状态变化
  metricsUpdated,      // 指标更新
  notification,       // 新通知
  commandExecuted,    // 命令执行完成
  transferProgress,    // 传输进度更新
  errorOccurred,       // 错误发生
}

class EventBus {
  /// 订阅事件
  Stream<T> on<T extends AppEvent>();

  /// 发布事件
  void emit(AppEvent event);
}
```

### 5.2 错误处理

```dart
/// 位于 lib/core/error/error_handler.dart

class HermesError {
  final String code;       // 错误码，如 "ERR_CONNECTION_LOST"
  final String message;     // 人类可读消息
  final dynamic detail;    // 附加详情
  final DateTime timestamp;
  final bool recoverable;  // 是否可恢复
}

/// 使用 Result 类型进行错误处理
class Result<T> {
  final T? data;
  final HermesError? error;
  bool get isOk => error == null;
  bool get isError => error != null;
}
```

---

## 6. 错误类型 / Error Types

| 错误码 | 说明 | 可恢复 |
|--------|------|--------|
| `ERR_CONNECTION_LOST` | 连接断开 | ✅ 重连 |
| `ERR_HANDSHAKE_FAILED` | 握手失败 | ❌ 需重新连接 |
| `ERR_AUTH_FAILED` | 认证失败 | ✅ 重试（限3次） |
| `ERR_ENCRYPTION_FAILED` | 加密失败 | ❌ |
| `ERR_DECRYPTION_FAILED` | 解密失败 | ❌ |
| `ERR_TIMEOUT` | 命令超时 | ✅ 重试 |
| `ERR_CIRCUIT_BREAKER` | 熔断器打开 | ✅ 等待恢复 |
| `ERR_INVALID_FRAME` | 畸形帧 | ❌ |
| `ERR_VERSION_MISMATCH` | 协议版本不匹配 | ❌ |

---

## 7. 插件扩展 / Plugin Extension

### 7.1 注册 MCP 服务器

```dart
// 在 main.dart 或 settings 中调用
appStateNotifier.addMcpServer(McpServer(
  id: 'my-server',
  name: 'My Server',
  url: 'http://localhost:8080',
  enabled: true,
));
```

### 7.2 监听连接状态

```dart
ref.listen<ConnectionState>(connectionStateProvider, (prev, next) {
  if (next == ConnectionState.connected) {
    // 连接建立后的处理
  }
});
```
