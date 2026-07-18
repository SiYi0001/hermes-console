import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webrtc/models/rtc_configuration.dart';
import 'package:webrtc/models/rtc_peer_connection.dart';
import 'package:webrtc/models/rtc_data_channel.dart';
import '../crypto/crypto_service.dart';
import '../protocol/hermes_protocol.dart';
import 'compression_service.dart';

/// Connection state enum
enum ConnectionState {
  disconnected,
  connecting,
  connected,
  authenticated,
  error,
}

/// P2P Data Channel Manager using WebRTC
class P2PDataChannelManager {
  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;
  
  final CryptoService _cryptoService;
  final CompressionService _compressionService;
  final HermesProtocol _protocol;
  
  ConnectionState _state = ConnectionState.disconnected;
  
  final _stateController = StreamController<ConnectionState>.broadcast();
  final _messageController = StreamController<ProtocolMessage>.broadcast();
  final _rawDataController = StreamController<Uint8List>.broadcast();
  
  Stream<ConnectionState> get stateStream => _stateController.stream;
  Stream<ProtocolMessage> get messageStream => _messageController.stream;
  Stream<Uint8List> get rawDataStream => _rawDataController.stream;
  
  ConnectionState get state => _state;
  
  // ICE Server configuration
  static final RTCConfiguration _iceConfig = RTCConfiguration(
    iceServers: [
      // STUN servers
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      // TURN servers (replace with your own)
      {
        'urls': 'turn:your-turn-server.com:3478',
        'username': 'hermes',
        'credential': 'hermes-secret',
      },
    ],
    iceCandidatePoolSize: 10,
    bundlePolicy: RTCBundlePolicy.maxBundle,
    rtcpMuxPolicy: RTCRtcpMuxPolicy.require,
  );

  P2PDataChannelManager({
    required CryptoService cryptoService,
    required CompressionService compressionService,
    required HermesProtocol protocol,
  })  : _cryptoService = cryptoService,
        _compressionService = compressionService,
        _protocol = protocol;

  /// Connect to a remote peer (offer side)
  Future<void> connectAsOffer(String remotePeerId) async {
    _updateState(ConnectionState.connecting);
    
    try {
      _peerConnection = await createPeerConnection(_iceConfig);
      _setupPeerConnectionHandlers();
      
      // Create data channel
      _dataChannel = await _peerConnection!.createDataChannel(
        'hermes-control',
        RTCDataChannelInit()
          ..ordered = true
          ..maxRetransmits = 3
          ..protocol = 'hermes-v1',
      );
      _setupDataChannelHandlers();
      
      // Create offer
      final offer = await _peerConnection!.createOffer({});
      await _peerConnection!.setLocalDescription(offer);
      
      // Wait for ICE gathering to complete
      await _waitForIceGathering();
      
      // Send offer to peer (would normally go through signaling server)
      final offerData = _encodeSessionDescription(offer);
      _rawDataController.add(offerData);
      
    } catch (e) {
      _updateState(ConnectionState.error);
      rethrow;
    }
  }

  /// Connect to a remote peer (answer side)
  Future<void> connectAsAnswer(String remoteOffer) async {
    _updateState(ConnectionState.connecting);
    
    try {
      _peerConnection = await createPeerConnection(_iceConfig);
      _setupPeerConnectionHandlers();
      
      // Set remote description from offer
      final offer = _decodeSessionDescription(remoteOffer);
      await _peerConnection!.setRemoteDescription(offer);
      
      // Create answer
      final answer = await _peerConnection!.createAnswer({});
      await _peerConnection!.setLocalDescription(answer);
      
      // Wait for ICE gathering
      await _waitForIceGathering();
      
      // Send answer
      final answerData = _encodeSessionDescription(answer);
      _rawDataController.add(answerData);
      
    } catch (e) {
      _updateState(ConnectionState.error);
      rethrow;
    }
  }

  /// Handle incoming answer (offer side)
  Future<void> handleAnswer(String answerData) async {
    try {
      final answer = _decodeSessionDescription(answerData);
      await _peerConnection!.setRemoteDescription(answer);
    } catch (e) {
      _updateState(ConnectionState.error);
      rethrow;
    }
  }

  /// Handle incoming ICE candidate
  Future<void> handleIceCandidate(String candidateData) async {
    try {
      final candidate = _decodeIceCandidate(candidateData);
      await _peerConnection!.addIceCandidate(candidate);
    } catch (e) {
      // ICE candidate errors are usually not fatal
    }
  }

  /// Send a protocol message
  Future<void> sendMessage(ProtocolMessage message) async {
    if (_dataChannel?.state != RTCDataChannelState.RTCDataChannelOpen) {
      throw StateError('Data channel not open');
    }
    
    // Encode and encrypt
    final encoded = _protocol.encode(message);
    final compressed = _compressionService.compress(encoded);
    final encrypted = await _cryptoService.encrypt(compressed);
    
    _dataChannel!.send(RTCDataChannelMessage.fromBinary(encrypted));
  }

  /// Send raw bytes
  Future<void> sendRaw(Uint8List data) async {
    if (_dataChannel?.state != RTCDataChannelState.RTCDataChannelOpen) {
      throw StateError('Data channel not open');
    }
    _dataChannel!.send(RTCDataChannelMessage.fromBinary(data));
  }

  /// Disconnect
  Future<void> disconnect() async {
    await _dataChannel?.close();
    await _peerConnection?.close();
    _dataChannel = null;
    _peerConnection = null;
    _cryptoService.clearSession();
    _updateState(ConnectionState.disconnected);
  }

  void _setupPeerConnectionHandlers() {
    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate != null) {
        final candidateData = _encodeIceCandidate(candidate);
        _rawDataController.add(candidateData);
      }
    };

    _peerConnection!.onConnectionState = (state) {
      switch (state) {
        case RTCPeerConnectionState.RTCPeerConnectionFailed:
        case RTCPeerConnectionState.RTCPeerConnectionClosed:
          _updateState(ConnectionState.disconnected);
          break;
        case RTCPeerConnectionState.RTCPeerConnectionConnected:
          // Wait for data channel to open
          break;
        default:
          break;
      }
    };

    _peerConnection!.onDataChannel = (channel) {
      _dataChannel = channel;
      _setupDataChannelHandlers();
    };
  }

  void _setupDataChannelHandlers() {
    _dataChannel!.onStateChange = (state) {
      switch (state) {
        case RTCDataChannelState.RTCDataChannelOpen:
          _updateState(ConnectionState.connected);
          break;
        case RTCDataChannelState.RTCDataChannelClosed:
          _updateState(ConnectionState.disconnected);
          break;
        default:
          break;
      }
    };

    _dataChannel!.onMessage = (message) async {
      if (message.isBinary) {
        await _handleIncomingData(message.binary);
      }
    };
  }

  Future<void> _handleIncomingData(Uint8List data) async {
    try {
      // Decrypt
      final decrypted = await _cryptoService.decrypt(data);
      // Decompress
      final decompressed = _compressionService.decompress(decrypted);
      // Decode protocol message
      final message = _protocol.decode(decompressed);
      _messageController.add(message);
    } catch (e) {
      // Handle decryption/decode errors
    }
  }

  void _updateState(ConnectionState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  Future<void> _waitForIceGathering() async {
    final completer = Completer<void>();
    
    Timer? timeout;
    timeout = Timer(const Duration(seconds: 10), () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    void checkComplete(RICECandidateType? type) {
      if (completer.isCompleted) return;
      
      _peerConnection!.getIceGatheringState().then((state) {
        if (state == RICEGatheringState.RICEGatheringComplete) {
          timeout?.cancel();
          completer.complete();
        }
      });
    }

    _peerConnection!.onIceGatheringState = checkComplete;
    checkComplete(null);

    return completer.future;
  }

  String _encodeSessionDescription(RTCSessionDescription desc) {
    return jsonEncode({
      'type': desc.type.name,
      'sdp': desc.sdp,
    });
  }

  RTCSessionDescription _decodeSessionDescription(String data) {
    final json = jsonDecode(data);
    return RTCSessionDescription(
      json['sdp'],
      json['type'],
    );
  }

  String _encodeIceCandidate(RTCIceCandidate candidate) {
    return jsonEncode({
      'candidate': candidate.candidate,
      'sdpMid': candidate.sdpMid,
      'sdpMLineIndex': candidate.sdpMLineIndex,
    });
  }

  RTCIceCandidate _decodeIceCandidate(String data) {
    final json = jsonDecode(data);
    return RTCIceCandidate(
      json['candidate'],
      json['sdpMid'],
      json['sdpMLineIndex'],
    );
  }

  void dispose() {
    disconnect();
    _stateController.close();
    _messageController.close();
    _rawDataController.close();
  }
}

/// Connection state notifier for Riverpod
final connectionStateProvider = StateNotifierProvider<ConnectionStateNotifier, ConnectionState>(
  (ref) => ConnectionStateNotifier(),
);

class ConnectionStateNotifier extends StateNotifier<ConnectionState> {
  ConnectionStateNotifier() : super(ConnectionState.disconnected);

  void updateState(ConnectionState newState) {
    state = newState;
  }
}

/// P2P Manager provider
final p2pManagerProvider = Provider<P2PDataChannelManager>((ref) {
  throw UnimplementedError('Must be overridden in main');
});
