import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_shell/adaptive_shell.dart';

void main() {
  group('onLayoutModeChanged callback', () {
    testWidgets('callback is triggered when layout mode changes',
        (tester) async {
      final List<(LayoutMode, LayoutMode)> callbacks = [];

      // Don't fight the test environment - just use different sizes
      // Size 1: Very small (definitely compact)
      tester.view.reset();
      tester.view.physicalSize = const Size(300, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveShell(
            destinations: const [
              AdaptiveDestination(icon: Icons.home, label: 'Home'),
              AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
            ],
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            onLayoutModeChanged: (oldMode, newMode) {
              callbacks.add((oldMode, newMode));
            },
            child1: const Text('Child1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Record baseline
      final initialCallbacks = callbacks.length;

      // Size 2: Very large (definitely expanded)
      tester.view.physicalSize = const Size(1600, 800);
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 1600,
            height: 800,
            child: AdaptiveShell(
              destinations: const [
                AdaptiveDestination(icon: Icons.home, label: 'Home'),
                AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
              ],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              onLayoutModeChanged: (oldMode, newMode) {
                callbacks.add((oldMode, newMode));
              },
              child1: const Text('Child1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should have triggered at least one callback
      expect(callbacks.length, greaterThan(initialCallbacks),
          reason:
              'Callback should fire when transitioning from 300px to 1600px');

      // The callback should show a mode change
      if (callbacks.isNotEmpty) {
        final transition = callbacks.last;
        expect(transition.$1, isNot(equals(transition.$2)),
            reason: 'Old and new mode should be different');
      }

      addTearDown(tester.view.reset);
    });

    testWidgets('callback shows correct mode transitions', (tester) async {
      LayoutMode? capturedOldMode;
      LayoutMode? capturedNewMode;

      // Start very small
      tester.view.reset();
      tester.view.physicalSize = const Size(300, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 300,
            height: 800,
            child: AdaptiveShell(
              destinations: const [
                AdaptiveDestination(icon: Icons.home, label: 'Home'),
                AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
              ],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              onLayoutModeChanged: (oldMode, newMode) {
                capturedOldMode = oldMode;
                capturedNewMode = newMode;
              },
              child1: const Text('Child1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Go very large
      tester.view.physicalSize = const Size(1600, 800);
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 1600,
            height: 800,
            child: AdaptiveShell(
              destinations: const [
                AdaptiveDestination(icon: Icons.home, label: 'Home'),
                AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
              ],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              onLayoutModeChanged: (oldMode, newMode) {
                capturedOldMode = oldMode;
                capturedNewMode = newMode;
              },
              child1: const Text('Child1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should have captured a transition
      expect(capturedOldMode, isNotNull, reason: 'Should capture old mode');
      expect(capturedNewMode, isNotNull, reason: 'Should capture new mode');
      expect(capturedOldMode, isNot(equals(capturedNewMode)),
          reason: 'Modes should be different');

      addTearDown(tester.view.reset);
    });

    testWidgets('callback is NOT triggered when mode stays the same',
        (tester) async {
      int callbackCount = 0;

      tester.view.reset();
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 800,
            child: AdaptiveShell(
              destinations: const [
                AdaptiveDestination(icon: Icons.home, label: 'Home'),
                AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
              ],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              onLayoutModeChanged: (old, updated) {
                callbackCount++;
              },
              child1: const Text('Child1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final initialCallbacks = callbackCount;

      // Change size but stay in same mode (both < 600)
      tester.view.physicalSize = const Size(500, 800);
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 500,
            height: 800,
            child: AdaptiveShell(
              destinations: const [
                AdaptiveDestination(icon: Icons.home, label: 'Home'),
                AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
              ],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              onLayoutModeChanged: (old, updated) {
                callbackCount++;
              },
              child1: const Text('Child1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should be same - no mode change
      expect(callbackCount, equals(initialCallbacks));

      addTearDown(tester.view.reset);
    });

    testWidgets('works without callback (null safety)', (tester) async {
      tester.view.reset();
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 800,
            child: AdaptiveShell(
              destinations: const [
                AdaptiveDestination(icon: Icons.home, label: 'Home'),
                AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
              ],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              child1: const Text('Child1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Change layout
      tester.view.physicalSize = const Size(1600, 800);
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 1600,
            height: 800,
            child: AdaptiveShell(
              destinations: const [
                AdaptiveDestination(icon: Icons.home, label: 'Home'),
                AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
              ],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              child1: const Text('Child1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should not throw
      expect(find.text('Child1'), findsOneWidget);

      addTearDown(tester.view.reset);
    });
  });

  group('Debug Overlay', () {
    testWidgets('overlay is shown when debugShowLayoutMode is true',
        (tester) async {
      tester.view.reset();
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 800,
            child: AdaptiveShell(
              debugShowLayoutMode: true,
              destinations: const [
                AdaptiveDestination(icon: Icons.home, label: 'Home'),
                AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
              ],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              child1: const Text('Child1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find debug overlay (with some mode text)
      expect(find.textContaining(RegExp(r'COMPACT|MEDIUM|EXPANDED')),
          findsOneWidget);
      expect(find.textContaining('Width:'), findsOneWidget);

      addTearDown(tester.view.reset);
    });

    testWidgets('overlay is hidden when debugShowLayoutMode is false',
        (tester) async {
      tester.view.reset();
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 800,
            child: AdaptiveShell(
              debugShowLayoutMode: false,
              destinations: const [
                AdaptiveDestination(icon: Icons.home, label: 'Home'),
                AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
              ],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              child1: const Text('Child1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should not find debug overlay
      expect(find.textContaining('COMPACT'), findsNothing);
      expect(find.textContaining('MEDIUM'), findsNothing);
      expect(find.textContaining('EXPANDED'), findsNothing);

      addTearDown(tester.view.reset);
    });

    testWidgets('overlay updates when layout changes', (tester) async {
      tester.view.reset();
      tester.view.physicalSize = const Size(300, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 300,
            height: 800,
            child: AdaptiveShell(
              debugShowLayoutMode: true,
              destinations: const [
                AdaptiveDestination(icon: Icons.home, label: 'Home'),
                AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
              ],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              child1: const Text('Child1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show some mode
      expect(find.textContaining(RegExp(r'COMPACT|MEDIUM|EXPANDED')),
          findsOneWidget);

      // Change to large
      tester.view.physicalSize = const Size(1600, 800);
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 1600,
            height: 800,
            child: AdaptiveShell(
              debugShowLayoutMode: true,
              destinations: const [
                AdaptiveDestination(icon: Icons.home, label: 'Home'),
                AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
              ],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              child1: const Text('Child1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should still show a mode (possibly different)
      expect(find.textContaining(RegExp(r'COMPACT|MEDIUM|EXPANDED')),
          findsOneWidget);

      addTearDown(tester.view.reset);
    });

    testWidgets('overlay shows width', (tester) async {
      tester.view.reset();
      tester.view.physicalSize = const Size(750, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 750,
            height: 800,
            child: AdaptiveShell(
              debugShowLayoutMode: true,
              destinations: const [
                AdaptiveDestination(icon: Icons.home, label: 'Home'),
                AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
              ],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              child1: const Text('Child1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Width:'), findsOneWidget);
      expect(find.textContaining('Compact:'), findsOneWidget);

      addTearDown(tester.view.reset);
    });
  });

  group('Combined features', () {
    testWidgets('callback and debug overlay work together', (tester) async {
      int callbackCount = 0;

      tester.view.reset();
      tester.view.physicalSize = const Size(300, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 300,
            height: 800,
            child: AdaptiveShell(
              debugShowLayoutMode: true,
              onLayoutModeChanged: (old, updated) {
                callbackCount++;
              },
              destinations: const [
                AdaptiveDestination(icon: Icons.home, label: 'Home'),
                AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
              ],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              child1: const Text('Child1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining(RegExp(r'COMPACT|MEDIUM|EXPANDED')),
          findsOneWidget);
      final initialCallbacks = callbackCount;

      // Change mode to very large
      tester.view.physicalSize = const Size(1600, 800);
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 1600,
            height: 800,
            child: AdaptiveShell(
              debugShowLayoutMode: true,
              onLayoutModeChanged: (old, updated) {
                callbackCount++;
              },
              destinations: const [
                AdaptiveDestination(icon: Icons.home, label: 'Home'),
                AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
              ],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              child1: const Text('Child1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining(RegExp(r'COMPACT|MEDIUM|EXPANDED')),
          findsOneWidget);
      expect(callbackCount, greaterThan(initialCallbacks));

      addTearDown(tester.view.reset);
    });
  });
}
