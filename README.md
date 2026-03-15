# adaptive_shell

[![pub package](https://img.shields.io/pub/v/adaptive_shell.svg)](https://pub.dev/packages/adaptive_shell)
[![License: BSD-3](https://img.shields.io/badge/license-BSD--3-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

An adaptive master-detail layout wrapper for Flutter. Supply `child1` + `child2` and the package handles everything: responsive pane layout, navigation mode switching, and layout-aware navigation — across mobile, tablet, web, and desktop.

## Why adaptive_shell?

Building adaptive layouts in Flutter typically requires hundreds of lines of boilerplate: checking screen widths, conditionally rendering `NavigationBar` vs `NavigationRail`, managing master-detail panes, and handling navigation differently per platform. `adaptive_shell` reduces this to a single wrapper widget.

`flutter_adaptive_scaffold` (the official package) has been **discontinued**. `adaptive_shell` is a simpler, actively-maintained alternative with a more intuitive API.

## Screenshots

### Compact layout (Mobile)

![Compact layout](screenshots/compact.png)

### Expanded layout (Tablet/Desktop)

![Expanded layout](screenshots/expanded.png)

## Features

- **Single wrapper widget** — just provide `child1` + `child2`
- **Automatic navigation** — `NavigationBar` on mobile, `NavigationRail` on tablet/web
- **Master-detail split** — `child1` always visible; `child2` shown beside it on larger screens
- **Layout awareness** — `AdaptiveShell.of(context)` returns the current mode so descendants can decide between pushing routes or updating state
- **Context extensions** — `context.isCompact`, `context.isTwoPane`, `context.adaptiveWidth()` and more for clean, readable code
- **Layout change callback** — `onLayoutModeChanged` fires when the layout transitions (e.g. compact → medium), useful for analytics or state management
- **Debug overlay** — `debugShowLayoutMode: true` shows a live overlay with current mode and breakpoints during development
- **Material 3 compliant** — follows M3 window size classes (compact / medium / expanded)
- **Badge support** — navigation destinations support notification counts
- **All platforms** — Android, iOS, web, macOS, Windows, Linux

## Layout behavior

```
Compact (<600dp)          Medium (600–1200dp)         Expanded (>1200dp)
┌─────────────────┐       ┌──┬────────┬──────────┐    ┌─────────┬────────┬──────────┐
│                 │       │  │        │          │    │ Rail    │        │          │
│    child1       │       │R │ child1 │  child2  │    │(labels) │ child1 │  child2  │
│   (fullscreen)  │       │a │ (35%)  │  (65%)   │    │         │ (35%)  │  (65%)   │
│                 │       │i │        │          │    │         │        │          │
│                 │       │l │        │          │    │         │        │          │
├─────────────────┤       └──┴────────┴──────────┘    └─────────┴────────┴──────────┘
│  BottomNavBar   │
└─────────────────┘
```

## Getting started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  adaptive_shell: ^1.1.0
```

## Usage

### Basic setup

```dart
import 'package:adaptive_shell/adaptive_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  Patient? _selected;

  void _onPatientTap(Patient patient) {
    // Check current layout to decide navigation strategy
    if (AdaptiveShell.of(context) == LayoutMode.compact) {
      // Mobile: push a new screen
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => PatientDetailScreen(patient: patient),
      ));
    } else {
      // Tablet/web: update child2 in-place
      setState(() => _selected = patient);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveShell(
      destinations: const [
        AdaptiveDestination(icon: Icons.people, label: 'Patients'),
        AdaptiveDestination(icon: Icons.task, label: 'Tasks', badge: 3),
        AdaptiveDestination(icon: Icons.chat, label: 'Chat'),
      ],
      selectedIndex: _navIndex,
      onDestinationSelected: (i) => setState(() => _navIndex = i),
      child1: PatientListScreen(onTap: _onPatientTap),
      child2: _selected != null
        ? PatientDetailScreen(patient: _selected!)
        : null,
      emptyDetailPlaceholder: const Center(
        child: Text('Select a patient'),
      ),
    );
  }
}
```

### Reading layout mode in descendants

```dart
// In any descendant widget:
final mode = AdaptiveShell.of(context);
// Returns LayoutMode.compact, .medium, or .expanded

// Or use the convenience helper:
if (AdaptiveShell.isTwoPane(context)) {
  // Show selected highlight, hide chevron, etc.
}
```

### Context extensions (v1.1.0)

Quick, readable access to layout information anywhere in the widget tree:

```dart
// Boolean checks
if (context.isCompact) { /* mobile */ }
if (context.isMedium) { /* tablet */ }
if (context.isExpanded) { /* desktop */ }

// Semantic aliases
if (context.isMobile) { /* same as isCompact */ }
if (context.isTablet) { /* medium or expanded */ }
if (context.isDesktop) { /* same as isExpanded */ }
if (context.isTwoPane) { /* two panes visible */ }

// Adaptive sizing
final width  = context.adaptiveWidth(300);     // 300 / 360 / 450
final height = context.adaptiveHeight(200);    // 200 / 230 / 260
final size   = context.adaptiveFontSize(16);   // 16 / 17.6 / 19.2
final space  = context.adaptiveSpacing(8);     // 8 / 10 / 12
final pad    = context.adaptivePadding();      // 16 / 24 / 32

// Custom padding thresholds
final pad2 = context.adaptivePadding(compact: 12, medium: 20, expanded: 28);
```

> **Note:** If you already define any of these names as `BuildContext` extensions in your own code, Dart will raise an ambiguity error. You can resolve it with a hide import:
> ```dart
> import 'package:adaptive_shell/adaptive_shell.dart' hide AdaptiveContextExtensions;
> ```

### Layout change callback (v1.1.0)

React to layout mode transitions for analytics, state resets, or logging:

```dart
AdaptiveShell(
  onLayoutModeChanged: (oldMode, newMode) {
    debugPrint('Layout: $oldMode → $newMode');
    analytics.logEvent('layout_change', {'mode': newMode.name});
  },
  // ...
)
```

### Debug overlay (v1.1.0)

Show a live overlay with the current mode, screen width, and breakpoint thresholds:

```dart
AdaptiveShell(
  debugShowLayoutMode: true, // remove before shipping
  // ...
)
```

### Custom breakpoints

```dart
AdaptiveShell(
  // Switch to two-pane earlier for tablet-first apps
  breakpoints: AdaptiveBreakpoints.tabletFirst,
  // ...
)

// Or fully custom:
AdaptiveShell(
  breakpoints: const AdaptiveBreakpoints(
    compact: 500,
    medium: 700,
    expanded: 960,
    masterRatio: 0.4, // 40% master, 60% detail
  ),
  // ...
)
```

### NavigationRail customization

```dart
AdaptiveShell(
  railLeading: FloatingActionButton.small(
    onPressed: _addPatient,
    child: const Icon(Icons.add),
  ),
  railTrailing: const Icon(Icons.settings),
  railBackgroundColor: Colors.grey.shade50,
  // ...
)
```

## API reference

### AdaptiveShell

| Property | Type | Default | Description |
|---|---|---|---|
| `child1` | `Widget` | required | Primary content, always visible |
| `child2` | `Widget?` | `null` | Detail content, shown on larger screens |
| `destinations` | `List<AdaptiveDestination>` | required | Navigation items (min 2) |
| `selectedIndex` | `int` | required | Currently selected nav index |
| `onDestinationSelected` | `ValueChanged<int>` | required | Nav tap callback |
| `breakpoints` | `AdaptiveBreakpoints` | M3 defaults | Breakpoint thresholds |
| `showPaneDivider` | `bool` | `true` | Divider between panes |
| `railLeading` | `Widget?` | `null` | Widget above rail items |
| `railTrailing` | `Widget?` | `null` | Widget below rail items |
| `railBackgroundColor` | `Color?` | `null` | Rail background |
| `appBar` | `PreferredSizeWidget?` | `null` | Top app bar |
| `transitionDuration` | `Duration` | 300ms | Pane animation speed |
| `floatingActionButton` | `Widget?` | `null` | FAB widget |
| `emptyDetailPlaceholder` | `Widget?` | `null` | Shown when child2 is null on large screens |
| `onLayoutModeChanged` | `void Function(LayoutMode, LayoutMode)?` | `null` | Called when layout mode transitions |
| `debugShowLayoutMode` | `bool` | `false` | Shows a live debug overlay in the top-right corner |

### AdaptiveMasterDetail

Zero-boilerplate alternative. Inherits all `AdaptiveShell` properties above, plus:

| Property | Type | Default | Description |
|---|---|---|---|
| `items` | `List<T>` | required | Data items for the master list |
| `itemBuilder` | `MasterItemBuilder<T>` | required | Builds each list item |
| `detailBuilder` | `DetailBuilder<T>` | required | Builds the detail view |
| `selectedNavIndex` | `int` | required | Currently selected nav index |
| `onNavSelected` | `ValueChanged<int>` | required | Nav tap callback |
| `itemKey` | `Object Function(T)?` | `null` | Unique key per item (defaults to hashCode) |
| `initialSelection` | `T Function(List<T>)?` | `null` | Pre-selects an item on first build |
| `detailAppBarTitle` | `String Function(T)?` | `null` | Title for mobile detail AppBar |
| `masterHeader` | `Widget?` | `null` | Widget above the master list (e.g. search bar) |
| `masterBuilder` | `Widget Function(...)?` | `null` | Fully custom master pane builder |
| `compactDetailScaffoldBuilder` | `Widget Function(...)?` | `null` | Custom scaffold for mobile detail push |

### AdaptiveContextExtensions

Extensions on `BuildContext` for concise layout-aware code. Require a `BuildContext` inside an `AdaptiveShell` subtree.

| Extension | Returns | Description |
|---|---|---|
| `context.screenType` | `LayoutMode` | Current layout mode |
| `context.isCompact` | `bool` | `true` on mobile (< compact bp) |
| `context.isMedium` | `bool` | `true` on tablet (compact–expanded bp) |
| `context.isExpanded` | `bool` | `true` on desktop (≥ expanded bp) |
| `context.isMobile` | `bool` | Alias for `isCompact` |
| `context.isTablet` | `bool` | `true` if medium or expanded |
| `context.isDesktop` | `bool` | Alias for `isExpanded` |
| `context.isTwoPane` | `bool` | `true` if two panes are visible |
| `context.adaptiveWidth(base)` | `double` | `base` × 1.0 / 1.2 / 1.5 |
| `context.adaptiveHeight(base)` | `double` | `base` × 1.0 / 1.15 / 1.3 |
| `context.adaptiveFontSize(base)` | `double` | `base` × 1.0 / 1.1 / 1.2 |
| `context.adaptiveSpacing(base)` | `double` | `base` × 1.0 / 1.25 / 1.5 |
| `context.adaptivePadding(...)` | `EdgeInsets` | 16 / 24 / 32 (customisable) |

### AdaptiveBreakpoints

| Preset | Compact | Medium | Expanded | Master ratio |
|---|---|---|---|---|
| `material3` | 600 | 840 | 1200 | 35% |
| `tabletFirst` | 500 | 700 | 960 | 38% |

### LayoutMode

| Value | Screen width | Navigation | Panes |
|---|---|---|---|
| `compact` | < compact | `NavigationBar` | 1 (child1 only) |
| `medium` | compact – expanded | `NavigationRail` (icons) | 2 |
| `expanded` | >= expanded | `NavigationRail` (labels) | 2 |

## Design guidelines

This package follows recommendations from:

- [Flutter Adaptive & Responsive Design](https://docs.flutter.dev/ui/adaptive-responsive)
- [Flutter Best Practices](https://docs.flutter.dev/ui/adaptive-responsive/best-practices)
- [Material 3 Window Size Classes](https://m3.material.io/foundations/layout/applying-layout/window-size-classes)

Principles applied:

- Uses `LayoutBuilder`, never checks device type or locks orientation
- Material 3 window size classes for breakpoints
- `NavigationBar` on compact, `NavigationRail` on medium/expanded
- Preserves child widget state across layout changes
- Supports keyboard, mouse, and touch input

## Comparison with alternatives

| | adaptive_shell | flutter_adaptive_scaffold |
|---|---|---|
| Status | Active | **Discontinued** |
| API | `child1` / `child2` | Slot-based configs |
| Nav switching | Automatic | Manual per breakpoint |
| Layout awareness | `AdaptiveShell.of(context)` | None |
| Lines to set up | ~20 | ~100+ |

## Additional information

- **Issues**: [GitHub Issues](https://github.com/RakeshGowdaR/adaptive_shell/issues)
- **Contributing**: PRs welcome. Please open an issue first for major changes.
- **License**: BSD-3-Clause
