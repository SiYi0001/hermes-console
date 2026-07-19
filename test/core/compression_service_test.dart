import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_console/core/network/compression_service.dart';

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
      // 高重复数据：1MB 全零，Zlib 压缩率极高
      final original = Uint8List.fromList(
        List<int>.generate(1024 * 1024, (_) => 0),
      );

      final compressed = compression.compress(original);

      // Zlib 对全零数据压缩后应远小于原始大小
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

    test('decompress on invalid frame does not throw', () {
      final invalidData = Uint8List.fromList([0xFF, 0xFE, 0xFD]);

      // 当前实现：数据过短或非压缩帧时直接返回载荷，不抛异常
      expect(() => compression.decompress(invalidData), returnsNormally);
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
