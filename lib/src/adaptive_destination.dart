import 'package:flutter/widgets.dart';

/// Signature for a builder that returns an icon widget based on selection
/// state. Used by [AdaptiveDestination.iconBuilder].
///
/// [context] gives access to [Theme], [MediaQuery], and other inherited
/// widgets — useful for SVG color-filter driven by the active color scheme:
///
/// ```dart
/// iconBuilder: (context, isSelected) => SvgPicture.asset(
///   'assets/home.svg',
///   colorFilter: ColorFilter.mode(
///     isSelected
///       ? Theme.of(context).colorScheme.primary
///       : Theme.of(context).colorScheme.onSurfaceVariant,
///     BlendMode.srcIn,
///   ),
/// ),
/// ```
typedef AdaptiveIconBuilder = Widget Function(
    BuildContext context, bool isSelected);

/// A navigation destination used by [AdaptiveShell].
///
/// Automatically maps to [NavigationDestination] (bottom bar on compact)
/// and [NavigationRailDestination] (rail on medium/expanded).
///
/// ## Icon options (pick one)
///
/// | Option | Best for |
/// |---|---|
/// | `icon: Icons.home` | Material icons — quick and simple |
/// | `iconWidget: SvgPicture.asset(...)` | Static SVG / PNG |
/// | `iconBuilder: (ctx, sel) => ...` | SVG/PNG that changes per selection state |
///
/// ## Examples
///
/// ```dart
/// // Classic — fully backward compatible with v1.x
/// const AdaptiveDestination(
///   icon: Icons.people_outline,
///   selectedIcon: Icons.people,
///   label: 'Patients',
///   badge: 3,
/// )
///
/// // Widget icon (SVG / PNG / any widget)
/// AdaptiveDestination(
///   iconWidget: SvgPicture.asset('assets/home.svg'),
///   selectedIconWidget: SvgPicture.asset('assets/home_filled.svg'),
///   label: 'Home',
/// )
///
/// // Builder — ideal for SVG that needs theme-driven color
/// AdaptiveDestination(
///   iconBuilder: (context, isSelected) => SvgPicture.asset(
///     'assets/home.svg',
///     colorFilter: ColorFilter.mode(
///       isSelected
///         ? Theme.of(context).colorScheme.primary
///         : Theme.of(context).colorScheme.onSurfaceVariant,
///       BlendMode.srcIn,
///     ),
///   ),
///   label: 'Home',
/// )
/// ```
class AdaptiveDestination {
  /// Creates a navigation destination.
  ///
  /// At least one of [icon], [iconWidget], or [iconBuilder] must be provided.
  const AdaptiveDestination({
    this.icon,
    this.selectedIcon,
    required this.label,
    this.badge = 0,
    this.badgeLabel,
    this.iconWidget,
    this.selectedIconWidget,
    this.iconBuilder,
    this.iconSize,
    this.tooltip,
    this.enabled = true,
  }) : assert(
          icon != null || iconWidget != null || iconBuilder != null,
          'AdaptiveDestination requires at least one of: icon (IconData), '
          'iconWidget (Widget), or iconBuilder.',
        );

  // ── Icon fields ────────────────────────────────────────────────────────────

  /// The [IconData] displayed when this destination is **not** selected.
  ///
  /// Classic API — fully backward compatible with v1.x:
  /// ```dart
  /// const AdaptiveDestination(icon: Icons.people_outline, label: 'Patients')
  /// ```
  /// Omit when using [iconWidget] or [iconBuilder].
  final IconData? icon;

  /// The [IconData] displayed when this destination is **selected**.
  ///
  /// Falls back to [icon] when null. Ignored when [iconBuilder] or
  /// [selectedIconWidget] are set.
  final IconData? selectedIcon;

  /// A custom [Widget] icon for the **unselected** state.
  ///
  /// Use this for SVG, PNG, or any widget. You are responsible for
  /// sizing and coloring — the widget is used as-is.
  /// Overrides [icon] when set.
  final Widget? iconWidget;

  /// A custom [Widget] icon for the **selected** state.
  ///
  /// Falls back to [iconWidget] when null.
  final Widget? selectedIconWidget;

  /// Builder that returns the icon widget based on [isSelected].
  ///
  /// The **recommended option for SVG/PNG** — receives [BuildContext] so you
  /// can read `Theme.of(context)` for dynamic colors. Takes priority over
  /// [iconWidget] and [icon] when non-null.
  final AdaptiveIconBuilder? iconBuilder;

  /// When non-null, wraps the resolved icon in
  /// `SizedBox(width: iconSize, height: iconSize)`.
  ///
  /// Useful for ensuring consistent icon dimensions with SVG/PNG assets.
  final double? iconSize;

  // ── Label / badge / meta ───────────────────────────────────────────────────

  /// The text label for this destination.
  final String label;

  /// Badge count shown on the icon when > 0.
  ///
  /// Ignored when [badgeLabel] is set. Defaults to `0` (no badge).
  final int badge;

  /// Flexible badge text. Takes priority over [badge] when non-null.
  ///
  /// - `""` → dot badge
  /// - `"NEW"` → text badge
  /// - `"99+"` → overflow text
  final String? badgeLabel;

  /// Tooltip shown on hover / long-press.
  ///
  /// Forwarded to [NavigationDestination.tooltip]. Defaults to [label].
  final String? tooltip;

  /// Whether this destination is interactive. Defaults to `true`.
  ///
  /// When `false`:
  /// - [NavigationBar] uses native [NavigationDestination.enabled].
  /// - [NavigationRail] dims the icon and silently ignores taps.
  final bool enabled;
}
