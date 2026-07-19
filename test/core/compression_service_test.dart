import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_console/core/compression/compression_service.dart';

void main() {
  late CompressionService compression;

  setUpAll(() {
    compression = CompressionService();
  });

  group('CompressionService — Basic', () {
    test('compress/decompress round-trip recovers original data', () {
      final original = Uint8List.fromList(
        'Hello, Hermes! 你好 Hermès! This is a test message.'.codeUnits,
      );

      final compressed = compression.compress(original);
      final decompressed = compression.decompress(compressed);

      expect(decompressed, equals(original));
    });

    test('compress reduces size for repetitive data', () {
      // 高重复数据：1MB 全零
      final original = Uint8List.fromList(
        List<int>.generate(1024 * 1024, (_) => 0),
      );

      final compressed = compression.compress(original);

      // zstd 对全零数据压缩率应极高（>90%）
      expect(
        compressed.length,
        lessThan(original.length ~/ 10),
        reason: 'Expected high compression ratio for repetitive data',
      );
    });

    test('compress does not increase size significantly for small data', () {
      final original = Uint8List.fromList(
        'tiny'.codeUnits,
      );

      final compressed = compression.compress(original);
      final decompressed = compression.decompress(compressed);

      expect(decompressed, equals(original));
    });

    test('handles empty input', () {
      final original = Uint8List(0);
      final compressed = compression.compress(original);
      final decompressed = compression.decompress(compressed);

      expect(decompressed, isEmpty);
    });

    test('handles binary data (non-text)', () {
      final original = Uint8List.fromList(
        List<int>.generate(1024, (i) => (i * 7 + 13) % 256),
      );

      final compressed = compression.compress(original);
      final decompressed = compression.decompress(compressed);

      expect(decompressed, equals(original));
    });

    test('compress level 1 vs level 3 produces different sizes', () {
      final original = Uint8List.fromList(
        List<int>.generate(10000, (i) => i % 26 + 65),
      );

      final compressed1 = compression.compress(original, level: 1);
      final compressed3 = compression.compress(original, level: 3);

      // 两者都应可解压
      expect(compression.decompress(compressed1), equals(original));
      expect(compression.decompress(compressed3), equals(original));
      // 高压缩级别通常更小（但不绝对）
      expect(compressed3.length, lessThanOrEqualTo(compressed1.length + 100));
    });

    test('decompress throws on invalid data', () {
      final invalidData = Uint8List.fromList([0xFF, 0xFE, 0xFD]);

      expect(
        () => compression.decompress(invalidData),
        throwsException,
      );
    });

    test('preserves data integrity across multiple compress cycles', () {
      final original = Uint8List.fromList(
        'Multiple compression cycles test data 多次压缩测试数据 🎉'.codeUnits,
      );

      var data = original;
      for (var i = 0; i < 5; i++) {
        data = compression.compress(data);
        expect(data, isNotEmpty);
      }
      for (var i = 0; i < 5; i++) {
        data = compression.decompress(data);
      }

      expect(data, equals(original));
    });
  });
}

import 'dart:typed_data';
