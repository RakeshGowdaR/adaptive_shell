/// Material 3 window size class breakpoints for [AdaptiveShell].
///
/// Two fields drive the actual layout switching:
/// - **[compact]** — below this, single-pane with bottom nav
/// - **[expanded]** — at or above this, extended rail with labels
///
/// Everything between [compact] and [expanded] is the medium range:
/// two-pane layout with an icon-only rail. The [medium] field is stored
/// for reference and validation but does not trigger a layout change.
///
/// Based on the [Material 3 window size classes](https://m3.material.io/foundations/layout/applying-layout/window-size-classes).
///
/// You can use the built-in presets:
/// ```dart
/// AdaptiveBreakpoints.material3   // default
/// AdaptiveBreakpoints.tabletFirst // switches to 2-pane earlier
/// ```
///
/// Or create a custom configuration:
/// ```dart
/// const AdaptiveBreakpoints(
///   compact: 500,
///   expanded: 960,
///   masterRatio: 0.4,
/// )
/// ```
class AdaptiveBreakpoints {
  /// Creates adaptive breakpoints.
  ///
  /// [compact] must be > 0, [medium] > [compact], [expanded] > [medium].
  /// [masterRatio] must be between 0.2 and 0.5.
  const AdaptiveBreakpoints({
    this.compact = 600,
    this.medium = 840,
    this.expanded = 1200,
    this.masterRatio = 0.35,
  });

  /// Width threshold for compact mode. Below this, single-pane layout.
  ///
  /// Defaults to 600 (Material 3 compact class).
  final double compact;

  /// Stored for reference — the Material 3 medium window size class boundary.
  ///
  /// **This field does not affect the layout switching logic.** The actual
  /// transitions are:
  /// - two-pane layout starts at [compact] (where `NavigationRail` appears)
  /// - extended rail with labels starts at [expanded]
  ///
  /// [medium] is kept here so callers can store the full M3 spec and use
  /// it in custom breakpoint validation, analytics, or their own UI logic.
  ///
  /// Defaults to 840 (Material 3 medium class).
  final double medium;

  /// Width threshold for expanded mode. At or above this, extended rail.
  ///
  /// Defaults to 1200 (Material 3 expanded class).
  final double expanded;

  /// Fraction of available width allocated to child1 (master pane)
  /// when in two-pane mode.
  ///
  /// The remaining space goes to child2 (detail pane).
  /// Defaults to 0.35 (35% master, 65% detail).
  ///
  /// Must be between 0.2 and 0.5 for a usable layout.
  final double masterRatio;

  /// Default Material 3 breakpoints.
  static const material3 = AdaptiveBreakpoints();

  /// Breakpoints optimized for tablet apps that should show
  /// two-pane layouts earlier.
  static const tabletFirst = AdaptiveBreakpoints(
    compact: 500,
    medium: 700,
    expanded: 960,
    masterRatio: 0.38,
  );

  /// Validates breakpoint values. Call this in debug mode.
  bool get isValid =>
      compact > 0 &&
      medium > compact &&
      expanded > medium &&
      masterRatio >= 0.2 &&
      masterRatio <= 0.5;
}
