import 'package:flutter/material.dart';

import 'adaptive_destination.dart';
import 'adaptive_shell.dart';
import 'breakpoints.dart';
import 'layout_mode.dart';

/// Signature for building a list item inside [AdaptiveMasterDetail].
///
/// [item] is the data item. [isSelected] is `true` when this item
/// is currently shown in the detail pane (on medium/expanded layouts).
typedef MasterItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  bool isSelected,
);

/// Signature for building the detail view for a selected item.
typedef DetailBuilder<T> = Widget Function(
  BuildContext context,
  T item,
);

/// A zero-boilerplate master-detail widget.
///
/// Provide a list of [items], an [itemBuilder] for the list, and a
/// [detailBuilder] for the detail pane — the widget handles selection
/// state, navigation (push on mobile, side-pane on tablet), and
/// responsive layout switching automatically.
///
/// This is a convenience wrapper over [AdaptiveShell]. For full control
/// over both panes, use [AdaptiveShell] directly with [child1]/[child2].
///
/// ## Example
///
/// ```dart
/// AdaptiveMasterDetail<Patient>(
///   items: patients,
///   destinations: const [
///     AdaptiveDestination(icon: Icons.people, label: 'Patients'),
///     AdaptiveDestination(icon: Icons.task, label: 'Tasks'),
///   ],
///   selectedNavIndex: _navIndex,
///   onNavSelected: (i) => setState(() => _navIndex = i),
///   itemBuilder: (context, patient, selected) => ListTile(
///     title: Text(patient.name),
///     selected: selected,
///   ),
///   detailBuilder: (context, patient) => PatientDetail(patient: patient),
/// )
/// ```
///
/// ## How navigation works internally
///
/// - **Compact** (mobile): tapping an item pushes a full-screen
///   [MaterialPageRoute] with the [detailBuilder] result wrapped
///   in a [Scaffold] + [AppBar].
/// - **Medium / Expanded** (tablet/web): tapping an item updates
///   the detail pane in place via `setState`.
///
/// ## Customization
///
/// For custom master list layouts (e.g., search bars, headers),
/// use [masterHeader] and [masterBuilder]. If [masterBuilder] is
/// provided, it replaces the default [ListView] and you must call
/// the provided `onItemTap` callback yourself.
class AdaptiveMasterDetail<T> extends StatefulWidget {
  /// Creates an adaptive master-detail widget.
  const AdaptiveMasterDetail({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.detailBuilder,
    required this.destinations,
    required this.selectedNavIndex,
    required this.onNavSelected,
    this.itemKey,
    this.initialSelection,
    this.detailAppBarTitle,
    this.masterHeader,
    this.masterBuilder,
    this.emptyDetailPlaceholder,
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
    this.compactDetailScaffoldBuilder,
  });

  /// The data items displayed in the master list.
  final List<T> items;

  /// Builds each item in the master list.
  ///
  /// [isSelected] is `true` when this item is currently shown in the
  /// detail pane. Use this to highlight the active item on tablet/web.
  ///
  /// You do NOT need to handle `onTap` — the widget wraps your result
  /// in a tap handler automatically.
  final MasterItemBuilder<T> itemBuilder;

  /// Builds the detail view for a selected item.
  ///
  /// On mobile, this is wrapped in a [Scaffold] with an [AppBar].
  /// On tablet/web, it's shown directly in the detail pane.
  final DetailBuilder<T> detailBuilder;

  /// Navigation destinations for the shell.
  final List<AdaptiveDestination> destinations;

  /// Currently selected navigation index.
  final int selectedNavIndex;

  /// Called when a navigation destination is tapped.
  final ValueChanged<int> onNavSelected;

  /// Extracts a unique key from an item for [AnimatedSwitcher] and
  /// selection tracking. Defaults to [Object.hashCode].
  final Object Function(T item)? itemKey;

  /// Called to determine the initial selection when the widget first builds.
  ///
  /// If null, no item is initially selected (placeholder shown on tablet).
  final T Function(List<T> items)? initialSelection;

  /// Title for the AppBar when detail is pushed on mobile.
  ///
  /// If null, no title is shown. Receives the selected item.
  final String Function(T item)? detailAppBarTitle;

  /// Optional header widget shown above the master list.
  final Widget? masterHeader;

  /// Optional custom builder for the entire master pane.
  ///
  /// When provided, this replaces the default [ListView]. You must
  /// call [onItemTap] when an item is tapped.
  final Widget Function(
    BuildContext context,
    List<T> items,
    T? selectedItem,
    ValueChanged<T> onItemTap,
  )? masterBuilder;

  /// Placeholder shown when no item is selected on large screens.
  final Widget? emptyDetailPlaceholder;

  /// Breakpoint configuration.
  final AdaptiveBreakpoints breakpoints;

  /// Whether to show a divider between master and detail panes.
  final bool showPaneDivider;

  /// Alignment of the detail pane content.
  ///
  /// Defaults to [Alignment.topLeft]. Set to [Alignment.center] for
  /// centered content like media viewers or placeholders.
  final AlignmentGeometry detailAlignment;

  /// Widget above rail destinations.
  final Widget? railLeading;

  /// Widget below rail destinations.
  final Widget? railTrailing;

  /// Background color for the [NavigationRail].
  final Color? railBackgroundColor;

  /// Optional [AppBar] for the entire shell.
  final PreferredSizeWidget? appBar;

  /// Animation duration for detail pane transitions.
  final Duration transitionDuration;

  /// Optional [FloatingActionButton].
  final Widget? floatingActionButton;

  /// Position of the [FloatingActionButton].
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Optional custom scaffold builder for the compact detail screen.
  ///
  /// By default, the detail view is wrapped in a plain [Scaffold] with
  /// an [AppBar] and back button.
  final Widget Function(
    BuildContext context,
    T item,
    Widget detailWidget,
  )? compactDetailScaffoldBuilder;

  @override
  State<AdaptiveMasterDetail<T>> createState() =>
      _AdaptiveMasterDetailState<T>();
}

class _AdaptiveMasterDetailState<T> extends State<AdaptiveMasterDetail<T>> {
  T? _selected;

  /// The current layout mode, computed directly from screen width via
  /// [LayoutBuilder].
  ///
  /// We compute this ourselves because [AdaptiveShell.of(context)] uses
  /// an [InheritedWidget] that lives INSIDE [AdaptiveShell]'s build tree.
  /// Our [State.context] is the PARENT of [AdaptiveShell], so it can never
  /// find that [InheritedWidget]. This would cause [_onItemTap] to always
  /// see [LayoutMode.compact] and always push a route — even on tablet.
  LayoutMode _currentMode = LayoutMode.compact;

  @override
  void initState() {
    super.initState();
    if (widget.initialSelection != null && widget.items.isNotEmpty) {
      _selected = widget.initialSelection!(widget.items);
    }
  }

  @override
  void didUpdateWidget(covariant AdaptiveMasterDetail<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clear selection if the item was removed from the list.
    if (_selected != null && !widget.items.contains(_selected)) {
      _selected = null;
    }
  }

  Object _keyOf(T item) {
    if (widget.itemKey != null) return widget.itemKey!(item);
    return item.hashCode;
  }

  LayoutMode _computeMode(double width) {
    if (width >= widget.breakpoints.expanded) return LayoutMode.expanded;
    if (width >= widget.breakpoints.compact) return LayoutMode.medium;
    return LayoutMode.compact;
  }

  /// Handles item taps using [_currentMode] (from LayoutBuilder),
  /// NOT [AdaptiveShell.of(context)].
  void _onItemTap(T item) {
    if (_currentMode == LayoutMode.compact) {
      // Mobile: push a full-screen route.
      _pushDetailRoute(item);
    } else {
      // Tablet/web/desktop: update the detail pane in place.
      setState(() => _selected = item);
    }
  }

  void _pushDetailRoute(T item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (routeContext) {
          final detailWidget = widget.detailBuilder(routeContext, item);

          if (widget.compactDetailScaffoldBuilder != null) {
            return widget.compactDetailScaffoldBuilder!(
              routeContext,
              item,
              detailWidget,
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: widget.detailAppBarTitle != null
                  ? Text(widget.detailAppBarTitle!(item))
                  : null,
            ),
            body: detailWidget,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder gives us the actual available width. We compute the
    // mode HERE so that _onItemTap (called later from a child) always
    // has the correct value. This runs on every rebuild, including
    // when the window is resized.
    return LayoutBuilder(
      builder: (layoutContext, constraints) {
        _currentMode = _computeMode(constraints.maxWidth);

        final Widget? detailPane;
        if (_selected != null) {
          detailPane = KeyedSubtree(
            key: ValueKey<Object>(_keyOf(_selected as T)),
            child: widget.detailBuilder(layoutContext, _selected as T),
          );
        } else {
          detailPane = null;
        }

        return AdaptiveShell(
          destinations: widget.destinations,
          selectedIndex: widget.selectedNavIndex,
          onDestinationSelected: widget.onNavSelected,
          breakpoints: widget.breakpoints,
          showPaneDivider: widget.showPaneDivider,
          detailAlignment: widget.detailAlignment,
          railLeading: widget.railLeading,
          railTrailing: widget.railTrailing,
          railBackgroundColor: widget.railBackgroundColor,
          appBar: widget.appBar,
          transitionDuration: widget.transitionDuration,
          floatingActionButton: widget.floatingActionButton,
          floatingActionButtonLocation: widget.floatingActionButtonLocation,
          emptyDetailPlaceholder: widget.emptyDetailPlaceholder,
          child1: _buildMasterList(),
          child2: detailPane,
        );
      },
    );
  }

  Widget _buildMasterList() {
    if (widget.masterBuilder != null) {
      return widget.masterBuilder!(
        context,
        widget.items,
        _selected,
        _onItemTap,
      );
    }

    final list = ListView.builder(
      itemCount: widget.items.length,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      itemBuilder: (listContext, index) {
        final item = widget.items[index];
        final isSelected =
            _selected != null && _keyOf(item) == _keyOf(_selected as T);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onItemTap(item),
          child: widget.itemBuilder(listContext, item, isSelected),
        );
      },
    );

    if (widget.masterHeader != null) {
      return Column(
        children: [
          widget.masterHeader!,
          Expanded(child: list),
        ],
      );
    }

    return list;
  }
}
