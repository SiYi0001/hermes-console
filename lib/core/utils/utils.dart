import 'dart:math';

/// UUID generator using random bytes
class UuidGenerator {
  static final Random _random = Random.secure();
  
  /// Generate a UUID v4
  static String generate() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    
    // Set version (4) and variant (RFC 4122)
    bytes[6] = (bytes[6] & 0x0F) | 0x40;
    bytes[8] = (bytes[8] & 0x3F) | 0x80;
    
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
           '${hex.substring(12, 16)}-${hex.substring(16, 20)}'
           '-${hex.substring(20, 32)}';
  }
  
  /// Generate a short ID (8 characters)
  static String shortId() {
    final bytes = List<int>.generate(4, (_) => _random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

/// Network utilities
class NetworkUtils {
  /// Check if string is a valid IP address
  static bool isValidIpAddress(String address) {
    final ipv4Regex = RegExp(
      r'^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$',
    );
    return ipv4Regex.hasMatch(address);
  }
  
  /// Check if string is a valid hostname
  static bool isValidHostname(String hostname) {
    final hostnameRegex = RegExp(
      r'^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*'
      r'([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$',
    );
    return hostnameRegex.hasMatch(hostname);
  }
  
  /// Check if string is a valid port number
  static bool isValidPort(int port) {
    return port >= 1 && port <= 65535;
  }
  
  /// Format bytes to human readable string
  static String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';
    
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
    final i = (log(bytes) / log(1024)).floor();
    final size = bytes / pow(1024, i);
    
    return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
  }
  
  /// Format duration to human readable string
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h';
    }
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    }
    return '${duration.inSeconds}s';
  }
}

/// String utilities
extension StringExtensions on String {
  /// Truncate string with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }
  
  /// Convert to title case
  String toTitleCase() {
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }
}

/// DateTime utilities
extension DateTimeExtensions on DateTime {
  /// Format as HH:mm:ss
  String get timeString {
    return '${hour.toString().padLeft(2, '0')}:'
           '${minute.toString().padLeft(2, '0')}:'
           '${second.toString().padLeft(2, '0')}';
  }
  
  /// Format as YYYY-MM-DD
  String get dateString {
    return '${year.toString().padLeft(4, '0')}-'
           '${month.toString().padLeft(2, '0')}-'
           '${day.toString().padLeft(2, '0')}';
  }
  
  /// Format as relative time (e.g., "2 minutes ago")
  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(this);
    
    if (diff.inSeconds < 60) {
      return 'Just now';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return dateString;
  }
}

/// List utilities
extension ListExtensions<T> on List<T> {
  /// Get element at index or null if out of bounds
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}
