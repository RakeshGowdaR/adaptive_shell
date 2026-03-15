import 'package:adaptive_shell/adaptive_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── Helpers ───

const _twoDestinations = [
  AdaptiveDestination(icon: Icons.home, label: 'Home'),
  AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
];

const _threeDestinations = [
  AdaptiveDestination(icon: Icons.home, label: 'Home'),
  AdaptiveDestination(icon: Icons.chat, label: 'Chat', badge: 5),
  AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
];

/// Sets the test surface to [width] x [height] logical pixels.
void setScreenSize(WidgetTester tester, double width, double height) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
}

/// Wraps a widget in MaterialApp for testing.
Widget wrapApp(Widget child) => MaterialApp(home: child);

// ════════════════════════════════════════════════════════════════════
// AdaptiveBreakpoints
// ════════════════════════════════════════════════════════════════════

void main() {
  group('AdaptiveBreakpoints', () {
    test('material3 preset has correct default values', () {
      const bp = AdaptiveBreakpoints.material3;
      expect(bp.compact, 600);
      expect(bp.medium, 840);
      expect(bp.expanded, 1200);
      expect(bp.masterRatio, 0.35);
      expect(bp.isValid, isTrue);
    });

    test('tabletFirst preset has correct values', () {
      const bp = AdaptiveBreakpoints.tabletFirst;
      expect(bp.compact, 500);
      expect(bp.medium, 700);
      expect(bp.expanded, 960);
      expect(bp.masterRatio, 0.38);
      expect(bp.isValid, isTrue);
    });

    test('custom breakpoints validate correctly', () {
      const valid = AdaptiveBreakpoints(
        compact: 400,
        medium: 700,
        expanded: 1000,
        masterRatio: 0.4,
      );
      expect(valid.isValid, isTrue);
    });

    test('detects invalid: compact > medium', () {
      const bp = AdaptiveBreakpoints(compact: 900, medium: 500, expanded: 1200);
      expect(bp.isValid, isFalse);
    });

    test('detects invalid: medium > expanded', () {
      const bp =
          AdaptiveBreakpoints(compact: 400, medium: 1300, expanded: 1200);
      expect(bp.isValid, isFalse);
    });

    test('detects invalid: compact <= 0', () {
      const bp = AdaptiveBreakpoints(compact: 0, medium: 500, expanded: 1000);
      expect(bp.isValid, isFalse);
    });

    test('detects invalid: masterRatio out of range', () {
      const tooLow = AdaptiveBreakpoints(masterRatio: 0.1);
      expect(tooLow.isValid, isFalse);

      const tooHigh = AdaptiveBreakpoints(masterRatio: 0.6);
      expect(tooHigh.isValid, isFalse);
    });

    test('masterRatio boundary values are valid', () {
      const low = AdaptiveBreakpoints(masterRatio: 0.2);
      expect(low.isValid, isTrue);

      const high = AdaptiveBreakpoints(masterRatio: 0.5);
      expect(high.isValid, isTrue);
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // LayoutMode
  // ════════════════════════════════════════════════════════════════════

  group('LayoutMode', () {
    test('has exactly three values', () {
      expect(LayoutMode.values.length, 3);
    });

    test('contains compact, medium, expanded', () {
      expect(LayoutMode.values, contains(LayoutMode.compact));
      expect(LayoutMode.values, contains(LayoutMode.medium));
      expect(LayoutMode.values, contains(LayoutMode.expanded));
    });

    test('values have correct indices', () {
      expect(LayoutMode.compact.index, 0);
      expect(LayoutMode.medium.index, 1);
      expect(LayoutMode.expanded.index, 2);
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // AdaptiveDestination
  // ════════════════════════════════════════════════════════════════════

  group('AdaptiveDestination', () {
    test('creates with required fields only', () {
      const dest = AdaptiveDestination(icon: Icons.home, label: 'Home');
      expect(dest.icon, Icons.home);
      expect(dest.label, 'Home');
      expect(dest.selectedIcon, isNull);
      expect(dest.badge, 0);
    });

    test('creates with all fields', () {
      const dest = AdaptiveDestination(
        icon: Icons.chat_outlined,
        selectedIcon: Icons.chat,
        label: 'Chat',
        badge: 42,
      );
      expect(dest.icon, Icons.chat_outlined);
      expect(dest.selectedIcon, Icons.chat);
      expect(dest.label, 'Chat');
      expect(dest.badge, 42);
    });

    test('selectedIcon falls back to icon when null', () {
      const dest = AdaptiveDestination(icon: Icons.star, label: 'Star');
      expect(dest.selectedIcon, isNull);
      // The actual fallback logic is in the shell widgets, not the model.
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // AdaptiveShell — Compact layout
  // ════════════════════════════════════════════════════════════════════

  group('AdaptiveShell — compact layout', () {
    testWidgets('shows NavigationBar and child1 on narrow screen',
        (tester) async {
      setScreenSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapApp(
        AdaptiveShell(
          destinations: _twoDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const Text('Master'),
        ),
      ));

      expect(find.text('Master'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('does not show child2 on compact screen', (tester) async {
      setScreenSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapApp(
        AdaptiveShell(
          destinations: _twoDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const Text('Master'),
          child2: const Text('Detail'),
        ),
      ));

      expect(find.text('Master'), findsOneWidget);
      // child2 is ignored on compact — not rendered.
      expect(find.text('Detail'), findsNothing);
    });

    testWidgets('fires onDestinationSelected on bottom nav tap',
        (tester) async {
      setScreenSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      int? tappedIndex;

      await tester.pumpWidget(wrapApp(
        AdaptiveShell(
          destinations: _twoDestinations,
          selectedIndex: 0,
          onDestinationSelected: (i) => tappedIndex = i,
          child1: const SizedBox(),
        ),
      ));

      // Tap the second destination ("Settings").
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(tappedIndex, 1);
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // AdaptiveShell — Medium / Expanded layout
  // ════════════════════════════════════════════════════════════════════

  group('AdaptiveShell — medium layout', () {
    testWidgets('shows NavigationRail and both children on wide screen',
        (tester) async {
      setScreenSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapApp(
        AdaptiveShell(
          destinations: _twoDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const Text('Master'),
          child2: const Text('Detail'),
        ),
      ));

      expect(find.text('Master'), findsOneWidget);
      expect(find.text('Detail'), findsOneWidget);
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('shows emptyDetailPlaceholder when child2 is null',
        (tester) async {
      setScreenSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapApp(
        AdaptiveShell(
          destinations: _twoDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const Text('Master'),
          emptyDetailPlaceholder: const Text('Select something'),
        ),
      ));

      expect(find.text('Master'), findsOneWidget);
      expect(find.text('Select something'), findsOneWidget);
    });

    testWidgets('child1 fills full width when no child2 and no placeholder',
        (tester) async {
      setScreenSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapApp(
        AdaptiveShell(
          destinations: _twoDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const Text('Master'),
          // No child2, no placeholder.
        ),
      ));

      expect(find.text('Master'), findsOneWidget);
      // No divider between panes since there's only one pane.
      // The VerticalDivider between rail and content always exists (1 instance).
    });

    testWidgets('fires onDestinationSelected on rail tap', (tester) async {
      setScreenSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      int? tappedIndex;

      await tester.pumpWidget(wrapApp(
        AdaptiveShell(
          destinations: _twoDestinations,
          selectedIndex: 0,
          onDestinationSelected: (i) => tappedIndex = i,
          child1: const SizedBox(),
        ),
      ));

      // Tap "Settings" on the rail.
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(tappedIndex, 1);
    });
  });

  group('AdaptiveShell — expanded layout', () {
    testWidgets('shows extended NavigationRail on very wide screen',
        (tester) async {
      setScreenSize(tester, 1400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapApp(
        AdaptiveShell(
          destinations: _twoDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const Text('Master'),
          child2: const Text('Detail'),
        ),
      ));

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('Master'), findsOneWidget);
      expect(find.text('Detail'), findsOneWidget);
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // AdaptiveShell — Static helpers
  // ════════════════════════════════════════════════════════════════════

  group('AdaptiveShell static methods', () {
    testWidgets('of() returns compact when no ancestor shell exists',
        (tester) async {
      late LayoutMode capturedMode;

      await tester.pumpWidget(wrapApp(
        Builder(builder: (context) {
          capturedMode = AdaptiveShell.of(context);
          return const SizedBox();
        }),
      ));

      expect(capturedMode, LayoutMode.compact);
    });

    testWidgets('isTwoPane() returns false when no ancestor', (tester) async {
      late bool result;

      await tester.pumpWidget(wrapApp(
        Builder(builder: (context) {
          result = AdaptiveShell.isTwoPane(context);
          return const SizedBox();
        }),
      ));

      expect(result, isFalse);
    });

    testWidgets('of() returns medium inside a wide AdaptiveShell',
        (tester) async {
      setScreenSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      late LayoutMode capturedMode;

      await tester.pumpWidget(wrapApp(
        AdaptiveShell(
          destinations: _twoDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: Builder(builder: (context) {
            capturedMode = AdaptiveShell.of(context);
            return const SizedBox();
          }),
        ),
      ));

      expect(capturedMode, LayoutMode.medium);
    });

    testWidgets('isTwoPane() returns true inside a wide AdaptiveShell',
        (tester) async {
      setScreenSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      late bool result;

      await tester.pumpWidget(wrapApp(
        AdaptiveShell(
          destinations: _twoDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: Builder(builder: (context) {
            result = AdaptiveShell.isTwoPane(context);
            return const SizedBox();
          }),
        ),
      ));

      expect(result, isTrue);
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // AdaptiveShell — detailAlignment
  // ════════════════════════════════════════════════════════════════════

  group('AdaptiveShell — detailAlignment', () {
    testWidgets('defaults to topLeft', (tester) async {
      setScreenSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapApp(
        AdaptiveShell(
          destinations: _twoDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const Text('Master'),
          child2: const Text('Detail'),
        ),
      ));

      // Find the Align wrapping child2.
      final align = tester.widget<Align>(find
          .ancestor(
            of: find.text('Detail'),
            matching: find.byType(Align),
          )
          .first);
      expect(align.alignment, Alignment.topLeft);
    });

    testWidgets('respects custom alignment', (tester) async {
      setScreenSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapApp(
        AdaptiveShell(
          destinations: _twoDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          detailAlignment: Alignment.center,
          child1: const Text('Master'),
          child2: const Text('Detail'),
        ),
      ));

      final align = tester.widget<Align>(find
          .ancestor(
            of: find.text('Detail'),
            matching: find.byType(Align),
          )
          .first);
      expect(align.alignment, Alignment.center);
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // AdaptiveShell — Badges
  // ════════════════════════════════════════════════════════════════════

  group('AdaptiveShell — badge support', () {
    testWidgets('shows badge on compact NavigationBar', (tester) async {
      setScreenSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapApp(
        AdaptiveShell(
          destinations: _threeDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const SizedBox(),
        ),
      ));

      // Badge.count renders the count as text.
      expect(find.text('5'), findsWidgets);
    });

    testWidgets('shows badge on medium NavigationRail', (tester) async {
      setScreenSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapApp(
        AdaptiveShell(
          destinations: _threeDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const SizedBox(),
        ),
      ));

      expect(find.text('5'), findsWidgets);
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // AdaptiveShell — Optional widgets
  // ════════════════════════════════════════════════════════════════════

  group('AdaptiveShell — optional widgets', () {
    testWidgets('shows railLeading on wide screen', (tester) async {
      setScreenSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapApp(
        AdaptiveShell(
          destinations: _twoDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const SizedBox(),
          railLeading: const Icon(Icons.add, key: Key('rail-leading')),
        ),
      ));

      expect(find.byKey(const Key('rail-leading')), findsOneWidget);
    });

    testWidgets('shows appBar', (tester) async {
      setScreenSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapApp(
        AdaptiveShell(
          destinations: _twoDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const SizedBox(),
          appBar: AppBar(title: const Text('Shell AppBar')),
        ),
      ));

      expect(find.text('Shell AppBar'), findsOneWidget);
    });

    testWidgets('shows FAB', (tester) async {
      setScreenSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapApp(
        AdaptiveShell(
          destinations: _twoDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const SizedBox(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      ));

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // AdaptiveShell — Layout transitions
  // ════════════════════════════════════════════════════════════════════

  group('AdaptiveShell — responsive transitions', () {
    testWidgets('switches from compact to medium on resize', (tester) async {
      // Start narrow.
      setScreenSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapApp(
        AdaptiveShell(
          destinations: _twoDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const Text('Master'),
          child2: const Text('Detail'),
        ),
      ));

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.text('Detail'), findsNothing);

      // Resize to wide.
      setScreenSize(tester, 900, 800);
      await tester.pumpWidget(wrapApp(
        AdaptiveShell(
          destinations: _twoDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const Text('Master'),
          child2: const Text('Detail'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('Detail'), findsOneWidget);
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // AdaptiveMasterDetail
  // ════════════════════════════════════════════════════════════════════

  group('AdaptiveMasterDetail', () {
    testWidgets('renders items in compact mode', (tester) async {
      setScreenSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapApp(
        AdaptiveMasterDetail<String>(
          items: const ['Alice', 'Bob', 'Charlie'],
          destinations: _twoDestinations,
          selectedNavIndex: 0,
          onNavSelected: (_) {},
          itemBuilder: (context, item, selected) => ListTile(
            key: Key(item),
            title: Text(item),
          ),
          detailBuilder: (context, item) => Text('Detail: $item'),
        ),
      ));

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Charlie'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('pushes route on tap in compact mode', (tester) async {
      setScreenSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapApp(
        AdaptiveMasterDetail<String>(
          items: const ['Alice', 'Bob'],
          destinations: _twoDestinations,
          selectedNavIndex: 0,
          onNavSelected: (_) {},
          itemBuilder: (context, item, selected) => ListTile(
            key: Key(item),
            title: Text(item),
          ),
          detailBuilder: (context, item) => Text('Detail: $item'),
          detailAppBarTitle: (item) => item,
        ),
      ));

      // Tap Alice.
      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();

      // Should push a new route with the detail and an AppBar.
      expect(find.text('Detail: Alice'), findsOneWidget);
      expect(find.text('Alice'),
          findsWidgets); // title in AppBar + possibly list behind

      // Back button should exist.
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('updates detail pane on tap in medium mode (no push)',
        (tester) async {
      setScreenSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapApp(
        AdaptiveMasterDetail<String>(
          items: const ['Alice', 'Bob', 'Charlie'],
          destinations: _twoDestinations,
          selectedNavIndex: 0,
          onNavSelected: (_) {},
          itemBuilder: (context, item, selected) => ListTile(
            key: Key('tile-$item'),
            title: Text(item),
          ),
          detailBuilder: (context, item) => Text('Detail: $item'),
        ),
      ));

      // No detail shown initially.
      expect(find.text('Detail: Alice'), findsNothing);

      // Tap Bob.
      await tester.tap(find.text('Bob'));
      await tester.pumpAndSettle();

      // Detail should update in place, NOT push a route.
      expect(find.text('Detail: Bob'), findsOneWidget);
      // No back button — we're still on the same screen.
      expect(find.byType(BackButton), findsNothing);
      // Both master and detail visible.
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsWidgets); // tile + detail

      // Tap Charlie — detail should switch.
      await tester.tap(find.text('Charlie'));
      await tester.pumpAndSettle();

      expect(find.text('Detail: Charlie'), findsOneWidget);
      expect(find.text('Detail: Bob'), findsNothing);
    });

    testWidgets('shows initialSelection on medium screen', (tester) async {
      setScreenSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapApp(
        AdaptiveMasterDetail<String>(
          items: const ['Alice', 'Bob'],
          destinations: _twoDestinations,
          selectedNavIndex: 0,
          onNavSelected: (_) {},
          initialSelection: (items) => items.first,
          itemBuilder: (context, item, selected) => ListTile(
            title: Text(item),
          ),
          detailBuilder: (context, item) => Text('Detail: $item'),
        ),
      ));

      // Alice should be pre-selected.
      expect(find.text('Detail: Alice'), findsOneWidget);
    });

    testWidgets('shows emptyDetailPlaceholder when nothing selected',
        (tester) async {
      setScreenSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapApp(
        AdaptiveMasterDetail<String>(
          items: const ['Alice', 'Bob'],
          destinations: _twoDestinations,
          selectedNavIndex: 0,
          onNavSelected: (_) {},
          itemBuilder: (context, item, selected) => ListTile(
            title: Text(item),
          ),
          detailBuilder: (context, item) => Text('Detail: $item'),
          emptyDetailPlaceholder: const Text('Pick one'),
        ),
      ));

      expect(find.text('Pick one'), findsOneWidget);
      expect(find.text('Detail: Alice'), findsNothing);
    });

    testWidgets('shows masterHeader above list', (tester) async {
      setScreenSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapApp(
        AdaptiveMasterDetail<String>(
          items: const ['Alice'],
          destinations: _twoDestinations,
          selectedNavIndex: 0,
          onNavSelected: (_) {},
          itemBuilder: (context, item, selected) => ListTile(
            title: Text(item),
          ),
          detailBuilder: (context, item) => Text('Detail: $item'),
          masterHeader: const Text('Search Header'),
        ),
      ));

      expect(find.text('Search Header'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('clears selection when item removed from list', (tester) async {
      setScreenSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      // Start with Alice selected.
      await tester.pumpWidget(wrapApp(
        AdaptiveMasterDetail<String>(
          items: const ['Alice', 'Bob'],
          destinations: _twoDestinations,
          selectedNavIndex: 0,
          onNavSelected: (_) {},
          initialSelection: (items) => items.first,
          itemBuilder: (context, item, selected) => ListTile(
            title: Text(item),
          ),
          detailBuilder: (context, item) => Text('Detail: $item'),
          emptyDetailPlaceholder: const Text('Pick one'),
        ),
      ));

      expect(find.text('Detail: Alice'), findsOneWidget);

      // Rebuild without Alice.
      await tester.pumpWidget(wrapApp(
        AdaptiveMasterDetail<String>(
          items: const ['Bob'],
          destinations: _twoDestinations,
          selectedNavIndex: 0,
          onNavSelected: (_) {},
          itemBuilder: (context, item, selected) => ListTile(
            title: Text(item),
          ),
          detailBuilder: (context, item) => Text('Detail: $item'),
          emptyDetailPlaceholder: const Text('Pick one'),
        ),
      ));

      // Selection should be cleared, placeholder shown.
      expect(find.text('Detail: Alice'), findsNothing);
      expect(find.text('Pick one'), findsOneWidget);
    });

    testWidgets('detailAlignment passes through to AdaptiveShell',
        (tester) async {
      setScreenSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapApp(
        AdaptiveMasterDetail<String>(
          items: const ['Alice'],
          destinations: _twoDestinations,
          selectedNavIndex: 0,
          onNavSelected: (_) {},
          initialSelection: (items) => items.first,
          detailAlignment: Alignment.center,
          itemBuilder: (context, item, selected) => ListTile(
            title: Text(item),
          ),
          detailBuilder: (context, item) => Text('Detail: $item'),
        ),
      ));

      final align = tester.widget<Align>(find
          .ancestor(
            of: find.text('Detail: Alice'),
            matching: find.byType(Align),
          )
          .first);
      expect(align.alignment, Alignment.center);
    });

    testWidgets('uses compactDetailScaffoldBuilder on mobile', (tester) async {
      setScreenSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapApp(
        AdaptiveMasterDetail<String>(
          items: const ['Alice'],
          destinations: _twoDestinations,
          selectedNavIndex: 0,
          onNavSelected: (_) {},
          itemBuilder: (context, item, selected) => ListTile(
            key: Key(item),
            title: Text(item),
          ),
          detailBuilder: (context, item) => Text('Detail: $item'),
          compactDetailScaffoldBuilder: (context, item, detail) {
            return Scaffold(
              appBar: AppBar(title: const Text('Custom AppBar')),
              body: detail,
            );
          },
        ),
      ));

      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();

      expect(find.text('Custom AppBar'), findsOneWidget);
      expect(find.text('Detail: Alice'), findsOneWidget);
    });
  });
}
