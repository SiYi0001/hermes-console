import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Advanced P2P Connection Manager with reconnection logic
class P2PConnectionManager {
  static final P2PConnectionManager _instance = P2PConnectionManager._internal();
  factory P2PConnectionManager() => _instance;
  P2PConnectionManager._internal();

  // Connection state
  P2PConnectionState _state = P2PConnectionState.disconnected;
  String? _peerId;
  DateTime? _connectedAt;

  // Reconnection settings
  static const int _maxRetries = 5;
  static const Duration _baseDelay = Duration(seconds: 1);
  static const Duration _maxDelay = Duration(minutes: 1);
  
  int _retryCount = 0;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  // Callbacks
  void Function(P2PConnectionState)? onStateChange;
  void Function(Uint8List)? onDataReceived;
  void Function(String)? onError;

  // Subscribers
  final _stateSubscribers = <void Function(P2PConnectionState)>[];
  final _dataSubscribers = <void Function(Uint8List)>[];

  P2PConnectionState get state => _state;
  String? get peerId => _peerId;
  bool get isConnected => _state == P2PConnectionState.connected;
  Duration? get connectionDuration => 
      _connectedAt != null ? DateTime.now().difference(_connectedAt!) : null;

  /// Connect to a peer
  Future<bool> connect(String peerId, {Map<String, dynamic>? options}) async {
    if (_state == P2PConnectionState.connecting) {
      return false;
    }

    _setState(P2PConnectionState.connecting);
    _peerId = peerId;

    try {
      // Simulate connection establishment
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate success (in real implementation, this would be WebRTC DataChannel)
      _setState(P2PConnectionState.connected);
      _connectedAt = DateTime.now();
      _retryCount = 0;
      _startHeartbeat();

      return true;
    } catch (e) {
      _handleConnectionError(e.toString());
      return false;
    }
  }

  /// Disconnect from current peer
  void disconnect({String? reason}) {
    _stopTimers();
    _setState(P2PConnectionState.disconnected);
    _peerId = null;
    _connectedAt = null;
  }

  /// Send data to peer
  Future<bool> send(Uint8List data) async {
    if (_state != P2PConnectionState.connected) {
      return false;
    }

    try {
      // In real implementation, this would send via DataChannel
      _notifyDataSubscribers(data);
      return true;
    } catch (e) {
      _handleConnectionError(e.toString());
      return false;
    }
  }

  /// Send text message
  Future<bool> sendText(String message) async {
    return send(Uint8List.fromList(message.codeUnits));
  }

  /// Subscribe to state changes
  void subscribe(void Function(P2PConnectionState) callback) {
    _stateSubscribers.add(callback);
  }

  /// Unsubscribe from state changes
  void unsubscribe(void Function(P2PConnectionState) callback) {
    _stateSubscribers.remove(callback);
  }

  /// Subscribe to data
  void subscribeData(void Function(Uint8List) callback) {
    _dataSubscribers.add(callback);
  }

  /// Unsubscribe from data
  void unsubscribeData(void Function(Uint8List) callback) {
    _dataSubscribers.remove(callback);
  }

  /// Handle connection error with retry logic
  void _handleConnectionError(String error) {
    onError?.call(error);
    
    if (_retryCount < _maxRetries) {
      _setState(P2PConnectionState.reconnecting);
      _scheduleReconnect();
    } else {
      _setState(P2PConnectionState.error);
      disconnect(reason: 'Max retries exceeded');
    }
  }

  /// Schedule reconnection with exponential backoff
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    
    final delay = _calculateBackoff();
    _retryCount++;

    _reconnectTimer = Timer(delay, () {
      if (_peerId != null) {
        connect(_peerId!);
      }
    });
  }

  /// Calculate exponential backoff delay
  Duration _calculateBackoff() {
    final delay = _baseDelay.inMilliseconds * (1 << _retryCount);
    final cappedDelay = delay.clamp(
      _baseDelay.inMilliseconds,
      _maxDelay.inMilliseconds,
    );
    return Duration(milliseconds: cappedDelay);
  }

  /// Start heartbeat to keep connection alive
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _sendHeartbeat();
    });
  }

  /// Send heartbeat ping
  void _sendHeartbeat() {
    if (_state == P2PConnectionState.connected) {
      send(Uint8List.fromList([0x06])); // HEARTBEAT message type
    }
  }

  /// Stop all timers
  void _stopTimers() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Update state and notify subscribers
  void _setState(P2PConnectionState newState) {
    if (_state != newState) {
      _state = newState;
      onStateChange?.call(newState);
      for (final callback in _stateSubscribers) {
        callback(newState);
      }
    }
  }

  /// Notify data subscribers
  void _notifyDataSubscribers(Uint8List data) {
    onDataReceived?.call(data);
    for (final callback in _dataSubscribers) {
      callback(data);
    }
  }

  /// Dispose resources
  void dispose() {
    _stopTimers();
    _stateSubscribers.clear();
    _dataSubscribers.clear();
    disconnect();
  }
}

/// P2P Connection States
enum P2PConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// Connection statistics
class ConnectionStats {
  final DateTime connectedAt;
  final Duration duration;
  final int packetsSent;
  final int packetsReceived;
  final int bytesSent;
  final int bytesReceived;
  final double latency;
  final double packetLoss;

  ConnectionStats({
    required this.connectedAt,
    required this.duration,
    required this.packetsSent,
    required this.packetsReceived,
    required this.bytesSent,
    required this.bytesReceived,
    required this.latency,
    required this.packetLoss,
  });

  double get throughputBps => 
      duration.inMilliseconds > 0 
          ? (bytesSent + bytesReceived) / (duration.inMilliseconds / 1000)
          : 0;
}

/// Network quality assessment
class NetworkQuality {
  static const double excellentThreshold = 50; // ms
  static const double goodThreshold = 150; // ms
  static const double fairThreshold = 300; // ms

  final double latency;
  final double packetLoss;
  final double jitter;

  NetworkQuality({
    required this.latency,
    required this.packetLoss,
    required this.jitter,
  });

  QualityLevel get level {
    if (latency <= excellentThreshold && packetLoss <= 0.1) {
      return QualityLevel.excellent;
    } else if (latency <= goodThreshold && packetLoss <= 1.0) {
      return QualityLevel.good;
    } else if (latency <= fairThreshold && packetLoss <= 5.0) {
      return QualityLevel.fair;
    } else {
      return QualityLevel.poor;
    }
  }
}

enum QualityLevel { excellent, good, fair, poor }

/// Connection profile for adaptive quality
class ConnectionProfile {
  final QualityLevel quality;
  final int maxBufferSize;
  final bool compressionEnabled;
  final int heartbeatInterval;

  static ConnectionProfile forQuality(QualityLevel quality) {
    switch (quality) {
      case QualityLevel.excellent:
        return ConnectionProfile(
          quality: quality,
          maxBufferSize: 65536,
          compressionEnabled: true,
          heartbeatInterval: 30,
        );
      case QualityLevel.good:
        return ConnectionProfile(
          quality: quality,
          maxBufferSize: 32768,
          compressionEnabled: true,
          heartbeatInterval: 20,
        );
      case QualityLevel.fair:
        return ConnectionProfile(
          quality: quality,
          maxBufferSize: 16384,
          compressionEnabled: true,
          heartbeatInterval: 15,
        );
      case QualityLevel.poor:
        return ConnectionProfile(
          quality: quality,
          maxBufferSize: 8192,
          compressionEnabled: false,
          heartbeatInterval: 10,
        );
    }
  }
}
