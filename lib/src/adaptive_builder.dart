import 'package:flutter/widgets.dart';

import 'breakpoints.dart';
import 'layout_mode.dart';

/// A widget that builds different layouts based on the current screen width.
///
/// Unlike [AdaptiveShell], this widget is **standalone** — it does NOT
/// require an [AdaptiveShell] ancestor and works anywhere in your widget tree.
/// It uses [LayoutBuilder] + [AdaptiveBreakpoints] directly.
///
/// ## Basic usage
///
/// ```dart
/// AdaptiveBuilder(
///   compact:  (context) => MobileNav(),
///   medium:   (context) => TabletSidebar(),
///   expanded: (context) => DesktopDrawer(),
/// )
/// ```
///
/// ## Fallback behaviour
///
/// - If [expanded] is omitted, expanded screens fall back to [medium].
/// - If [medium] is omitted, medium screens fall back to [compact].
///
/// ## Custom breakpoints
///
/// ```dart
/// AdaptiveBuilder(
///   breakpoints: AdaptiveBreakpoints(compact: 480, expanded: 1024),
///   compact:  (context) => SmallLayout(),
///   expanded: (context) => WideLayout(),
/// )
/// ```
class AdaptiveBuilder extends StatelessWidget {
  /// Creates an [AdaptiveBuilder].
  ///
  /// [compact] is the only required builder — the others fall back to it
  /// when not provided.
  const AdaptiveBuilder({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
    this.breakpoints = const AdaptiveBreakpoints(),
  });

  /// Builder for compact (mobile) screens. Always required.
  ///
  /// Screen width < [AdaptiveBreakpoints.compact] dp.
  final WidgetBuilder compact;

  /// Builder for medium (tablet) screens.
  ///
  /// Falls back to [compact] when not provided.
  /// Screen width between [AdaptiveBreakpoints.compact] and
  /// [AdaptiveBreakpoints.expanded] dp.
  final WidgetBuilder? medium;

  /// Builder for expanded (desktop/web) screens.
  ///
  /// Falls back to [medium] (then [compact]) when not provided.
  /// Screen width >= [AdaptiveBreakpoints.expanded] dp.
  final WidgetBuilder? expanded;

  /// Breakpoint configuration. Defaults to [AdaptiveBreakpoints.material3].
  final AdaptiveBreakpoints breakpoints;

  /// Returns the resolved [LayoutMode] for the given [width].
  LayoutMode _modeFor(double width) {
    if (width >= breakpoints.expanded) return LayoutMode.expanded;
    if (width >= breakpoints.compact) return LayoutMode.medium;
    return LayoutMode.compact;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        switch (_modeFor(constraints.maxWidth)) {
          case LayoutMode.compact:
            return compact(context);
          case LayoutMode.medium:
            return (medium ?? compact)(context);
          case LayoutMode.expanded:
            return (expanded ?? medium ?? compact)(context);
        }
      },
    );
  }
}

