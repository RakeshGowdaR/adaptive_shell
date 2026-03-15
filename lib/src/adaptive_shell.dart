import 'package:flutter/material.dart';

import 'adaptive_destination.dart';
import 'breakpoints.dart';
import 'layout_mode.dart';

/// Provides the current [LayoutMode] to descendants via [AdaptiveShell.of].
class AdaptiveShellScope extends InheritedWidget {
  /// Creates an [AdaptiveShellScope].
  const AdaptiveShellScope({
    super.key,
    required this.layoutMode,
    required super.child,
  });

  /// The current layout mode.
  final LayoutMode layoutMode;

  @override
  bool updateShouldNotify(AdaptiveShellScope oldWidget) {
    return layoutMode != oldWidget.layoutMode;
  }
}

/// An adaptive master-detail layout wrapper.
///
/// Wraps your content and automatically provides:
///
/// - **Compact** (mobile): [child1] fills the screen with a
///   [NavigationBar] at the bottom.
/// - **Medium** (tablet): A [NavigationRail] on the left with [child1]
///   and [child2] shown side by side.
/// - **Expanded** (desktop/web): A [NavigationRail] with extended labels,
///   and [child1] + [child2] side by side.
///
/// ## Navigation pattern
///
/// Use [AdaptiveShell.of] in descendants to determine how to navigate:
///
/// ```dart
/// void onItemTap(Item item) {
///   if (AdaptiveShell.of(context) == LayoutMode.compact) {
///     // Mobile: push a full-screen route
///     Navigator.push(context, MaterialPageRoute(
///       builder: (_) => DetailScreen(item: item),
///     ));
///   } else {
///     // Tablet/web: update child2 in place
///     setState(() => _selectedItem = item);
///   }
/// }
/// ```
///
/// ## Example
///
/// ```dart
/// AdaptiveShell(
///   destinations: const [
///     AdaptiveDestination(icon: Icons.people, label: 'Patients'),
///     AdaptiveDestination(icon: Icons.task, label: 'Tasks'),
///   ],
///   selectedIndex: _navIndex,
///   onDestinationSelected: (i) => setState(() => _navIndex = i),
///   child1: PatientListScreen(onTap: _handleTap),
///   child2: _selected != null
///     ? PatientDetailScreen(patient: _selected!)
///     : null,
///   emptyDetailPlaceholder: const Center(
///     child: Text('Select a patient'),
///   ),
/// )
/// ```

class AdaptiveShell extends StatefulWidget {
  /// Called when the layout mode changes (e.g., compact → medium).
  final void Function(LayoutMode oldMode, LayoutMode newMode)?
      onLayoutModeChanged;

  /// Shows a debug overlay with current layout mode info.
  final bool debugShowLayoutMode;

  /// Creates an adaptive shell.
  const AdaptiveShell({
    super.key,
    required this.child1,
    this.child2,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.breakpoints = const AdaptiveBreakpoints(),
    this.showPaneDivider = true,
    this.detailAlignment = Alignment.topLeft,
    this.railLeading,
    this.railTrailing,
    this.railBackgroundColor,
    this.appBar,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.emptyDetailPlaceholder,
    this.onLayoutModeChanged,
    this.debugShowLayoutMode = false,
  });

  /// The primary content widget, always visible.
  ///
  /// Typically a list or master view.
  final Widget child1;

  /// The secondary content widget, shown beside [child1] on larger screens.
  ///
  /// On compact (mobile) screens, this is ignored — you should push
  /// a separate route instead.
  ///
  /// If null on medium/expanded screens:
  /// - [emptyDetailPlaceholder] is shown if provided.
  /// - Otherwise [child1] fills the full available width.
  final Widget? child2;

  /// Navigation destinations shown in the bottom bar or rail.
  final List<AdaptiveDestination> destinations;

  /// The index of the currently selected destination.
  final int selectedIndex;

  /// Called when a destination is tapped.
  final ValueChanged<int> onDestinationSelected;

  /// Breakpoint configuration. Defaults to [AdaptiveBreakpoints.material3].
  final AdaptiveBreakpoints breakpoints;

  /// Whether to show a [VerticalDivider] between the two panes.
  final bool showPaneDivider;

  /// Alignment of the detail pane ([child2]) content.
  ///
  /// Defaults to [Alignment.topLeft] so content starts from the top.
  /// Set to [Alignment.center] if you want centered detail content
  /// (e.g., a placeholder or media viewer).
  ///
  /// ```dart
  /// AdaptiveShell(
  ///   detailAlignment: Alignment.topCenter,
  ///   // ...
  /// )
  /// ```
  final AlignmentGeometry detailAlignment;

  /// Optional widget above rail destinations (e.g., a logo or [FloatingActionButton]).
  final Widget? railLeading;

  /// Optional widget below rail destinations.
  final Widget? railTrailing;

  /// Background color for the [NavigationRail].
  final Color? railBackgroundColor;

  /// Optional [AppBar] shown at the top of the entire shell.
  final PreferredSizeWidget? appBar;

  /// Duration for layout transition animations.
  final Duration transitionDuration;

  /// Optional [FloatingActionButton].
  final Widget? floatingActionButton;

  /// Position of the [FloatingActionButton].
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Placeholder shown in the detail area when [child2] is null
  /// and the screen is large enough for two panes.
  final Widget? emptyDetailPlaceholder;

  /// Returns the current [LayoutMode] from the nearest [AdaptiveShell].
  ///
  /// Returns [LayoutMode.compact] if no ancestor [AdaptiveShell] exists.
  static LayoutMode of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AdaptiveShellScope>();
    return scope?.layoutMode ?? LayoutMode.compact;
  }

  /// Returns `true` if the current layout shows two panes.
  static bool isTwoPane(BuildContext context) {
    final mode = of(context);
    return mode == LayoutMode.medium || mode == LayoutMode.expanded;
  }

  @override
  State<AdaptiveShell> createState() => _AdaptiveShellState();
}

class _AdaptiveShellState extends State<AdaptiveShell> {
  // Initialize to compact so that a freshly-created state will fire the
  // callback when the widget is first built at a larger breakpoint.
  LayoutMode _previousMode = LayoutMode.compact;

  LayoutMode _computeMode(double width) {
    if (width >= widget.breakpoints.expanded) return LayoutMode.expanded;
    if (width >= widget.breakpoints.compact) return LayoutMode.medium;
    return LayoutMode.compact;
  }

  void _notifyIfModeChanged(LayoutMode newMode) {
    if (_previousMode != newMode && widget.onLayoutModeChanged != null) {
      final oldMode = _previousMode;
      _previousMode = newMode;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onLayoutModeChanged!(oldMode, newMode);
      });
    } else {
      _previousMode = newMode;
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.breakpoints.isValid, 'Invalid breakpoints configuration.');
    assert(
      widget.destinations.length >= 2,
      'At least 2 destinations are required.',
    );
    assert(
      widget.selectedIndex >= 0 &&
          widget.selectedIndex < widget.destinations.length,
      'selectedIndex (${widget.selectedIndex}) out of range [0, ${widget.destinations.length}).',
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final mode = _computeMode(constraints.maxWidth);
        _notifyIfModeChanged(mode);

        Widget child = AdaptiveShellScope(
          layoutMode: mode,
          child: _buildLayout(context, mode, constraints.maxWidth),
        );

        // Add debug overlay if enabled
        if (widget.debugShowLayoutMode) {
          child = Stack(
            children: [
              child,
              _DebugOverlay(
                mode: mode,
                screenWidth: constraints.maxWidth,
                breakpoints: widget.breakpoints,
              ),
            ],
          );
        }

        return child;
      },
    );
  }

  Widget _buildLayout(BuildContext context, LayoutMode mode, double width) {
    switch (mode) {
      case LayoutMode.compact:
        return _CompactLayout(shell: widget);
      case LayoutMode.medium:
        return _WideLayout(shell: widget, extended: false, totalWidth: width);
      case LayoutMode.expanded:
        return _WideLayout(shell: widget, extended: true, totalWidth: width);
    }
  }
}

// ─── Compact (mobile) layout ───

class _CompactLayout extends StatelessWidget {
  const _CompactLayout({required this.shell});

  final AdaptiveShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: shell.appBar,
      body: shell.child1,
      floatingActionButton: shell.floatingActionButton,
      floatingActionButtonLocation: shell.floatingActionButtonLocation,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.selectedIndex,
        onDestinationSelected: shell.onDestinationSelected,
        destinations: shell.destinations.map(_toNavDestination).toList(),
      ),
    );
  }

  NavigationDestination _toNavDestination(AdaptiveDestination dest) {
    Widget icon = Icon(dest.icon);
    Widget selectedIcon = Icon(dest.selectedIcon ?? dest.icon);

    if (dest.badge > 0) {
      icon = Badge.count(count: dest.badge, child: icon);
      selectedIcon = Badge.count(count: dest.badge, child: selectedIcon);
    }

    return NavigationDestination(
      icon: icon,
      selectedIcon: selectedIcon,
      label: dest.label,
    );
  }
}

// ─── Wide (medium / expanded) layout ───

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.shell,
    required this.extended,
    required this.totalWidth,
  });

  final AdaptiveShell shell;
  final bool extended;
  final double totalWidth;

  @override
  Widget build(BuildContext context) {
    final hasChild2 = shell.child2 != null;
    final hasPlaceholder = shell.emptyDetailPlaceholder != null;
    final showSecondPane = hasChild2 || hasPlaceholder;

    return Scaffold(
      appBar: shell.appBar,
      floatingActionButton: shell.floatingActionButton,
      floatingActionButtonLocation: shell.floatingActionButtonLocation,
      body: Row(
        children: [
          // ─── Navigation Rail ───
          NavigationRail(
            selectedIndex: shell.selectedIndex,
            onDestinationSelected: shell.onDestinationSelected,
            extended: extended,
            leading: shell.railLeading,
            trailing: shell.railTrailing,
            backgroundColor: shell.railBackgroundColor,
            labelType: extended
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            destinations: shell.destinations.map(_toRailDestination).toList(),
          ),

          const VerticalDivider(width: 1, thickness: 1),

          // ─── child1 (master pane) ───
          if (showSecondPane)
            SizedBox(
              width: _computeMasterWidth(),
              child: shell.child1,
            )
          else
            Expanded(child: shell.child1),

          // ─── Divider between panes ───
          if (showSecondPane && shell.showPaneDivider)
            const VerticalDivider(width: 1, thickness: 1),

          // ─── child2 or placeholder (detail pane) ───
          if (hasChild2)
            Expanded(
              child: Align(
                alignment: shell.detailAlignment,
                child: AnimatedSwitcher(
                  duration: shell.transitionDuration,
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      alignment: shell.detailAlignment,
                      children: [
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(shell.child2.hashCode),
                    child: shell.child2!,
                  ),
                ),
              ),
            )
          else if (hasPlaceholder)
            Expanded(child: shell.emptyDetailPlaceholder!),
        ],
      ),
    );
  }

  double _computeMasterWidth() {
    // Subtract approx rail width to compute available content width.
    final railWidth = extended ? 256.0 : 80.0;
    final contentWidth = totalWidth - railWidth - 2; // 2 for dividers
    final masterWidth = contentWidth * shell.breakpoints.masterRatio;
    return masterWidth.clamp(200.0, contentWidth * 0.5);
  }

  NavigationRailDestination _toRailDestination(AdaptiveDestination dest) {
    Widget icon = Icon(dest.icon);
    Widget selectedIcon = Icon(dest.selectedIcon ?? dest.icon);

    if (dest.badge > 0) {
      icon = Badge.count(count: dest.badge, child: icon);
      selectedIcon = Badge.count(count: dest.badge, child: selectedIcon);
    }

    return NavigationRailDestination(
      icon: icon,
      selectedIcon: selectedIcon,
      label: Text(dest.label),
    );
  }
}

/// Debug overlay showing current layout mode and breakpoints.
class _DebugOverlay extends StatelessWidget {
  const _DebugOverlay({
    required this.mode,
    required this.screenWidth,
    required this.breakpoints,
  });

  final LayoutMode mode;
  final double screenWidth;
  final AdaptiveBreakpoints breakpoints;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        color: Colors.black87,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getModeIcon(mode) + mode.name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Width: ${screenWidth.toInt()}dp',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
              Text(
                'Compact: < ${breakpoints.compact.toInt()}',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
              Text(
                'Medium: ${breakpoints.compact.toInt()}-${breakpoints.expanded.toInt()}',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
              Text(
                'Expanded: > ${breakpoints.expanded.toInt()}',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getModeIcon(LayoutMode mode) {
    switch (mode) {
      case LayoutMode.compact:
        return '📱 ';
      case LayoutMode.medium:
        return '📟 ';
      case LayoutMode.expanded:
        return '🖥️ ';
    }
  }
}
