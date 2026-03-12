import 'package:flutter/widgets.dart';

/// A navigation destination used by [AdaptiveShell].
///
/// Automatically maps to [NavigationDestination] (bottom bar on compact)
/// and [NavigationRailDestination] (rail on medium/expanded).
///
/// ```dart
/// const AdaptiveDestination(
///   icon: Icons.people_outline,
///   selectedIcon: Icons.people,
///   label: 'Patients',
///   badge: 3,
/// )
/// ```
class AdaptiveDestination {
  /// Creates a navigation destination.
  const AdaptiveDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.badge = 0,
  });

  /// The icon displayed when this destination is not selected.
  final IconData icon;

  /// The icon displayed when this destination is selected.
  ///
  /// Falls back to [icon] if null.
  final IconData? selectedIcon;

  /// The text label for this destination.
  final String label;

  /// An optional badge count displayed on the icon.
  ///
  /// When greater than 0, a [Badge] is shown. Defaults to 0 (no badge).
  final int badge;
}
