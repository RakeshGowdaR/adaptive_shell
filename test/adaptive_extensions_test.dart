import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_shell/adaptive_shell.dart';

void main() {
  group('AdaptiveContextExtensions', () {
    // Helper to set actual screen size in tests
    Widget buildTestApp({
      required double width,
      required double height,
      required Widget Function(BuildContext) builder,
    }) {
      return MaterialApp(
        home: SizedBox(
          width: width,
          height: height,
          child: AdaptiveShell(
            destinations: const [
              AdaptiveDestination(icon: Icons.home, label: 'Home'),
              AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
            ],
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            child1: Builder(builder: builder),
          ),
        ),
      );
    }

    testWidgets('screenType returns correct LayoutMode', (tester) async {
      LayoutMode? capturedMode;

      // Set explicit screen size for test
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildTestApp(
          width: 400,
          height: 800,
          builder: (context) {
            capturedMode = context.screenType;
            return const Text('Child1');
          },
        ),
      );

      expect(capturedMode, isA<LayoutMode>());
    });

    testWidgets('isCompact returns true for small screens', (tester) async {
      bool? isCompact;

      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildTestApp(
          width: 400,
          height: 800,
          builder: (context) {
            isCompact = context.isCompact;
            return const Text('Child1');
          },
        ),
      );

      expect(isCompact, isTrue);
    });

    testWidgets('isMedium returns true for medium screens', (tester) async {
      bool? isMedium;

      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildTestApp(
          width: 700,
          height: 800,
          builder: (context) {
            isMedium = context.isMedium;
            return const Text('Child1');
          },
        ),
      );

      expect(isMedium, isTrue);
    });

    testWidgets('isExpanded returns true for large screens', (tester) async {
      bool? isExpanded;

      tester.view.physicalSize = const Size(1400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildTestApp(
          width: 1400,
          height: 800,
          builder: (context) {
            isExpanded = context.isExpanded;
            return const Text('Child1');
          },
        ),
      );

      expect(isExpanded, isTrue);
    });

    testWidgets('isMobile alias works correctly', (tester) async {
      bool? isMobile;

      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildTestApp(
          width: 400,
          height: 800,
          builder: (context) {
            isMobile = context.isMobile;
            return const Text('Child1');
          },
        ),
      );

      expect(isMobile, isTrue);
    });

    testWidgets('isTablet returns true for medium screens', (tester) async {
      bool? isTablet;

      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildTestApp(
          width: 700,
          height: 800,
          builder: (context) {
            isTablet = context.isTablet;
            return const Text('Child1');
          },
        ),
      );

      expect(isTablet, isTrue);
    });

    testWidgets('isTablet returns true for expanded screens', (tester) async {
      bool? isTablet;

      tester.view.physicalSize = const Size(1400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildTestApp(
          width: 1400,
          height: 800,
          builder: (context) {
            isTablet = context.isTablet;
            return const Text('Child1');
          },
        ),
      );

      expect(isTablet, isTrue);
    });

    testWidgets('isDesktop alias works correctly', (tester) async {
      bool? isDesktop;

      tester.view.physicalSize = const Size(1400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildTestApp(
          width: 1400,
          height: 800,
          builder: (context) {
            isDesktop = context.isDesktop;
            return const Text('Child1');
          },
        ),
      );

      expect(isDesktop, isTrue);
    });

    testWidgets('isTwoPane returns false on compact', (tester) async {
      bool? isTwoPane;

      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildTestApp(
          width: 400,
          height: 800,
          builder: (context) {
            isTwoPane = context.isTwoPane;
            return const Text('Child1');
          },
        ),
      );

      expect(isTwoPane, isFalse);
    });

    testWidgets('isTwoPane returns true on medium with child2', (tester) async {
      bool? isTwoPane;

      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 700,
            height: 800,
            child: AdaptiveShell(
              destinations: const [
                AdaptiveDestination(icon: Icons.home, label: 'Home'),
                AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
              ],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              child1: Builder(
                builder: (context) {
                  isTwoPane = context.isTwoPane;
                  return const Text('Child1');
                },
              ),
              child2: const Text('Child2'),
            ),
          ),
        ),
      );

      expect(isTwoPane, isTrue);
    });

    testWidgets('adaptiveWidth scales correctly', (tester) async {
      final results = <String, double>{};

      // Test compact
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        buildTestApp(
          width: 400,
          height: 800,
          builder: (context) {
            results['compact'] = context.adaptiveWidth(100);
            return const Text('Child1');
          },
        ),
      );

      // Test medium
      tester.view.physicalSize = const Size(700, 800);
      await tester.pumpWidget(
        buildTestApp(
          width: 700,
          height: 800,
          builder: (context) {
            results['medium'] = context.adaptiveWidth(100);
            return const Text('Child1');
          },
        ),
      );

      // Test expanded
      tester.view.physicalSize = const Size(1400, 800);
      await tester.pumpWidget(
        buildTestApp(
          width: 1400,
          height: 800,
          builder: (context) {
            results['expanded'] = context.adaptiveWidth(100);
            return const Text('Child1');
          },
        ),
      );

      addTearDown(tester.view.reset);

      expect(results['compact'], equals(100.0));
      expect(results['medium'], equals(120.0));
      expect(results['expanded'], equals(150.0));
    });

    testWidgets('adaptiveHeight scales correctly', (tester) async {
      final results = <String, double>{};

      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        buildTestApp(
          width: 400,
          height: 800,
          builder: (context) {
            results['compact'] = context.adaptiveHeight(100);
            return const Text('Child1');
          },
        ),
      );

      tester.view.physicalSize = const Size(700, 800);
      await tester.pumpWidget(
        buildTestApp(
          width: 700,
          height: 800,
          builder: (context) {
            results['medium'] = context.adaptiveHeight(100);
            return const Text('Child1');
          },
        ),
      );

      tester.view.physicalSize = const Size(1400, 800);
      await tester.pumpWidget(
        buildTestApp(
          width: 1400,
          height: 800,
          builder: (context) {
            results['expanded'] = context.adaptiveHeight(100);
            return const Text('Child1');
          },
        ),
      );

      addTearDown(tester.view.reset);

      // Use closeTo for floating point comparisons
      expect(results['compact'], equals(100.0));
      expect(results['medium'], closeTo(115.0, 0.01));
      expect(results['expanded'], closeTo(130.0, 0.01));
    });

    testWidgets('adaptivePadding returns correct EdgeInsets', (tester) async {
      final results = <String, EdgeInsets>{};

      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        buildTestApp(
          width: 400,
          height: 800,
          builder: (context) {
            results['compact'] = context.adaptivePadding();
            return const Text('Child1');
          },
        ),
      );

      tester.view.physicalSize = const Size(700, 800);
      await tester.pumpWidget(
        buildTestApp(
          width: 700,
          height: 800,
          builder: (context) {
            results['medium'] = context.adaptivePadding();
            return const Text('Child1');
          },
        ),
      );

      tester.view.physicalSize = const Size(1400, 800);
      await tester.pumpWidget(
        buildTestApp(
          width: 1400,
          height: 800,
          builder: (context) {
            results['expanded'] = context.adaptivePadding();
            return const Text('Child1');
          },
        ),
      );

      addTearDown(tester.view.reset);

      expect(results['compact'], equals(const EdgeInsets.all(16.0)));
      expect(results['medium'], equals(const EdgeInsets.all(24.0)));
      expect(results['expanded'], equals(const EdgeInsets.all(32.0)));
    });

    testWidgets('adaptivePadding with custom values', (tester) async {
      EdgeInsets? customPadding;

      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildTestApp(
          width: 400,
          height: 800,
          builder: (context) {
            customPadding = context.adaptivePadding(
              compact: 8.0,
              medium: 12.0,
              expanded: 20.0,
            );
            return const Text('Child1');
          },
        ),
      );

      expect(customPadding, equals(const EdgeInsets.all(8.0)));
    });

    testWidgets('adaptiveFontSize scales correctly', (tester) async {
      final results = <String, double>{};

      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        buildTestApp(
          width: 400,
          height: 800,
          builder: (context) {
            results['compact'] = context.adaptiveFontSize(16);
            return const Text('Child1');
          },
        ),
      );

      tester.view.physicalSize = const Size(700, 800);
      await tester.pumpWidget(
        buildTestApp(
          width: 700,
          height: 800,
          builder: (context) {
            results['medium'] = context.adaptiveFontSize(16);
            return const Text('Child1');
          },
        ),
      );

      tester.view.physicalSize = const Size(1400, 800);
      await tester.pumpWidget(
        buildTestApp(
          width: 1400,
          height: 800,
          builder: (context) {
            results['expanded'] = context.adaptiveFontSize(16);
            return const Text('Child1');
          },
        ),
      );

      addTearDown(tester.view.reset);

      expect(results['compact'], equals(16.0));
      expect(results['medium'], equals(17.6));
      expect(results['expanded'], equals(19.2));
    });

    testWidgets('adaptiveSpacing scales correctly', (tester) async {
      final results = <String, double>{};

      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        buildTestApp(
          width: 400,
          height: 800,
          builder: (context) {
            results['compact'] = context.adaptiveSpacing(8);
            return const Text('Child1');
          },
        ),
      );

      tester.view.physicalSize = const Size(700, 800);
      await tester.pumpWidget(
        buildTestApp(
          width: 700,
          height: 800,
          builder: (context) {
            results['medium'] = context.adaptiveSpacing(8);
            return const Text('Child1');
          },
        ),
      );

      tester.view.physicalSize = const Size(1400, 800);
      await tester.pumpWidget(
        buildTestApp(
          width: 1400,
          height: 800,
          builder: (context) {
            results['expanded'] = context.adaptiveSpacing(8);
            return const Text('Child1');
          },
        ),
      );

      addTearDown(tester.view.reset);

      expect(results['compact'], equals(8.0));
      expect(results['medium'], equals(10.0));
      expect(results['expanded'], equals(12.0));
    });
  });
}
