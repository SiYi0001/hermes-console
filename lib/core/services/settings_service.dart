import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// Real, persistent application settings backed by Hive.
///
/// This replaces the previous mock-only settings screen state with an actual
/// data flow: [SettingsNotifier] reads from and writes to a Hive box, and UI
/// widgets consume [settingsProvider] via Riverpod.
///
/// Design goals:
/// - Single source of truth for all persisted preferences.
/// - Cheap immutable state object with copyWith for selective rebuilds.
/// - Debounced disk writes are unnecessary here because Hive writes are fast,
///   but every mutation persists synchronously to survive crashes.
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.localeCode = 'en',
    this.enableCompression = true,
    this.enableEncryption = true,
    this.compressionLevel = 6,
    this.heartbeatSeconds = 30,
    this.autoReconnect = true,
    this.maxReconnectAttempts = 5,
    this.consoleFontSize = 13.0,
    this.consoleMaxLines = 1000,
    this.reduceMotion = false,
    this.highContrast = false,
    this.hapticFeedback = true,
    this.biometricLock = false,
    this.telemetryEnabled = false,
    this.onboardingComplete = false,
  });

  final ThemeMode themeMode;
  final String localeCode;
  final bool enableCompression;
  final bool enableEncryption;
  final int compressionLevel;
  final int heartbeatSeconds;
  final bool autoReconnect;
  final int maxReconnectAttempts;
  final double consoleFontSize;
  final int consoleMaxLines;
  final bool reduceMotion;
  final bool highContrast;
  final bool hapticFeedback;
  final bool biometricLock;
  final bool telemetryEnabled;
  final bool onboardingComplete;

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? localeCode,
    bool? enableCompression,
    bool? enableEncryption,
    int? compressionLevel,
    int? heartbeatSeconds,
    bool? autoReconnect,
    int? maxReconnectAttempts,
    double? consoleFontSize,
    int? consoleMaxLines,
    bool? reduceMotion,
    bool? highContrast,
    bool? hapticFeedback,
    bool? biometricLock,
    bool? telemetryEnabled,
    bool? onboardingComplete,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      localeCode: localeCode ?? this.localeCode,
      enableCompression: enableCompression ?? this.enableCompression,
      enableEncryption: enableEncryption ?? this.enableEncryption,
      compressionLevel: compressionLevel ?? this.compressionLevel,
      heartbeatSeconds: heartbeatSeconds ?? this.heartbeatSeconds,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      maxReconnectAttempts: maxReconnectAttempts ?? this.maxReconnectAttempts,
      consoleFontSize: consoleFontSize ?? this.consoleFontSize,
      consoleMaxLines: consoleMaxLines ?? this.consoleMaxLines,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      highContrast: highContrast ?? this.highContrast,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      biometricLock: biometricLock ?? this.biometricLock,
      telemetryEnabled: telemetryEnabled ?? this.telemetryEnabled,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.index,
        'localeCode': localeCode,
        'enableCompression': enableCompression,
        'enableEncryption': enableEncryption,
        'compressionLevel': compressionLevel,
        'heartbeatSeconds': heartbeatSeconds,
        'autoReconnect': autoReconnect,
        'maxReconnectAttempts': maxReconnectAttempts,
        'consoleFontSize': consoleFontSize,
        'consoleMaxLines': consoleMaxLines,
        'reduceMotion': reduceMotion,
        'highContrast': highContrast,
        'hapticFeedback': hapticFeedback,
        'biometricLock': biometricLock,
        'telemetryEnabled': telemetryEnabled,
        'onboardingComplete': onboardingComplete,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemeMode.values[(json['themeMode'] as int?) ?? 2],
      localeCode: json['localeCode'] as String? ?? 'en',
      enableCompression: json['enableCompression'] as bool? ?? true,
      enableEncryption: json['enableEncryption'] as bool? ?? true,
      compressionLevel: json['compressionLevel'] as int? ?? 6,
      heartbeatSeconds: json['heartbeatSeconds'] as int? ?? 30,
      autoReconnect: json['autoReconnect'] as bool? ?? true,
      maxReconnectAttempts: json['maxReconnectAttempts'] as int? ?? 5,
      consoleFontSize: (json['consoleFontSize'] as num?)?.toDouble() ?? 13.0,
      consoleMaxLines: json['consoleMaxLines'] as int? ?? 1000,
      reduceMotion: json['reduceMotion'] as bool? ?? false,
      highContrast: json['highContrast'] as bool? ?? false,
      hapticFeedback: json['hapticFeedback'] as bool? ?? true,
      biometricLock: json['biometricLock'] as bool? ?? false,
      telemetryEnabled: json['telemetryEnabled'] as bool? ?? false,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
    );
  }
}

/// Notifier that persists [AppSettings] to a Hive box on every mutation.
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._box) : super(_load(_box));

  final Box _box;
  static const String _key = 'app_settings';

  static AppSettings _load(Box box) {
    final raw = box.get(_key);
    if (raw is String && raw.isNotEmpty) {
      try {
        return AppSettings.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {
        return const AppSettings();
      }
    }
    return const AppSettings();
  }

  Future<void> _persist(AppSettings next) async {
    state = next;
    await _box.put(_key, jsonEncode(next.toJson()));
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _persist(state.copyWith(themeMode: mode));

  Future<void> setLocale(String code) =>
      _persist(state.copyWith(localeCode: code));

  Future<void> setCompression(bool enabled) =>
      _persist(state.copyWith(enableCompression: enabled));

  Future<void> setEncryption(bool enabled) =>
      _persist(state.copyWith(enableEncryption: enabled));

  Future<void> setCompressionLevel(int level) =>
      _persist(state.copyWith(compressionLevel: level.clamp(0, 9)));

  Future<void> setHeartbeat(int seconds) =>
      _persist(state.copyWith(heartbeatSeconds: seconds.clamp(5, 300)));

  Future<void> setAutoReconnect(bool enabled) =>
      _persist(state.copyWith(autoReconnect: enabled));

  Future<void> setMaxReconnectAttempts(int attempts) =>
      _persist(state.copyWith(maxReconnectAttempts: attempts.clamp(0, 20)));

  Future<void> setConsoleFontSize(double size) =>
      _persist(state.copyWith(consoleFontSize: size.clamp(8.0, 28.0)));

  Future<void> setConsoleMaxLines(int lines) =>
      _persist(state.copyWith(consoleMaxLines: lines.clamp(100, 10000)));

  Future<void> setReduceMotion(bool enabled) =>
      _persist(state.copyWith(reduceMotion: enabled));

  Future<void> setHighContrast(bool enabled) =>
      _persist(state.copyWith(highContrast: enabled));

  Future<void> setHapticFeedback(bool enabled) =>
      _persist(state.copyWith(hapticFeedback: enabled));

  Future<void> setBiometricLock(bool enabled) =>
      _persist(state.copyWith(biometricLock: enabled));

  Future<void> setTelemetry(bool enabled) =>
      _persist(state.copyWith(telemetryEnabled: enabled));

  Future<void> completeOnboarding() =>
      _persist(state.copyWith(onboardingComplete: true));

  Future<void> resetToDefaults() => _persist(const AppSettings());
}

/// Injected at app bootstrap with the opened Hive box.
///
/// Override in main.dart:
/// ```dart
/// ProviderScope(
///   overrides: [
///     settingsBoxProvider.overrideWithValue(box),
///   ],
///   child: const HermesApp(),
/// )
/// ```
final settingsBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError('settingsBoxProvider must be overridden at startup');
});

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return SettingsNotifier(box);
});

/// Convenience selectors to minimize rebuilds — widgets watch only the slice
/// they render instead of the whole settings object.
final themeModeProvider = Provider<ThemeMode>(
  (ref) => ref.watch(settingsProvider.select((s) => s.themeMode)),
);

final localeCodeProvider = Provider<String>(
  (ref) => ref.watch(settingsProvider.select((s) => s.localeCode)),
);

final onboardingCompleteProvider = Provider<bool>(
  (ref) => ref.watch(settingsProvider.select((s) => s.onboardingComplete)),
);
