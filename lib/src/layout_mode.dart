/// The current layout mode of [AdaptiveShell].
///
/// Read via [AdaptiveShell.of] to adjust your widget behavior
/// depending on the available screen space.
enum LayoutMode {
  /// Single-pane layout with a [NavigationBar] at the bottom.
  ///
  /// Typically phones with width < 600 dp.
  /// In this mode, detail views should be pushed as separate routes.
  compact,

  /// Two-pane layout with an icon-only [NavigationRail] on the left.
  ///
  /// Typically small tablets or foldables, width 600–1199 dp.
  /// Both `child1` and `child2` are shown side by side.
  medium,

  /// Two-pane layout with an extended [NavigationRail] showing labels.
  ///
  /// Typically large tablets, desktops, or web, width ≥ 1200 dp.
  /// Same two-pane split as medium but with a wider, labeled rail.
  expanded,
}
