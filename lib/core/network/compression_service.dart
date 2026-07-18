import 'dart:typed_data';
import 'package:archive/archive.dart';

/// Compression service using Zstandard (via Archive package)
/// Note: For production, consider using zstd package for true Zstandard compression
class CompressionService {
  static const int _minCompressionSize = 64; // Skip compression for small data
  static const int _compressionLevel = 6;
  
  /// Compress data using Zlib (closest available to Zstd in pure Dart)
  Uint8List compress(Uint8List data) {
    // Skip compression for small data
    if (data.length < _minCompressionSize) {
      return _createCompressedFrame(data, isCompressed: false);
    }
    
    try {
      // Use Zlib deflate
      final compressed = ZLibEncoder().encode(
        data,
        level: _compressionLevel,
      );
      
      if (compressed != null && compressed.length < data.length) {
        return _createCompressedFrame(Uint8List.fromList(compressed), isCompressed: true);
      }
      
      // Compression didn't help, send uncompressed
      return _createCompressedFrame(data, isCompressed: false);
    } catch (e) {
      // Compression failed, send uncompressed
      return _createCompressedFrame(data, isCompressed: false);
    }
  }

  /// Decompress data
  Uint8List decompress(Uint8List data) {
    if (data.isEmpty) return data;
    
    // Read header
    final isCompressed = data[0] == 0x01;
    final payload = data.sublist(1);
    
    if (!isCompressed) {
      return payload;
    }
    
    try {
      final decompressed = ZLibDecoder().decodeBytes(payload);
      return Uint8List.fromList(decompressed);
    } catch (e) {
      // Decompression failed, return raw data
      return payload;
    }
  }

  /// Create frame with compression header
  Uint8List _createCompressedFrame(Uint8List payload, {required bool isCompressed}) {
    final frame = Uint8List(1 + payload.length);
    frame[0] = isCompressed ? 0x01 : 0x00;
    frame.setRange(1, frame.length, payload);
    return frame;
  }

  /// Get compression ratio
  double getCompressionRatio(int originalSize, int compressedSize) {
    if (originalSize == 0) return 0;
    return (1 - (compressedSize / originalSize)) * 100;
  }
}

/// Adaptive compression based on data type
class AdaptiveCompression {
  final CompressionService _compression = CompressionService();
  
  /// Compress based on data characteristics
  Uint8List compress(Uint8List data, {DataTypeHint? hint}) {
    // Text data compresses well
    if (hint == DataTypeHint.text || _isLikelyText(data)) {
      return _compression.compress(data);
    }
    
    // Binary/protobuf data
    if (hint == DataTypeHint.binary || _isLikelyBinary(data)) {
      return _compression.compress(data);
    }
    
    // Already compressed data (images, etc.)
    if (hint == DataTypeHint.compressed || _isLikelyCompressed(data)) {
      // Don't recompress
      return _compression._createCompressedFrame(data, isCompressed: false);
    }
    
    // Default: try compression
    return _compression.compress(data);
  }

  bool _isLikelyText(List<int> data) {
    if (data.isEmpty) return false;
    
    int textBytes = 0;
    int controlBytes = 0;
    
    for (final byte in data.take(100)) {
      if ((byte >= 0x20 && byte <= 0x7E) || byte == 0x09 || byte == 0x0A || byte == 0x0D) {
        textBytes++;
      } else if (byte < 0x20) {
        controlBytes++;
      }
    }
    
    return textBytes > controlBytes && textBytes > data.take(100).length * 0.7;
  }

  bool _isLikelyBinary(List<int> data) {
    // Check for null bytes or high entropy
    int nullCount = 0;
    for (final byte in data.take(100)) {
      if (byte == 0x00) nullCount++;
    }
    
    return nullCount > 10;
  }

  bool _isLikelyCompressed(List<int> data) {
    // Check for common compression signatures
    if (data.length < 4) return false;
    
    // PNG signature
    if (data[0] == 0x89 && data[1] == 0x50 && data[2] == 0x4E && data[3] == 0x47) {
      return true;
    }
    
    // Gzip signature
    if (data[0] == 0x1F && data[1] == 0x8B) {
      return true;
    }
    
    // Zip signature
    if (data[0] == 0x50 && data[1] == 0x4B) {
      return true;
    }
    
    // JPEG signature
    if (data[0] == 0xFF && data[1] == 0xD8) {
      return true;
    }
    
    return false;
  }
}

enum DataTypeHint {
  text,
  binary,
  compressed,
}
