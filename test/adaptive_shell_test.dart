import 'package:adaptive_shell/adaptive_shell.dart';
import 'package:adaptive_shell/src/adaptive_destination.dart';
import 'package:adaptive_shell/src/breakpoints.dart';
import 'package:adaptive_shell/src/layout_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveBreakpoints', () {
    test('material3 preset has valid values', () {
      const bp = AdaptiveBreakpoints.material3;
      expect(bp.isValid, isTrue);
      expect(bp.compact, 600);
      expect(bp.medium, 840);
      expect(bp.expanded, 1200);
      expect(bp.masterRatio, 0.35);
    });

    test('tabletFirst preset has valid values', () {
      const bp = AdaptiveBreakpoints.tabletFirst;
      expect(bp.isValid, isTrue);
      expect(bp.compact, 500);
    });

    test('invalid breakpoints are detected', () {
      const bp = AdaptiveBreakpoints(compact: 1000, medium: 500, expanded: 200);
      expect(bp.isValid, isFalse);
    });
  });

  group('LayoutMode', () {
    test('has three values', () {
      expect(LayoutMode.values.length, 3);
      expect(LayoutMode.values, contains(LayoutMode.compact));
      expect(LayoutMode.values, contains(LayoutMode.medium));
      expect(LayoutMode.values, contains(LayoutMode.expanded));
    });
  });

  group('AdaptiveDestination', () {
    test('creates with required fields', () {
      const dest = AdaptiveDestination(icon: Icons.home, label: 'Home');
      expect(dest.icon, Icons.home);
      expect(dest.label, 'Home');
      expect(dest.selectedIcon, isNull);
      expect(dest.badge, 0);
    });

    test('creates with badge', () {
      const dest = AdaptiveDestination(
        icon: Icons.chat,
        label: 'Chat',
        badge: 5,
      );
      expect(dest.badge, 5);
    });
  });

  group('AdaptiveShell', () {
    testWidgets('renders compact layout on narrow screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: AdaptiveShell(
              destinations: const [
                AdaptiveDestination(icon: Icons.home, label: 'Home'),
                AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
              ],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              child1: const Text('child1'),
            ),
          ),
        ),
      );

      expect(find.text('child1'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('renders medium layout on wide screen', (tester) async {
      tester.view.physicalSize = const Size(900, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveShell(
            destinations: const [
              AdaptiveDestination(icon: Icons.home, label: 'Home'),
              AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
            ],
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            child1: const Text('child1'),
            child2: const Text('child2'),
          ),
        ),
      );

      expect(find.text('child1'), findsOneWidget);
      expect(find.text('child2'), findsOneWidget);
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('AdaptiveShell.of returns compact when no ancestor', (
      tester,
    ) async {
      late LayoutMode capturedMode;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedMode = AdaptiveShell.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedMode, LayoutMode.compact);
    });

    testWidgets(
      'shows emptyDetailPlaceholder when child2 is null on wide screen',
      (tester) async {
        tester.view.physicalSize = const Size(1000, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            home: AdaptiveShell(
              destinations: const [
                AdaptiveDestination(icon: Icons.home, label: 'Home'),
                AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
              ],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              child1: const Text('child1'),
              emptyDetailPlaceholder: const Text('No selection'),
            ),
          ),
        );

        expect(find.text('No selection'), findsOneWidget);
      },
    );
  });
}
