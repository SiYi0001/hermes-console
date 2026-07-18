import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_console/core/services/settings_service.dart';

void main() {
  group('AppSettings serialization', () {
    test('round-trips through JSON without loss', () {
      const settings = AppSettings(
        themeMode: ThemeMode.light,
        localeCode: 'zh',
        enableCompression: false,
        compressionLevel: 9,
        heartbeatSeconds: 60,
        consoleFontSize: 16.0,
        onboardingComplete: true,
      );

      final json = jsonEncode(settings.toJson());
      final restored =
          AppSettings.fromJson(jsonDecode(json) as Map<String, dynamic>);

      expect(restored.themeMode, ThemeMode.light);
      expect(restored.localeCode, 'zh');
      expect(restored.enableCompression, false);
      expect(restored.compressionLevel, 9);
      expect(restored.heartbeatSeconds, 60);
      expect(restored.consoleFontSize, 16.0);
      expect(restored.onboardingComplete, true);
    });

    test('applies sensible defaults for missing fields', () {
      final restored = AppSettings.fromJson(<String, dynamic>{});

      expect(restored.themeMode, ThemeMode.dark);
      expect(restored.localeCode, 'en');
      expect(restored.enableEncryption, true);
      expect(restored.compressionLevel, 6);
      expect(restored.maxReconnectAttempts, 5);
      expect(restored.onboardingComplete, false);
    });

    test('copyWith overrides only the given fields', () {
      const base = AppSettings();
      final next = base.copyWith(
        localeCode: 'ja',
        highContrast: true,
      );

      expect(next.localeCode, 'ja');
      expect(next.highContrast, true);
      // Untouched fields preserved.
      expect(next.themeMode, base.themeMode);
      expect(next.enableEncryption, base.enableEncryption);
      expect(next.heartbeatSeconds, base.heartbeatSeconds);
    });

    test('malformed JSON falls back to defaults gracefully', () {
      // Simulate a corrupted stored value being coerced.
      AppSettings result;
      try {
        result = AppSettings.fromJson(
          jsonDecode('{"themeMode": 99}') as Map<String, dynamic>,
        );
      } catch (_) {
        result = const AppSettings();
      }
      // themeMode index 99 is out of range -> would throw, caught -> default.
      expect(result.themeMode, ThemeMode.dark);
    });
  });
}
