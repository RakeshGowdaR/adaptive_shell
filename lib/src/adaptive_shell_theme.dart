import 'dart:ui';

import 'package:flutter/material.dart';

/// Visual theme for [AdaptiveShell]'s navigation chrome.
///
/// Pass an [AdaptiveShellTheme] to [AdaptiveShell.theme] to fully
/// customise the [NavigationBar] (compact mode) and [NavigationRail]
/// (medium/expanded mode) without touching [ThemeData].
///
/// All fields are optional — `null` means "inherit from [ThemeData]".
///
/// ```dart
/// AdaptiveShell(
///   theme: const AdaptiveShellTheme(
///     railMinExtendedWidth: 180,
///     railBackgroundColor: Color(0xFFF8F9FA),
///     railIndicatorColor: Color(0xFFD0BCFF),
///     navBarIndicatorColor: Color(0xFFD0BCFF),
///     navBarLabelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
///   ),
/// )
/// ```
class AdaptiveShellTheme {
  /// Creates an adaptive shell theme.
  ///
  /// All fields default to `null` (inherits from [ThemeData]) unless
  /// a concrete default is listed.
  const AdaptiveShellTheme({
    this.railMinWidth = 72.0,
    this.railMinExtendedWidth = 160.0,
    this.railBackgroundColor,
    this.railElevation,
    this.railGroupAlignment,
    this.railIndicatorColor,
    this.railIndicatorShape,
    this.railSelectedIconTheme,
    this.railUnselectedIconTheme,
    this.railSelectedLabelStyle,
    this.railUnselectedLabelStyle,
    this.railLabelType,
    this.railDecoration,
    this.navBarHeight,
    this.navBarBackgroundColor,
    this.navBarElevation,
    this.navBarShadowColor,
    this.navBarSurfaceTintColor,
    this.navBarIndicatorColor,
    this.navBarIndicatorShape,
    this.navBarLabelBehavior,
    this.navBarSelectedIconTheme,
    this.navBarUnselectedIconTheme,
    this.navBarSelectedLabelStyle,
    this.navBarUnselectedLabelStyle,
    this.disabledOpacity = 0.38,
  });

  // ── Navigation Rail ────────────────────────────────────────────────────────

  /// Minimum width of the icon-only (collapsed) rail.
  ///
  /// Defaults to `72.0`.
  final double railMinWidth;

  /// Minimum width of the extended (labeled) rail.
  ///
  /// Defaults to `160.0` — tighter than Flutter's built-in `256` default.
  /// Increase this for longer destination labels:
  /// ```dart
  /// AdaptiveShellTheme(railMinExtendedWidth: 200)
  /// ```
  final double railMinExtendedWidth;

  /// Background color for the [NavigationRail].
  final Color? railBackgroundColor;

  /// Elevation for the [NavigationRail].
  final double? railElevation;

  /// Vertical alignment of destinations within the rail.
  ///
  /// `-1.0` = top (default in Flutter), `0.0` = center, `1.0` = bottom.
  final double? railGroupAlignment;

  /// Color of the selection-indicator pill on the rail.
  final Color? railIndicatorColor;

  /// Shape of the selection-indicator pill on the rail.
  final ShapeBorder? railIndicatorShape;

  /// Icon theme applied to the **selected** rail destination.
  final IconThemeData? railSelectedIconTheme;

  /// Icon theme applied to **unselected** rail destinations.
  final IconThemeData? railUnselectedIconTheme;

  /// Text style for the **selected** rail destination label.
  final TextStyle? railSelectedLabelStyle;

  /// Text style for **unselected** rail destination labels.
  final TextStyle? railUnselectedLabelStyle;

  /// Label display mode for the rail.
  ///
  /// When `null`, the shell sets this automatically:
  /// - expanded mode   → [NavigationRailLabelType.none] (labels inline)
  /// - medium mode     → [NavigationRailLabelType.all]  (labels below icons)
  /// - collapsed state → [NavigationRailLabelType.none]
  final NavigationRailLabelType? railLabelType;

  /// Optional [BoxDecoration] applied to the entire rail column.
  ///
  /// Use this to add a right-side border, drop shadow, or a gradient
  /// background:
  /// ```dart
  /// AdaptiveShellTheme(
  ///   railDecoration: BoxDecoration(
  ///     border: Border(
  ///       right: BorderSide(color: Color(0xFFE0E0E0)),
  ///     ),
  ///   ),
  /// )
  /// ```
  final BoxDecoration? railDecoration;

  // ── Navigation Bar ─────────────────────────────────────────────────────────

  /// Height of the compact [NavigationBar].
  final double? navBarHeight;

  /// Background color of the compact [NavigationBar].
  final Color? navBarBackgroundColor;

  /// Elevation of the compact [NavigationBar].
  final double? navBarElevation;

  /// Shadow color of the compact [NavigationBar].
  final Color? navBarShadowColor;

  /// Surface tint color of the compact [NavigationBar].
  final Color? navBarSurfaceTintColor;

  /// Indicator color for the selected destination in the [NavigationBar].
  final Color? navBarIndicatorColor;

  /// Indicator shape for the selected destination in the [NavigationBar].
  final ShapeBorder? navBarIndicatorShape;

  /// Label behavior of the [NavigationBar].
  final NavigationDestinationLabelBehavior? navBarLabelBehavior;

  /// Icon theme for the **selected** destination in the [NavigationBar].
  final IconThemeData? navBarSelectedIconTheme;

  /// Icon theme for **unselected** destinations in the [NavigationBar].
  final IconThemeData? navBarUnselectedIconTheme;

  /// Text style for the **selected** destination label in the [NavigationBar].
  final TextStyle? navBarSelectedLabelStyle;

  /// Text style for **unselected** destination labels in the [NavigationBar].
  final TextStyle? navBarUnselectedLabelStyle;

  // ── Disabled ───────────────────────────────────────────────────────────────

  /// Opacity applied to disabled [NavigationRail] destinations.
  ///
  /// Matches Material 3's disabled-content alpha. Defaults to `0.38`.
  ///
  /// Note: [NavigationBar] destinations use the native
  /// [NavigationDestination.enabled] flag instead of this opacity.
  final double disabledOpacity;

  // ── copyWith ───────────────────────────────────────────────────────────────

  /// Returns a copy of this theme with the given fields replaced.
  AdaptiveShellTheme copyWith({
    double? railMinWidth,
    double? railMinExtendedWidth,
    Color? railBackgroundColor,
    double? railElevation,
    double? railGroupAlignment,
    Color? railIndicatorColor,
    ShapeBorder? railIndicatorShape,
    IconThemeData? railSelectedIconTheme,
    IconThemeData? railUnselectedIconTheme,
    TextStyle? railSelectedLabelStyle,
    TextStyle? railUnselectedLabelStyle,
    NavigationRailLabelType? railLabelType,
    BoxDecoration? railDecoration,
    double? navBarHeight,
    Color? navBarBackgroundColor,
    double? navBarElevation,
    Color? navBarShadowColor,
    Color? navBarSurfaceTintColor,
    Color? navBarIndicatorColor,
    ShapeBorder? navBarIndicatorShape,
    NavigationDestinationLabelBehavior? navBarLabelBehavior,
    IconThemeData? navBarSelectedIconTheme,
    IconThemeData? navBarUnselectedIconTheme,
    TextStyle? navBarSelectedLabelStyle,
    TextStyle? navBarUnselectedLabelStyle,
    double? disabledOpacity,
  }) {
    return AdaptiveShellTheme(
      railMinWidth: railMinWidth ?? this.railMinWidth,
      railMinExtendedWidth: railMinExtendedWidth ?? this.railMinExtendedWidth,
      railBackgroundColor: railBackgroundColor ?? this.railBackgroundColor,
      railElevation: railElevation ?? this.railElevation,
      railGroupAlignment: railGroupAlignment ?? this.railGroupAlignment,
      railIndicatorColor: railIndicatorColor ?? this.railIndicatorColor,
      railIndicatorShape: railIndicatorShape ?? this.railIndicatorShape,
      railSelectedIconTheme:
          railSelectedIconTheme ?? this.railSelectedIconTheme,
      railUnselectedIconTheme:
          railUnselectedIconTheme ?? this.railUnselectedIconTheme,
      railSelectedLabelStyle:
          railSelectedLabelStyle ?? this.railSelectedLabelStyle,
      railUnselectedLabelStyle:
          railUnselectedLabelStyle ?? this.railUnselectedLabelStyle,
      railLabelType: railLabelType ?? this.railLabelType,
      railDecoration: railDecoration ?? this.railDecoration,
      navBarHeight: navBarHeight ?? this.navBarHeight,
      navBarBackgroundColor:
          navBarBackgroundColor ?? this.navBarBackgroundColor,
      navBarElevation: navBarElevation ?? this.navBarElevation,
      navBarShadowColor: navBarShadowColor ?? this.navBarShadowColor,
      navBarSurfaceTintColor:
          navBarSurfaceTintColor ?? this.navBarSurfaceTintColor,
      navBarIndicatorColor: navBarIndicatorColor ?? this.navBarIndicatorColor,
      navBarIndicatorShape: navBarIndicatorShape ?? this.navBarIndicatorShape,
      navBarLabelBehavior: navBarLabelBehavior ?? this.navBarLabelBehavior,
      navBarSelectedIconTheme:
          navBarSelectedIconTheme ?? this.navBarSelectedIconTheme,
      navBarUnselectedIconTheme:
          navBarUnselectedIconTheme ?? this.navBarUnselectedIconTheme,
      navBarSelectedLabelStyle:
          navBarSelectedLabelStyle ?? this.navBarSelectedLabelStyle,
      navBarUnselectedLabelStyle:
          navBarUnselectedLabelStyle ?? this.navBarUnselectedLabelStyle,
      disabledOpacity: disabledOpacity ?? this.disabledOpacity,
    );
  }

  // ── lerp ──────────────────────────────────────────────────────────────────

  /// Linearly interpolates between two [AdaptiveShellTheme]s.
  static AdaptiveShellTheme lerp(
      AdaptiveShellTheme? a, AdaptiveShellTheme? b, double t) {
    if (a == null && b == null) return const AdaptiveShellTheme();
    if (a == null) return b!;
    if (b == null) return a;
    return AdaptiveShellTheme(
      railMinWidth: lerpDouble(a.railMinWidth, b.railMinWidth, t)!,
      railMinExtendedWidth:
          lerpDouble(a.railMinExtendedWidth, b.railMinExtendedWidth, t)!,
      railBackgroundColor:
          Color.lerp(a.railBackgroundColor, b.railBackgroundColor, t),
      railElevation: lerpDouble(a.railElevation, b.railElevation, t),
      railGroupAlignment:
          lerpDouble(a.railGroupAlignment, b.railGroupAlignment, t),
      railIndicatorColor:
          Color.lerp(a.railIndicatorColor, b.railIndicatorColor, t),
      railIndicatorShape:
          ShapeBorder.lerp(a.railIndicatorShape, b.railIndicatorShape, t),
      railSelectedIconTheme: IconThemeData.lerp(
        a.railSelectedIconTheme ?? const IconThemeData(),
        b.railSelectedIconTheme ?? const IconThemeData(),
        t,
      ),
      railUnselectedIconTheme: IconThemeData.lerp(
        a.railUnselectedIconTheme ?? const IconThemeData(),
        b.railUnselectedIconTheme ?? const IconThemeData(),
        t,
      ),
      railSelectedLabelStyle:
          TextStyle.lerp(a.railSelectedLabelStyle, b.railSelectedLabelStyle, t),
      railUnselectedLabelStyle: TextStyle.lerp(
          a.railUnselectedLabelStyle, b.railUnselectedLabelStyle, t),
      railLabelType: t < 0.5 ? a.railLabelType : b.railLabelType,
      railDecoration:
          BoxDecoration.lerp(a.railDecoration, b.railDecoration, t),
      navBarHeight: lerpDouble(a.navBarHeight, b.navBarHeight, t),
      navBarBackgroundColor:
          Color.lerp(a.navBarBackgroundColor, b.navBarBackgroundColor, t),
      navBarElevation: lerpDouble(a.navBarElevation, b.navBarElevation, t),
      navBarShadowColor:
          Color.lerp(a.navBarShadowColor, b.navBarShadowColor, t),
      navBarSurfaceTintColor:
          Color.lerp(a.navBarSurfaceTintColor, b.navBarSurfaceTintColor, t),
      navBarIndicatorColor:
          Color.lerp(a.navBarIndicatorColor, b.navBarIndicatorColor, t),
      navBarIndicatorShape:
          ShapeBorder.lerp(a.navBarIndicatorShape, b.navBarIndicatorShape, t),
      navBarLabelBehavior:
          t < 0.5 ? a.navBarLabelBehavior : b.navBarLabelBehavior,
      navBarSelectedIconTheme: IconThemeData.lerp(
        a.navBarSelectedIconTheme ?? const IconThemeData(),
        b.navBarSelectedIconTheme ?? const IconThemeData(),
        t,
      ),
      navBarUnselectedIconTheme: IconThemeData.lerp(
        a.navBarUnselectedIconTheme ?? const IconThemeData(),
        b.navBarUnselectedIconTheme ?? const IconThemeData(),
        t,
      ),
      navBarSelectedLabelStyle: TextStyle.lerp(
          a.navBarSelectedLabelStyle, b.navBarSelectedLabelStyle, t),
      navBarUnselectedLabelStyle: TextStyle.lerp(
          a.navBarUnselectedLabelStyle, b.navBarUnselectedLabelStyle, t),
      disabledOpacity:
          lerpDouble(a.disabledOpacity, b.disabledOpacity, t)!,
    );
  }
}

