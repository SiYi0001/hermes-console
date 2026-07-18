import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../shared/theme/hermes_theme.dart';

/// Base class for optimized stateful widgets
abstract class OptimizedStatefulWidget extends StatefulWidget {
  const OptimizedStatefulWidget({super.key});
}

/// Mixin for widgets that should maintain their state
mixin OptimizedKeepAlive<T extends StatefulWidget> on State<T>, AutomaticKeepAliveClientMixin<T> {
  @override
  bool get wantKeepAlive => true;
}

/// Memoized widget builder for expensive computations
class MemoizedBuilder<T> extends StatefulWidget {
  final T value;
  final Widget Function(BuildContext context, T value) builder;
  final bool shouldRebuild(T oldValue, T newValue);

  const MemoizedBuilder({
    super.key,
    required this.value,
    required this.builder,
    this.shouldRebuild = _defaultShouldRebuild,
  });

  static bool _defaultShouldRebuild<T>(T oldValue, T newValue) => oldValue != newValue;

  @override
  State<MemoizedBuilder<T>> createState() => _MemoizedBuilderState<T>();
}

class _MemoizedBuilderState<T> extends State<MemoizedBuilder<T>> {
  late Widget _cachedWidget;
  late T _cachedValue;

  @override
  void initState() {
    super.initState();
    _cachedValue = widget.value;
    _cachedWidget = widget.builder(context, widget.value);
  }

  @override
  void didUpdateWidget(MemoizedBuilder<T> oldWidget) {
    if (widget.shouldRebuild(_cachedValue, widget.value)) {
      _cachedValue = widget.value;
      _cachedWidget = widget.builder(context, widget.value);
    }
  }

  @override
  Widget build(BuildContext context) => _cachedWidget;
}

/// RepaintBoundary wrapper for isolating repaints
class IsolatedWidget extends StatelessWidget {
  final Widget child;

  const IsolatedWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: child);
  }
}

/// Cached gradient background
class CachedGradientBackground extends StatelessWidget {
  final Widget child;

  const CachedGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HermesTheme.backgroundBlack,
            Color(0xFF0D0D1A),
          ],
        ),
      ),
      child: child,
    );
  }
}

/// Optimized glass morphism card with const construction
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark.withOpacity(0.8),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Optimized animated status indicator
class AnimatedStatusIndicator extends StatefulWidget {
  final bool isActive;
  final Color activeColor;
  final double size;

  const AnimatedStatusIndicator({
    super.key,
    required this.isActive,
    this.activeColor = HermesTheme.successGreen,
    this.size = 12,
  });

  @override
  State<AnimatedStatusIndicator> createState() => _AnimatedStatusIndicatorState();
}

class _AnimatedStatusIndicatorState extends State<AnimatedStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isActive
                ? widget.activeColor.withOpacity(_animation.value)
                : HermesTheme.textSecondary.withOpacity(0.3),
          ),
        );
      },
    );
  }
}

/// Object pool for reusing widgets
class WidgetPool<T> {
  final Queue<T> _pool = Queue<T>();
  final T Function() factory;
  final void Function(T)? reset;
  final int maxSize;

  WidgetPool({
    required this.factory,
    this.reset,
    this.maxSize = 20,
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
}

/// Lazy list view for large data sets
class LazyListView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context)? separatorBuilder;
  final ScrollController? controller;
  final EdgeInsets? padding;

  const LazyListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.separatorBuilder,
    this.controller,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: controller,
      padding: padding,
      itemCount: items.length,
      separatorBuilder: separatorBuilder ?? (_, __) => const SizedBox(height: 0),
      itemBuilder: (context, index) => itemBuilder(context, items[index], index),
    );
  }
}

/// Cached text style
class CachedTextStyle {
  static const TextStyle headline1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: HermesTheme.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: HermesTheme.textTertiary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: HermesTheme.textSecondary,
  );
}

/// Optimized icon button with tap feedback
class OptimizedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double size;
  final String? tooltip;

  const OptimizedIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 24,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      icon: Icon(icon, size: size, color: color ?? HermesTheme.textSecondary),
      onPressed: onPressed,
      splashRadius: 20,
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}

/// Batch update widget for high-frequency updates
class BatchUpdateWidget extends StatefulWidget {
  final Duration batchWindow;
  final Widget Function(BuildContext context, dynamic data) builder;
  final Stream<dynamic> Function()? streamFactory;

  const BatchUpdateWidget({
    super.key,
    this.batchWindow = const Duration(milliseconds: 100),
    required this.builder,
    this.streamFactory,
  });

  @override
  State<BatchUpdateWidget> createState() => _BatchUpdateWidgetState();
}

class _BatchUpdateWidgetState extends State<BatchUpdateWidget> {
  dynamic _cachedData;
  dynamic _pendingData;
  DateTime? _lastUpdate;

  @override
  void initState() {
    super.initState();
    _scheduleUpdate();
  }

  void _scheduleUpdate() {
    Future.delayed(widget.batchWindow, () {
      if (mounted && _pendingData != null) {
        setState(() {
          _cachedData = _pendingData;
          _pendingData = null;
          _lastUpdate = DateTime.now();
        });
      }
    });
  }

  void updateData(dynamic data) {
    _pendingData = data;
    _scheduleUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _cachedData);
  }
}

/// Debounced callback handler
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Throttled callback handler
class Throttler {
  final Duration interval;
  DateTime? _lastRun;

  Throttler({this.interval = const Duration(milliseconds: 100)});

  bool run(VoidCallback action) {
    final now = DateTime.now();
    if (_lastRun == null || now.difference(_lastRun!) >= interval) {
      _lastRun = now;
      action();
      return true;
    }
    return false;
  }
}

/// Memory-efficient map for frequently accessed data
class EfficientMap<K, V> {
  final Map<K, V> _data = {};
  final int maxSize;
  final Queue<K> _order = Queue<K>();

  EfficientMap({this.maxSize = 100});

  V? get(K key) => _data[key];

  void set(K key, V value) {
    if (_data.containsKey(key)) {
      _order.remove(key);
    } else if (_data.length >= maxSize) {
      _data.remove(_order.removeFirst());
    }
    _data[key] = value;
    _order.addLast(key);
  }

  void clear() {
    _data.clear();
    _order.clear();
  }

  int get length => _data.length;
}

/// LRU cache implementation
class LruCache<K, V> {
  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();
  final int capacity;

  LruCache({this.capacity = 50});

  V? get(K key) {
    if (!_cache.containsKey(key)) return null;
    // Move to end (most recently used)
    final value = _cache.remove(key)!;
    _cache[key] = value;
    return value;
  }

  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= capacity) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  void clear() => _cache.clear();

  int get length => _cache.length;
}
