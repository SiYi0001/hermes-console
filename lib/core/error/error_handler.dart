import 'dart:async';
import 'package:flutter/foundation.dart';

/// Global error handler for the application
class AppErrorHandler {
  static final AppErrorHandler _instance = AppErrorHandler._internal();
  factory AppErrorHandler() => _instance;
  AppErrorHandler._internal();

  // Error listeners
  final _listeners = <void Function(AppError)>[];

  // Error log
  final List<AppError> _errorLog = [];
  static const int _maxLogSize = 100;

  // Error callbacks
  void Function(AppError)? onError;
  void Function(AppError)? onCriticalError;
  void Function(String)? onWarning;

  /// Handle error
  void handleError(dynamic error, {StackTrace? stackTrace, String? context}) {
    final appError = AppError(
      message: error.toString(),
      stackTrace: stackTrace,
      context: context,
      timestamp: DateTime.now(),
    );

    // Log error
    _logError(appError);

    // Notify listeners
    onError?.call(appError);
    for (final listener in _listeners) {
      listener(appError);
    }

    // Handle critical errors
    if (appError.isCritical) {
      onCriticalError?.call(appError);
    }
  }

  /// Handle warning
  void handleWarning(String message, {String? context}) {
    onWarning?.call(message);
    debugPrint('⚠️ Warning${context != null ? ' [$context]' : ''}: $message');
  }

  /// Log error
  void _logError(AppError error) {
    _errorLog.add(error);
    if (_errorLog.length > _maxLogSize) {
      _errorLog.removeAt(0);
    }
  }

  /// Get error log
  List<AppError> get errorLog => List.unmodifiable(_errorLog);

  /// Get recent errors
  List<AppError> getRecentErrors({int limit = 10}) {
    return _errorLog.reversed.take(limit).toList();
  }

  /// Clear error log
  void clearLog() {
    _errorLog.clear();
  }

  /// Subscribe to errors
  void subscribe(void Function(AppError) callback) {
    _listeners.add(callback);
  }

  /// Unsubscribe from errors
  void unsubscribe(void Function(AppError) callback) {
    _listeners.remove(callback);
  }
}

/// Application error model
class AppError {
  final String message;
  final StackTrace? stackTrace;
  final String? context;
  final DateTime timestamp;
  final ErrorSeverity severity;

  AppError({
    required this.message,
    this.stackTrace,
    this.context,
    required this.timestamp,
    ErrorSeverity? severity,
  }) : severity = severity ?? _determineSeverity(message);

  static ErrorSeverity _determineSeverity(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('fatal') || 
        lower.contains('crash') || 
        lower.contains('exception')) {
      return ErrorSeverity.critical;
    } else if (lower.contains('error')) {
      return ErrorSeverity.error;
    } else if (lower.contains('warn')) {
      return ErrorSeverity.warning;
    }
    return ErrorSeverity.info;
  }

  bool get isCritical => severity == ErrorSeverity.critical;
  bool get isError => severity == ErrorSeverity.error || isCritical;
  bool get isWarning => severity == ErrorSeverity.warning;

  String get formatted {
    final buffer = StringBuffer();
    buffer.writeln('[$timestamp] ${severity.name.toUpperCase()}');
    if (context != null) {
      buffer.writeln('Context: $context');
    }
    buffer.writeln('Message: $message');
    if (stackTrace != null) {
      buffer.writeln('StackTrace: $stackTrace');
    }
    return buffer.toString();
  }
}

enum ErrorSeverity { info, warning, error, critical }

/// Result type for operations that can fail
class Result<T> {
  final T? data;
  final AppError? error;
  final bool isSuccess;
  bool get isFailure => !isSuccess;

  Result._({this.data, this.error, required this.isSuccess});

  factory Result.success(T data) {
    return Result._(data: data, isSuccess: true);
  }

  factory Result.failure(AppError error) {
    return Result._(error: error, isSuccess: false);
  }

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppError error) onFailure,
  }) {
    if (isSuccess) {
      return onSuccess(data as T);
    } else {
      return onFailure(error as AppError);
    }
  }

  T? getOrNull() => data;
  
  T getOrElse(T defaultValue) => data ?? defaultValue;

  @override
  String toString() {
    return isSuccess ? 'Success($data)' : 'Failure($error)';
  }
}

/// Recovery strategy for automatic error recovery
abstract class RecoveryStrategy {
  Future<bool> tryRecover(dynamic error);
  bool get canRecover;
  int get maxAttempts;
}

/// Retry recovery strategy
class RetryStrategy implements RecoveryStrategy {
  final int maxRetries;
  final Duration delay;
  final bool exponentialBackoff;

  RetryStrategy({
    this.maxRetries = 3,
    this.delay = const Duration(seconds: 1),
    this.exponentialBackoff = true,
  });

  @override
  bool get canRecover => true;

  @override
  int get maxAttempts => maxRetries;

  @override
  Future<bool> tryRecover(dynamic error) async {
    for (var i = 0; i < maxRetries; i++) {
      await Future.delayed(_calculateDelay(i));
      // Attempt recovery here
      // In real implementation, would retry the operation
    }
    return false;
  }

  Duration _calculateDelay(int attempt) {
    if (!exponentialBackoff) return delay;
    final multiplier = (1 << attempt).clamp(1, 32);
    return Duration(milliseconds: delay.inMilliseconds * multiplier);
  }
}

/// Circuit breaker pattern
class CircuitBreaker {
  static const int _defaultThreshold = 5;
  static const Duration _defaultTimeout = Duration(seconds: 30);

  final int failureThreshold;
  final Duration timeout;

  CircuitState _state = CircuitState.closed;
  int _failureCount = 0;
  DateTime? _lastFailure;

  CircuitBreaker({
    this.failureThreshold = _defaultThreshold,
    this.timeout = _defaultTimeout,
  });

  CircuitState get state => _state;

  Future<T> execute<T>(Future<T> Function() operation) async {
    if (_state == CircuitState.open) {
      if (_shouldAttemptReset()) {
        _state = CircuitState.halfOpen;
      } else {
        throw CircuitBreakerOpenException();
      }
    }

    try {
      final result = await operation();
      _onSuccess();
      return result;
    } catch (e) {
      _onFailure();
      rethrow;
    }
  }

  void _onSuccess() {
    _failureCount = 0;
    _state = CircuitState.closed;
  }

  void _onFailure() {
    _failureCount++;
    _lastFailure = DateTime.now();

    if (_failureCount >= failureThreshold) {
      _state = CircuitState.open;
    }
  }

  bool _shouldAttemptReset() {
    if (_lastFailure == null) return true;
    return DateTime.now().difference(_lastFailure!) >= timeout;
  }

  void reset() {
    _state = CircuitState.closed;
    _failureCount = 0;
    _lastFailure = null;
  }
}

enum CircuitState { closed, open, halfOpen }

class CircuitBreakerOpenException implements Exception {
  final String message = 'Circuit breaker is open';
  @override
  String toString() => message;
}

/// Graceful degradation handler
class DegradationHandler {
  final Map<String, FeatureFlag> _features = {};
  bool _degraded = false;

  void registerFeature(String name, {bool enabled = true}) {
    _features[name] = FeatureFlag(name: name, enabled: enabled);
  }

  void disableFeature(String name) {
    _features[name]?.enabled = false;
  }

  void enableFeature(String name) {
    _features[name]?.enabled = true;
  }

  bool isEnabled(String name) => _features[name]?.enabled ?? true;

  void enterDegradedMode() {
    _degraded = true;
    // Disable non-essential features
    for (final entry in _features.entries) {
      if (!_isEssential(entry.key)) {
        entry.value.enabled = false;
      }
    }
  }

  void exitDegradedMode() {
    _degraded = false;
    for (final entry in _features.entries) {
      entry.value.enabled = true;
    }
  }

  bool get isDegraded => _degraded;

  bool _isEssential(String feature) {
    const essential = ['auth', 'connection', 'security'];
    return essential.contains(feature.toLowerCase());
  }

  T executeWithFallback<T>({
    required String feature,
    required T Function() operation,
    required T Function() fallback,
  }) {
    if (isEnabled(feature)) {
      try {
        return operation();
      } catch (e) {
        if (_degraded) rethrow;
        AppErrorHandler().handleError(e, context: feature);
        return fallback();
      }
    }
    return fallback();
  }
}

class FeatureFlag {
  final String name;
  bool enabled;

  FeatureFlag({required this.name, required this.enabled});
}

/// Crash reporter interface
abstract class CrashReporter {
  Future<void> report(AppError error);
  Future<void> reportBreadcrumb(String message);
}

/// Logging utility
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  final List<LogEntry> _logs = [];
  static const int _maxLogs = 500;

  LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  set minLevel(LogLevel level) => _minLevel = level;

  void debug(String message, {String? tag}) => _log(LogLevel.debug, message, tag);
  void info(String message, {String? tag}) => _log(LogLevel.info, message, tag);
  void warning(String message, {String? tag}) => _log(LogLevel.warning, message, tag);
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag, error: error, stackTrace: stackTrace);
  }

  void _log(
    LogLevel level,
    String message,
    String? tag, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < _minLevel.index) return;

    final entry = LogEntry(
      level: level,
      message: message,
      tag: tag,
      timestamp: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );

    _logs.add(entry);
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }

    // Print to console in debug mode
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      final colorCode = _getColorCode(level);
      debugPrint('$colorCode${level.name.toUpperCase()}$prefix $message');
    }
  }

  String _getColorCode(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔵 ';
      case LogLevel.info:
        return 'ℹ️ ';
      case LogLevel.warning:
        return '⚠️ ';
      case LogLevel.error:
        return '🔴 ';
    }
  }

  List<LogEntry> get logs => List.unmodifiable(_logs);

  List<LogEntry> getLogsByLevel(LogLevel level) {
    return _logs.where((l) => l.level == level).toList();
  }

  void clear() {
    _logs.clear();
  }
}

enum LogLevel { debug, info, warning, error }

class LogEntry {
  final LogLevel level;
  final String message;
  final String? tag;
  final DateTime timestamp;
  final Object? error;
  final StackTrace? stackTrace;

  LogEntry({
    required this.level,
    required this.message,
    this.tag,
    required this.timestamp,
    this.error,
    this.stackTrace,
  });
}
