import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermes_console/core/services/settings_service.dart';
import 'package:hermes_console/features/settings/settings_screen.dart';
import 'package:hermes_console/shared/theme/hermes_theme.dart';
import 'package:hive/hive.dart';

/// In-memory Hive Box stub — satisfies SettingsNotifier's _box.get / _box.put.
@pragma('vm:entry-point')
class _FakeHiveBox implements Box {
  final Map<String, dynamic> _data = {};

  @override
  dynamic get(dynamic key, {dynamic defaultValue}) =>
      _data[key.toString()] ?? defaultValue;

  @override
  Future<void> put(dynamic key, dynamic value) async {
    _data[key.toString()] = value;
  }

  // Remaining Box members — no-ops for tests (SettingsNotifier doesn't use them).
  @override
  Future<void> delete(dynamic key) async {}
  @override
  Future<int> clear() async {
    final n = _data.length;
    _data.clear();
    return n;
  }
  @override
  bool get isEmpty => _data.isEmpty;
  @override
  int get length => _data.length;
  @override
  bool get isNotEmpty => _data.isNotEmpty;
  @override
  bool get isOpen => true;
  @override
  Future<void> close() async {}
  @override
  Iterable<dynamic> get values => _data.values;
  @override
  Iterable<dynamic> get keys => _data.keys;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

const _testSettings = AppSettings(
  themeMode: ThemeMode.dark,
  localeCode: 'en',
  enableCompression: true,
  enableEncryption: true,
  compressionLevel: 6,
  heartbeatSeconds: 30,
  autoReconnect: true,
  maxReconnectAttempts: 5,
  consoleFontSize: 13.0,
  consoleMaxLines: 1000,
  reduceMotion: false,
  highContrast: false,
  hapticFeedback: true,
  biometricLock: false,
  telemetryEnabled: false,
  onboardingComplete: false,
  connectionTimeoutSeconds: 30,
  stunServers: ['stun:stun.l.google.com:19302'],
  turnServers: [],
  ipWhitelistEnabled: false,
);

/// Extends the real SettingsNotifier but pre-loads test state instead of Hive.
class _FakeSettingsNotifier extends SettingsNotifier {
  _FakeSettingsNotifier()
      : super(_FakeHiveBox()) {
    // Override state so _load() doesn't return empty defaults.
    // ignore: invalid_use_of_protected_member
    state = _testSettings;
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {}
  @override
  Future<void> setLocale(String code) async {}
  @override
  Future<void> setCompression(bool enabled) async {}
  @override
  Future<void> setEncryption(bool enabled) async {}
  @override
  Future<void> setCompressionLevel(int level) async {}
  @override
  Future<void> setHeartbeat(int seconds) async {}
  @override
  Future<void> setAutoReconnect(bool enabled) async {}
  @override
  Future<void> setMaxReconnectAttempts(int attempts) async {}
  @override
  Future<void> setConsoleFontSize(double size) async {}
  @override
  Future<void> setConsoleMaxLines(int lines) async {}
  @override
  Future<void> setReduceMotion(bool enabled) async {}
  @override
  Future<void> setHighContrast(bool enabled) async {}
  @override
  Future<void> setHapticFeedback(bool enabled) async {}
  @override
  Future<void> setBiometricLock(bool enabled) async {}
  @override
  Future<void> setTelemetry(bool enabled) async {}
  @override
  Future<void> completeOnboarding() async {}
  @override
  Future<void> setConnectionTimeout(int seconds) async {}
  @override
  Future<void> setStunServers(List<String> servers) async {}
  @override
  Future<void> setTurnServers(List<String> servers) async {}
  @override
  Future<void> setIpWhitelist(bool enabled) async {}
  @override
  Future<void> setDarkMode(bool dark) async {}
  @override
  Future<void> resetToDefaults() async {}
}

void main() {
  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        settingsProvider.overrideWith((ref) => _FakeSettingsNotifier()),
      ],
      child: MaterialApp(
        theme: HermesTheme.lightTheme,
        darkTheme: HermesTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const SettingsScreen(),
      ),
    );
  }

  group('SettingsScreen — Widget Tests', () {
    testWidgets('renders all setting sections', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Network'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('dark mode toggle is present', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('can scroll through settings', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Danger Zone'), findsOneWidget);
    });

    testWidgets('app version info is displayed', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1000));
      await tester.pumpAndSettle();

      expect(find.text('Version'), findsWidgets);
    });
  });
}
