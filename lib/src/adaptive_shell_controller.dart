import 'package:flutter/foundation.dart';
/// Programmatic controller for [AdaptiveShell]'s navigation rail.
///
/// Pass an [AdaptiveShellController] to [AdaptiveShell.controller] to
/// collapse/expand the rail from anywhere in your widget tree — an AppBar
/// action, a FAB, a drawer — without prop-drilling.
///
/// The controller only manages **rail collapse state**. The selected
/// navigation index is still driven by [AdaptiveShell.selectedIndex] and
/// [AdaptiveShell.onDestinationSelected] (your own `setState`) so there is
/// no double-update risk.
///
/// ## Usage
///
/// ```dart
/// class _MyState extends State<MyScreen> {
///   final _navController = AdaptiveShellController();
///
///   @override
///   void dispose() {
///     _navController.dispose(); // caller owns lifecycle
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return AdaptiveShell(
///       controller: _navController,
///       // ...
///     );
///   }
/// }
///
/// // From an AppBar action:
/// IconButton(
///   icon: const Icon(Icons.menu),
///   onPressed: _navController.toggleRail,
/// )
/// ```
class AdaptiveShellController extends ChangeNotifier {
  /// Creates an [AdaptiveShellController].
  ///
  /// [initiallyCollapsed] sets the starting collapsed state of the rail.
  AdaptiveShellController({bool initiallyCollapsed = false})
      : _isRailCollapsed = initiallyCollapsed;

  bool _isRailCollapsed;
  bool _disposed = false;

  /// Whether the navigation rail is currently collapsed (icon-only).
  bool get isRailCollapsed => _isRailCollapsed;

  /// `true` after [dispose] has been called.
  ///
  /// Only meaningful inside debug-mode asserts — do not use in production logic.
  bool get debugDisposed => _disposed;

  /// Collapses the navigation rail to icon-only mode.
  ///
  /// Has no effect if the rail is already collapsed.
  void collapseRail() {
    _assertNotDisposed();
    if (!_isRailCollapsed) {
      _isRailCollapsed = true;
      notifyListeners();
    }
  }

  /// Expands the navigation rail to show labels.
  ///
  /// Has no effect if the rail is already expanded.
  void expandRail() {
    _assertNotDisposed();
    if (_isRailCollapsed) {
      _isRailCollapsed = false;
      notifyListeners();
    }
  }

  /// Toggles the navigation rail between collapsed and expanded.
  void toggleRail() {
    _assertNotDisposed();
    _isRailCollapsed = !_isRailCollapsed;
    notifyListeners();
  }

  void _assertNotDisposed() {
    assert(
      !_disposed,
      'AdaptiveShellController was used after dispose().\n'
      'Call dispose() only when the controller is no longer needed.',
    );
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

