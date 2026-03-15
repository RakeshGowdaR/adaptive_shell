// Tests for features added in v1.1.0:
//   • AutoScale (Feature #2)
//   • State Persistence (Feature #4)
//   • Animated Transitions — transitionCurve + enableHeroAnimations (Feature #5)
//   • New Context Extensions — layoutMode, adaptiveColumns, adaptiveValue (Feature #3)

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

/// A minimal stateful counter widget used to verify state preservation.
class _Counter extends StatefulWidget {
  const _Counter({super.key});

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Count: $_count'),
          ElevatedButton(
            key: const Key('increment'),
            onPressed: () => setState(() => _count++),
            child: const Text('+'),
          ),
        ],
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// Feature #2 — AutoScale
// ═════════════════════════════════════════════════════════════════════════════

void main() {
  group('AutoScale', () {
    testWidgets(
        'autoScale:true with default design width shows compact layout '
        'in portrait regardless of screen width', (tester) async {
      // 800×1200 — portrait, would normally be "medium" without autoScale.
      _setSize(tester, 800, 1200);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(
        AdaptiveShell(
          autoScale: true, // default design width = 360 dp → compact mode
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const Text('Master'),
          child2: const Text('Detail'),
        ),
      ));

      // 360 dp design ⟹ compact ⟹ NavigationBar, no NavigationRail
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      // child2 is NOT rendered in compact mode
      expect(find.text('Detail'), findsNothing);
    });

    testWidgets(
        'autoScale:true with autoScaleDesignWidth in medium range '
        'shows medium layout', (tester) async {
      _setSize(tester, 800, 1200); // portrait — autoScale is active
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(
        AdaptiveShell(
          autoScale: true,
          autoScaleDesignWidth: 900, // 900 dp → medium mode (600–1200)
          destinations: _dest,
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

    testWidgets('autoScale:false (default) still uses actual screen width',
        (tester) async {
      _setSize(tester, 1200, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(
        AdaptiveShell(
          // autoScale defaults to false
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const Text('Master'),
          child2: const Text('Detail'),
        ),
      ));

      // 1 200 dp = expanded boundary, so NavigationRail is shown
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('autoScale uses ClipRect + OverflowBox wrappers',
        (tester) async {
      _setSize(tester, 600, 800); // portrait — autoScale is active
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(
        AdaptiveShell(
          autoScale: true,
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const Text('Master'),
        ),
      ));

      // OverflowBox is only added by our AutoScale logic
      expect(find.byType(ClipRect), findsOneWidget);
      expect(find.byType(OverflowBox), findsOneWidget);
    });

    testWidgets('scaleFactor multiplies the auto-computed scale',
        (tester) async {
      // We can't easily measure the rendered pixel size in a widget test,
      // but we can verify the widget tree is built without errors.
      _setSize(tester, 600, 800); // portrait — autoScale is active
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(
        AdaptiveShell(
          autoScale: true,
          scaleFactor: 1.5,
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const Text('Master'),
        ),
      ));

      expect(find.text('Master'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('autoScale debug overlay shows Scale info', (tester) async {
      _setSize(tester, 600, 800); // portrait — autoScale is active
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(
        AdaptiveShell(
          autoScale: true,
          debugShowLayoutMode: true,
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const SizedBox(),
        ),
      ));

      // Debug overlay should show the "⚖️ Scale" line
      expect(find.textContaining('Scale'), findsOneWidget);
      expect(find.textContaining('Design:'), findsOneWidget);
    });

    testWidgets(
        'autoScale:true passes AdaptiveShell.of() as compact inside child1',
        (tester) async {
      _setSize(tester, 800, 1400); // portrait — autoScale forces compact
      addTearDown(tester.view.resetPhysicalSize);

      LayoutMode? capturedMode;

      await tester.pumpWidget(_app(
        AdaptiveShell(
          autoScale: true, // design width 360 → compact
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: Builder(builder: (ctx) {
            capturedMode = AdaptiveShell.of(ctx);
            return const SizedBox();
          }),
        ),
      ));

      expect(capturedMode, LayoutMode.compact);
    });

    // ── Landscape bypass ────────────────────────────────────────────────

    testWidgets(
        'autoScale is bypassed in landscape — layout adapts and no '
        'ClipRect is applied', (tester) async {
      // 844×390 — typical phone in landscape.
      // Without the bypass, scale = 844/360 = ×2.34 and the compact
      // layout's design height shrinks to ~167 dp, causing overflow.
      _setSize(tester, 844, 390);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(
        AdaptiveShell(
          autoScale: true,
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const Text('Master'),
          child2: const Text('Detail'),
        ),
      ));

      // Landscape → bypass → effectiveWidth = 844 dp → medium mode.
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      // No scale transform applied.
      expect(find.byType(ClipRect), findsNothing);
      expect(find.byType(OverflowBox), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'autoScale is still applied in portrait — compact mode + ClipRect',
        (tester) async {
      // 390×844 — same phone in portrait.
      _setSize(tester, 390, 844);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(
        AdaptiveShell(
          autoScale: true, // design width 360 → compact
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const Text('Master'),
        ),
      ));

      // Portrait → autoScale active → compact mode.
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      // Scale transform is applied.
      expect(find.byType(ClipRect), findsOneWidget);
      expect(find.byType(OverflowBox), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Feature #4 — State Persistence
  // ═══════════════════════════════════════════════════════════════════════════

  group('State Persistence', () {
    testWidgets('persistState:true renders correctly on compact screen',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(
        AdaptiveShell(
          persistState: true,
          stateKey: 'test_shell',
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const Text('Master'),
        ),
      ));

      expect(find.text('Master'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('persistState:true renders correctly on medium screen',
        (tester) async {
      _setSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(
        AdaptiveShell(
          persistState: true,
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const Text('Master'),
          child2: const Text('Detail'),
        ),
      ));

      expect(find.text('Master'), findsOneWidget);
      expect(find.text('Detail'), findsOneWidget);
      expect(find.byType(NavigationRail), findsOneWidget);
    });

    testWidgets(
        'child1 state is preserved when layout mode changes from '
        'compact to medium', (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      // Build with a stateful counter as child1.
      Widget buildShell(double width) => _app(
            SizedBox(
              width: width,
              height: 800,
              child: AdaptiveShell(
                persistState: true,
                destinations: _dest,
                selectedIndex: 0,
                onDestinationSelected: (_) {},
                child1: const _Counter(key: ValueKey('counter')),
              ),
            ),
          );

      await tester.pumpWidget(buildShell(400));

      // Increment counter.
      await tester.tap(find.byKey(const Key('increment')));
      await tester.pump();
      expect(find.text('Count: 1'), findsOneWidget);

      // Switch to medium layout (900 dp).
      _setSize(tester, 900, 800);
      await tester.pumpWidget(buildShell(900));
      await tester.pumpAndSettle();

      // Counter state should be preserved.
      expect(find.text('Count: 1'), findsOneWidget);
    });

    testWidgets(
        'child1 state is LOST when persistState:false (default) and '
        'layout mode changes', (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      Widget buildShell(double width) => _app(
            SizedBox(
              width: width,
              height: 800,
              child: AdaptiveShell(
                persistState: false, // explicit false
                destinations: _dest,
                selectedIndex: 0,
                onDestinationSelected: (_) {},
                child1: const _Counter(key: ValueKey('counter')),
              ),
            ),
          );

      await tester.pumpWidget(buildShell(400));

      await tester.tap(find.byKey(const Key('increment')));
      await tester.pump();
      expect(find.text('Count: 1'), findsOneWidget);

      // Switch layout — without persistState the state is rebuilt.
      _setSize(tester, 900, 800);
      await tester.pumpWidget(buildShell(900));
      await tester.pumpAndSettle();

      // Counter resets to 0 without persistState.
      expect(find.text('Count: 0'), findsOneWidget);
    });

    testWidgets('PageStorage wrapper is present in widget tree when enabled',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(
        AdaptiveShell(
          persistState: true,
          stateKey: 'ps_key', // our key → ValueKey('ps_key')
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const SizedBox(),
        ),
      ));

      // Our PageStorage is identifiable by the stateKey ValueKey.
      expect(find.byKey(const ValueKey('ps_key')), findsOneWidget);
    });

    testWidgets('PageStorage with default stateKey is present when enabled',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(
        AdaptiveShell(
          persistState: true, // no stateKey → defaults to 'adaptive_shell'
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const SizedBox(),
        ),
      ));

      expect(find.byKey(const ValueKey('adaptive_shell')), findsOneWidget);
    });

    testWidgets('PageStorage with our key is absent when persistState:false',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(
        AdaptiveShell(
          persistState: false, // no stateKey → default 'adaptive_shell'
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const SizedBox(),
        ),
      ));

      // Our keyed PageStorage should NOT be in the tree.
      expect(find.byKey(const ValueKey('adaptive_shell')), findsNothing);
    });

    testWidgets('toggleing persistState mid-life does not throw',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      Widget buildShell({required bool persist}) => _app(
            AdaptiveShell(
              persistState: persist,
              destinations: _dest,
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              child1: const Text('M'),
            ),
          );

      await tester.pumpWidget(buildShell(persist: false));
      expect(find.byKey(const ValueKey('adaptive_shell')), findsNothing);

      await tester.pumpWidget(buildShell(persist: true));
      await tester.pump();
      expect(find.byKey(const ValueKey('adaptive_shell')), findsOneWidget);

      await tester.pumpWidget(buildShell(persist: false));
      await tester.pump();
      expect(find.byKey(const ValueKey('adaptive_shell')), findsNothing);

      expect(tester.takeException(), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Feature #5 — Animated Transitions
  // ═══════════════════════════════════════════════════════════════════════════

  group('Animated Transitions — transitionCurve', () {
    testWidgets('custom transitionCurve is accepted without error',
        (tester) async {
      _setSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(
        AdaptiveShell(
          transitionCurve: Curves.bounceIn,
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const Text('Master'),
          child2: const Text('Detail'),
        ),
      ));

      expect(find.text('Master'), findsOneWidget);
      expect(find.text('Detail'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('null transitionCurve (default) renders correctly',
        (tester) async {
      _setSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(
        AdaptiveShell(
          // transitionCurve defaults to null → falls back to Curves.easeInOut
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const Text('Master'),
          child2: const Text('Detail'),
        ),
      ));

      expect(find.text('Detail'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('detail pane AnimatedSwitcher changes content', (tester) async {
      _setSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      Widget? detail = const Text('Detail A');

      await tester.pumpWidget(_app(
        StatefulBuilder(
          builder: (_, setState) => AdaptiveShell(
            transitionCurve: Curves.linear,
            transitionDuration: const Duration(milliseconds: 200),
            destinations: _dest,
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            child1: GestureDetector(
              onTap: () => setState(() => detail = const Text('Detail B')),
              child: const Text('Master'),
            ),
            child2: detail,
          ),
        ),
      ));

      expect(find.text('Detail A'), findsOneWidget);

      await tester.tap(find.text('Master'));
      await tester.pumpAndSettle();

      expect(find.text('Detail B'), findsOneWidget);
      expect(find.text('Detail A'), findsNothing);
    });
  });

  group('Animated Transitions — enableHeroAnimations', () {
    testWidgets('enableHeroAnimations:true builds without error',
        (tester) async {
      _setSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(
        AdaptiveShell(
          enableHeroAnimations: true,
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const Text('Master'),
          child2: const Text('Detail'),
        ),
      ));

      expect(find.text('Detail'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'enableHeroAnimations:true uses SlideTransition for detail swap',
        (tester) async {
      _setSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      Widget? detail = const Text('Detail 1');

      await tester.pumpWidget(_app(
        StatefulBuilder(
          builder: (_, setState) => AdaptiveShell(
            enableHeroAnimations: true,
            transitionDuration: const Duration(milliseconds: 300),
            destinations: _dest,
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            child1: GestureDetector(
              key: const Key('master_tap'),
              onTap: () => setState(() => detail = const Text('Detail 2')),
              child: const Text('Master'),
            ),
            child2: detail,
          ),
        ),
      ));

      // Trigger a detail change.
      await tester.tap(find.byKey(const Key('master_tap')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Our AnimatedSwitcher has key '_detail_pane_switcher'.
      // SlideTransition should exist INSIDE it during the hero animation.
      final switcherFinder =
          find.byKey(const ValueKey('_detail_pane_switcher'));
      expect(switcherFinder, findsOneWidget);
      expect(
        find.descendant(
          of: switcherFinder,
          matching: find.byType(SlideTransition),
        ),
        findsWidgets, // at least one inside the switcher
      );

      await tester.pumpAndSettle();
      expect(find.text('Detail 2'), findsOneWidget);
    });

    testWidgets(
        'enableHeroAnimations:false (default) has no SlideTransition '
        'inside the detail switcher', (tester) async {
      _setSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      Widget? detail = const Text('Detail 1');

      await tester.pumpWidget(_app(
        StatefulBuilder(
          builder: (_, setState) => AdaptiveShell(
            enableHeroAnimations: false,
            transitionDuration: const Duration(milliseconds: 300),
            destinations: _dest,
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            child1: GestureDetector(
              key: const Key('tap'),
              onTap: () => setState(() => detail = const Text('Detail 2')),
              child: const Text('Master'),
            ),
            child2: detail,
          ),
        ),
      ));

      await tester.tap(find.byKey(const Key('tap')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Default transition uses FadeTransition — NO SlideTransition
      // should be inside our detail switcher.
      final switcherFinder =
          find.byKey(const ValueKey('_detail_pane_switcher'));
      expect(switcherFinder, findsOneWidget);
      expect(
        find.descendant(
          of: switcherFinder,
          matching: find.byType(SlideTransition),
        ),
        findsNothing,
      );

      await tester.pumpAndSettle();
      expect(find.text('Detail 2'), findsOneWidget);
    });

    testWidgets('transitionCurve and enableHeroAnimations work together',
        (tester) async {
      _setSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(
        AdaptiveShell(
          transitionCurve: Curves.easeInOutCubic,
          enableHeroAnimations: true,
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: const Text('Master'),
          child2: const Text('Detail'),
        ),
      ));

      expect(find.text('Detail'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Feature #3 — New Context Extensions
  // ═══════════════════════════════════════════════════════════════════════════

  group('Context Extensions — layoutMode', () {
    testWidgets('returns LayoutMode.compact on narrow screen', (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      LayoutMode? captured;

      await tester.pumpWidget(_app(
        AdaptiveShell(
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: Builder(builder: (ctx) {
            captured = ctx.layoutMode;
            return const SizedBox();
          }),
        ),
      ));

      expect(captured, LayoutMode.compact);
    });

    testWidgets('returns LayoutMode.medium on medium screen', (tester) async {
      _setSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      LayoutMode? captured;

      await tester.pumpWidget(_app(
        AdaptiveShell(
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: Builder(builder: (ctx) {
            captured = ctx.layoutMode;
            return const SizedBox();
          }),
        ),
      ));

      expect(captured, LayoutMode.medium);
    });

    testWidgets('returns LayoutMode.expanded on large screen', (tester) async {
      _setSize(tester, 1400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      LayoutMode? captured;

      await tester.pumpWidget(_app(
        AdaptiveShell(
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: Builder(builder: (ctx) {
            captured = ctx.layoutMode;
            return const SizedBox();
          }),
        ),
      ));

      expect(captured, LayoutMode.expanded);
    });

    testWidgets('layoutMode is an alias for screenType', (tester) async {
      _setSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      LayoutMode? viaLayoutMode;
      LayoutMode? viaScreenType;

      await tester.pumpWidget(_app(
        AdaptiveShell(
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: Builder(builder: (ctx) {
            viaLayoutMode = ctx.layoutMode;
            viaScreenType = ctx.screenType;
            return const SizedBox();
          }),
        ),
      ));

      expect(viaLayoutMode, viaScreenType);
    });
  });

  group('Context Extensions — adaptiveColumns', () {
    testWidgets('returns 1 on compact screen', (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      int? cols;

      await tester.pumpWidget(_app(
        AdaptiveShell(
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: Builder(builder: (ctx) {
            cols = ctx.adaptiveColumns;
            return const SizedBox();
          }),
        ),
      ));

      expect(cols, 1);
    });

    testWidgets('returns 2 on medium screen', (tester) async {
      _setSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      int? cols;

      await tester.pumpWidget(_app(
        AdaptiveShell(
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: Builder(builder: (ctx) {
            cols = ctx.adaptiveColumns;
            return const SizedBox();
          }),
        ),
      ));

      expect(cols, 2);
    });

    testWidgets('returns 3 on expanded screen', (tester) async {
      _setSize(tester, 1400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      int? cols;

      await tester.pumpWidget(_app(
        AdaptiveShell(
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: Builder(builder: (ctx) {
            cols = ctx.adaptiveColumns;
            return const SizedBox();
          }),
        ),
      ));

      expect(cols, 3);
    });
  });

  group('Context Extensions — adaptiveValue<T>', () {
    testWidgets('returns compact value on compact screen', (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      double? val;

      await tester.pumpWidget(_app(
        AdaptiveShell(
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: Builder(builder: (ctx) {
            val = ctx.adaptiveValue(
              compact: 8.0,
              medium: 16.0,
              expanded: 24.0,
            );
            return const SizedBox();
          }),
        ),
      ));

      expect(val, 8.0);
    });

    testWidgets('returns medium value on medium screen', (tester) async {
      _setSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      double? val;

      await tester.pumpWidget(_app(
        AdaptiveShell(
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: Builder(builder: (ctx) {
            val = ctx.adaptiveValue(
              compact: 8.0,
              medium: 16.0,
              expanded: 24.0,
            );
            return const SizedBox();
          }),
        ),
      ));

      expect(val, 16.0);
    });

    testWidgets('returns expanded value on expanded screen', (tester) async {
      _setSize(tester, 1400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      double? val;

      await tester.pumpWidget(_app(
        AdaptiveShell(
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: Builder(builder: (ctx) {
            val = ctx.adaptiveValue(
              compact: 8.0,
              medium: 16.0,
              expanded: 24.0,
            );
            return const SizedBox();
          }),
        ),
      ));

      expect(val, 24.0);
    });

    testWidgets('works with non-double generic types (String)', (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      String? val;

      await tester.pumpWidget(_app(
        AdaptiveShell(
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: Builder(builder: (ctx) {
            val = ctx.adaptiveValue(
              compact: 'mobile',
              medium: 'tablet',
              expanded: 'desktop',
            );
            return const SizedBox();
          }),
        ),
      ));

      expect(val, 'mobile');
    });

    testWidgets('works with Widget generic type', (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      Widget? chosen;

      await tester.pumpWidget(_app(
        AdaptiveShell(
          destinations: _dest,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          child1: Builder(builder: (ctx) {
            chosen = ctx.adaptiveValue<Widget>(
              compact: const Icon(Icons.phone),
              medium: const Icon(Icons.tablet),
              expanded: const Icon(Icons.desktop_mac),
            );
            return chosen!;
          }),
        ),
      ));

      // On compact we expect the phone icon
      expect(find.byIcon(Icons.phone), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // AdaptiveMasterDetail — new param pass-through
  // ═══════════════════════════════════════════════════════════════════════════

  group('AdaptiveMasterDetail — new param pass-through', () {
    testWidgets(
        'autoScale:true in AdaptiveMasterDetail shows compact on wide screen',
        (tester) async {
      _setSize(tester, 800, 1200); // portrait — autoScale is active
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(
        AdaptiveMasterDetail<String>(
          autoScale: true,
          items: const ['Alice', 'Bob'],
          destinations: _dest,
          selectedNavIndex: 0,
          onNavSelected: (_) {},
          itemBuilder: (_, item, __) => ListTile(title: Text(item)),
          detailBuilder: (_, item) => Text('Detail: $item'),
        ),
      ));

      // autoScale → compact → NavigationBar
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('persistState:true in AdaptiveMasterDetail does not throw',
        (tester) async {
      _setSize(tester, 400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(
        AdaptiveMasterDetail<String>(
          persistState: true,
          stateKey: 'master_detail_key',
          items: const ['Alice'],
          destinations: _dest,
          selectedNavIndex: 0,
          onNavSelected: (_) {},
          itemBuilder: (_, item, __) => ListTile(title: Text(item)),
          detailBuilder: (_, item) => Text('Detail: $item'),
        ),
      ));

      expect(find.text('Alice'), findsOneWidget);
      // Our keyed PageStorage should be present.
      expect(find.byKey(const ValueKey('master_detail_key')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('transitionCurve + enableHeroAnimations pass through',
        (tester) async {
      _setSize(tester, 900, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_app(
        AdaptiveMasterDetail<String>(
          transitionCurve: Curves.easeInOut,
          enableHeroAnimations: true,
          items: const ['Alice', 'Bob'],
          destinations: _dest,
          selectedNavIndex: 0,
          onNavSelected: (_) {},
          itemBuilder: (_, item, __) =>
              ListTile(key: Key(item), title: Text(item)),
          detailBuilder: (_, item) => Text('Detail: $item'),
        ),
      ));

      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();

      expect(find.text('Detail: Alice'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
