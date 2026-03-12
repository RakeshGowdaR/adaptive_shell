/// The current layout mode of [AdaptiveShell].
///
/// Read via [AdaptiveShell.of] to adjust your widget behavior
/// depending on the available screen space.
enum LayoutMode {
  /// Single-pane layout with [BottomNavigationBar].
  ///
  /// Typically phones with width < 600dp.
  /// In this mode, detail views should be pushed as separate routes.
  compact,

  /// Two-pane layout with [NavigationRail] (icon-only).
  ///
  /// Typically small tablets or foldables, width 600–1200dp.
  /// [child2] is shown beside [child1].
  medium,

  /// Two-pane layout with [NavigationRail] (extended labels).
  ///
  /// Typically large tablets, desktops, or web, width > 1200dp.
  /// [child2] is shown beside [child1] with more breathing room.
  expanded,
}
