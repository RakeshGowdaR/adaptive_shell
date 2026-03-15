## 1.1.0

### ✨ New Features

#### AdaptiveBuilder 🏗️
A standalone responsive builder widget that works **without** an `AdaptiveShell` ancestor — it uses `LayoutBuilder` and `AdaptiveBreakpoints` directly:

```dart
AdaptiveBuilder(
  compact:  (context) => MobileWidget(),
  medium:   (context) => TabletWidget(),   // optional, falls back to compact
  expanded: (context) => DesktopWidget(),  // optional, falls back to medium
  breakpoints: AdaptiveBreakpoints.tabletFirst, // customisable
)
```

#### Keyboard Shortcuts ⌨️
Map any `ShortcutActivator` (e.g. `SingleActivator`, `LogicalKeySet`) to a navigation destination index. Only active on medium/expanded layouts (tablet / desktop):

```dart
AdaptiveShell(
  keyboardShortcuts: {
    SingleActivator(LogicalKeyboardKey.digit1, control: true): 0,
    SingleActivator(LogicalKeyboardKey.digit2, control: true): 1,
  },
  // ...
)
```

#### Collapsible Navigation Rail 📍
A chevron toggle button above the rail destinations lets users collapse the rail to icon-only mode. `railCollapseOnMedium` auto-collapses when the layout enters medium mode:

```dart
AdaptiveShell(
  railCollapsible: true,         // shows toggle button
  railCollapseOnMedium: true,    // auto-collapses on tablet breakpoint
  // ...
)
```

#### Custom Pane Divider ➗
Replace the hardcoded `VerticalDivider` between the master and detail panes with any widget:

```dart
AdaptiveShell(
  paneDivider: VerticalDivider(width: 2, color: Colors.blue),
  // ...
)
```

#### Context Extensions 🔧
Quick access to layout information anywhere in your widget tree:

- `context.screenType` / `context.layoutMode` — get current `LayoutMode` (usable in `switch`)
- `context.isCompact`, `context.isMedium`, `context.isExpanded` — boolean checks
- `context.isMobile`, `context.isTablet`, `context.isDesktop` — semantic aliases
- `context.isTwoPane` — true when two panes are visible
- `context.adaptiveWidth(base)` / `context.adaptiveHeight(base)` — scale dimensions
- `context.adaptivePadding()` — responsive `EdgeInsets` (16 / 24 / 32)
- `context.adaptiveFontSize(base)` / `context.adaptiveSpacing(base)` — scale text & gaps
- `context.adaptiveColumns` — grid column count: **1 / 2 / 3** (compact / medium / expanded)
- `context.adaptiveValue<T>(compact:, medium:, expanded:)` — any typed value per breakpoint

```dart
// Boolean checks
if (context.isCompact) { /* mobile */ }
if (context.isTablet)  { /* medium or expanded */ }

// Typed per-breakpoint value
final padding = context.adaptiveValue(compact: 8.0, medium: 16.0, expanded: 24.0);

// Grid columns
GridView.count(crossAxisCount: context.adaptiveColumns, ...)

// Layout mode in switch
switch (context.layoutMode) {
  case LayoutMode.compact:  return MobileNav();
  case LayoutMode.medium:   return TabletNav();
  case LayoutMode.expanded: return DesktopNav();
}
```

#### Layout Change Callback
React to layout mode transitions for analytics or state management:

```dart
AdaptiveShell(
  onLayoutModeChanged: (oldMode, newMode) {
    print('Layout: $oldMode → $newMode');
  },
  // ...
)
```

#### Debug Overlay
Visual indicator showing current layout mode and breakpoints during development:

```dart
AdaptiveShell(
  debugShowLayoutMode: true, // Shows overlay in top-right corner
  // ...
)
```

#### AutoScale 📏
Proportionally scales your layout to fill any screen size — the same technique that made `responsive_framework`'s AutoScale popular:

```dart
AdaptiveShell(
  autoScale: true,               // render at 360 dp design canvas, scale to screen
  scaleFactor: 1.2,              // optional: 20% boost on top of auto scale
  autoScaleDesignWidth: 390,     // optional: override canvas (e.g. iPhone 14 = 390 dp)
  // ...
)
```

Default `autoScaleDesignWidth` is **360 dp** — a typical phone canvas that ensures a compact (single-pane, bottom-nav) layout by default. The debug overlay gains a live `⚖️ Scale ×N.NN` line when `autoScale` is enabled.

#### State Persistence 💾
Preserves scroll positions and widget state when the device rotates, the window resizes, or the layout mode changes:

```dart
AdaptiveShell(
  persistState: true,
  stateKey: 'my_shell',   // optional namespace (default: 'adaptive_shell')
  // ...
)
```

Uses stable `GlobalKey`s on `child1`/`child2` so element subtrees survive compact ↔ wide transitions, plus a keyed `PageStorage` bucket for scroll restoration.

#### Animated Transitions ✨
Fine-tune detail-pane animations:

```dart
AdaptiveShell(
  transitionCurve: Curves.easeInOutCubic,   // custom curve (default: easeInOut)
  enableHeroAnimations: true,               // slide + fade instead of cross-fade
  // ...
)
```

### 🔗 All new params available on `AdaptiveMasterDetail`
`autoScale`, `scaleFactor`, `autoScaleDesignWidth`, `persistState`, `stateKey`, `transitionCurve`, `enableHeroAnimations`, `paneDivider`, `railCollapsible`, `railCollapseOnMedium`, `keyboardShortcuts` are all forwarded to the internal `AdaptiveShell`.

### 🐛 Bug Fixes & Internal Improvements
- `AdaptiveShell` refactored from `StatelessWidget` to `StatefulWidget` — fully backward-compatible.
- `onLayoutModeChanged` now reliably fires across hot-reload and test pumps.
- Fixed identical debug-overlay emoji for compact/medium modes.
- `AdaptiveMasterDetail._computeMode` respects `autoScale` — navigation decisions (push vs in-place) now correctly match the visually rendered compact layout.
- **Fixed `NavigationRail` overflow when `railCollapsible: true`** — the toggle button (~36 px) consumed height from the `Column` that also holds the `NavigationRail`, causing a `RenderFlex overflowed by N pixels on the bottom` assertion on short screens with many destinations. The rail is now wrapped in `LayoutBuilder → SingleChildScrollView + ConstrainedBox(minHeight) + IntrinsicHeight` so destinations scroll gracefully when they exceed the available height, while still centering correctly on taller screens. The wrapper is applied only when the toggle is present; the default (`railCollapsible: false`) path is unchanged.

### ✅ Tests
- **37 new tests** for AutoScale, State Persistence, Animated Transitions, new context extensions, and `AdaptiveMasterDetail` pass-through.
- **29 new tests** for AdaptiveBuilder, keyboard shortcuts, collapsible rail, and custom `paneDivider`.
- **3 new regression tests** for the `railCollapsible` overflow fix (expanded + medium layouts, and default path).
- Total: **139 tests**, all passing.

### ⚠️ Breaking Changes
- None. All `1.0.x` code compiles and runs unchanged.
- New `BuildContext` extensions (`layoutMode`, `adaptiveColumns`, `adaptiveValue`, and all v1.1.0 additions) may conflict if you already define identically-named extensions. Resolve with a hide import: `import 'package:adaptive_shell/adaptive_shell.dart' hide AdaptiveContextExtensions;`

---

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
