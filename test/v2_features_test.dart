// Tests for features added in v2.0.0:
//   • AdaptiveShellTheme     — rail + nav-bar visual properties
//   • AdaptiveShellController — programmatic rail collapse/expand
//   • AdaptiveDestination v2 — widget icons, iconBuilder, enabled,
//                              badgeLabel, tooltip, iconSize
//   • Custom nav builders    — navigationBarBuilder / navigationRailBuilder
//   • Tight rail width       — minExtendedWidth default 160 dp

import 'package:adaptive_shell/adaptive_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── Shared helpers ───────────────────────────────────────────────────────────

const _dest = [
  AdaptiveDestination(icon: Icons.home, label: 'Home'),
  AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
];

void _setSize(WidgetTester t, double w, double h) {
  t.view.physicalSize = Size(w, h);
  t.view.devicePixelRatio = 1.0;
}

Widget _app(Widget child) => MaterialApp(home: child);

// ═════════════════════════════════════════════════════════════════════════════
// AdaptiveShellTheme — data class
// ═════════════════════════════════════════════════════════════════════════════

void main() {
  // ── AdaptiveShellTheme unit tests ──────────────────────────────────────────

  group('AdaptiveShellTheme', () {
    test('default values are correct', () {
      const t = AdaptiveShellTheme();
      expect(t.railMinWidth, 72.0);
      expect(t.railMinExtendedWidth, 160.0);
      expect(t.disabledOpacity, 0.38);
      expect(t.railBackgroundColor, isNull);
      expect(t.navBarHeight, isNull);
      expect(t.railDecoration, isNull);
    });

    test('copyWith replaces only supplied fields', () {
      const original = AdaptiveShellTheme(
        railMinWidth: 72.0,
        railMinExtendedWidth: 160.0,
        disabledOpacity: 0.38,
      );
      final copy = original.copyWith(
        railMinExtendedWidth: 200.0,
        railBackgroundColor: Colors.blue,
      );

      expect(copy.railMinWidth, 72.0); // unchanged
      expect(copy.railMinExtendedWidth, 200.0); // changed
      expect(copy.railBackgroundColor, Colors.blue); // changed
      expect(copy.disabledOpacity, 0.38); // unchanged
    });

    test('copyWith with no args returns identical values', () {
      const t = AdaptiveShellTheme(
        railMinWidth: 80.0,
        railMinExtendedWidth: 180.0,
        disabledOpacity: 0.5,
      );
      final copy = t.copyWith();
      expect(copy.railMinWidth, t.railMinWidth);
      expect(copy.railMinExtendedWidth, t.railMinExtendedWidth);
      expect(copy.disabledOpacity, t.disabledOpacity);
    });

    test('lerp returns a when t=0', () {
      const a = AdaptiveShellTheme(railMinWidth: 72.0);
      const b = AdaptiveShellTheme(railMinWidth: 120.0);
      final result = AdaptiveShellTheme.lerp(a, b, 0.0);
      expect(result.railMinWidth, 72.0);
    });

    test('lerp returns b when t=1', () {
      const a = AdaptiveShellTheme(railMinWidth: 72.0);
      const b = AdaptiveShellTheme(railMinWidth: 120.0);
      final result = AdaptiveShellTheme.lerp(a, b, 1.0);
      expect(result.railMinWidth, 120.0);
    });

    test('lerp interpolates railMinWidth at t=0.5', () {
      const a = AdaptiveShellTheme(railMinWidth: 0.0);
      const b = AdaptiveShellTheme(railMinWidth: 100.0);
      final result = AdaptiveShellTheme.lerp(a, b, 0.5);
      expect(result.railMinWidth, closeTo(50.0, 0.01));
    });

    test('lerp interpolates railMinExtendedWidth', () {
      const a = AdaptiveShellTheme(railMinExtendedWidth: 160.0);
      const b = AdaptiveShellTheme(railMinExtendedWidth: 256.0);
      final result = AdaptiveShellTheme.lerp(a, b, 0.5);
      expect(result.railMinExtendedWidth, closeTo(208.0, 0.01));
    });

    test('lerp with null a returns b', () {
      const b = AdaptiveShellTheme(railMinWidth: 80.0);
      final result = AdaptiveShellTheme.lerp(null, b, 0.7);
      expect(result.railMinWidth, 80.0);
    });

    test('lerp with null b returns a', () {
      const a = AdaptiveShellTheme(railMinWidth: 80.0);
      final result = AdaptiveShellTheme.lerp(a, null, 0.7);
      expect(result.railMinWidth, 80.0);
    });

    test('lerp with both null returns default theme', () {
      final result = AdaptiveShellTheme.lerp(null, null, 0.5);
      expect(result.railMinWidth, 72.0);
      expect(result.railMinExtendedWidth, 160.0);
    });

    test('lerp interpolates Color fields', () {
      final a = AdaptiveShellTheme(railBackgroundColor: Colors.blue);
      final b = AdaptiveShellTheme(railBackgroundColor: Colors.red);
      final result = AdaptiveShellTheme.lerp(a, b, 0.5);
      expect(result.railBackgroundColor, isNotNull);
    });

    test('lerp picks a for railLabelType at t<0.5', () {
      final a = AdaptiveShellTheme(
          railLabelType: NavigationRailLabelType.all);
      final b = AdaptiveShellTheme(
          railLabelType: NavigationRailLabelType.none);
      expect(
          AdaptiveShellTheme.lerp(a, b, 0.4).railLabelType,
          NavigationRailLabelType.all);
    });

    test('lerp picks b for railLabelType at t>=0.5', () {
      final a = AdaptiveShellTheme(
          railLabelType: NavigationRailLabelType.all);
      final b = AdaptiveShellTheme(
          railLabelType: NavigationRailLabelType.none);
      expect(
          AdaptiveShellTheme.lerp(a, b, 0.5).railLabelType,
          NavigationRailLabelType.none);
    });
  });

  // ── AdaptiveShellController unit tests ─────────────────────────────────────

  group('AdaptiveShellController', () {
    test('initiallyCollapsed:false → isRailCollapsed is false', () {
      final c = AdaptiveShellController();
      expect(c.isRailCollapsed, isFalse);
      c.dispose();
    });

    test('initiallyCollapsed:true → isRailCollapsed is true', () {
      final c = AdaptiveShellController(initiallyCollapsed: true);
      expect(c.isRailCollapsed, isTrue);
      c.dispose();
    });

    test('collapseRail sets isRailCollapsed to true', () {
      final c = AdaptiveShellController();
      c.collapseRail();
      expect(c.isRailCollapsed, isTrue);
      c.dispose();
    });

    test('expandRail sets isRailCollapsed to false', () {
      final c = AdaptiveShellController(initiallyCollapsed: true);
      c.expandRail();
      expect(c.isRailCollapsed, isFalse);
      c.dispose();
    });

    test('toggleRail flips state each call', () {
      final c = AdaptiveShellController();
      expect(c.isRailCollapsed, isFalse);
      c.toggleRail();
      expect(c.isRailCollapsed, isTrue);
      c.toggleRail();
      expect(c.isRailCollapsed, isFalse);
      c.dispose();
    });

    test('collapseRail is idempotent when already collapsed', () {
      final c = AdaptiveShellController(initiallyCollapsed: true);
      int notifications = 0;
      c.addListener(() => notifications++);
      c.collapseRail(); // already collapsed — should not notify
      expect(notifications, 0);
      c.dispose();
    });

    test('expandRail is idempotent when already expanded', () {
      final c = AdaptiveShellController();
      int notifications = 0;
      c.addListener(() => notifications++);
      c.expandRail(); // already expanded — should not notify
      expect(notifications, 0);
      c.dispose();
    });

    test('notifies listeners on collapseRail', () {
      final c = AdaptiveShellController();
      int notifications = 0;
      c.addListener(() => notifications++);
      c.collapseRail();
      expect(notifications, 1);
      c.dispose();
    });

    test('notifies listeners on toggleRail', () {
      final c = AdaptiveShellController();
      int notifications = 0;
      c.addListener(() => notifications++);
      c.toggleRail();
      expect(notifications, 1);
      c.dispose();
    });

    test('debugDisposed is false before dispose', () {
      final c = AdaptiveShellController();
      expect(c.debugDisposed, isFalse);
      c.dispose();
    });

    test('debugDisposed is true after dispose', () {
      final c = AdaptiveShellController();
      c.dispose();
      expect(c.debugDisposed, isTrue);
    });

    test('assert fires in debug mode when used after dispose', () {
      final c = AdaptiveShellController();
      c.dispose();
      expect(
        () => c.collapseRail(),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  // ── AdaptiveDestination — new fields ──────────────────────────────────────

  group('AdaptiveDestination', () {
    test('classic icon: IconData still constructs', () {
      const d = AdaptiveDestination(icon: Icons.home, label: 'Home');
      expect(d.icon, Icons.home);
      expect(d.label, 'Home');
      expect(d.enabled, isTrue);
      expect(d.badge, 0);
      expect(d.badgeLabel, isNull);
      expect(d.tooltip, isNull);
      expect(d.iconSize, isNull);
      expect(d.iconWidget, isNull);
      expect(d.iconBuilder, isNull);
    });

    test('iconWidget constructors set fields correctly', () {
      final icon = Container(color: Colors.red);
      final selected = Container(color: Colors.blue);
      final d = AdaptiveDestination(
        iconWidget: icon,
        selectedIconWidget: selected,
        label: 'Test',
      );
      expect(d.iconWidget, same(icon));
      expect(d.selectedIconWidget, same(selected));
      expect(d.icon, isNull);
    });

    test('iconBuilder field is stored', () {
      Widget builder(BuildContext ctx, bool sel) => const Icon(Icons.home);
      final d = AdaptiveDestination(iconBuilder: builder, label: 'Test');
      expect(d.iconBuilder, same(builder));
    });

    test('enabled defaults to true', () {
      const d = AdaptiveDestination(icon: Icons.home, label: 'Home');
      expect(d.enabled, isTrue);
    });

    test('enabled can be set to false', () {
      const d = AdaptiveDestination(
          icon: Icons.lock, label: 'Admin', enabled: false);
      expect(d.enabled, isFalse);
    });

    test('badgeLabel stored correctly', () {
      const d = AdaptiveDestination(
          icon: Icons.notifications, label: 'Alerts', badgeLabel: 'NEW');
      expect(d.badgeLabel, 'NEW');
    });

    test('empty badgeLabel (dot badge) stored correctly', () {
      const d = AdaptiveDestination(
          icon: Icons.circle, label: 'Test', badgeLabel: '');
      expect(d.badgeLabel, '');
    });

    test('tooltip stored correctly', () {
      const d = AdaptiveDestination(
          icon: Icons.home, label: 'Home', tooltip: 'Go home');
      expect(d.tooltip, 'Go home');
    });

    test('iconSize stored correctly', () {
      final d = AdaptiveDestination(
          iconWidget: const Icon(Icons.home), label: 'Home', iconSize: 24.0);
      expect(d.iconSize, 24.0);
    });

    test('assert fires when none of icon/iconWidget/iconBuilder provided', () {
      expect(
        () => AdaptiveDestination(label: 'Bad'),
        throwsA(isA<AssertionError>()),
      );
    });

    test('const construction with only iconWidget is valid', () {
      // Should not throw
      final d = AdaptiveDestination(
        iconWidget: const SizedBox(),
        label: 'Widget icon',
      );
      expect(d.label, 'Widget icon');
    });
  });

  // ── Widget icons rendered in NavigationBar (compact) ──────────────────────

  group('Widget icons in compact NavigationBar', () {
    testWidgets('iconWidget is rendered for unselected destination',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: [
          AdaptiveDestination(
            iconWidget: const Icon(Icons.home, key: Key('home-icon')),
            label: 'Home',
          ),
          const AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
        ],
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Child1'),
      )));

      expect(find.byKey(const Key('home-icon')), findsOneWidget);
    });

    testWidgets('selectedIconWidget is rendered for selected destination',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: [
          AdaptiveDestination(
            iconWidget: const Icon(Icons.home_outlined),
            selectedIconWidget:
                const Icon(Icons.home, key: Key('home-selected')),
            label: 'Home',
          ),
          const AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
        ],
        selectedIndex: 0, // Home is selected
        onDestinationSelected: (_) {},
        child1: const Text('Child1'),
      )));

      expect(find.byKey(const Key('home-selected')), findsOneWidget);
    });

    testWidgets('iconBuilder is called with context and isSelected',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      final calls = <bool>[];

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: [
          AdaptiveDestination(
            iconBuilder: (context, isSelected) {
              calls.add(isSelected);
              return Icon(isSelected ? Icons.home : Icons.home_outlined);
            },
            label: 'Home',
          ),
          const AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
        ],
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Child1'),
      )));

      // iconBuilder should have been called (at least once for each state)
      expect(calls, isNotEmpty);
    });

    testWidgets('iconSize wraps icon in SizedBox', (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: [
          AdaptiveDestination(
            iconWidget: const Icon(Icons.home),
            label: 'Home',
            iconSize: 32.0,
          ),
          const AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
        ],
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Child1'),
      )));

      // SizedBox with 32x32 should appear in the tree
      final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(boxes.any((b) => b.width == 32.0 && b.height == 32.0), isTrue);
    });

    testWidgets('badgeLabel text badge is shown', (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: const [
          AdaptiveDestination(
              icon: Icons.notifications,
              label: 'Alerts',
              badgeLabel: 'NEW'),
          AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
        ],
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Child1'),
      )));

      expect(find.text('NEW'), findsOneWidget);
    });

    testWidgets('int badge count is still shown when badgeLabel is null',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: const [
          AdaptiveDestination(
              icon: Icons.notifications, label: 'Alerts', badge: 3),
          AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
        ],
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Child1'),
      )));

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('disabled destination passes enabled:false to NavigationDestination',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: const [
          AdaptiveDestination(icon: Icons.home, label: 'Home'),
          AdaptiveDestination(
              icon: Icons.lock, label: 'Admin', enabled: false),
        ],
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Child1'),
      )));

      // NavigationDestination with enabled:false should appear
      final destinations = tester
          .widgetList<NavigationDestination>(
              find.byType(NavigationDestination))
          .toList();
      expect(destinations.any((d) => d.enabled == false), isTrue);
    });
  });

  // ── Widget icons rendered in NavigationRail (wide) ─────────────────────────

  group('Widget icons in wide NavigationRail', () {
    testWidgets('iconWidget is rendered in rail', (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: [
          AdaptiveDestination(
            iconWidget: const Icon(Icons.home, key: Key('rail-home')),
            label: 'Home',
          ),
          const AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
        ],
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      expect(find.byKey(const Key('rail-home')), findsOneWidget);
    });

    testWidgets('iconBuilder called in rail with correct isSelected',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      final calls = <bool>[];

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: [
          AdaptiveDestination(
            iconBuilder: (ctx, isSelected) {
              calls.add(isSelected);
              return Icon(isSelected ? Icons.home : Icons.home_outlined);
            },
            label: 'Home',
          ),
          const AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
        ],
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      expect(calls, isNotEmpty);
    });

    testWidgets('disabled destination dims icon with Opacity in rail',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: const [
          AdaptiveDestination(icon: Icons.home, label: 'Home'),
          AdaptiveDestination(
              icon: Icons.lock, label: 'Admin', enabled: false),
        ],
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      // Should have at least one Opacity widget (for the disabled destination)
      expect(find.byType(Opacity), findsWidgets);
    });

    testWidgets('disabled destination does NOT fire onDestinationSelected',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      int? selectedIndex;

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: const [
          AdaptiveDestination(icon: Icons.home, label: 'Home'),
          AdaptiveDestination(
              icon: Icons.lock, label: 'Admin', enabled: false),
        ],
        selectedIndex: 0,
        onDestinationSelected: (i) => selectedIndex = i,
        child1: const Text('Master'),
      )));

      // Tap the second (disabled) rail destination
      final rail =
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      // Directly call onDestinationSelected with index 1 to simulate tap
      rail.onDestinationSelected?.call(1);
      expect(selectedIndex, isNull); // guard prevented propagation
    });

    testWidgets('badgeLabel text shown in rail', (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: const [
          AdaptiveDestination(
              icon: Icons.home, label: 'Home', badgeLabel: '9+'),
          AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
        ],
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      expect(find.text('9+'), findsOneWidget);
    });

    testWidgets('custom disabledOpacity from theme is applied', (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        theme: const AdaptiveShellTheme(disabledOpacity: 0.2),
        destinations: const [
          AdaptiveDestination(icon: Icons.home, label: 'Home'),
          AdaptiveDestination(
              icon: Icons.lock, label: 'Admin', enabled: false),
        ],
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      final opacities = tester
          .widgetList<Opacity>(find.byType(Opacity))
          .where((o) => o.opacity == 0.2)
          .toList();
      expect(opacities, isNotEmpty);
    });
  });

  // ── AdaptiveShellTheme applied to widgets ──────────────────────────────────

  group('AdaptiveShellTheme applied', () {
    testWidgets(
        'railBackgroundColor is forwarded to NavigationRail.backgroundColor',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        theme: const AdaptiveShellTheme(
            railBackgroundColor: Color(0xFFF1F1F1)),
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      final rail =
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.backgroundColor, const Color(0xFFF1F1F1));
    });

    testWidgets(
        'theme.railBackgroundColor overrides legacy railBackgroundColor',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        railBackgroundColor: Colors.red, // legacy field
        theme:
            const AdaptiveShellTheme(railBackgroundColor: Color(0xFF00FF00)),
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      final rail =
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.backgroundColor, const Color(0xFF00FF00));
    });

    testWidgets('legacy railBackgroundColor still works without theme',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        railBackgroundColor: Colors.amber,
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      final rail =
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.backgroundColor, Colors.amber);
    });

    testWidgets('railMinExtendedWidth is forwarded to NavigationRail',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        theme: const AdaptiveShellTheme(railMinExtendedWidth: 200.0),
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      final rail =
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.minExtendedWidth, 200.0);
    });

    testWidgets('default railMinExtendedWidth is 160 (not 256)', (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      final rail =
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.minExtendedWidth, 160.0);
    });

    testWidgets('railMinWidth is forwarded to NavigationRail', (tester) async {
      _setSize(tester, 800, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        theme: const AdaptiveShellTheme(railMinWidth: 60.0),
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      final rail =
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.minWidth, 60.0);
    });

    testWidgets('railGroupAlignment is forwarded to NavigationRail',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        theme: const AdaptiveShellTheme(railGroupAlignment: 0.0),
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      final rail =
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.groupAlignment, 0.0);
    });

    testWidgets('railElevation is forwarded to NavigationRail', (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        theme: const AdaptiveShellTheme(railElevation: 4.0),
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      final rail =
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.elevation, 4.0);
    });

    testWidgets('railIndicatorColor is forwarded to NavigationRail',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        theme: const AdaptiveShellTheme(
            railIndicatorColor: Color(0xFFD0BCFF)),
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      final rail =
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.indicatorColor, const Color(0xFFD0BCFF));
    });

    testWidgets(
        'railLabelType override is respected on medium (non-extended) rail',
        (tester) async {
      // Must use medium screen — Flutter asserts labelType must be none/null
      // when extended=true, so the override only applies when !extended.
      _setSize(tester, 800, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        theme: const AdaptiveShellTheme(
            railLabelType: NavigationRailLabelType.selected),
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      final rail =
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.labelType, NavigationRailLabelType.selected);
    });

    testWidgets('railDecoration wraps rail column in DecoratedBox',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      const decoration = BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFFE0E0E0))),
      );

      await tester.pumpWidget(_app(AdaptiveShell(
        theme: const AdaptiveShellTheme(railDecoration: decoration),
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      final boxes = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .toList();
      expect(boxes.any((b) => b.decoration == decoration), isTrue);
    });

    testWidgets('navBarBackgroundColor is forwarded to NavigationBar',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        theme:
            const AdaptiveShellTheme(navBarBackgroundColor: Color(0xFF123456)),
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Child1'),
      )));

      final bar =
          tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.backgroundColor, const Color(0xFF123456));
    });

    testWidgets('navBarHeight is forwarded to NavigationBar', (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        theme: const AdaptiveShellTheme(navBarHeight: 90.0),
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Child1'),
      )));

      final bar =
          tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.height, 90.0);
    });

    testWidgets('navBarIndicatorColor is forwarded to NavigationBar',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        theme: const AdaptiveShellTheme(
            navBarIndicatorColor: Color(0xFFD0BCFF)),
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Child1'),
      )));

      final bar =
          tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.indicatorColor, const Color(0xFFD0BCFF));
    });

    testWidgets('navBarLabelBehavior is forwarded to NavigationBar',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        theme: const AdaptiveShellTheme(
          navBarLabelBehavior:
              NavigationDestinationLabelBehavior.alwaysHide,
        ),
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Child1'),
      )));

      final bar =
          tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.labelBehavior,
          NavigationDestinationLabelBehavior.alwaysHide);
    });

    testWidgets(
        'NavigationBarTheme wraps bar when icon/label style overrides set',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        theme: AdaptiveShellTheme(
          navBarSelectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold),
          navBarSelectedIconTheme:
              const IconThemeData(color: Colors.purple),
        ),
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Child1'),
      )));

      expect(find.byType(NavigationBarTheme), findsOneWidget);
    });

    testWidgets(
        'no NavigationBarTheme wrapper when no icon/label style overrides',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        theme: const AdaptiveShellTheme(navBarHeight: 72),
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Child1'),
      )));

      // No extra NavigationBarTheme should be injected
      expect(find.byType(NavigationBarTheme), findsNothing);
    });
  });

  // ── AdaptiveShellController — widget integration ───────────────────────────

  group('AdaptiveShellController — widget integration', () {
    testWidgets('controller collapses extended rail on desktop',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      final controller = AdaptiveShellController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(AdaptiveShell(
        controller: controller,
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      // Rail starts extended (desktop, not collapsed)
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isTrue,
      );

      // Collapse via controller
      controller.collapseRail();
      await tester.pump();

      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isFalse,
      );
    });

    testWidgets('controller expands collapsed rail', (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      final controller =
          AdaptiveShellController(initiallyCollapsed: true);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(AdaptiveShell(
        controller: controller,
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isFalse,
      );

      controller.expandRail();
      await tester.pump();

      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isTrue,
      );
    });

    testWidgets('controller.toggleRail cycles state', (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      final controller = AdaptiveShellController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(AdaptiveShell(
        controller: controller,
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      // Extended → collapsed
      controller.toggleRail();
      await tester.pump();
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isFalse,
      );

      // Collapsed → extended
      controller.toggleRail();
      await tester.pump();
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isTrue,
      );
    });

    testWidgets('toggle button uses controller when both present',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      final controller = AdaptiveShellController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(AdaptiveShell(
        controller: controller,
        railCollapsible: true,
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      // Tap the collapse toggle button
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();

      // Controller state should be updated
      expect(controller.isRailCollapsed, isTrue);
    });

    testWidgets('new controller swap is handled by shell', (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      final c1 = AdaptiveShellController();
      final c2 = AdaptiveShellController(initiallyCollapsed: true);
      addTearDown(c1.dispose);
      addTearDown(c2.dispose);

      Widget build(AdaptiveShellController c) => _app(AdaptiveShell(
            controller: c,
            destinations: _dest,
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            child1: const Text('Master'),
          ));

      await tester.pumpWidget(build(c1));
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isTrue,
      );

      // Swap to c2 (which starts collapsed)
      await tester.pumpWidget(build(c2));
      await tester.pump();
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isFalse,
      );
    });

    testWidgets('shell does not leak listener after dispose', (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      final controller = AdaptiveShellController();

      await tester.pumpWidget(_app(AdaptiveShell(
        controller: controller,
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      // Remove the shell from the tree
      await tester.pumpWidget(_app(const Text('Replaced')));

      // Controller should have 0 listeners after the shell is removed
      expect(controller.hasListeners, isFalse);
      controller.dispose();
    });

    testWidgets(
        'initiallyCollapsed:true sets rail collapsed on first build',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      final controller =
          AdaptiveShellController(initiallyCollapsed: true);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(AdaptiveShell(
        controller: controller,
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      final rail =
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isFalse);
    });
  });

  // ── Custom nav builders ────────────────────────────────────────────────────

  group('navigationBarBuilder', () {
    testWidgets('custom builder replaces NavigationBar on compact',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        navigationBarBuilder: (ctx, destinations, index, onSelected) =>
            const Text('CustomNavBar'),
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Child1'),
      )));

      expect(find.text('CustomNavBar'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('builder receives correct selectedIndex', (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      int? receivedIndex;

      await tester.pumpWidget(_app(AdaptiveShell(
        navigationBarBuilder: (ctx, destinations, index, onSelected) {
          receivedIndex = index;
          return const SizedBox();
        },
        destinations: _dest,
        selectedIndex: 1,
        onDestinationSelected: (_) {},
        child1: const Text('Child1'),
      )));

      expect(receivedIndex, 1);
    });

    testWidgets('builder receives all destinations', (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      List<AdaptiveDestination>? received;

      await tester.pumpWidget(_app(AdaptiveShell(
        navigationBarBuilder: (ctx, destinations, index, onSelected) {
          received = destinations;
          return const SizedBox();
        },
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Child1'),
      )));

      expect(received, hasLength(2));
    });

    testWidgets('builder fires onDestinationSelected callback',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      int? tappedIndex;

      await tester.pumpWidget(_app(AdaptiveShell(
        navigationBarBuilder: (ctx, destinations, index, onSelected) =>
            GestureDetector(
          key: const Key('tap-target'),
          onTap: () => onSelected(1),
          child: const Text('Tap me'),
        ),
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (i) => tappedIndex = i,
        child1: const Text('Child1'),
      )));

      await tester.tap(find.byKey(const Key('tap-target')));
      expect(tappedIndex, 1);
    });

    testWidgets('navigationBarBuilder not called on wide layout',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      int builderCalls = 0;

      await tester.pumpWidget(_app(AdaptiveShell(
        navigationBarBuilder: (ctx, dest, index, onSelected) {
          builderCalls++;
          return const Text('Bar');
        },
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      expect(builderCalls, 0);
      expect(find.byType(NavigationBar), findsNothing);
    });
  });

  group('navigationRailBuilder', () {
    testWidgets('custom builder replaces NavigationRail on wide layout',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        navigationRailBuilder:
            (ctx, destinations, index, onSelected, isExtended) =>
                const Text('CustomRail'),
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      expect(find.text('CustomRail'), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('builder receives isExtended=true on expanded layout',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      bool? receivedExtended;

      await tester.pumpWidget(_app(AdaptiveShell(
        navigationRailBuilder:
            (ctx, destinations, index, onSelected, isExtended) {
          receivedExtended = isExtended;
          return const SizedBox();
        },
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      expect(receivedExtended, isTrue);
    });

    testWidgets('builder receives isExtended=false on medium layout',
        (tester) async {
      _setSize(tester, 800, 800);
      addTearDown(tester.view.resetPhysicalSize);

      bool? receivedExtended;

      await tester.pumpWidget(_app(AdaptiveShell(
        navigationRailBuilder:
            (ctx, destinations, index, onSelected, isExtended) {
          receivedExtended = isExtended;
          return const SizedBox();
        },
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      expect(receivedExtended, isFalse);
    });

    testWidgets('navigationRailBuilder not called on compact layout',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      int builderCalls = 0;

      await tester.pumpWidget(_app(AdaptiveShell(
        navigationRailBuilder:
            (ctx, dest, index, onSelected, isExtended) {
          builderCalls++;
          return const Text('Rail');
        },
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Child1'),
      )));

      expect(builderCalls, 0);
      expect(find.byType(NavigationRail), findsNothing);
    });
  });

  // ── Backward compatibility — existing v1.x API ─────────────────────────────

  group('Backward compatibility — v1.x API unchanged', () {
    testWidgets('classic icon:IconData compact layout works', (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: const [
          AdaptiveDestination(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: 'Home'),
          AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
        ],
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Child1'),
      )));

      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('classic badge:int still shown in compact', (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: const [
          AdaptiveDestination(icon: Icons.home, label: 'Home'),
          AdaptiveDestination(
              icon: Icons.notifications, label: 'Alerts', badge: 7),
        ],
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Child1'),
      )));

      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('classic badge:int still shown in rail', (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: const [
          AdaptiveDestination(icon: Icons.home, label: 'Home'),
          AdaptiveDestination(
              icon: Icons.notifications, label: 'Alerts', badge: 4),
        ],
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('AdaptiveMasterDetail with new params passes through',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      final controller = AdaptiveShellController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(AdaptiveMasterDetail<String>(
        items: const ['a', 'b'],
        destinations: _dest,
        selectedNavIndex: 0,
        onNavSelected: (_) {},
        controller: controller,
        theme: const AdaptiveShellTheme(navBarHeight: 72),
        itemBuilder: (ctx, item, sel) => Text(item),
        detailBuilder: (ctx, item) => Text('Detail: $item'),
      )));

      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('no theme param still renders correctly', (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      // Standard rail should render with Flutter defaults for everything
      // except minExtendedWidth (which defaults to 160 in v2.0)
      expect(find.byType(NavigationRail), findsOneWidget);
      final rail =
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.minExtendedWidth, 160.0);
    });
  });
}

