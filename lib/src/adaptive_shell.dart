import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  // ── AutoScale (Feature #2) ──────────────────────────────────────────────

  /// When `true`, the layout is rendered at [autoScaleDesignWidth] and
  /// then proportionally scaled to fill the real screen width — so a
  /// mobile design "just works" on every screen size without manual
  /// tweaking.
  ///
  /// **Landscape bypass:** autoScale is automatically disabled when the
  /// device is in landscape orientation (`width > height`). In that case
  /// the normal adaptive logic runs — the layout switches to a
  /// [NavigationRail] as expected — and no scale transform is applied.
  /// This prevents extreme scale values (e.g. ×2.3 on an 844 dp landscape
  /// phone) and the render overflows they cause.
  ///
  /// ```dart
  /// AdaptiveShell(autoScale: true, scaleFactor: 1.2)
  /// ```
  final bool autoScale;

  /// Multiplier applied on top of the auto-computed scale.
  ///
  /// Defaults to `1.0` (no adjustment). `1.2` makes everything 20% larger
  /// than the auto-computed scale. Only active when [autoScale] is `true`.
  final double scaleFactor;

  /// Reference canvas width (logical pixels) used when [autoScale] is on.
  ///
  /// Defaults to **360 dp** — a typical phone design-canvas width that
  /// ensures a compact (single-pane, bottom-nav) layout is used as the
  /// reference point when no explicit value is provided.
  ///
  /// Override this when your design was created for a different width:
  /// ```dart
  /// AdaptiveShell(autoScale: true, autoScaleDesignWidth: 390) // iPhone 14
  /// ```
  final double? autoScaleDesignWidth;

  // ── State Persistence (Feature #4) ────────────────────────────────────

  /// Preserves widget state (scroll positions, selections) when the device
  /// rotates, the window resizes, or the layout mode changes.
  ///
  /// Uses stable [GlobalKey]s for [child1]/[child2] so element subtrees
  /// survive compact ↔ wide transitions, and wraps the shell in a
  /// [PageStorage] bucket for scroll restoration.
  ///
  /// ```dart
  /// AdaptiveShell(persistState: true, stateKey: 'my_shell')
  /// ```
  final bool persistState;

  /// Namespace for persisted state. Defaults to `'adaptive_shell'`.
  ///
  /// Use a distinct value if you have multiple [AdaptiveShell] widgets
  /// in the same tree.
  final String? stateKey;

  // ── Animated Transitions (Feature #5) ─────────────────────────────────

  /// Curve applied to the detail-pane [AnimatedSwitcher] when [child2]
  /// changes. Defaults to [Curves.easeInOut].
  ///
  /// ```dart
  /// AdaptiveShell(transitionCurve: Curves.easeInOutCubic)
  /// ```
  final Curve? transitionCurve;

  /// When `true`, the detail pane uses a slide + fade transition instead
  /// of the default cross-fade, giving a hero-like feel as new content
  /// slides in from the right.
  ///
  /// Works together with [transitionCurve] and [transitionDuration].
  final bool enableHeroAnimations;

  // ── Pane Divider (Feature #11) ─────────────────────────────────────────

  /// Custom widget used as the divider between the master and detail panes.
  ///
  /// Replaces the default `VerticalDivider(width: 1, thickness: 1)`.
  /// Only visible when [showPaneDivider] is `true`.
  ///
  /// ```dart
  /// AdaptiveShell(
  ///   paneDivider: VerticalDivider(width: 2, color: Colors.blue),
  /// )
  /// ```
  final Widget? paneDivider;

  // ── Collapsible Rail (Feature #14) ─────────────────────────────────────

  /// When `true`, a toggle button is added above the rail destinations
  /// so the user can collapse the rail to icon-only mode at any time.
  ///
  /// ```dart
  /// AdaptiveShell(railCollapsible: true)
  /// ```
  final bool railCollapsible;

  /// Automatically collapses the rail when the layout enters medium mode.
  ///
  /// Only effective when [railCollapsible] is also `true`.
  ///
  /// ```dart
  /// AdaptiveShell(railCollapsible: true, railCollapseOnMedium: true)
  /// ```
  final bool railCollapseOnMedium;

  // ── Keyboard Shortcuts (Feature #13) ───────────────────────────────────

  /// Maps keyboard shortcuts to navigation destination indices.
  ///
  /// Any [ShortcutActivator] (e.g. [SingleActivator], [LogicalKeySet])
  /// can be used as a key. The value is the destination index to select.
  ///
  /// Only active on medium and expanded layouts (tablet / desktop).
  ///
  /// ```dart
  /// AdaptiveShell(
  ///   keyboardShortcuts: {
  ///     SingleActivator(LogicalKeyboardKey.digit1, control: true): 0,
  ///     SingleActivator(LogicalKeyboardKey.digit2, control: true): 1,
  ///   },
  /// )
  /// ```
  final Map<ShortcutActivator, int>? keyboardShortcuts;

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
    // AutoScale
    this.autoScale = false,
    this.scaleFactor = 1.0,
    this.autoScaleDesignWidth,
    // State persistence
    this.persistState = true,
    this.stateKey,
    // Animated transitions
    this.transitionCurve,
    this.enableHeroAnimations = false,
    // Pane divider
    this.paneDivider,
    // Collapsible rail
    this.railCollapsible = false,
    this.railCollapseOnMedium = false,
    // Keyboard shortcuts
    this.keyboardShortcuts,
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
  // Initialize to compact so the callback fires when first built at a
  // larger breakpoint.
  LayoutMode _previousMode = LayoutMode.compact;

  // ── Collapsible Rail ──────────────────────────────────────────────────
  bool _isRailCollapsed = false;

  // ── State Persistence ──────────────────────────────────────────────────
  // A stable GlobalKey on child1 ensures its Element (and therefore all
  // stateful descendants) survives compact ↔ wide transitions, preserving
  // scroll positions without any work from the caller.
  //
  // We intentionally do NOT apply a GlobalKey to child2 even when
  // persistState is true.  child2 lives inside AnimatedSwitcher, which
  // temporarily keeps both the outgoing and incoming child in the tree
  // during a transition.  A GlobalKey appearing in two places at once
  // causes an immediate framework assertion ("Duplicate GlobalKey").
  // child2 uses its own incoming key (e.g. ValueKey(itemId) set by
  // AdaptiveMasterDetail) to drive the AnimatedSwitcher instead.
  final GlobalKey _child1Key = GlobalKey();
  PageStorageBucket? _storageBucket;

  @override
  void initState() {
    super.initState();
    if (widget.persistState) _storageBucket = PageStorageBucket();
  }

  @override
  void didUpdateWidget(AdaptiveShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.persistState && _storageBucket == null) {
      _storageBucket = PageStorageBucket();
    } else if (!widget.persistState && _storageBucket != null) {
      _storageBucket = null;
    }
  }

  Widget get _effectiveChild1 => widget.persistState
      ? KeyedSubtree(key: _child1Key, child: widget.child1)
      : widget.child1;

  // child2 is returned as-is (no GlobalKey wrapper) — see the comment on
  // _child1Key above for the full explanation.
  Widget? get _effectiveChild2 => widget.child2;

  // ─────────────────────────────────────────────────────────────────────────
  LayoutMode _computeMode(double width) {
    if (width >= widget.breakpoints.expanded) return LayoutMode.expanded;
    if (width >= widget.breakpoints.compact) return LayoutMode.medium;
    return LayoutMode.compact;
  }

  void _notifyIfModeChanged(LayoutMode newMode) {
    if (_previousMode != newMode) {
      final oldMode = _previousMode;
      _previousMode = newMode;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onLayoutModeChanged?.call(oldMode, newMode);
        // Auto-collapse rail on medium if configured.
        if (widget.railCollapsible && widget.railCollapseOnMedium) {
          final shouldCollapse = newMode == LayoutMode.medium;
          if (shouldCollapse != _isRailCollapsed) {
            setState(() => _isRailCollapsed = shouldCollapse);
          }
        }
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
        // ── AutoScale: build at design width, then scale to real width ──
        // Default design width is 360 dp (typical phone) so the layout
        // always resolves to compact mode by default.
        //
        // LANDSCAPE BYPASS: when width > height the scale factor becomes
        // extreme (e.g. ×2.3 on an 844 dp landscape phone) and the design
        // height shrinks to ≈167 dp — far too small for a compact layout
        // with a NavigationBar.  We skip autoScale in landscape so the
        // normal adaptive logic takes over: the layout switches to a
        // NavigationRail as the user would expect, at 1:1 scale.
        const defaultDesignWidth = 360.0;
        final bool isLandscape = constraints.maxWidth > constraints.maxHeight;
        final bool applyAutoScale = widget.autoScale && !isLandscape;
        final double effectiveWidth = applyAutoScale
            ? (widget.autoScaleDesignWidth ?? defaultDesignWidth)
            : constraints.maxWidth;

        final mode = _computeMode(effectiveWidth);
        _notifyIfModeChanged(mode);

        Widget content = AdaptiveShellScope(
          layoutMode: mode,
          child: _buildLayout(context, mode, effectiveWidth),
        );

        // ── State Persistence: PageStorage for scroll restoration ────────
        if (widget.persistState && _storageBucket != null) {
          content = PageStorage(
            key: ValueKey(widget.stateKey ?? 'adaptive_shell'),
            bucket: _storageBucket!,
            child: content,
          );
        }

        // ── AutoScale: apply proportional Transform ──────────────────────
        if (applyAutoScale && constraints.maxWidth > 0) {
          final designWidth = widget.autoScaleDesignWidth ?? defaultDesignWidth;
          final scale =
              (constraints.maxWidth / designWidth) * widget.scaleFactor;
          content = ClipRect(
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              alignment: Alignment.topLeft,
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: designWidth,
                  height: constraints.maxHeight / scale,
                  child: content,
                ),
              ),
            ),
          );
        }

        // ── Debug overlay ────────────────────────────────────────────────
        if (widget.debugShowLayoutMode) {
          content = Stack(
            children: [
              content,
              _DebugOverlay(
                mode: mode,
                screenWidth: constraints.maxWidth,
                breakpoints: widget.breakpoints,
                autoScale: applyAutoScale,
                effectiveWidth: effectiveWidth,
                scaleFactor: widget.scaleFactor,
              ),
            ],
          );
        }

        // ── Keyboard shortcuts ────────────────────────────────────────────
        if (widget.keyboardShortcuts != null &&
            widget.keyboardShortcuts!.isNotEmpty &&
            mode != LayoutMode.compact) {
          content = Focus(
            autofocus: true,
            onKeyEvent: (node, event) {
              if (event is! KeyDownEvent) return KeyEventResult.ignored;
              for (final entry in widget.keyboardShortcuts!.entries) {
                if (entry.key.accepts(event, HardwareKeyboard.instance)) {
                  widget.onDestinationSelected(entry.value);
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
            child: content,
          );
        }

        return content;
      },
    );
  }

  Widget _buildLayout(BuildContext context, LayoutMode mode, double width) {
    final c1 = _effectiveChild1;
    final c2 = _effectiveChild2;
    final VoidCallback? toggleCollapse = widget.railCollapsible
        ? () => setState(() => _isRailCollapsed = !_isRailCollapsed)
        : null;
    switch (mode) {
      case LayoutMode.compact:
        return _CompactLayout(shell: widget, child1: c1);
      case LayoutMode.medium:
        return _WideLayout(
            shell: widget,
            extended: false,
            totalWidth: width,
            child1: c1,
            child2: c2,
            isRailCollapsed: _isRailCollapsed,
            onToggleRailCollapse: toggleCollapse);
      case LayoutMode.expanded:
        return _WideLayout(
            shell: widget,
            extended: true,
            totalWidth: width,
            child1: c1,
            child2: c2,
            isRailCollapsed: _isRailCollapsed,
            onToggleRailCollapse: toggleCollapse);
    }
  }
}

// ─── Compact (mobile) layout ───

class _CompactLayout extends StatelessWidget {
  const _CompactLayout({required this.shell, required this.child1});

  final AdaptiveShell shell;
  final Widget child1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: shell.appBar,
      body: child1,
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
    required this.child1,
    this.child2,
    this.isRailCollapsed = false,
    this.onToggleRailCollapse,
  });

  final AdaptiveShell shell;
  final bool extended;
  final double totalWidth;
  final Widget child1;
  final Widget? child2;
  final bool isRailCollapsed;
  final VoidCallback? onToggleRailCollapse;

  @override
  Widget build(BuildContext context) {
    final hasChild2 = child2 != null;
    final hasPlaceholder = shell.emptyDetailPlaceholder != null;
    final showSecondPane = hasChild2 || hasPlaceholder;
    final bool effectiveExtended = !isRailCollapsed && extended;

    return Scaffold(
      appBar: shell.appBar,
      floatingActionButton: shell.floatingActionButton,
      floatingActionButtonLocation: shell.floatingActionButtonLocation,
      body: Row(
        children: [
          // ─── Navigation column ───────────────────────────────────────
          // The collapse toggle lives OUTSIDE the NavigationRail so its
          // height is never added to the rail's internal Column. Putting
          // it inside NavigationRail.leading caused a RenderFlex overflow
          // on screens where (toggle height + destinations height) exceeded
          // the available viewport height.
          Column(
            children: [
              if (onToggleRailCollapse != null)
                IconButton(
                  icon: Icon(
                    isRailCollapsed
                        ? Icons.chevron_right
                        : Icons.chevron_left,
                    size: 20,
                  ),
                  tooltip: isRailCollapsed
                      ? 'Expand navigation'
                      : 'Collapse navigation',
                  onPressed: onToggleRailCollapse,
                  padding: EdgeInsets.zero,
                  // Keep the touch target compact so it doesn't eat into
                  // the rail's destination area on small screens.
                  constraints: const BoxConstraints(minHeight: 36),
                ),
              // When the collapsible toggle is shown it steals height from
              // the NavigationRail, which can push the rail's internal
              // RenderFlex past its bounds on shorter screens.
              // Fix: only wrap in a scrollable when the toggle is present.
              // LayoutBuilder measures the remaining height; then
              // SingleChildScrollView + ConstrainedBox(minHeight) +
              // IntrinsicHeight let the rail scroll when destinations
              // overflow while still centering them when they fit.
              // When railCollapsible is OFF the original Expanded(rail) path
              // is used so no extra ClipRect is injected into the tree.
              Expanded(
                child: onToggleRailCollapse != null
                    ? LayoutBuilder(
                        builder: (context, railConstraints) {
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: railConstraints.maxHeight,
                              ),
                              child: IntrinsicHeight(
                                child: NavigationRail(
                                  selectedIndex: shell.selectedIndex,
                                  onDestinationSelected:
                                      shell.onDestinationSelected,
                                  extended: effectiveExtended,
                                  leading: shell.railLeading,
                                  trailing: shell.railTrailing,
                                  backgroundColor: shell.railBackgroundColor,
                                  labelType: isRailCollapsed
                                      ? NavigationRailLabelType.none
                                      : (effectiveExtended
                                          ? NavigationRailLabelType.none
                                          : NavigationRailLabelType.all),
                                  destinations: shell.destinations
                                      .map(_toRailDestination)
                                      .toList(),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : NavigationRail(
                        selectedIndex: shell.selectedIndex,
                        onDestinationSelected: shell.onDestinationSelected,
                        extended: effectiveExtended,
                        leading: shell.railLeading,
                        trailing: shell.railTrailing,
                        backgroundColor: shell.railBackgroundColor,
                        labelType: isRailCollapsed
                            ? NavigationRailLabelType.none
                            : (effectiveExtended
                                ? NavigationRailLabelType.none
                                : NavigationRailLabelType.all),
                        destinations: shell.destinations
                            .map(_toRailDestination)
                            .toList(),
                      ),
              ),
            ],
          ),

          const VerticalDivider(width: 1, thickness: 1),

          // ─── child1 (master pane) ───
          if (showSecondPane)
            SizedBox(
              width: _computeMasterWidth(),
              child: child1,
            )
          else
            Expanded(child: child1),

          // ─── Divider between panes ───
          if (showSecondPane && shell.showPaneDivider)
            shell.paneDivider ?? const VerticalDivider(width: 1, thickness: 1),

          // ─── child2 or placeholder (detail pane) ───
          if (hasChild2)
            Expanded(
              child: Align(
                alignment: shell.detailAlignment,
                  child: AnimatedSwitcher(
                  key: const ValueKey('_detail_pane_switcher'),
                  duration: shell.transitionDuration,
                  switchInCurve: shell.transitionCurve ?? Curves.easeInOut,
                  switchOutCurve:
                      (shell.transitionCurve ?? Curves.easeInOut).flipped,
                  transitionBuilder: shell.enableHeroAnimations
                      ? _heroTransitionBuilder
                      : AnimatedSwitcher.defaultTransitionBuilder,
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      alignment: shell.detailAlignment,
                      children: [
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
                  // Use child2 directly so AnimatedSwitcher relies on its
                  // own key (e.g. ValueKey(itemId) from AdaptiveMasterDetail)
                  // to decide when to animate.  The old
                  // KeyedSubtree(key: ValueKey(child2.hashCode)) wrapper was
                  // wrong on two counts: hashCode changed every frame
                  // (triggering animation on every build), and it placed a
                  // GlobalKey inside AnimatedSwitcher's transition pool,
                  // causing the "Duplicate GlobalKey" crash.
                  child: child2!,
                ),
              ),
            )
          else if (hasPlaceholder)
            Expanded(child: shell.emptyDetailPlaceholder!),
        ],
      ),
    );
  }

  /// Slide + fade transition used when [AdaptiveShell.enableHeroAnimations]
  /// is `true`. The incoming child slides in from the right while fading in.
  Widget _heroTransitionBuilder(Widget child, Animation<double> animation) {
    final curve = shell.transitionCurve ?? Curves.easeInOut;
    final curved = CurvedAnimation(parent: animation, curve: curve);
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.05, 0.0),
        end: Offset.zero,
      ).animate(curved),
      child: FadeTransition(opacity: curved, child: child),
    );
  }

  double _computeMasterWidth() {
    // Subtract approx rail width to compute available content width.
    final bool effectiveExtended = !isRailCollapsed && extended;
    final railWidth = effectiveExtended ? 256.0 : 80.0;
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
    this.autoScale = false,
    this.effectiveWidth,
    this.scaleFactor = 1.0,
  });

  final LayoutMode mode;
  final double screenWidth;
  final AdaptiveBreakpoints breakpoints;
  final bool autoScale;
  final double? effectiveWidth;
  final double scaleFactor;

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
              if (autoScale) ...[
                Text(
                  '⚖️ Scale ×${((screenWidth / (effectiveWidth ?? screenWidth)) * scaleFactor).toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.amber, fontSize: 10),
                ),
                Text(
                  'Design: ${(effectiveWidth ?? screenWidth).toInt()}dp',
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
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
