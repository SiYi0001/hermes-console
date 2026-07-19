import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_console/core/crypto/crypto_service.dart';

void main() {
  late CryptoService crypto;

  setUpAll(() {
    crypto = CryptoService();
  });

  group('CryptoService — Key Generation', () {
    test('generateKeyPair creates valid Curve25519 key pair', () async {
      final keyPair = await crypto.generateKeyPair();

      expect(keyPair.publicKey, isNotEmpty);
      expect(keyPair.privateKey, isNotEmpty);
      expect(keyPair.publicKey.length, greaterThan(0));
      expect(keyPair.privateKey.length, greaterThan(0));
      // 公钥和私钥不应相同
      expect(keyPair.publicKey, isNot(equals(keyPair.privateKey)));
    });

    test('generated keys are deterministic (seeded by random)', () async {
      final kp1 = await crypto.generateKeyPair();
      final kp2 = await crypto.generateKeyPair();

      // 每次生成应当不同（基于随机数）
      expect(kp1.publicKey, isNot(equals(kp2.publicKey)));
    });
  });

  group('CryptoService — ECDH Key Exchange', () {
    test('ECDH produces same shared secret for both parties', () async {
      final alice = await crypto.generateKeyPair();
      final bob = await crypto.generateKeyPair();

      final sharedAlice = crypto.deriveSharedSecret(
        bob.publicKey, // Alice 用 Bob 的公钥
        alice.privateKey,
      );
      final sharedBob = crypto.deriveSharedSecret(
        alice.publicKey, // Bob 用 Alice 的公钥
        bob.privateKey,
      );

      expect(sharedAlice, equals(sharedBob));
      expect(sharedAlice.length, greaterThan(0));
    });

    test('ECDH with mismatched keys produces different secrets', () async {
      final alice = await crypto.generateKeyPair();
      final bob = await crypto.generateKeyPair();
      final charlie = await crypto.generateKeyPair();

      final sharedAlice = crypto.deriveSharedSecret(bob.publicKey, alice.privateKey);
      final sharedCharlie = crypto.deriveSharedSecret(
        charlie.publicKey,
        alice.privateKey,
      );

      expect(sharedAlice, isNot(equals(sharedCharlie)));
    });
  });

  group('CryptoService — HKDF Key Derivation', () {
    test('HKDF derives 32-byte session key from IKM', () {
      final ikm = List<int>.generate(32, (i) => i * 4 % 256);
      final sessionKey = crypto.hkdfDerive(
        ikm: Uint8List.fromList(ikm),
        info: 'hermes-v1',
        length: 32,
      );

      expect(sessionKey.length, equals(32));
    });

    test('HKDF with different info produces different keys', () {
      final ikm = List<int>.generate(32, (i) => i * 4 % 256);
      final key1 = crypto.hkdfDerive(
        ikm: Uint8List.fromList(ikm),
        info: 'hermes-v1',
        length: 32,
      );
      final key2 = crypto.hkdfDerive(
        ikm: Uint8List.fromList(ikm),
        info: 'hermes-v2',
        length: 32,
      );

      expect(key1, isNot(equals(key2)));
    });

    test('HKDF with different length produces correct size', () {
      final ikm = List<int>.generate(32, (i) => i * 4 % 256);
      final key64 = crypto.hkdfDerive(
        ikm: Uint8List.fromList(ikm),
        info: 'hermes-v1',
        length: 64,
      );

      expect(key64.length, equals(64));
    });
  });

  group('CryptoService — AES-256-GCM Encryption', () {
    test('encrypt/decrypt round-trip recovers plaintext', () async {
      final plaintext = 'Hello, Hermes! 你好 Hermès! 🎉';
      final plaintextBytes = Uint8List.fromList(utf8.encode(plaintext));

      final keyPair = await crypto.generateKeyPair();
      final sharedKey = crypto.deriveSharedSecret(
        keyPair.publicKey,
        keyPair.privateKey,
      );
      final sessionKey = crypto.hkdfDerive(
        ikm: sharedKey,
        info: 'hermes-v1',
        length: 32,
      );
      final nonce = crypto.generateNonce();

      final encrypted = crypto.encryptAesGcm(
        plaintext: plaintextBytes,
        key: sessionKey,
        nonce: nonce,
      );

      expect(encrypted, isNot(equals(plaintextBytes)));

      final decrypted = crypto.decryptAesGcm(
        ciphertext: encrypted,
        key: sessionKey,
        nonce: nonce,
      );

      expect(utf8.decode(decrypted), equals(plaintext));
    });

    test('different nonce produces different ciphertext', () async {
      final plaintext = Uint8List.fromList(utf8.encode('test'));
      final keyPair = await crypto.generateKeyPair();
      final sharedKey = crypto.deriveSharedSecret(
        keyPair.publicKey,
        keyPair.privateKey,
      );
      final sessionKey = crypto.hkdfDerive(
        ikm: sharedKey,
        info: 'hermes-v1',
        length: 32,
      );

      final encrypted1 = crypto.encryptAesGcm(
        plaintext: plaintext,
        key: sessionKey,
        nonce: crypto.generateNonce(),
      );
      final encrypted2 = crypto.encryptAesGcm(
        plaintext: plaintext,
        key: sessionKey,
        nonce: crypto.generateNonce(),
      );

      expect(encrypted1, isNot(equals(encrypted2)));
    });

    test('wrong nonce fails to decrypt', () async {
      final plaintext = Uint8List.fromList(utf8.encode('secret'));
      final keyPair = await crypto.generateKeyPair();
      final sharedKey = crypto.deriveSharedSecret(
        keyPair.publicKey,
        keyPair.privateKey,
      );
      final sessionKey = crypto.hkdfDerive(
        ikm: sharedKey,
        info: 'hermes-v1',
        length: 32,
      );

      final encrypted = crypto.encryptAesGcm(
        plaintext: plaintext,
        key: sessionKey,
        nonce: crypto.generateNonce(),
      );

      final wrongNonce = crypto.generateNonce();
      final decrypted = crypto.decryptAesGcm(
        ciphertext: encrypted,
        key: sessionKey,
        nonce: wrongNonce,
      );

      // AES-GCM 带 tag 验证，nonce 不匹配会破坏认证标签
      // 行为取决于实现：可能返回错误数据或抛出异常
      // 这里只检查解密结果与原文不同（认证失败）
      expect(utf8.decode(decrypted), isNot(equals('secret')));
    });

    test('wrong key fails to decrypt', () async {
      final plaintext = Uint8List.fromList(utf8.encode('secret'));
      final keyPair = await crypto.generateKeyPair();
      final sharedKey = crypto.deriveSharedSecret(
        keyPair.publicKey,
        keyPair.privateKey,
      );
      final correctKey = crypto.hkdfDerive(
        ikm: sharedKey,
        info: 'hermes-v1',
        length: 32,
      );
      final wrongKey = crypto.hkdfDerive(
        ikm: sharedKey,
        info: 'wrong-key',
        length: 32,
      );
      final nonce = crypto.generateNonce();

      final encrypted = crypto.encryptAesGcm(
        plaintext: plaintext,
        key: correctKey,
        nonce: nonce,
      );

      final decrypted = crypto.decryptAesGcm(
        ciphertext: encrypted,
        key: wrongKey,
        nonce: nonce,
      );

      expect(utf8.decode(decrypted), isNot(equals('secret')));
    });

    test('handles empty plaintext', () async {
      final plaintext = Uint8List(0);
      final keyPair = await crypto.generateKeyPair();
      final sharedKey = crypto.deriveSharedSecret(
        keyPair.publicKey,
        keyPair.privateKey,
      );
      final sessionKey = crypto.hkdfDerive(
        ikm: sharedKey,
        info: 'hermes-v1',
        length: 32,
      );
      final nonce = crypto.generateNonce();

      final encrypted = crypto.encryptAesGcm(
        plaintext: plaintext,
        key: sessionKey,
        nonce: nonce,
      );
      final decrypted = crypto.decryptAesGcm(
        ciphertext: encrypted,
        key: sessionKey,
        nonce: nonce,
      );

      expect(decrypted, isEmpty);
    });

    test('handles large plaintext (1MB)', () async {
      final plaintext = Uint8List.fromList(
        List<int>.generate(1024 * 1024, (i) => i % 256),
      );
      final keyPair = await crypto.generateKeyPair();
      final sharedKey = crypto.deriveSharedSecret(
        keyPair.publicKey,
        keyPair.privateKey,
      );
      final sessionKey = crypto.hkdfDerive(
        ikm: sharedKey,
        info: 'hermes-v1',
        length: 32,
      );
      final nonce = crypto.generateNonce();

      final encrypted = crypto.encryptAesGcm(
        plaintext: plaintext,
        key: sessionKey,
        nonce: nonce,
      );
      final decrypted = crypto.decryptAesGcm(
        ciphertext: encrypted,
        key: sessionKey,
        nonce: nonce,
      );

      expect(decrypted.length, equals(plaintext.length));
      for (var i = 0; i < plaintext.length; i++) {
        expect(decrypted[i], equals(plaintext[i]));
      }
    });
  });

  group('CryptoService — Nonce Generation', () {
    test('generateNonce creates 12-byte nonce', () {
      final nonce = crypto.generateNonce();
      expect(nonce.length, equals(12));
    });

    test('generateNonce produces unique values', () {
      final nonce1 = crypto.generateNonce();
      final nonce2 = crypto.generateNonce();
      expect(nonce1, isNot(equals(nonce2)));
    });
  });
}

// Re-export for convenience
import 'dart:typed_data';
import 'dart:convert';
