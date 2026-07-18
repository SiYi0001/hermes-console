import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_console/core/crypto/crypto_service.dart';
import 'package:hermes_console/core/network/compression_service.dart';
import 'package:hermes_console/core/protocol/hermes_protocol.dart';

void main() {
  group('HermesProtocol', () {
    late HermesProtocol protocol;

    setUp(() {
      protocol = HermesProtocol();
    });

    test('should encode and decode HELLO message', () {
      final hello = HelloMessage(
        version: '1.0.0',
        clientId: 'test-client-001',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        capabilities: ['encryption', 'compression'],
      );

      final encoded = protocol.encode(hello);
      final decoded = protocol.decode(encoded);

      expect(decoded, isA<HelloMessage>());
      expect((decoded as HelloMessage).version, equals(hello.version));
      expect(decoded.clientId, equals(hello.clientId));
      expect(decoded.capabilities, equals(hello.capabilities));
    });

    test('should encode and decode AUTH_REQUEST message', () {
      final auth = AuthRequestMessage(
        token: 'test-token-123',
        username: 'admin',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        nonce: 'random-nonce',
      );

      final encoded = protocol.encode(auth);
      final decoded = protocol.decode(encoded);

      expect(decoded, isA<AuthRequestMessage>());
      expect((decoded as AuthRequestMessage).token, equals(auth.token));
      expect(decoded.username, equals(auth.username));
    });

    test('should encode and decode COMMAND message', () {
      final command = CommandMessage(
        id: 'cmd-001',
        command: 'ls -la',
        args: {'cwd': '/home'},
        timeout: 30,
      );

      final encoded = protocol.encode(command);
      final decoded = protocol.decode(encoded);

      expect(decoded, isA<CommandMessage>());
      expect((decoded as CommandMessage).command, equals(command.command));
      expect(decoded.id, equals(command.id));
    });

    test('should encode and decode HEARTBEAT message', () {
      final heartbeat = HeartbeatMessage(
        timestamp: DateTime.now().millisecondsSinceEpoch,
        latency: 25,
        sequence: 100,
      );

      final encoded = protocol.encode(heartbeat);
      final decoded = protocol.decode(encoded);

      expect(decoded, isA<HeartbeatMessage>());
      expect((decoded as HeartbeatMessage).latency, equals(heartbeat.latency));
      expect(decoded.sequence, equals(heartbeat.sequence));
    });

    test('should throw on invalid magic number', () {
      final invalidData = Uint8List.fromList([0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x05]);
      
      expect(
        () => protocol.decode(invalidData),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('CryptoService', () {
    late CryptoService cryptoService;

    setUp(() async {
      cryptoService = CryptoService();
      final key = await cryptoService.generateSessionKey();
      await cryptoService.initializeKey(key);
    });

    test('should encrypt and decrypt data', () async {
      final originalData = Uint8List.fromList('Hello, Hermes!'.codeUnits);

      final encrypted = await cryptoService.encrypt(originalData);
      final decrypted = await cryptoService.decrypt(encrypted);

      expect(decrypted, equals(originalData));
      expect(encrypted, isNot(equals(originalData)));
    });

    test('should produce different ciphertext for same plaintext', () async {
      final data = Uint8List.fromList('Test data'.codeUnits);

      final encrypted1 = await cryptoService.encrypt(data);
      final encrypted2 = await cryptoService.encrypt(data);

      // Due to random nonce, ciphertexts should differ
      expect(encrypted1, isNot(equals(encrypted2)));
    });

    test('should clear session', () {
      expect(cryptoService.isInitialized, isTrue);
      cryptoService.clearSession();
      expect(cryptoService.isInitialized, isFalse);
    });
  });

  group('KeyExchangeService', () {
    late KeyExchangeService keyExchange;

    setUp(() {
      keyExchange = KeyExchangeService();
    });

    test('should generate key pair', () async {
      final keyPair = await keyExchange.generateKeyPair();
      
      expect(keyPair, isNotNull);
      final publicKey = await keyPair.extractPublicKey();
      expect(publicKey, isNotNull);
    });

    test('should derive shared secret', () async {
      final aliceKeyPair = await keyExchange.generateKeyPair();
      final bobKeyPair = await keyExchange.generateKeyPair();

      final alicePublicKey = await aliceKeyPair.extractPublicKey();
      final bobPublicKey = await bobKeyPair.extractPublicKey();

      final aliceSharedSecret = await keyExchange.deriveSharedSecret(
        aliceKeyPair,
        bobPublicKey,
      );
      final bobSharedSecret = await keyExchange.deriveSharedSecret(
        bobKeyPair,
        alicePublicKey,
      );

      // Both should derive the same shared secret
      expect(aliceSharedSecret, equals(bobSharedSecret));
      expect(aliceSharedSecret.length, equals(32)); // X25519 shared secret is 32 bytes
    });
  });

  group('CompressionService', () {
    late CompressionService compressionService;

    setUp(() {
      compressionService = CompressionService();
    });

    test('should compress and decompress data', () {
      final originalData = Uint8List.fromList('Test data for compression'.codeUnits);

      final compressed = compressionService.compress(originalData);
      final decompressed = compressionService.decompress(compressed);

      expect(decompressed, equals(originalData));
    });

    test('should skip compression for small data', () {
      final smallData = Uint8List.fromList('Hi'.codeUnits);

      final compressed = compressionService.compress(smallData);

      // Small data should not be compressed (first byte indicates compression)
      expect(compressed[0], equals(0x00)); // Not compressed
    });

    test('should compress repetitive data well', () {
      final repetitiveData = Uint8List.fromList('AAAA' * 1000);

      final compressed = compressionService.compress(repetitiveData);

      // Compressed data should be smaller
      expect(compressed.length, lessThan(repetitiveData.length));
    });
  });

  group('HkdfService', () {
    late HkdfService hkdfService;

    setUp(() {
      hkdfService = HkdfService();
    });

    test('should derive encryption and MAC keys', () async {
      final sharedSecret = Uint8List(32); // 32 bytes of shared secret
      for (int i = 0; i < 32; i++) {
        sharedSecret[i] = i;
      }

      final derivedKeys = await hkdfService.deriveKeys(sharedSecret);

      expect(derivedKeys.encryptionKey.length, equals(32));
      expect(derivedKeys.macKey.length, equals(32));
      expect(derivedKeys.encryptionKey, isNot(equals(derivedKeys.macKey)));
    });

    test('should produce same keys for same input', () async {
      final sharedSecret = Uint8List(32);
      for (int i = 0; i < 32; i++) {
        sharedSecret[i] = i;
      }

      final keys1 = await hkdfService.deriveKeys(sharedSecret);
      final keys2 = await hkdfService.deriveKeys(sharedSecret);

      expect(keys1.encryptionKey, equals(keys2.encryptionKey));
      expect(keys1.macKey, equals(keys2.macKey));
    });
  });
}
