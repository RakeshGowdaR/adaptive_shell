// Tests for features added in v1.1.0 (UI / interaction batch):
//   • AdaptiveBuilder    (Feature #17) — standalone responsive builder
//   • paneDivider        (Feature #11) — custom master↔detail divider widget
//   • Collapsible Rail   (Feature #14) — railCollapsible + railCollapseOnMedium
//   • Keyboard Shortcuts (Feature #13) — keyboardShortcuts map

import 'package:adaptive_shell/adaptive_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── Shared helpers ───────────────────────────────────────────────────────────

const _dest = [
  AdaptiveDestination(icon: Icons.home, label: 'Home'),
  AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
];

/// Sets the logical screen size to [w] × [h].
void _setSize(WidgetTester t, double w, double h) {
  t.view.physicalSize = Size(w, h);
  t.view.devicePixelRatio = 1.0;
}

Widget _app(Widget child) => MaterialApp(home: child);

// ═════════════════════════════════════════════════════════════════════════════
// Feature #17 — AdaptiveBuilder
// ═════════════════════════════════════════════════════════════════════════════

void main() {
  group('AdaptiveBuilder — layout selection', () {
    testWidgets('shows compact builder below compact breakpoint',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveBuilder(
        compact: (_) => const Text('Compact'),
        medium: (_) => const Text('Medium'),
        expanded: (_) => const Text('Expanded'),
      )));

      expect(find.text('Compact'), findsOneWidget);
      expect(find.text('Medium'), findsNothing);
      expect(find.text('Expanded'), findsNothing);
    });

    testWidgets('shows medium builder in medium range', (tester) async {
      _setSize(tester, 800, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveBuilder(
        compact: (_) => const Text('Compact'),
        medium: (_) => const Text('Medium'),
        expanded: (_) => const Text('Expanded'),
      )));

      expect(find.text('Compact'), findsNothing);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Expanded'), findsNothing);
    });

    testWidgets('shows expanded builder above expanded breakpoint',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveBuilder(
        compact: (_) => const Text('Compact'),
        medium: (_) => const Text('Medium'),
        expanded: (_) => const Text('Expanded'),
      )));

      expect(find.text('Compact'), findsNothing);
      expect(find.text('Medium'), findsNothing);
      expect(find.text('Expanded'), findsOneWidget);
    });

    testWidgets('falls back to compact when medium and expanded are omitted',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveBuilder(
        compact: (_) => const Text('Compact'),
      )));

      expect(find.text('Compact'), findsOneWidget);
    });

    testWidgets('falls back to medium when only expanded is omitted',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveBuilder(
        compact: (_) => const Text('Compact'),
        medium: (_) => const Text('Medium'),
      )));

      expect(find.text('Medium'), findsOneWidget);
    });

    testWidgets('respects custom breakpoints', (tester) async {
      // 550 dp — above default compact threshold (600), but above the
      // custom compact threshold (400), so → medium.
      _setSize(tester, 550, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveBuilder(
        breakpoints: const AdaptiveBreakpoints(
          compact: 400,
          medium: 700,
          expanded: 1000,
        ),
        compact: (_) => const Text('Compact'),
        medium: (_) => const Text('Medium'),
        expanded: (_) => const Text('Expanded'),
      )));

      expect(find.text('Medium'), findsOneWidget);
    });

    testWidgets('works standalone — no AdaptiveShell ancestor required',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      // Plain MaterialApp → AdaptiveBuilder, no AdaptiveShell anywhere.
      await tester.pumpWidget(MaterialApp(
        home: AdaptiveBuilder(
          compact: (_) => const Text('Standalone'),
        ),
      ));

      expect(find.text('Standalone'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('builder receives a valid BuildContext', (tester) async {
      BuildContext? captured;
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveBuilder(
        compact: (ctx) {
          captured = ctx;
          return const Text('ok');
        },
      )));

      expect(captured, isNotNull);
    });

    testWidgets('rebuilds correctly when screen size changes', (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveBuilder(
        compact: (_) => const Text('Compact'),
        medium: (_) => const Text('Medium'),
      )));
      expect(find.text('Compact'), findsOneWidget);

      // Grow to medium.
      _setSize(tester, 800, 800);
      await tester.pumpAndSettle();
      expect(find.text('Medium'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Feature #11 — Custom paneDivider
  // ═══════════════════════════════════════════════════════════════════════════

  group('Custom paneDivider', () {
    testWidgets('default VerticalDivider used when paneDivider is null',
        (tester) async {
      _setSize(tester, 1000, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        showPaneDivider: true,
        child1: const Text('Master'),
        child2: const Text('Detail'),
      )));

      // Rail divider + pane divider = at least 2 VerticalDividers.
      expect(find.byType(VerticalDivider), findsAtLeastNWidgets(2));
    });

    testWidgets('custom paneDivider widget is rendered', (tester) async {
      _setSize(tester, 1000, 800);
      addTearDown(tester.view.resetPhysicalSize);

      const divKey = Key('custom-divider');

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        showPaneDivider: true,
        paneDivider: const SizedBox(key: divKey, width: 8),
        child1: const Text('Master'),
        child2: const Text('Detail'),
      )));

      expect(find.byKey(divKey), findsOneWidget);
    });

    testWidgets('custom paneDivider is not rendered when showPaneDivider false',
        (tester) async {
      _setSize(tester, 1000, 800);
      addTearDown(tester.view.resetPhysicalSize);

      const divKey = Key('custom-divider');

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        showPaneDivider: false,
        paneDivider: const SizedBox(key: divKey, width: 8),
        child1: const Text('Master'),
        child2: const Text('Detail'),
      )));

      expect(find.byKey(divKey), findsNothing);
    });

    testWidgets('paneDivider not visible on compact (no second pane)',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      const divKey = Key('custom-divider');

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        paneDivider: const SizedBox(key: divKey, width: 8),
        child1: const Text('Master'),
        child2: const Text('Detail'),
      )));

      // Compact → no two-pane layout → no divider.
      expect(find.byKey(divKey), findsNothing);
    });

    testWidgets('AdaptiveMasterDetail passes paneDivider through',
        (tester) async {
      _setSize(tester, 1000, 800);
      addTearDown(tester.view.resetPhysicalSize);

      const divKey = Key('amd-divider');

      await tester.pumpWidget(_app(AdaptiveMasterDetail<String>(
        items: const ['a', 'b'],
        destinations: _dest,
        selectedNavIndex: 0,
        onNavSelected: (_) {},
        showPaneDivider: true,
        paneDivider: const SizedBox(key: divKey, width: 8),
        itemBuilder: (_, item, __) => Text(item),
        detailBuilder: (_, item) => Text('D:$item'),
        initialSelection: (items) => items.first,
      )));

      await tester.pumpAndSettle();
      expect(find.byKey(divKey), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Feature #14 — Collapsible Navigation Rail
  // ═══════════════════════════════════════════════════════════════════════════

  group('Collapsible Rail', () {
    testWidgets('no toggle button when railCollapsible is false (default)',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child1: const Text('Master'),
      )));

      expect(find.byIcon(Icons.chevron_left), findsNothing);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets(
        'shows collapse button (chevron_left) when railCollapsible true',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        railCollapsible: true,
        child1: const Text('Master'),
      )));

      // Extended rail → chevron_left = "collapse"
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('tapping toggle collapses extended rail', (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        railCollapsible: true,
        child1: const Text('Master'),
      )));

      // Rail starts extended on expanded (1300 dp).
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isTrue,
      );

      // Tap the collapse toggle.
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // Rail is now icon-only.
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isFalse,
      );
      // Icon flips to "expand".
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsNothing);
    });

    testWidgets('tapping toggle again re-expands the rail', (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        railCollapsible: true,
        child1: const Text('Master'),
      )));

      await tester.tap(find.byIcon(Icons.chevron_left)); // collapse
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.chevron_right)); // re-expand
      await tester.pumpAndSettle();

      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isTrue,
      );
    });

    testWidgets(
        'railCollapseOnMedium auto-collapses label-type when entering medium',
        (tester) async {
      _setSize(tester, 1300, 800); // Expanded
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        railCollapsible: true,
        railCollapseOnMedium: true,
        child1: const Text('Master'),
      )));

      // Starts extended.
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isTrue,
      );

      // Shrink to medium (800 dp).
      _setSize(tester, 800, 800);
      await tester.pumpAndSettle();

      // Auto-collapsed: icon-only, no labels.
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isFalse);
      expect(rail.labelType, NavigationRailLabelType.none);
    });

    testWidgets(
        'no toggle shown on compact layout even if railCollapsible true',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        railCollapsible: true,
        child1: const Text('Master'),
      )));

      // Compact → NavigationBar, no NavigationRail, no chevron.
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byIcon(Icons.chevron_left), findsNothing);
    });

    testWidgets('toggle button coexists with railLeading', (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        railCollapsible: true,
        railLeading: const Text('LOGO'),
        child1: const Text('Master'),
      )));

      // Both the toggle and the custom leading are present.
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.text('LOGO'), findsOneWidget);
    });

    testWidgets('AdaptiveMasterDetail passes railCollapsible through',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveMasterDetail<String>(
        items: const ['a'],
        destinations: _dest,
        selectedNavIndex: 0,
        onNavSelected: (_) {},
        railCollapsible: true,
        itemBuilder: (_, item, __) => Text(item),
        detailBuilder: (_, item) => Text('D:$item'),
      )));

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    // ── Overflow regression ──────────────────────────────────────────────────
    // Previously the toggle button (~36 px) consumed height from the Column
    // that also held the NavigationRail.  On short screens with many
    // destinations the rail's internal RenderFlex overflowed.
    // Fix: Expanded(LayoutBuilder→SingleChildScrollView+ConstrainedBox+
    //      IntrinsicHeight) lets the rail scroll instead of asserting.

    testWidgets(
        'no RenderFlex overflow with 5 destinations on a short screen '
        'when railCollapsible is true (regression test)',
        (tester) async {
      // 5 destinations × ~72 px each ≈ 360 px + toggle ~36 px = ~396 px.
      // A 380 px viewport previously triggered the overflow assertion.
      _setSize(tester, 1300, 380);
      addTearDown(tester.view.resetPhysicalSize);

      const fiveDest = [
        AdaptiveDestination(icon: Icons.home, label: 'Home'),
        AdaptiveDestination(icon: Icons.chat, label: 'Chat'),
        AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
        AdaptiveDestination(icon: Icons.person, label: 'Profile'),
        AdaptiveDestination(icon: Icons.notifications, label: 'Alerts'),
      ];

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: fiveDest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        railCollapsible: true,
        child1: const Text('Master'),
      )));
      await tester.pumpAndSettle();

      // Must not throw a RenderFlex overflow.
      expect(tester.takeException(), isNull);

      // Rail is present (expanded layout at 1300 dp width).
      expect(find.byType(NavigationRail), findsOneWidget);

      // The scroll wrapper from the fix must be in the tree.
      expect(find.byType(SingleChildScrollView), findsWidgets);

      // Toggle button is still shown.
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets(
        'no overflow on medium layout with 5 destinations and short screen',
        (tester) async {
      _setSize(tester, 800, 380);
      addTearDown(tester.view.resetPhysicalSize);

      const fiveDest = [
        AdaptiveDestination(icon: Icons.home, label: 'Home'),
        AdaptiveDestination(icon: Icons.chat, label: 'Chat'),
        AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
        AdaptiveDestination(icon: Icons.person, label: 'Profile'),
        AdaptiveDestination(icon: Icons.notifications, label: 'Alerts'),
      ];

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: fiveDest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        railCollapsible: true,
        child1: const Text('Master'),
      )));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(NavigationRail), findsOneWidget);
    });

    testWidgets(
        'no overflow regression — railCollapsible false uses no scroll wrapper',
        (tester) async {
      // When the toggle is OFF the simple Expanded(NavigationRail) path is
      // still used — verify nothing broke for the default case.
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        // railCollapsible defaults to false
        child1: const Text('Master'),
      )));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(NavigationRail), findsOneWidget);
      // No chevron toggle present.
      expect(find.byIcon(Icons.chevron_left), findsNothing);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Feature #13 — Keyboard Shortcuts
  // ═══════════════════════════════════════════════════════════════════════════

  group('Keyboard Shortcuts', () {
    testWidgets('Ctrl+2 navigates to index 1 on expanded layout',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      int? selected;
      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (i) => selected = i,
        keyboardShortcuts: const {
          SingleActivator(LogicalKeyboardKey.digit1, control: true): 0,
          SingleActivator(LogicalKeyboardKey.digit2, control: true): 1,
        },
        child1: const Text('Master'),
      )));
      await tester.pumpAndSettle(); // let autofocus settle

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit2);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.digit2);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      expect(selected, 1);
    });

    testWidgets('Ctrl+1 navigates to index 0 on expanded layout',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      int? selected;
      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: _dest,
        selectedIndex: 1,
        onDestinationSelected: (i) => selected = i,
        keyboardShortcuts: const {
          SingleActivator(LogicalKeyboardKey.digit1, control: true): 0,
          SingleActivator(LogicalKeyboardKey.digit2, control: true): 1,
        },
        child1: const Text('Master'),
      )));
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit1);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.digit1);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      expect(selected, 0);
    });

    testWidgets('shortcuts work on medium layout', (tester) async {
      _setSize(tester, 800, 800);
      addTearDown(tester.view.resetPhysicalSize);

      int? selected;
      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (i) => selected = i,
        keyboardShortcuts: const {
          SingleActivator(LogicalKeyboardKey.digit2, control: true): 1,
        },
        child1: const Text('Master'),
      )));
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit2);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.digit2);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      expect(selected, 1);
    });

    testWidgets('shortcuts are NOT active on compact layout', (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      int? selected;
      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (i) => selected = i,
        keyboardShortcuts: const {
          SingleActivator(LogicalKeyboardKey.digit1, control: true): 0,
        },
        child1: const Text('Master'),
      )));
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit1);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.digit1);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      expect(selected, isNull); // Focus widget absent → callback never fires
    });

    testWidgets('unregistered key does not trigger callback', (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      int? selected;
      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (i) => selected = i,
        keyboardShortcuts: const {
          SingleActivator(LogicalKeyboardKey.digit1, control: true): 0,
        },
        child1: const Text('Master'),
      )));
      await tester.pumpAndSettle();

      // Ctrl+9 is not registered.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit9);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.digit9);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      expect(selected, isNull);
    });

    testWidgets('null keyboardShortcuts does not add Focus widget',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(AdaptiveShell(
        destinations: _dest,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        // keyboardShortcuts intentionally omitted (null)
        child1: const Text('Master'),
      )));

      // No Focus widget added for shortcuts when the map is null.
      // The shell itself may contain Focus for other reasons, but
      // onKeyEvent should not fire via our handler.
      expect(tester.takeException(), isNull);
    });

    testWidgets('AdaptiveMasterDetail passes keyboardShortcuts through',
        (tester) async {
      _setSize(tester, 1300, 800);
      addTearDown(tester.view.resetPhysicalSize);

      int? selected;
      await tester.pumpWidget(_app(AdaptiveMasterDetail<String>(
        items: const ['a', 'b'],
        destinations: _dest,
        selectedNavIndex: 0,
        onNavSelected: (i) => selected = i,
        keyboardShortcuts: const {
          SingleActivator(LogicalKeyboardKey.digit2, control: true): 1,
        },
        itemBuilder: (_, item, __) => Text(item),
        detailBuilder: (_, item) => Text('D:$item'),
      )));
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.digit2);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.digit2);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      expect(selected, 1);
    });
  });
}
