import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_console/core/crypto/crypto_service.dart';

void main() {
  group('CryptoService', () {
    late CryptoService crypto;

    setUp(() {
      crypto = CryptoService();
    });

    test('is not initialized before a key is set', () {
      expect(crypto.isInitialized, isFalse);
    });

    test('encrypt throws StateError when not initialized', () {
      expect(
        () => crypto.encrypt(Uint8List.fromList([1, 2, 3])),
        throwsStateError,
      );
    });

    test('encrypt/decrypt round-trip recovers plaintext', () async {
      await crypto.initializeKey(
        Uint8List.fromList(List<int>.generate(32, (i) => i)),
      );
      final plaintext =
          Uint8List.fromList(utf8.encode('Hello, Hermes! 你好 🎉'));

      final encrypted = await crypto.encrypt(plaintext);
      final decrypted = await crypto.decrypt(encrypted);

      expect(decrypted, equals(plaintext));
      expect(encrypted, isNot(equals(plaintext)));
    });

    test('same plaintext yields different ciphertext (random nonce)', () async {
      await crypto.initializeKey(
        Uint8List.fromList(List<int>.generate(32, (i) => i)),
      );
      final data = Uint8List.fromList(utf8.encode('test'));

      final e1 = await crypto.encrypt(data);
      final e2 = await crypto.encrypt(data);

      expect(e1, isNot(equals(e2)));
    });

    test('generateSessionKey initializes and returns a 32-byte key', () async {
      final key = await crypto.generateSessionKey();
      expect(key.length, equals(32));
      expect(crypto.isInitialized, isTrue);
    });

    test('clearSession resets the initialized state', () async {
      await crypto.generateSessionKey();
      expect(crypto.isInitialized, isTrue);

      crypto.clearSession();
      expect(crypto.isInitialized, isFalse);
    });

    test('decrypt throws ArgumentError on too-short data', () async {
      await crypto.initializeKey(
        Uint8List.fromList(List<int>.generate(32, (i) => i)),
      );
      expect(
        () => crypto.decrypt(Uint8List.fromList([1, 2, 3])),
        throwsArgumentError,
      );
    });
  });

  group('KeyExchangeService', () {
    late KeyExchangeService kex;

    setUp(() {
      kex = KeyExchangeService();
    });

    test('generateKeyPair creates a valid X25519 key pair', () async {
      final kp = await kex.generateKeyPair();
      final pub = await kp.extractPublicKey();
      final priv = await kp.extractPrivateKeyBytes();

      expect(pub.bytes, isNotEmpty);
      expect(priv, isNotEmpty);
      expect(pub.bytes.length, equals(32));
      expect(priv.length, equals(32));
    });

    test('generated key pairs are unique', () async {
      final kp1 = await kex.generateKeyPair();
      final kp2 = await kex.generateKeyPair();

      final pub1 = await kp1.extractPublicKey();
      final pub2 = await kp2.extractPublicKey();

      expect(pub1.bytes, isNot(equals(pub2.bytes)));
    });

    test('ECDH derives identical shared secret in both directions', () async {
      final alice = await kex.generateKeyPair();
      final bob = await kex.generateKeyPair();

      final alicePub = await alice.extractPublicKey();
      final bobPub = await bob.extractPublicKey();

      final sharedAlice = await kex.deriveSharedSecret(alice, bobPub);
      final sharedBob = await kex.deriveSharedSecret(bob, alicePub);

      expect(sharedAlice, equals(sharedBob));
      expect(sharedAlice.length, equals(32));
    });

    test('ECDH with different peers yields different secrets', () async {
      final alice = await kex.generateKeyPair();
      final bob = await kex.generateKeyPair();
      final charlie = await kex.generateKeyPair();

      final bobPub = await bob.extractPublicKey();
      final charliePub = await charlie.extractPublicKey();

      final sharedAB = await kex.deriveSharedSecret(alice, bobPub);
      final sharedAC = await kex.deriveSharedSecret(alice, charliePub);

      expect(sharedAB, isNot(equals(sharedAC)));
    });

    test('bytesToPublicKey reconstructs a usable public key', () async {
      final kp = await kex.generateKeyPair();
      final pub = await kp.extractPublicKey();

      final restored = kex.bytesToPublicKey(Uint8List.fromList(pub.bytes));
      expect(restored.bytes, equals(pub.bytes));
    });
  });

  group('HkdfService', () {
    late HkdfService hkdf;

    setUp(() {
      hkdf = HkdfService();
    });

    test('deriveKeys returns 32-byte encryption and mac keys', () async {
      final ikm = Uint8List.fromList(List<int>.generate(32, (i) => i));

      final keys = await hkdf.deriveKeys(ikm);

      expect(keys.encryptionKey.length, equals(32));
      expect(keys.macKey.length, equals(32));
      expect(keys.encryptionKey, isNot(equals(keys.macKey)));
    });

    test('deriveKeys is deterministic for the same input', () async {
      final ikm = Uint8List.fromList(List<int>.generate(32, (i) => i));

      final k1 = await hkdf.deriveKeys(ikm);
      final k2 = await hkdf.deriveKeys(ikm);

      expect(k1.encryptionKey, equals(k2.encryptionKey));
      expect(k1.macKey, equals(k2.macKey));
    });

    test('different salt yields different keys', () async {
      final ikm = Uint8List.fromList(List<int>.generate(32, (i) => i));

      final k1 = await hkdf.deriveKeys(
        ikm,
        salt: Uint8List.fromList([1, 2, 3]),
      );
      final k2 = await hkdf.deriveKeys(
        ikm,
        salt: Uint8List.fromList([4, 5, 6]),
      );

      expect(k1.encryptionKey, isNot(equals(k2.encryptionKey)));
    });
  });
}
