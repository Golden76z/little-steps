import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/theme/motion.dart';
import 'package:little_steps/core/widgets/spring_builder.dart';

Widget host(Widget child, {bool reduce = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduce),
    child: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  late double seen;
  Widget spring(double v, {bool reduce = false, double? from}) => host(
    SpringBuilder(
      value: v,
      from: from,
      spring: Springs.smooth,
      builder: (context, value, child) {
        seen = value;
        return const SizedBox();
      },
    ),
    reduce: reduce,
  );

  testWidgets('SpringBuilder settles on its target', (tester) async {
    await tester.pumpWidget(spring(0));
    expect(seen, 0);
    await tester.pumpWidget(spring(100));
    await tester.pump(const Duration(milliseconds: 16));
    expect(seen, greaterThan(0));
    expect(seen, lessThan(100));
    await tester.pumpAndSettle();
    expect(seen, 100);
  });

  testWidgets('SpringBuilder animates from `from` on mount', (tester) async {
    await tester.pumpWidget(spring(1, from: 0));
    expect(seen, 0);
    await tester.pumpAndSettle();
    expect(seen, 1);
  });

  testWidgets('a target change in flight keeps value and velocity', (
    tester,
  ) async {
    await tester.pumpWidget(spring(0));
    await tester.pumpWidget(spring(100));
    await tester.pump(const Duration(milliseconds: 100));
    final before = seen;
    await tester.pump(const Duration(milliseconds: 16));
    final speed = seen - before;
    expect(speed, greaterThan(0));
    // Retarget further away: no jump, still moving the same way.
    await tester.pumpWidget(spring(200));
    final at = seen;
    expect(at, closeTo(before + speed, 0.001));
    await tester.pump(const Duration(milliseconds: 16));
    expect(seen - at, greaterThan(speed * 0.5));
    await tester.pumpAndSettle();
    expect(seen, 200);
  });

  testWidgets('with reduced motion, the target is reached at once', (
    tester,
  ) async {
    await tester.pumpWidget(spring(0, reduce: true));
    await tester.pumpWidget(spring(100, reduce: true));
    expect(seen, 100);
    await tester.pumpWidget(spring(5, reduce: true, from: 0));
    expect(seen, 5);
  });

  group('Pop', () {
    double scale(WidgetTester tester) => tester
        .widget<ScaleTransition>(
          find.descendant(
            of: find.byType(Pop),
            matching: find.byType(ScaleTransition),
          ),
        )
        .scale
        .value;

    Widget pop(int trigger, {bool reduce = false}) => host(
      Pop(trigger: trigger, child: const SizedBox.square(dimension: 40)),
      reduce: reduce,
    );

    testWidgets('does not animate on mount', (tester) async {
      await tester.pumpWidget(pop(3));
      await tester.pump(const Duration(milliseconds: 50));
      expect(scale(tester), 1);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('dips, peaks above 1, then rests at 1 when triggered', (
      tester,
    ) async {
      await tester.pumpWidget(pop(0));
      await tester.pumpWidget(pop(1));
      var low = 1.0, high = 1.0;
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        low = scale(tester) < low ? scale(tester) : low;
        high = scale(tester) > high ? scale(tester) : high;
      }
      expect(low, lessThan(1));
      expect(high, closeTo(1.04, 0.01));
      await tester.pumpAndSettle();
      expect(scale(tester), 1);
    });

    testWidgets('stays still with reduced motion', (tester) async {
      await tester.pumpWidget(pop(0, reduce: true));
      await tester.pumpWidget(pop(1, reduce: true));
      await tester.pump(const Duration(milliseconds: 100));
      expect(scale(tester), 1);
    });
  });
}
