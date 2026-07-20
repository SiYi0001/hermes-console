import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

/// AES-256-GCM encryption service using Flutter cryptography package
class CryptoService {
  final AesGcm _aesGcm = AesGcm.with256bits();
  SecretKey? _sessionKey;

  /// Initialize with a pre-shared key or derive from DH
  Future<void> initializeKey(Uint8List keyBytes) async {
    _sessionKey = SecretKey(keyBytes);
  }

  /// Generate a new random session key
  Future<Uint8List> generateSessionKey() async {
    final key = await _aesGcm.newSecretKey();
    final keyBytes = await key.extractBytes();
    _sessionKey = key;
    return Uint8List.fromList(keyBytes);
  }

  /// Encrypt data with AES-256-GCM
  Future<Uint8List> encrypt(Uint8List plaintext) async {
    if (_sessionKey == null) {
      throw StateError('CryptoService not initialized. Call initializeKey first.');
    }

    final nonce = _aesGcm.newNonce();
    
    final secretBox = await _aesGcm.encrypt(
      plaintext,
      secretKey: _sessionKey!,
      nonce: nonce,
    );

    // Combine nonce + ciphertext + mac
    final result = Uint8List(
      nonce.length + secretBox.cipherText.length + secretBox.mac.bytes.length,
    );
    result.setAll(0, nonce);
    result.setAll(nonce.length, secretBox.cipherText);
    result.setAll(
      nonce.length + secretBox.cipherText.length,
      secretBox.mac.bytes,
    );

    return result;
  }

  /// Decrypt data with AES-256-GCM
  Future<Uint8List> decrypt(Uint8List encryptedData) async {
    if (_sessionKey == null) {
      throw StateError('CryptoService not initialized. Call initializeKey first.');
    }

    const nonceLength = 12; // GCM standard nonce length
    const macLength = 16; // GCM standard MAC length

    if (encryptedData.length < nonceLength + macLength) {
      throw ArgumentError('Encrypted data too short');
    }

    final nonce = encryptedData.sublist(0, nonceLength);
    final ciphertext = encryptedData.sublist(
      nonceLength,
      encryptedData.length - macLength,
    );
    final mac = Mac(encryptedData.sublist(encryptedData.length - macLength));

    final secretBox = SecretBox(
      ciphertext,
      nonce: nonce,
      mac: mac,
    );

    final plaintext = await _aesGcm.decrypt(
      secretBox,
      secretKey: _sessionKey!,
    );

    return Uint8List.fromList(plaintext);
  }

  /// Clear session key
  void clearSession() {
    _sessionKey = null;
  }

  /// Check if initialized
  bool get isInitialized => _sessionKey != null;
}

/// X25519 key exchange service
class KeyExchangeService {
  final X25519 _x25519 = X25519();

  /// Generate a new key pair
  Future<SimpleKeyPair> generateKeyPair() async {
    return await _x25519.newKeyPair();
  }

  /// Derive shared secret from key pair and peer public key
  Future<Uint8List> deriveSharedSecret(
    SimpleKeyPair localKeyPair,
    SimplePublicKey peerPublicKey,
  ) async {
    final sharedSecret = await _x25519.sharedSecretKey(
      keyPair: localKeyPair,
      remotePublicKey: peerPublicKey,
    );
    return Uint8List.fromList(await sharedSecret.extractBytes());
  }

  /// Convert bytes to public key
  SimplePublicKey bytesToPublicKey(Uint8List bytes) {
    return SimplePublicKey(bytes, type: KeyPairType.x25519);
  }
}

/// HKDF key derivation
class HkdfService {
  static const int _keyLength = 64; // 32 bytes for encryption + 32 for MAC

  /// Derive keys from shared secret using HKDF-SHA256
  Future<DerivedKeys> deriveKeys(Uint8List sharedSecret, {Uint8List? salt}) async {
    final hkdf = Hkdf(
      hmac: Hmac.sha256(),
      outputLength: _keyLength,
    );

    final derivedKey = await hkdf.deriveKey(
      secretKey: SecretKey(sharedSecret),
      nonce: salt ?? Uint8List(0),
    );

    final keyBytes = await derivedKey.extractBytes();
    
    return DerivedKeys(
      encryptionKey: Uint8List.fromList(keyBytes.sublist(0, 32)),
      macKey: Uint8List.fromList(keyBytes.sublist(32, 64)),
    );
  }
}

/// Container for derived encryption and MAC keys
class DerivedKeys {
  final Uint8List encryptionKey;
  final Uint8List macKey;

  DerivedKeys({
    required this.encryptionKey,
    required this.macKey,
  });
}
