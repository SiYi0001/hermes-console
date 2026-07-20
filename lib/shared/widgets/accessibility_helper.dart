import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';

/// Accessibility utilities and helpers
class AccessibilityHelper {
  /// Semantic labels for common actions
  static const Map<String, String> semanticLabels = {
    'connect_button': 'Connect to Hermes agent',
    'disconnect_button': 'Disconnect from current agent',
    'refresh_button': 'Refresh data',
    'settings_button': 'Open settings',
    'notification_icon': 'Notifications',
    'search_field': 'Search input',
    'menu_button': 'Open menu',
    'close_button': 'Close dialog',
    'back_button': 'Go back',
  };

  /// Color contrast helper
  static bool meetsContrastRatio(Color foreground, Color background) {
    final ratio = _calculateContrastRatio(foreground, background);
    return ratio >= 4.5; // WCAG AA standard
  }

  static double _calculateContrastRatio(Color c1, Color c2) {
    final l1 = _relativeLuminance(c1);
    final l2 = _relativeLuminance(c2);
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _relativeLuminance(Color color) {
    final r = _linearize(color.r / 255);
    final g = _linearize(color.g / 255);
    final b = _linearize(color.b / 255);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _linearize(double value) {
    return value <= 0.03928
        ? value / 12.92
        : ((value + 0.055) / 1.055).clamp(0.0, 1.0);
  }

  /// Focus traversal group for keyboard navigation
  static Widget focusTraversalGroup(Widget child) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: child,
    );
  }

  /// Create a focusable widget
  static Widget focusable({
    required Widget child,
    required String semanticLabel,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool enabled = true,
  }) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        child: child,
      ),
    );
  }

  /// Exclude from accessibility tree
  static Widget excludeSemantics({
    required Widget child,
    String? label,
  }) {
    if (label != null) {
      return Semantics(label: label, child: child);
    }
    return ExcludeSemantics(child: child);
  }

  /// Large tap target for touch accessibility
  static Widget largeTapTarget({
    required Widget child,
    double minSize = 48.0,
    VoidCallback? onTap,
    AlignmentGeometry alignment = Alignment.center,
  }) {
    return SizedBox(
      width: minSize,
      height: minSize,
      child: Align(
        alignment: alignment,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: child,
        ),
      ),
    );
  }
}

/// Screen reader announcements
class ScreenReaderAnnouncer {
  static void announce(BuildContext context, String message) {
    SemanticsService.sendAnnouncement(View.of(context), message, TextDirection.ltr);
  }

  static void announceError(BuildContext context, String message) {
    SemanticsService.sendAnnouncement(View.of(context), 'Error: $message', TextDirection.ltr);
  }

  static void announceSuccess(BuildContext context, String message) {
    SemanticsService.sendAnnouncement(View.of(context), 'Success: $message', TextDirection.ltr);
  }
}

/// Reduced motion utilities
class ReducedMotionUtils {
  static bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  static Duration getAnimationDuration(
    BuildContext context,
    Duration normalDuration,
  ) {
    if (shouldReduceMotion(context)) {
      return Duration.zero;
    }
    return normalDuration;
  }

  static Curve getAnimationCurve(
    BuildContext context,
    Curve normalCurve,
  ) {
    if (shouldReduceMotion(context)) {
      return Curves.linear;
    }
    return normalCurve;
  }
}

/// High contrast theme utilities
class HighContrastUtils {
  static bool isHighContrastMode(BuildContext context) {
    return MediaQuery.highContrastOf(context);
  }

  static Color getHighContrastColor(Color normal, Color highContrast) {
    return highContrast;
  }
}

/// Text scaling utilities
class TextScaleUtils {
  static double getScaledFontSize(
    BuildContext context,
    double baseFontSize, {
    double minScale = 0.8,
    double maxScale = 2.0,
  }) {
    final scale = MediaQuery.textScalerOf(context).scale(1.0);
    return baseFontSize * scale.clamp(minScale, maxScale);
  }

  static TextStyle getScaledTextStyle(
    BuildContext context,
    TextStyle baseStyle, {
    double minScale = 0.8,
    double maxScale = 2.0,
  }) {
    return baseStyle.copyWith(
      fontSize: getScaledFontSize(
        context,
        baseStyle.fontSize ?? 14,
        minScale: minScale,
        maxScale: maxScale,
      ),
    );
  }
}

/// Keyboard navigation helpers
class KeyboardNavigationHelper {
  static final FocusNode rootFocusNode = FocusNode();

  static void moveFocusToNext(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  static void moveFocusToPrevious(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  static void clearFocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static bool isTabPressed(KeyEvent event) {
    return event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.tab;
  }

  static bool isEscapePressed(KeyEvent event) {
    return event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape;
  }

  static bool isEnterPressed(KeyEvent event) {
    return event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter);
  }

  static bool isArrowKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final key = event.logicalKey;
    return key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight;
  }
}

/// Live region for dynamic updates
class LiveRegion extends StatelessWidget {
  final String message;
  final TextDirection textDirection;
  final Widget child;

  const LiveRegion({
    super.key,
    required this.message,
    this.textDirection = TextDirection.ltr,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: message,
      textDirection: textDirection,
      child: child,
    );
  }
}

/// Tooltip with accessibility support
class AccessibleTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  final bool preferBelow;

  const AccessibleTooltip({
    super.key,
    required this.message,
    required this.child,
    this.preferBelow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      preferBelow: preferBelow,
      child: child,
    );
  }
}
