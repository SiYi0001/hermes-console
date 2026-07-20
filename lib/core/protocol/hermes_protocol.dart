import 'dart:convert';
import 'dart:typed_data';
import 'dart:convert' as convert;

/// Hermes Binary Protocol Implementation
class HermesProtocol {
  // Magic number "HE" (0x4845)
  static const int magic = 0x4845;
  
  // Message types
  static const int typeHello = 0x01;
  static const int typeAuthRequest = 0x02;
  static const int typeAuthResponse = 0x03;
  static const int typeCommand = 0x04;
  static const int typeResponse = 0x05;
  static const int typeHeartbeat = 0x06;
  static const int typeDisconnect = 0x07;
  
  // Header size: Magic(2) + Type(1) + Flags(1) + Length(4) = 8 bytes
  static const int headerSize = 8;
  
  /// Encode a protocol message to bytes
  Uint8List encode(ProtocolMessage message) {
    switch (message.type) {
      case MessageType.hello:
        return _encodeHello(message as HelloMessage);
      case MessageType.authRequest:
        return _encodeAuthRequest(message as AuthRequestMessage);
      case MessageType.authResponse:
        return _encodeAuthResponse(message as AuthResponseMessage);
      case MessageType.command:
        return _encodeCommand(message as CommandMessage);
      case MessageType.response:
        return _encodeResponse(message as ResponseMessage);
      case MessageType.heartbeat:
        return _encodeHeartbeat(message as HeartbeatMessage);
      case MessageType.disconnect:
        return _encodeDisconnect(message as DisconnectMessage);
    }
  }

  /// Decode bytes to a protocol message
  ProtocolMessage decode(Uint8List data) {
    if (data.length < headerSize) {
      throw const FormatException('Invalid frame: too short');
    }
    
    // Parse header
    final magicValue = (data[0] << 8) | data[1];
    if (magicValue != magic) {
      throw FormatException('Invalid magic number: ${magicValue.toRadixString(16)}');
    }
    
    final type = data[2];
    final flags = data[3];
    final length = (data[4] << 24) | (data[5] << 16) | (data[6] << 8) | data[7];
    
    if (data.length < headerSize + length) {
      throw const FormatException('Invalid frame: payload truncated');
    }
    
    final payload = data.sublist(headerSize, headerSize + length);
    
    switch (type) {
      case typeHello:
        return _decodeHello(payload, flags);
      case typeAuthRequest:
        return _decodeAuthRequest(payload, flags);
      case typeAuthResponse:
        return _decodeAuthResponse(payload, flags);
      case typeCommand:
        return _decodeCommand(payload, flags);
      case typeResponse:
        return _decodeResponse(payload, flags);
      case typeHeartbeat:
        return _decodeHeartbeat(payload, flags);
      case typeDisconnect:
        return _decodeDisconnect(payload, flags);
      default:
        throw FormatException('Unknown message type: $type');
    }
  }

  Uint8List _createFrame(int type, int flags, Uint8List payload) {
    final frame = Uint8List(headerSize + payload.length);
    frame[0] = (magic >> 8) & 0xFF;
    frame[1] = magic & 0xFF;
    frame[2] = type;
    frame[3] = flags;
    frame[4] = (payload.length >> 24) & 0xFF;
    frame[5] = (payload.length >> 16) & 0xFF;
    frame[6] = (payload.length >> 8) & 0xFF;
    frame[7] = payload.length & 0xFF;
    frame.setRange(headerSize, frame.length, payload);
    return frame;
  }

  // HELLO Message
  Uint8List _encodeHello(HelloMessage msg) {
    final payload = Uint8List.fromList(convert.jsonEncode({
      'version': msg.version,
      'clientId': msg.clientId,
      'timestamp': msg.timestamp,
      'capabilities': msg.capabilities,
    }).codeUnits);
    return _createFrame(typeHello, 0, payload);
  }

  HelloMessage _decodeHello(Uint8List payload, int flags) {
    final json = convert.jsonDecode(utf8.decode(payload));
    return HelloMessage(
      version: json['version'],
      clientId: json['clientId'],
      timestamp: json['timestamp'],
      capabilities: List<String>.from(json['capabilities'] ?? []),
    );
  }

  // AUTH Request
  Uint8List _encodeAuthRequest(AuthRequestMessage msg) {
    final payload = Uint8List.fromList(convert.jsonEncode({
      'token': msg.token,
      'username': msg.username,
      'timestamp': msg.timestamp,
      'nonce': msg.nonce,
    }).codeUnits);
    return _createFrame(typeAuthRequest, 0, payload);
  }

  AuthRequestMessage _decodeAuthRequest(Uint8List payload, int flags) {
    final json = convert.jsonDecode(utf8.decode(payload));
    return AuthRequestMessage(
      token: json['token'],
      username: json['username'],
      timestamp: json['timestamp'],
      nonce: json['nonce'],
    );
  }

  // AUTH Response
  Uint8List _encodeAuthResponse(AuthResponseMessage msg) {
    final payload = Uint8List.fromList(convert.jsonEncode({
      'success': msg.success,
      'sessionId': msg.sessionId,
      'expiresAt': msg.expiresAt,
      'error': msg.error,
    }).codeUnits);
    return _createFrame(typeAuthResponse, 0, payload);
  }

  AuthResponseMessage _decodeAuthResponse(Uint8List payload, int flags) {
    final json = convert.jsonDecode(utf8.decode(payload));
    return AuthResponseMessage(
      success: json['success'],
      sessionId: json['sessionId'],
      expiresAt: json['expiresAt'],
      error: json['error'],
    );
  }

  // COMMAND
  Uint8List _encodeCommand(CommandMessage msg) {
    final payload = Uint8List.fromList(convert.jsonEncode({
      'id': msg.id,
      'command': msg.command,
      'args': msg.args,
      'timeout': msg.timeout,
    }).codeUnits);
    return _createFrame(typeCommand, 0, payload);
  }

  CommandMessage _decodeCommand(Uint8List payload, int flags) {
    final json = convert.jsonDecode(utf8.decode(payload));
    return CommandMessage(
      id: json['id'],
      command: json['command'],
      args: Map<String, dynamic>.from(json['args'] ?? {}),
      timeout: json['timeout'],
    );
  }

  // RESPONSE
  Uint8List _encodeResponse(ResponseMessage msg) {
    final payload = Uint8List.fromList(convert.jsonEncode({
      'commandId': msg.commandId,
      'exitCode': msg.exitCode,
      'stdout': msg.stdout,
      'stderr': msg.stderr,
      'duration': msg.duration,
    }).codeUnits);
    return _createFrame(typeResponse, 0, payload);
  }

  ResponseMessage _decodeResponse(Uint8List payload, int flags) {
    final json = convert.jsonDecode(utf8.decode(payload));
    return ResponseMessage(
      commandId: json['commandId'],
      exitCode: json['exitCode'],
      stdout: json['stdout'],
      stderr: json['stderr'],
      duration: json['duration'],
    );
  }

  // HEARTBEAT
  Uint8List _encodeHeartbeat(HeartbeatMessage msg) {
    final payload = Uint8List.fromList(convert.jsonEncode({
      'timestamp': msg.timestamp,
      'latency': msg.latency,
      'seq': msg.sequence,
    }).codeUnits);
    return _createFrame(typeHeartbeat, 0, payload);
  }

  HeartbeatMessage _decodeHeartbeat(Uint8List payload, int flags) {
    final json = convert.jsonDecode(utf8.decode(payload));
    return HeartbeatMessage(
      timestamp: json['timestamp'],
      latency: json['latency'],
      sequence: json['seq'],
    );
  }

  // DISCONNECT
  Uint8List _encodeDisconnect(DisconnectMessage msg) {
    final payload = Uint8List.fromList(convert.jsonEncode({
      'reason': msg.reason,
      'code': msg.code,
    }).codeUnits);
    return _createFrame(typeDisconnect, 0, payload);
  }

  DisconnectMessage _decodeDisconnect(Uint8List payload, int flags) {
    final json = convert.jsonDecode(utf8.decode(payload));
    return DisconnectMessage(
      reason: json['reason'],
      code: json['code'],
    );
  }
}

// Message types
enum MessageType {
  hello,
  authRequest,
  authResponse,
  command,
  response,
  heartbeat,
  disconnect,
}

// Base message class
abstract class ProtocolMessage {
  MessageType get type;
}

// Concrete message classes
class HelloMessage extends ProtocolMessage {
  final String version;
  final String clientId;
  final int timestamp;
  final List<String> capabilities;

  HelloMessage({
    required this.version,
    required this.clientId,
    required this.timestamp,
    this.capabilities = const [],
  });

  @override
  MessageType get type => MessageType.hello;
}

class AuthRequestMessage extends ProtocolMessage {
  final String token;
  final String username;
  final int timestamp;
  final String nonce;

  AuthRequestMessage({
    required this.token,
    required this.username,
    required this.timestamp,
    required this.nonce,
  });

  @override
  MessageType get type => MessageType.authRequest;
}

class AuthResponseMessage extends ProtocolMessage {
  final bool success;
  final String? sessionId;
  final int? expiresAt;
  final String? error;

  AuthResponseMessage({
    required this.success,
    this.sessionId,
    this.expiresAt,
    this.error,
  });

  @override
  MessageType get type => MessageType.authResponse;
}

class CommandMessage extends ProtocolMessage {
  final String id;
  final String command;
  final Map<String, dynamic> args;
  final int? timeout;

  CommandMessage({
    required this.id,
    required this.command,
    this.args = const {},
    this.timeout,
  });

  @override
  MessageType get type => MessageType.command;
}

class ResponseMessage extends ProtocolMessage {
  final String commandId;
  final int exitCode;
  final String stdout;
  final String stderr;
  final int duration;

  ResponseMessage({
    required this.commandId,
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    required this.duration,
  });

  @override
  MessageType get type => MessageType.response;
}

class HeartbeatMessage extends ProtocolMessage {
  final int timestamp;
  final int latency;
  final int sequence;

  HeartbeatMessage({
    required this.timestamp,
    required this.latency,
    required this.sequence,
  });

  @override
  MessageType get type => MessageType.heartbeat;
}

class DisconnectMessage extends ProtocolMessage {
  final String reason;
  final int code;

  DisconnectMessage({
    required this.reason,
    required this.code,
  });

  @override
  MessageType get type => MessageType.disconnect;
}
