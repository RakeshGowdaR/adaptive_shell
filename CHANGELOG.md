## 1.0.0

* Initial release with two APIs:
  * **`AdaptiveShell`** — flexible wrapper with `child1`/`child2` for full manual control over both panes, navigation, and state.
  * **`AdaptiveMasterDetail<T>`** — zero-boilerplate generic widget with `itemBuilder`/`detailBuilder`. Handles selection state, navigation (push on mobile, side-pane on tablet), and responsive layout switching automatically.
* Automatic `NavigationBar` (compact) / `NavigationRail` (medium/expanded) switching.
* `AdaptiveShell.of(context)` for descendant layout-mode awareness.
* `AdaptiveShell.isTwoPane(context)` convenience helper.
* `AdaptiveBreakpoints` with Material 3 window size class defaults + `tabletFirst` preset.
* `AdaptiveDestination` with badge support.
* `emptyDetailPlaceholder` for large screens with no selection.
* `masterHeader` and `masterBuilder` for custom master pane layouts.
* `compactDetailScaffoldBuilder` for custom mobile detail screen wrapping.
* Animated pane transitions with configurable duration.
* Full support for Android, iOS, web, macOS, Windows, Linux.
