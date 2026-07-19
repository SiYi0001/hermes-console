# Hermes 协议规范 / Protocol Specification

> Hermes Protocol v1.0 — 二进制帧协议 / Binary Framing Protocol

---

## 1. 概览 / Overview

Hermes 协议用于 P2P 端点之间的可靠加密通信，基于 WebRTC DataChannel 构建。
适用于 Web、移动端（iOS/Android）和桌面端（Flutter）跨平台部署。

**传输层**：WebRTC SctpDtlsTransport / DTLS 加密的 SCTP 流
**应用层**：二进制帧 / Binary Framing

---

## 2. 帧格式 / Frame Format

每个帧由 **8 字节固定头部 + 变长载荷** 组成：

```
 Byte  0        1         2         3         4         5         6         7
  +--------+--------+--------+--------+--------+--------+--------+--------+
  |  Type |        Payload Length (24-bit big-endian)       | Flags  |
  +--------+--------+--------+--------+--------+--------+--------+--------+
                                                                 +--------+
                                                                 | CRC16  |
                                                                 +--------+

  Type     : 1 byte  — 消息类型（见下表）
  Length   : 3 bytes — 载荷长度（不含头部），大端序，最大 16 MB
  Flags    : 1 byte  — 控制标志位
  CRC16    : 2 bytes — 整个帧（含头部）的 CRC-16-CCITT 校验
```

### 帧类型 / Frame Types

| Type 值 | 名称 | 方向 | 说明 |
|---------|------|------|------|
| `0x01` | **Hello** | 双方均可 | 握手请求，交换版本与能力 |
| `0x02` | **Auth** | 双方均可 | 认证消息，含身份令牌 |
| `0x03` | **Command** | A → B | 命令下发（A 为控制端） |
| `0x04` | **Response** | B → A | 命令响应，含执行结果 |
| `0x05` | **Heartbeat** | 双方均可 | 心跳保活，间隔 30 秒 |
| `0x06` | **Disconnect** | 双方均可 | 优雅断开连接 |
| `0x07` | **Data** | 双向 | 大块数据传输（文件/流） |

### 标志位 / Flags

```
Bit 0 (0x01): Compressed  — 载荷经 zstd 压缩
Bit 1 (0x02): Encrypted   — 载荷已加密（AES-256-GCM）
Bit 2 (0x04): Fragmented  — 分片帧（非最后一帧）
Bit 3 (0x08): Priority    — 高优先级
Bits 4-7: Reserved        — 保留
```

---

## 3. 消息载荷格式 / Payload Format

### 3.1 Hello（0x01）

握手请求，交换协议版本和端点能力。

```json
{
  "version": 1,          // 协议版本（uint8）
  "agentId": "string",   // Agent 唯一标识
  "capabilities": [      // 支持的能力列表
    "aes-256-gcm",
    "zstd",
    "curve25519",
    "hkdf"
  ],
  "timestamp": 1710000000000
}
```

**响应 Hello**（对方回 Hello）：
```json
{
  "version": 1,
  "agentId": "string",
  "capabilities": [...],
  "timestamp": 1710000000000,
  "accepted": true,
  "sessionId": "uuid-v4"
}
```

### 3.2 Auth（0x02）

身份认证，支持令牌和密钥两种方式。

```json
{
  "method": "token",     // "token" | "key"
  "token": "string",     // JWT 令牌（method=token 时）
  "keyFingerprint": "",  // 公钥指纹（method=key 时）
  "timestamp": 1710000000000
}
```

### 3.3 Command（0x03）

命令下发，仅从控制端流向被控端。

```json
{
  "commandId": "uuid-v4",       // 命令唯一 ID（用于追踪）
  "command": "string",           // 命令名称，如 "ping" / "status" / "exec"
  "args": {},                     // 命令参数（JSON 对象）
  "timeout": 30,                  // 超时秒数
  "priority": 1                   // 优先级 0-9
}
```

**示例**：
```json
// ping
{ "commandId": "a1b2c3d4", "command": "ping", "args": {}, "timeout": 5 }

// exec（执行 shell）
{ "commandId": "e5f6g7h8", "command": "exec",
  "args": { "script": "ls -la", "cwd": "/home" }, "timeout": 60 }

// connect（建立新 P2P 连接）
{ "commandId": "i9j0k1l2", "command": "connect",
  "args": { "peerId": "peer-xxx", "offer": "..." }, "timeout": 30 }
```

### 3.4 Response（0x04）

命令响应，与 Command 一一对应。

```json
{
  "commandId": "a1b2c3d4",        // 对应的命令 ID
  "status": "ok",                 // "ok" | "error" | "timeout"
  "exitCode": 0,                  // 退出码（exec 命令）
  "stdout": "",                   // 标准输出
  "stderr": "",                   // 标准错误
  "durationMs": 42,               // 执行耗时
  "timestamp": 1710000000000
}
```

### 3.5 Heartbeat（0x05）

心跳保活，无载荷（空帧）。若 90 秒未收到心跳则认为连接断开。

```json
{
  "latencyMs": 12,       // 估算延迟
  "bytesReceived": 1024,  // 本周期接收字节数
  "cpuPercent": 0.5       // 本节点 CPU 占用（可选）
}
```

### 3.6 Disconnect（0x06）

优雅断开，通知对方清理状态。

```json
{
  "reason": "string",     // 断开原因
  "code": 1000           // 断开码（参考 WebSocket close codes）
}
```

### 3.7 Data（0x07）

大块数据传输，支持分片重组。

```json
{
  "transferId": "uuid-v4",     // 传输会话 ID
  "filename": "report.pdf",    // 文件名
  "mimeType": "application/pdf",
  "totalSize": 1048576,        // 文件总大小（字节）
  "offset": 0,                  // 当前分片偏移
  "chunk": "base64...",        // 当前分片数据（Base64 编码）
  "isLast": false,             // 是否最后一个分片
  "checksum": "sha256:..."     // 文件 SHA-256 校验和
}
```

---

## 4. 加密流程 / Encryption Flow

### 4.1 密钥交换（Curve25519）

```
端点 A:
  - 生成临时密钥对 (pubA, privA)
端点 B:
  - 生成临时密钥对 (pubB, privB)

交换: A → B: pubA
      B → A: pubB

共享密钥: DH(pubB, privA) = DH(pubA, privB)
```

### 4.2 密钥派生（HKDF）

```dart
// label = "hermes-v1"
shared_secret = Curve25519.dh(pubB, privA)
keying_material = HKDF-SHA256(salt=null, ikm=shared_secret, info="hermes-v1", len=64)
// → [0..31]  session_key（数据加密）
// → [32..63] mac_key（完整性校验）
```

### 4.3 消息加密（AES-256-GCM）

```
plaintext  = Payload（JSON bytes）
nonce      = 随机 12 字节
ciphertext = AES-256-GCM(plaintext, session_key, nonce)
aad        = Type || Length || Flags  （附加认证数据）

输出: nonce(12) || ciphertext || authTag(16)
```

---

## 5. 压缩流程 / Compression Flow

启用条件：`Flags.Compressed = 1`

```
应用层 JSON → UTF-8 bytes → Zstd.compress(level=3) → 载荷
```

---

## 6. 连接流程 / Connection Lifecycle

```
  A                           B
  | ----- Hello (version) ---> |
  | <---- Hello (accepted) --- |
  | ----- Auth (token) ------> |
  | <---- Auth (ok) ---------- |
  | ====== 加密通道建立 ====== |
  |                             |
  | <====== Command/Response ====|
  | <====== Heartbeat =========> |
  |                             |
  | ----- Disconnect ---------> |
```

**错误处理**：
- 版本不兼容 → Hello.rejected，关闭连接
- 认证失败 → Auth.rejected，最大重试 3 次
- 90 秒无心跳 → 判定超时，断开连接
- 连续 5 次命令失败 → CircuitBreaker open

---

## 7. 分片重组 / Fragmentation

大文件（> 64 KB）自动分片：

```
TransferId=xxx, totalSize=10MB
  Frame 1: Data, offset=0,    chunk=64KB,  isLast=false, Flags=Fragmented
  Frame 2: Data, offset=64KB, chunk=64KB,  isLast=false, Flags=Fragmented
  ...
  Frame N: Data, offset=...,  chunk=<64KB, isLast=true,  Flags=0
```

接收端按 `transferId` + `offset` 重组，超时 5 分钟未完成则丢弃。

---

## 8. 错误码 / Error Codes

| Code | 名称 | 说明 |
|------|------|------|
| 1000 | `CLOSE_NORMAL` | 正常关闭 |
| 1001 | `CLOSE_GOING_AWAY` | 端点离开 |
| 1002 | `CLOSE_PROTOCOL_ERROR` | 协议错误 |
| 1003 | `CLOSE_UNSUPPORTED` | 不支持的载荷类型 |
| 1010 | `CLOSE_MALFORMED_FRAME` | 畸形帧 |
| 1011 | `CLOSE_ENCRYPTION_FAILED` | 加密失败 |
| 1012 | `CLOSE_DECRYPTION_FAILED` | 解密失败 |
| 1013 | `CLOSE_TIMEOUT` | 超时 |
| 1014 | `CLOSE_AUTH_FAILED` | 认证失败 |
| 1015 | `CLOSE_VERSION_MISMATCH` | 协议版本不匹配 |

---

## 9. 实现参考 / Implementation Reference

### Dart（Flutter）

```dart
import 'dart:typed_data';

/// HermesFrame 编码
Uint8List encodeFrame(HermesMessage msg, {Uint8List? sessionKey}) {
  final payload = _encodePayload(msg);
  final compressed = (msg.compressed)
      ? zstd.encode(payload)
      : payload;

  final encrypted = (msg.encrypted && sessionKey != null)
      ? _aesGcmEncrypt(compressed, sessionKey, msg.type, msg.length, msg.flags)
      : compressed;

  final header = _buildHeader(msg.type, encrypted.length, msg.flags);
  final crc = _crc16Ccitt(Uint8List.fromList([...header, ...encrypted]));
  return Uint8List.fromList([...header, ...crc, ...encrypted]);
}
```

### Go（Gateway）

```go
func EncodeFrame(msg *Message, key []byte) ([]byte, error) {
    payload, _ := json.Marshal(msg.Payload)
    if msg.Compressed {
        payload = zstd.Encode(payload, 3)
    }
    if msg.Encrypted && key != nil {
        payload = AESGCMEncrypt(payload, key, msg.Type, msg.Flags)
    }
    header := BuildHeader(msg.Type, len(payload), msg.Flags)
    crc := CRC16CCITT(append(header, payload...))
    return append(header, crc, payload...), nil
}
```
