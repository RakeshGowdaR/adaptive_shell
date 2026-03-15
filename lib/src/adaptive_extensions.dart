import 'package:flutter/widgets.dart';
import 'adaptive_shell.dart';
import 'layout_mode.dart';

/// Convenience extensions for adaptive layouts.
///
/// These extensions work with [AdaptiveShell.of] to provide
/// quick access to layout information anywhere in your widget tree.
///
/// ```dart
/// // Instead of:
/// if (AdaptiveShell.of(context) == LayoutMode.compact) { ... }
///
/// // You can write:
/// if (context.isCompact) { ... }
/// ```
extension AdaptiveContextExtensions on BuildContext {
  /// Returns the current [LayoutMode] from the nearest [AdaptiveShell].
  ///
  /// This is equivalent to calling [AdaptiveShell.of(context)].
  LayoutMode get screenType => AdaptiveShell.of(this);

  /// True if currently in compact mode (mobile).
  ///
  /// Screen width < 600dp by default.
  bool get isCompact => AdaptiveShell.of(this) == LayoutMode.compact;

  /// True if currently in medium mode (tablet with icon-only rail).
  ///
  /// Screen width between 600-1200dp by default.
  bool get isMedium => AdaptiveShell.of(this) == LayoutMode.medium;

  /// True if currently in expanded mode (desktop with labeled rail).
  ///
  /// Screen width >= 1200dp by default.
  bool get isExpanded => AdaptiveShell.of(this) == LayoutMode.expanded;

  /// Alias for [isCompact] - true on mobile screens.
  bool get isMobile => isCompact;

  /// True if currently showing two panes side-by-side.
  ///
  /// This is equivalent to [AdaptiveShell.isTwoPane(context)].
  bool get isTwoPane => AdaptiveShell.isTwoPane(this);

  /// Alias for [isMedium] or [isExpanded] - true on tablet/desktop.
  bool get isTablet => isMedium || isExpanded;

  /// Alias for [isExpanded] - true on desktop screens.
  bool get isDesktop => isExpanded;

  /// Returns an adaptive width scaled based on current screen type.
  ///
  /// - Compact: returns [baseWidth] (1.0x)
  /// - Medium: returns [baseWidth] * 1.2
  /// - Expanded: returns [baseWidth] * 1.5
  ///
  /// ```dart
  /// Container(
  ///   width: context.adaptiveWidth(300), // 300 on mobile, 360 on tablet, 450 on desktop
  /// )
  /// ```
  double adaptiveWidth(double baseWidth) {
    final mode = AdaptiveShell.of(this);
    switch (mode) {
      case LayoutMode.compact:
        return baseWidth;
      case LayoutMode.medium:
        return baseWidth * 1.2;
      case LayoutMode.expanded:
        return baseWidth * 1.5;
    }
  }

  /// Returns an adaptive height scaled based on current screen type.
  ///
  /// - Compact: returns [baseHeight] (1.0x)
  /// - Medium: returns [baseHeight] * 1.15
  /// - Expanded: returns [baseHeight] * 1.3
  ///
  /// ```dart
  /// Container(
  ///   height: context.adaptiveHeight(200),
  /// )
  /// ```
  double adaptiveHeight(double baseHeight) {
    final mode = AdaptiveShell.of(this);
    switch (mode) {
      case LayoutMode.compact:
        return baseHeight;
      case LayoutMode.medium:
        return baseHeight * 1.15;
      case LayoutMode.expanded:
        return baseHeight * 1.3;
    }
  }

  /// Returns adaptive padding based on current screen type.
  ///
  /// Defaults:
  /// - Compact: 16.0
  /// - Medium: 24.0
  /// - Expanded: 32.0
  ///
  /// ```dart
  /// Padding(
  ///   padding: context.adaptivePadding(),
  ///   child: child,
  /// )
  /// ```
  EdgeInsets adaptivePadding({
    double compact = 16.0,
    double medium = 24.0,
    double expanded = 32.0,
  }) {
    final mode = AdaptiveShell.of(this);
    final value = mode == LayoutMode.compact
        ? compact
        : mode == LayoutMode.medium
            ? medium
            : expanded;
    return EdgeInsets.all(value);
  }

  /// Returns adaptive font size based on current screen type.
  ///
  /// - Compact: returns [baseSize] (1.0x)
  /// - Medium: returns [baseSize] * 1.1
  /// - Expanded: returns [baseSize] * 1.2
  ///
  /// ```dart
  /// Text(
  ///   'Hello',
  ///   style: TextStyle(
  ///     fontSize: context.adaptiveFontSize(16),
  ///   ),
  /// )
  /// ```
  double adaptiveFontSize(double baseSize) {
    final mode = AdaptiveShell.of(this);
    switch (mode) {
      case LayoutMode.compact:
        return baseSize;
      case LayoutMode.medium:
        return baseSize * 1.1;
      case LayoutMode.expanded:
        return baseSize * 1.2;
    }
  }

  /// Returns adaptive spacing based on current screen type.
  ///
  /// Useful for gaps, margins, and other spacing values.
  ///
  /// - Compact: returns [baseSpacing] (1.0x)
  /// - Medium: returns [baseSpacing] * 1.25
  /// - Expanded: returns [baseSpacing] * 1.5
  ///
  /// ```dart
  /// SizedBox(height: context.adaptiveSpacing(8)),
  /// ```
  double adaptiveSpacing(double baseSpacing) {
    final mode = AdaptiveShell.of(this);
    switch (mode) {
      case LayoutMode.compact:
        return baseSpacing;
      case LayoutMode.medium:
        return baseSpacing * 1.25;
      case LayoutMode.expanded:
        return baseSpacing * 1.5;
    }
  }

  /// Alias for [screenType] — returns the current [LayoutMode].
  ///
  /// Useful in `switch` expressions without importing [AdaptiveShell]:
  ///
  /// ```dart
  /// switch (context.layoutMode) {
  ///   case LayoutMode.compact:  return MobileNav();
  ///   case LayoutMode.medium:   return TabletNav();
  ///   case LayoutMode.expanded: return DesktopNav();
  /// }
  /// ```
  LayoutMode get layoutMode => AdaptiveShell.of(this);

  /// Number of grid columns appropriate for the current layout.
  ///
  /// - Compact  → **1**
  /// - Medium   → **2**
  /// - Expanded → **3**
  ///
  /// ```dart
  /// GridView.count(
  ///   crossAxisCount: context.adaptiveColumns,
  ///   children: tiles,
  /// )
  /// ```
  int get adaptiveColumns {
    switch (AdaptiveShell.of(this)) {
      case LayoutMode.compact:
        return 1;
      case LayoutMode.medium:
        return 2;
      case LayoutMode.expanded:
        return 3;
    }
  }

  /// Returns one of three typed values based on the current layout mode.
  ///
  /// The most concise way to vary any property per breakpoint:
  ///
  /// ```dart
  /// // padding
  /// context.adaptiveValue(compact: 8.0, medium: 16.0, expanded: 24.0)
  ///
  /// // widget
  /// context.adaptiveValue<Widget>(
  ///   compact: const Icon(Icons.menu),
  ///   medium:  const SizedBox.shrink(),
  ///   expanded: const SizedBox.shrink(),
  /// )
  /// ```
  T adaptiveValue<T>({
    required T compact,
    required T medium,
    required T expanded,
  }) {
    switch (AdaptiveShell.of(this)) {
      case LayoutMode.compact:
        return compact;
      case LayoutMode.medium:
        return medium;
      case LayoutMode.expanded:
        return expanded;
    }
  }
}
