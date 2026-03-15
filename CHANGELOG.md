## 1.1.0

### ✨ New Features

#### Context Extensions
Quick access to layout information anywhere in your widget tree:

- `context.screenType` - Get current LayoutMode
- `context.isCompact`, `context.isMedium`, `context.isExpanded` - Boolean checks
- `context.isMobile`, `context.isTablet`, `context.isDesktop` - Semantic aliases
- `context.isTwoPane` - Check if showing two panes
- `context.adaptiveWidth(baseWidth)` - Scale widths responsively
- `context.adaptiveHeight(baseHeight)` - Scale heights responsively
- `context.adaptivePadding()` - Get responsive padding
- `context.adaptiveFontSize(baseSize)` - Scale font sizes
- `context.adaptiveSpacing(baseSpacing)` - Scale spacing values

**Example:**
```dart
if (context.isCompact) {
  // Mobile-specific code
} else if (context.isTablet) {
  // Tablet-specific code
}

final width = context.adaptiveWidth(300); // Scales: 300/360/450
```

#### Layout Change Callback
React to layout mode transitions for analytics or state management:

**Example:**
```dart
AdaptiveShell(
  onLayoutModeChanged: (oldMode, newMode) {
    print('Layout: $oldMode → $newMode');
    analytics.logEvent('layout_change', {'mode': newMode.name});
  },
  // ...
)

// Also available on AdaptiveMasterDetail:
AdaptiveMasterDetail(
  onLayoutModeChanged: (oldMode, newMode) { ... },
  // ...
)
```

#### Debug Overlay
Visual indicator showing current layout mode and breakpoints during development:

**Example:**
```dart
// Works on both AdaptiveShell and AdaptiveMasterDetail:
AdaptiveShell(
  debugShowLayoutMode: true, // Shows overlay in top-right corner
  // ...
)
AdaptiveMasterDetail(
  debugShowLayoutMode: true,
  // ...
)
```

### 🐛 Bug Fixes & Internal Improvements
- `AdaptiveShell` refactored from `StatelessWidget` to `StatefulWidget` so layout-mode state is correctly preserved across widget rebuilds. This is fully backward-compatible — all existing code continues to work unchanged.
- `onLayoutModeChanged` callback now reliably fires even when the widget tree is restructured between frames (e.g. during hot-reload or test pumps).
- Fixed identical emoji used for `compact` and `medium` modes in the debug overlay — medium now correctly shows a distinct icon.

### 📖 Documentation
- README updated with new features section, context extensions usage guide, and full API reference table for all 1.1.0 additions.
- All `[parameterName]` doc references replaced with backtick style to resolve 10 `dart doc` warnings (zero warnings now).
- Added inline documentation for `onLayoutModeChanged` and `debugShowLayoutMode`.

### ⚠️ Breaking Changes
- None. All existing `1.0.0` / `1.0.0+2` code compiles and runs unchanged.
- **Edge case**: The new `AdaptiveContextExtensions` adds extension methods on `BuildContext` (`isCompact`, `isMedium`, `isExpanded`, `isMobile`, `isTablet`, `isDesktop`, `isTwoPane`, `adaptiveWidth`, `adaptiveHeight`, `adaptiveFontSize`, `adaptiveSpacing`, `adaptivePadding`, `screenType`). If your codebase already defines any of these as `BuildContext` extensions with the same names, Dart will raise an ambiguity error. Resolve it by qualifying the call: `AdaptiveContextExtensions(context).isCompact` or by hiding the import: `import 'package:adaptive_shell/adaptive_shell.dart' hide AdaptiveContextExtensions;`.

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
