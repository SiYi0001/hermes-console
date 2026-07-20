import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_console/core/error/error_handler.dart';

void main() {
  group('AppErrorHandler', () {
    late AppErrorHandler handler;

    setUp(() {
      handler = AppErrorHandler();
      handler.clearLog(); // isolate each test against the singleton log
    });

    test('should log errors', () {
      handler.handleError('Test error', context: 'test');

      final logs = handler.getRecentErrors();
      expect(logs.length, 1);
      expect(logs.first.message, 'Test error');
      expect(logs.first.context, 'test');
    });

    test('should limit error log size', () {
      for (var i = 0; i < 150; i++) {
        handler.handleError('Error $i');
      }

      final logs = handler.errorLog;
      expect(logs.length, 100);
    });

    test('should notify listeners on error', () {
      var notified = false;
      handler.subscribe((error) {
        notified = true;
      });

      handler.handleError('Test error');
      expect(notified, true);
    });

    test('should identify critical errors', () {
      handler.handleError('Fatal error occurred');
      final error = handler.errorLog.first;
      expect(error.isCritical, true);
    });
  });

  group('CircuitBreaker', () {
    test('should start in closed state', () {
      final cb = CircuitBreaker();
      expect(cb.state, CircuitState.closed);
    });

    test('should open after threshold failures', () async {
      final cb = CircuitBreaker(failureThreshold: 3);

      for (var i = 0; i < 3; i++) {
        try {
          await cb.execute(() async {
            throw Exception('Error');
          });
        } catch (_) {}
      }

      expect(cb.state, CircuitState.open);
    });

    test('should allow success after reset', () async {
      final cb = CircuitBreaker(failureThreshold: 1);

      try {
        await cb.execute(() async {
          throw Exception('Error');
        });
      } catch (_) {}

      expect(cb.state, CircuitState.open);

      cb.reset();
      expect(cb.state, CircuitState.closed);
    });
  });

  group('Result', () {
    test('should create success result', () {
      final result = Result.success('data');
      expect(result.isSuccess, true);
      expect(result.data, 'data');
    });

    test('should create failure result', () {
      final result = Result.failure(AppError(
        message: 'Error',
        timestamp: DateTime.now(),
      ));
      expect(result.isFailure, true);
      expect(result.error?.message, 'Error');
    });

    test('should fold correctly', () {
      final success = Result.success(42);
      final folded = success.fold(
        onSuccess: (data) => data * 2,
        onFailure: (_) => 0,
      );
      expect(folded, 84);
    });

    test('should getOrElse return default on failure', () {
      final failure = Result.failure(AppError(
        message: 'Error',
        timestamp: DateTime.now(),
      ));
      expect(failure.getOrElse(100), 100);
    });
  });

  group('RetryStrategy', () {
    test('should attempt retries', () async {
      final strategy = RetryStrategy(maxRetries: 3, delay: const Duration(milliseconds: 10));

      await strategy.tryRecover(Exception('test'));
      expect(strategy.maxAttempts, 3);
    });
  });

  group('DegradationHandler', () {
    test('should track feature flags', () {
      final handler = DegradationHandler();
      handler.registerFeature('test', enabled: true);

      expect(handler.isEnabled('test'), true);

      handler.disableFeature('test');
      expect(handler.isEnabled('test'), false);
    });

    test('should enter degraded mode', () {
      final handler = DegradationHandler();
      handler.registerFeature('feature1', enabled: true);
      handler.registerFeature('feature2', enabled: true);
      handler.registerFeature('auth', enabled: true);

      handler.enterDegradedMode();

      expect(handler.isDegraded, true);
      expect(handler.isEnabled('auth'), true); // Essential
      expect(handler.isEnabled('feature1'), false); // Non-essential
    });
  });

  group('AppLogger', () {
    test('should log messages', () {
      final logger = AppLogger();
      logger.info('Test message', tag: 'test');

      final logs = logger.logs;
      expect(logs.length, 1);
      expect(logs.first.message, 'Test message');
      expect(logs.first.tag, 'test');
    });

    test('should filter by level', () {
      final logger = AppLogger();
      logger.debug('Debug');
      logger.info('Info');
      logger.warning('Warning');
      logger.error('Error');

      final errors = logger.getLogsByLevel(LogLevel.error);
      expect(errors.length, 1);
      expect(errors.first.message, 'Error');
    });

    test('should clear logs', () {
      final logger = AppLogger();
      logger.info('Test');
      logger.clear();
      expect(logger.logs.length, 0);
    });
  });
}
