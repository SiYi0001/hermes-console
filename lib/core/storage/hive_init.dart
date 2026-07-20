import 'package:hive_flutter/hive_flutter.dart';

class HiveInit {
  static const String _settingsBox = 'settings';
  static const String _sessionsBox = 'sessions';
  static const String _historyBox = 'history';
  static const String _keysBox = 'keys';

  static const String _keyStoreBox = 'hermes_key_store';

  static Future<void> initialize() async {
    await Hive.initFlutter();

    // The encryption-key store must be opened BEFORE _getOrCreateEncryptionKey
    // is called (it reads/writes into this box). Opening it here guarantees it
    // exists when the encrypted keysBox is opened below.
    await Hive.openBox<List<int>>(_keyStoreBox);

    // Open boxes
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_sessionsBox);
    await Hive.openBox(_historyBox);
    await Hive.openBox(_keysBox,
        encryptionCipher: HiveAesCipher(_getOrCreateEncryptionKey()));
  }

  static Box get settingsBox => Hive.box(_settingsBox);
  static Box get sessionsBox => Hive.box(_sessionsBox);
  static Box get historyBox => Hive.box(_historyBox);
  static Box get keysBox => Hive.box(_keysBox);

  static List<int> _getOrCreateEncryptionKey() {
    const keyBoxName = 'hermes_key_store';
    final keyBox = Hive.box<List<int>>(keyBoxName);
    
    final existingKey = keyBox.get('encryption_key');
    if (existingKey != null) {
      return existingKey;
    }
    
    // Generate new key
    final key = List<int>.generate(32, (i) => DateTime.now().microsecondsSinceEpoch % 256);
    keyBox.put('encryption_key', key);
    return key;
  }

  static Future<void> clearAll() async {
    await settingsBox.clear();
    await sessionsBox.clear();
    await historyBox.clear();
    await keysBox.clear();
  }
}

/// Settings storage helper
class SettingsStorage {
  static const String _themeKey = 'theme';
  static const String _encryptionEnabledKey = 'encryption_enabled';
  static const String _compressionEnabledKey = 'compression_enabled';
  static const String _autoReconnectKey = 'auto_reconnect';
  static const String _timeoutKey = 'connection_timeout';
  static const String _stunServersKey = 'stun_servers';
  static const String _turnServersKey = 'turn_servers';

  // Theme
  static bool get isDarkMode => 
      HiveInit.settingsBox.get(_themeKey, defaultValue: true);

  static Future<void> setDarkMode(bool value) async =>
      await HiveInit.settingsBox.put(_themeKey, value);

  // Encryption
  static bool get encryptionEnabled =>
      HiveInit.settingsBox.get(_encryptionEnabledKey, defaultValue: true);

  static Future<void> setEncryptionEnabled(bool value) async =>
      await HiveInit.settingsBox.put(_encryptionEnabledKey, value);

  // Compression
  static bool get compressionEnabled =>
      HiveInit.settingsBox.get(_compressionEnabledKey, defaultValue: true);

  static Future<void> setCompressionEnabled(bool value) async =>
      await HiveInit.settingsBox.put(_compressionEnabledKey, value);

  // Auto reconnect
  static bool get autoReconnect =>
      HiveInit.settingsBox.get(_autoReconnectKey, defaultValue: true);

  static Future<void> setAutoReconnect(bool value) async =>
      await HiveInit.settingsBox.put(_autoReconnectKey, value);

  // Connection timeout (seconds)
  static int get connectionTimeout =>
      HiveInit.settingsBox.get(_timeoutKey, defaultValue: 30);

  static Future<void> setConnectionTimeout(int value) async =>
      await HiveInit.settingsBox.put(_timeoutKey, value);

  // STUN servers
  static List<String> get stunServers =>
      List<String>.from(HiveInit.settingsBox.get(_stunServersKey, defaultValue: [
        'stun:stun.l.google.com:19302',
        'stun:stun1.l.google.com:19302',
      ]));

  static Future<void> setStunServers(List<String> value) async =>
      await HiveInit.settingsBox.put(_stunServersKey, value);

  // TURN servers
  static List<String> get turnServers =>
      List<String>.from(HiveInit.settingsBox.get(_turnServersKey, defaultValue: <String>[]));

  static Future<void> setTurnServers(List<String> value) async =>
      await HiveInit.settingsBox.put(_turnServersKey, value);
}

/// Session storage helper
class SessionStorage {
  static Future<void> saveSession(SessionData session) async {
    await HiveInit.sessionsBox.put(session.id, {
      'id': session.id,
      'name': session.name,
      'peerId': session.peerId,
      'createdAt': session.createdAt,
      'lastConnected': session.lastConnected,
      'isFavorite': session.isFavorite,
    });
  }

  static List<SessionData> getAllSessions() {
    return HiveInit.sessionsBox.values.map((data) {
      final map = Map<String, dynamic>.from(data);
      return SessionData(
        id: map['id'],
        name: map['name'],
        peerId: map['peerId'],
        createdAt: map['createdAt'],
        lastConnected: map['lastConnected'],
        isFavorite: map['isFavorite'] ?? false,
      );
    }).toList()
      ..sort((a, b) => (b.lastConnected ?? 0).compareTo(a.lastConnected ?? 0));
  }

  static Future<void> deleteSession(String id) async {
    await HiveInit.sessionsBox.delete(id);
  }

  static Future<void> updateLastConnected(String id) async {
    final data = HiveInit.sessionsBox.get(id);
    if (data != null) {
      await HiveInit.sessionsBox.put(id, {
        ...Map<String, dynamic>.from(data),
        'lastConnected': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }
}

/// Command history storage
class HistoryStorage {
  static const int maxHistoryItems = 1000;

  static Future<void> addCommand(String sessionId, String command) async {
    final history = HiveInit.historyBox.get(sessionId, defaultValue: <String>[]);
    final historyList = List<String>.from(history);
    
    historyList.add(command);
    
    // Keep only last N items
    while (historyList.length > maxHistoryItems) {
      historyList.removeAt(0);
    }
    
    await HiveInit.historyBox.put(sessionId, historyList);
  }

  static List<String> getHistory(String sessionId) {
    return List<String>.from(
      HiveInit.historyBox.get(sessionId, defaultValue: <String>[]),
    );
  }

  static Future<void> clearHistory(String sessionId) async {
    await HiveInit.historyBox.put(sessionId, <String>[]);
  }
}

/// Secure key storage
class SecureKeyStorage {
  static Future<void> saveKey(String keyId, List<int> keyData) async {
    await HiveInit.keysBox.put(keyId, keyData);
  }

  static List<int>? getKey(String keyId) {
    return HiveInit.keysBox.get(keyId);
  }

  static Future<void> deleteKey(String keyId) async {
    await HiveInit.keysBox.delete(keyId);
  }
}

/// Session data model
class SessionData {
  final String id;
  final String name;
  final String peerId;
  final int createdAt;
  int? lastConnected;
  bool isFavorite;

  SessionData({
    required this.id,
    required this.name,
    required this.peerId,
    required this.createdAt,
    this.lastConnected,
    this.isFavorite = false,
  });
}
