# 更新日志 / Changelog

所有重要版本更新均记录于此。遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/) 规范。

---

## [2.6.0] — 2026-07-19

### 变更 / Changed
- **全部 10 个功能屏幕**接入真实 `AppState` Provider：
  - `dashboard_screen` — 连接状态 + P2P 指标真实数据
  - `console_screen` — 命令历史 + ping/status/connect/disconnect 真实调用
  - `connect_screen` — 真实 P2P 连接控制器
  - `status_screen` — `connectionMetricsProvider` + `activityLogProvider` 驱动
  - `settings_screen` — `settingsProvider` 完整集成
  - `memory_screen` — 长期记忆 CRUD
  - `mcp_screen` — MCP 服务器管理
  - `automation_screen` — Cron 任务管理
  - `logs_screen` — 日志查看与过滤
  - `gateway_screen` — 网关渠道配置
  - `transfer_screen` — 文件传输管理
  - `notifications_screen` — 通知中心
  - `profile_screen` — Agent Profile 配置
  - `performance_screen` — 性能监控

### 新增 / Added
- `AgentProfile` 模型（`models.dart`）
- `AppState.profile` 字段 + `updateProfile()` 方法
- `removeSharedFile()` 方法（`AppStateNotifier`）
- `lib/models.dart` — 统一导出所有 model 类
- `lib/app_state.dart` — 单源 `AppState` + `StateNotifier`
- README.md 中文为主、英文备选格式
- `docs/protocol.md` — 完整协议规范文档
- `docs/api.md` — API 参考文档
- `.editorconfig` — 跨编辑器代码风格配置
- `test/core/crypto_service_test.dart` — 加密服务单元测试（9 个测试用例）
- `test/core/compression_service_test.dart` — 压缩服务单元测试（8 个测试用例）
- `test/core/app_state_test.dart` — AppState 单元测试（17 个测试用例）
- `Makefile` — 常用命令快捷方式
- `analysis_options.yaml` — 严格 Lint 规则（80+ 规则）

### 修复 / Fixed
- **编译错误**：`pubspec.yaml` `webrtc` → `flutter_webrtc`
- **编译错误**：`p2p_data_channel.dart` 导入路径 `package:webrtc/...` → `package:flutter_webrtc/webrtc.dart`
- **编译错误**：`assets/` 目录缺失 → 创建 `icons/`、`images/`、`fonts/` 子目录
- **重复定义**：`GlassCard` 在两处定义 → 删除孤立 `optimized_widgets.dart`
- **死依赖**：`secure_storage` 未使用 → 从 pubspec.yaml 移除
- `AppNotification.isRead` → 正确使用 `AppNotification.read`
- `AppNotification.type` 为 `String` 非枚举 → 修复类型判断
- `ConnectionMetrics` 不存在字段 → 移除不存在的属性引用

### 删除 / Removed
- `lib/core/state/connection_state.dart`（重复定义）
- `lib/core/performance/performance_optimizations.dart`（孤立重复状态层）
- `lib/features/dashboard/dashboard_screen_optimized.dart`（孤儿屏）
- `lib/features/console/console_screen_optimized.dart`（孤儿屏）
- `lib/shared/widgets/optimized_widgets.dart`（重复定义 + 无引用）

---

## [2.5.0] — 2026-07-19

### 新增 / Added
- **P2P 网络管理器**（`P2PManager`）：
  - 五态状态机（disconnected / connecting / connected / reconnecting / error）
  - 指数退避重连（1s → 60s，上限 10 次）
  - 心跳保活（30 秒间隔，90 秒超时判定断开）
  - 连接质量评估（四级：excellent/good/fair/poor）
  - CircuitBreaker 熔断器（失败阈值 5，冷却 30s）
  - 活跃节点列表管理
- **错误处理框架**（`ErrorHandler`）：
  - `Result<T>` 类型（isOk/isError 判读）
  - `RetryStrategy`（指数退避重试）
  - `DegradationHandler`（优雅降级）
  - 全局 `runZoned` 错误捕获

### 变更 / Changed
- **性能优化基础设施**（可选用）：
  - `RingBuffer<T>` — O(1) 环形缓冲（固定容量）
  - `ExpiringCache<K,V>` — 自动过期缓存（LRU + TTL）
  - `EventBus` — 进程内事件总线
  - `MemoryTracker` — 内存使用追踪
  - `MemoizedBuilder` — 记忆化 Widget 构造
  - `RepaintBoundary` 隔离优化
  - `BatchedUpdater` — 16ms 帧对齐批量更新
  - `Debouncer` / `Throttler` — 防抖节流

---

## [2.4.0] — 2026-07-19

### 新增 / Added
- **引导流程**（Onboarding）：
  - HiveInit 初始化 → SplashScreen → OnboardingScreen → MainNavigation
  - 欢迎页 + 核心特性介绍 + 隐私说明 + 完成确认
- **设置屏扩展字段**：
  - `connectionTimeoutSeconds`
  - `stunServers` / `turnServers`
  - `ipWhitelistEnabled`
- **GitHub 集成**：
  - 仓库初始化 + Issue 模板（bug / feature）
  - `CONTRIBUTING.md` / `CODE_OF_CONDUCT.md` / `SECURITY.md`
  - CI/CD 工作流（dart.yml + labels.yml）

---

## [2.3.0] — 2026-07-19

### 新增 / Added
- **国际化**（i18n）：
  - 4 种语言：中文（zh）/ English（en）/ 日本語（ja）/ 한국어（ko）
  - `AppLocalizations` 框架 + ARB 资源文件
  - 语言切换实时生效
- **无障碍支持**（a11y）：
  - 语义化标签（Semantics）
  - 高对比度配色（WCAG AA 4.5:1）
  - 减少动效（减少动效偏好检测）
  - 键盘导航支持

---

## [2.0.0] — 2026-07-19

### 新增 / Added
- **完整 UI 套件**：13 个功能屏幕
- **统一状态管理**：Riverpod + Provider
- **CI/CD 流水线**：GitHub Actions
- **性能监控屏**：`performance_screen`
- **通知中心**：`notifications_screen`
- **Profile 配置**：`profile_screen`

---

## [1.0.0] — 2026-07-19

### 新增 / Added
- Hermes 控制台核心应用骨架
- P2P WebRTC DataChannel 实现
- AES-256-GCM 端到端加密
- zstd 数据压缩
- 二进制协议（Hermes Protocol）
- Hive 本地持久化存储
- QClaw 风格深色主题
