import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:collection';

/// Lightweight performance monitoring service
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  // Metrics collection
  final _metrics = <String, List<Metric>>{};
  final _maxMetricsPerKey = 60; // Keep last 60 data points

  // Subscribers
  final _subscribers = <void Function(String, Metric)>[];

  // Throttling
  Timer? _collectionTimer;
  final _pendingUpdates = <String, Metric>{};
  bool _isCollecting = false;

  void start() {
    _collectionTimer?.cancel();
    _collectionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _flushPendingUpdates();
    });
  }

  void stop() {
    _collectionTimer?.cancel();
    _collectionTimer = null;
  }

  void record(String key, double value) {
    _pendingUpdates[key] = Metric(
      timestamp: DateTime.now(),
      value: value,
    );
  }

  void _flushPendingUpdates() {
    if (_isCollecting || _pendingUpdates.isEmpty) return;

    _isCollecting = true;

    for (final entry in _pendingUpdates.entries) {
      final key = entry.key;
      final metric = entry.value;

      _metrics.putIfAbsent(key, () => []);
      _metrics[key]!.add(metric);

      // Trim old data
      if (_metrics[key]!.length > _maxMetricsPerKey) {
        _metrics[key]!.removeAt(0);
      }

      // Notify subscribers
      for (final callback in _subscribers) {
        callback(key, metric);
      }
    }

    _pendingUpdates.clear();
    _isCollecting = false;
  }

  void subscribe(void Function(String, Metric) callback) {
    _subscribers.add(callback);
  }

  void unsubscribe(void Function(String, Metric) callback) {
    _subscribers.remove(callback);
  }

  List<Metric> getMetrics(String key) {
    return List.unmodifiable(_metrics[key] ?? []);
  }

  Metric? getLatestMetric(String key) {
    final list = _metrics[key];
    return list != null && list.isNotEmpty ? list.last : null;
  }

  void clear() {
    _metrics.clear();
    _pendingUpdates.clear();
  }
}

class Metric {
  final DateTime timestamp;
  final double value;

  Metric({required this.timestamp, required this.value});
}

/// Memory-efficient metrics calculator
class MetricsCalculator {
  static double average(List<Metric> metrics) {
    if (metrics.isEmpty) return 0;
    return metrics.fold(0.0, (sum, m) => sum + m.value) / metrics.length;
  }

  static double min(List<Metric> metrics) {
    if (metrics.isEmpty) return 0;
    return metrics.map((m) => m.value).reduce((a, b) => a < b ? a : b);
  }

  static double max(List<Metric> metrics) {
    if (metrics.isEmpty) return 0;
    return metrics.map((m) => m.value).reduce((a, b) => a > b ? a : b);
  }

  static double percentile(List<Metric> metrics, double p) {
    if (metrics.isEmpty) return 0;
    final sorted = metrics.map((m) => m.value).toList()..sort();
    final index = ((sorted.length - 1) * p).round();
    return sorted[index];
  }
}

/// Debounced task scheduler for high-frequency operations
class TaskScheduler {
  final Queue<_ScheduledTask> _tasks = Queue();
  Timer? _timer;
  bool _isProcessing = false;

  void schedule(Duration delay, VoidCallback task) {
    _tasks.add(_ScheduledTask(
      executeAt: DateTime.now().add(delay),
      task: task,
    ));
    _scheduleTimer();
  }

  void _scheduleTimer() {
    if (_timer != null || _tasks.isEmpty) return;

    final next = _tasks.first;
    final delay = next.executeAt.difference(DateTime.now());
    if (delay.isNegative) {
      _processTasks();
    } else {
      _timer = Timer(delay, _processTasks);
    }
  }

  void _processTasks() {
    if (_isProcessing) return;
    _isProcessing = true;

    final now = DateTime.now();
    while (_tasks.isNotEmpty && !_tasks.first.executeAt.isAfter(now)) {
      final task = _tasks.removeFirst();
      task.task();
    }

    _isProcessing = false;
    _timer = null;
    _scheduleTimer();
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _tasks.clear();
  }
}

class _ScheduledTask {
  final DateTime executeAt;
  final VoidCallback task;

  _ScheduledTask({required this.executeAt, required this.task});
}

/// Object pool for reducing garbage collection
class ObjectPool<T> {
  final T Function() factory;
  final void Function(T)? reset;
  final int maxSize;
  final Queue<T> _pool = Queue();

  ObjectPool({
    required this.factory,
    this.reset,
    this.maxSize = 100,
  });

  T acquire() {
    if (_pool.isEmpty) {
      return factory();
    }
    return _pool.removeFirst();
  }

  void release(T item) {
    reset?.call(item);
    if (_pool.length < maxSize) {
      _pool.add(item);
    }
  }

  void clear() {
    _pool.clear();
  }
}

/// Ring buffer for streaming data
class RingBuffer<T> {
  final int capacity;
  final List<T?> _buffer;
  int _head = 0;
  int _size = 0;

  RingBuffer(this.capacity) : _buffer = List<T?>.filled(capacity, null);

  void add(T item) {
    _buffer[_head] = item;
    _head = (_head + 1) % capacity;
    if (_size < capacity) _size++;
  }

  List<T> toList() {
    final result = <T>[];
    if (_size == 0) return result;

    final start = _size < capacity ? 0 : _head;
    for (var i = 0; i < _size; i++) {
      final index = (start + i) % capacity;
      final item = _buffer[index];
      if (item != null) result.add(item);
    }
    return result;
  }

  T? get last => _size > 0 ? _buffer[(_head - 1 + capacity) % capacity] : null;

  void clear() {
    _buffer.fillRange(0, capacity, null);
    _head = 0;
    _size = 0;
  }

  int get length => _size;
}

/// Batched updates for high-frequency UI updates
class BatchedUpdater<T> {
  final Duration window;
  final void Function(T) onUpdate;
  Timer? _timer;
  T? _pending;

  BatchedUpdater({
    this.window = const Duration(milliseconds: 16),
    required this.onUpdate,
  });

  void update(T data) {
    _pending = data;
    _timer ??= Timer(window, _flush);
  }

  void _flush() {
    if (_pending != null) {
      onUpdate(_pending as T);
      _pending = null;
    }
    _timer = null;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Lazy initialization helper
class LazyInit<T> {
  T? _value;
  final T Function() factory;
  bool _initialized = false;

  LazyInit(this.factory);

  T get value {
    if (!_initialized) {
      _value = factory();
      _initialized = true;
    }
    return _value!;
  }

  bool get isInitialized => _initialized;

  void reset() {
    _value = null;
    _initialized = false;
  }
}

/// Cache with automatic expiration
class ExpiringCache<K, V> {
  final Map<K, _CacheEntry<V>> _cache = {};
  final Duration maxAge;
  Timer? _cleanupTimer;

  ExpiringCache({this.maxAge = const Duration(minutes: 5)}) {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 1), (_) => _cleanup());
  }

  V? get(K key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (DateTime.now().difference(entry.createdAt) > maxAge) {
      _cache.remove(key);
      return null;
    }

    return entry.value;
  }

  void set(K key, V value) {
    _cache[key] = _CacheEntry(value);
  }

  void remove(K key) {
    _cache.remove(key);
  }

  void _cleanup() {
    final now = DateTime.now();
    _cache.removeWhere((_, entry) =>
      now.difference(entry.createdAt) > maxAge
    );
  }

  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
  }
}

class _CacheEntry<V> {
  final V value;
  final DateTime createdAt;

  _CacheEntry(this.value) : createdAt = DateTime.now();
}

/// Lightweight event bus for cross-component communication
class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  final _handlers = <String, List<void Function(dynamic)>>{};

  void subscribe(String event, void Function(dynamic) handler) {
    _handlers.putIfAbsent(event, () => []).add(handler);
  }

  void unsubscribe(String event, void Function(dynamic) handler) {
    _handlers[event]?.remove(handler);
  }

  void publish(String event, [dynamic data]) {
    final handlers = _handlers[event];
    if (handlers != null) {
      for (final handler in handlers) {
        handler(data);
      }
    }
  }

  void clear() {
    _handlers.clear();
  }
}

/// Memory usage tracker
class MemoryTracker {
  static final MemoryTracker _instance = MemoryTracker._internal();
  factory MemoryTracker() => _instance;
  MemoryTracker._internal();

  int _allocations = 0;
  int _deallocations = 0;
  final _sizes = <String, int>{};

  void trackAllocation(String type, int size) {
    _allocations++;
    _sizes[type] = (_sizes[type] ?? 0) + size;
  }

  void trackDeallocation(String type, int size) {
    _deallocations++;
    _sizes[type] = ((_sizes[type] ?? 0) - size).clamp(0, double.infinity).toInt();
  }

  Map<String, dynamic> getStats() {
    return {
      'totalAllocations': _allocations,
      'totalDeallocations': _deallocations,
      'activeAllocations': _allocations - _deallocations,
      'byType': Map.from(_sizes),
    };
  }

  void reset() {
    _allocations = 0;
    _deallocations = 0;
    _sizes.clear();
  }
}
