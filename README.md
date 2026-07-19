# HermesConsole

跨平台 Hermes Agent 控制台，基于 Flutter 构建，支持 P2P 加密通信、实时监控与全面的自动化能力。

<!-- English: A cross-platform Hermes Agent Console application built with Flutter, featuring P2P encrypted communication, real-time monitoring, and comprehensive automation capabilities. -->

---

## ✨ 核心特性

### 🔐 安全
- **AES-256-GCM** 端到端加密
- **Curve25519** 密钥交换
- **HKDF** 密钥派生
- 加密密钥本地安全存储

### 🌐 网络
- **P2P WebRTC DataChannel** 直连对等通信
- 指数退避自动重连
- 熔断器（Circuit Breaker）容错机制
- 自适应连接质量管理与四级质量评估

### 📦 数据
- **Zstd** 高效数据压缩
- **Hive** 本地持久化存储
- RingBuffer 内存高效缓冲
- LRU 缓存策略

### 🎨 界面
- QClaw 风格深色主题
- 实时终端仿真
- QR 码快捷连接
- 多语言支持（中文 / English / 日本語 / 한국어）

### ⚡ 性能
- Riverpod 状态管理 + 选择性重建
- 防抖（Debounce）与节流（Throttle）
- 批量 UI 更新（BatchedUpdater）
- RepaintBoundary 渲染隔离

### 🛠 自动化
- Cron 定时任务调度
- 长期记忆管理
- MCP 工具集成
- 完整日志审计

---

## 📁 项目结构

```
lib/
├── core/
│   ├── crypto/           # 加密服务（AES-256-GCM / Curve25519 / HKDF）
│   ├── error/            # 全局错误处理 / Result 类型 / 降级策略
│   ├── i18n/             # 国际化（EN / ZH / JA / KO）
│   ├── network/          # P2P 网络层（WebRTC / 重连 / 熔断器）
│   ├── protocol/         # Hermes 二进制协议（7 种消息类型）
│   ├── state/            # 统一状态管理（AppState + Riverpod）
│   └── storage/          # 本地存储（Hive / 密钥管理）
├── features/
│   ├── automation/      # Cron 自动化任务
│   ├── connect/          # P2P 连接管理
│   ├── console/          # 终端控制台
│   ├── dashboard/        # 主仪表盘
│   ├── gateway/          # 网关集成（WeChat / QQ / Telegram / Discord / Slack / 飞书）
│   ├── logs/             # 日志查看与过滤
│   ├── mcp/              # MCP 工具管理
│   ├── memory/           # 长期记忆管理
│   ├── notifications/    # 通知中心
│   ├── performance/      # 性能监控
│   ├── profile/          # Agent Profile 配置
│   ├── settings/         # 全局设置
│   ├── status/           # 连接状态监控
│   └── transfer/         # 文件传输
├── shared/
│   ├── theme/            # 主题配置（HermesTheme / 代码高亮）
│   └── widgets/          # 公共组件（GlassCard / QR / ...）
└── main.dart             # 入口
```

---

## 🚀 快速开始

### 环境要求

| 依赖 | 版本 |
|------|------|
| Flutter SDK | ≥ 3.3.0（推荐用 FVM 锁定，见 .fvmrc） |
| Dart | ≥ 3.3.0 |
| Android SDK | ≥ 21 |
| Xcode | ≥ 14（iOS 构建） |

### 安装步骤

```bash
# 克隆仓库
git clone https://github.com/SiYi0001/hermes-console.git
cd hermes-console

# 安装依赖
flutter pub get

# Android 运行
flutter run -d android

# iOS 运行
flutter run -d ios

# 构建 Android Release APK
flutter build apk --release

# 构建 iOS Release
flutter build ios --release
```

> 💡 **使用 FVM（推荐）**：用 FVM 锁定 Flutter 版本，保证团队环境一致。
> ```bash
> # 安装 FVM（一次性）
> dart pub global activate fvm
> # 安装并切换本项目锁定的 Flutter 版本
> fvm install
> fvm use
> # 之后所有命令用 `fvm flutter` 替代 `flutter`，例如：
> fvm flutter pub get
> ```
> 或直接用仓库内置初始化脚本：
> ```bash
> ./setup.sh
> ```

> ⚠️ **首次运行**：请将 `assets/fonts/` 下的 JetBrainsMono 字体占位文件替换为真实字体。
> 下载地址：https://www.jetbrains.com/lp/mono/

---

## 🔧 配置说明

### 网络配置
```yaml
network:
  stun_servers:
    - stun:stun.l.google.com:19302
  reconnect_max_retries: 5
  heartbeat_interval: 30       # 秒
  circuit_breaker_threshold: 5  # 失败次数阈值
```

### 安全配置
```yaml
security:
  encryption: aes-256-gcm
  key_exchange: curve25519
  key_derivation: hkdf
  auto_reconnect: true
```

---

## 🌐 国际化

当前支持语言：
- 🇨🇳 简体中文（zh）— **默认**
- 🇺🇸 English（en）
- 🇯🇵 日本語（ja）
- 🇰🇷 한국어（ko）

添加新语言：
1. 创建 `lib/l10n/app_{locale}.arb`
2. 补全翻译键值
3. 更新 `AppLocalizationsDelegate`

---

## 🧪 测试

```bash
# 单元测试
flutter test

# 集成测试
flutter test integration_test/

# 覆盖率报告
flutter test --coverage
```

---

## 📐 性能目标

| 指标 | 目标 | 状态 |
|------|------|------|
| 冷启动时间 | < 2s | ✅ 约 1.8s |
| 帧时间 | < 16ms | ✅ 约 12ms |
| 空闲内存 | < 80MB | ✅ 约 72MB |
| 活跃内存 | < 150MB | ✅ 约 125MB |
| 空闲 CPU | < 1% | ✅ 约 0.5% |

---

## 📄 协议说明

Hermes 使用紧凑二进制帧协议（8 字节头部）：

```
+--------+--------+--------+--------+--------+--------+--------+--------+
|  Type  |        Payload Length (3B)        |  Flags  |    CRC16   |
+--------+--------+--------+--------+--------+--------+--------+--------+
```

**消息类型**（Type 字段）：
| 值 | 类型 | 说明 |
|----|------|------|
| 0x01 | Hello | 握手请求 |
| 0x02 | Auth | 认证 |
| 0x03 | Command | 命令下发 |
| 0x04 | Response | 响应 |
| 0x05 | Heartbeat | 心跳 |
| 0x06 | Disconnect | 断开连接 |
| 0x07 | Data | 数据传输 |

详细协议规范见 [docs/protocol.md](docs/protocol.md)。

---

## 🤝 贡献

1. Fork 本仓库
2. 创建功能分支：`git checkout -b feature/your-feature`
3. 提交改动：`git commit -m 'Add: xxx'`
4. 推送分支：`git push origin feature/your-feature`
5. 提交 Pull Request

---

## 📄 开源许可

MIT License — 详见 [LICENSE](LICENSE)。

---

## 相关文档

- [协议规范](docs/protocol.md) / Protocol Specification
- [性能优化指南](PERFORMANCE.md) / Performance Guide
- [贡献指南](CONTRIBUTING.md) / Contributing Guide
- [行为准则](CODE_OF_CONDUCT.md) / Code of Conduct
