import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/theme/motion.dart';
import 'package:little_steps/core/widgets/press_scale.dart';
import 'package:little_steps/core/widgets/rolling_text.dart';

Widget host(Widget child, {bool reduce = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduce),
    child: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('durations vanish when the system asks for less motion', (tester) async {
    late Duration normal, reduced;
    await tester.pumpWidget(host(Builder(builder: (c) {
      normal = c.motion(Motion.medium);
      return const SizedBox();
    })));
    await tester.pumpWidget(host(Builder(builder: (c) {
      reduced = c.motion(Motion.medium);
      return const SizedBox();
    }), reduce: true));
    expect((normal, reduced), (Motion.medium, Duration.zero));
  });

  testWidgets('PressScale shrinks while pressed, then springs back', (tester) async {
    var taps = 0;
    await tester.pumpWidget(host(PressScale(child: TextButton(onPressed: () => taps++, child: const Text('Go')))));
    double scale() => tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;
    final gesture = await tester.startGesture(tester.getCenter(find.text('Go')));
    await tester.pump();
    expect(scale(), lessThan(1));
    await gesture.up();
    await tester.pumpAndSettle();
    expect((scale(), taps), (1.0, 1));
  });

  testWidgets('PressScale lets go once the finger starts a scroll', (tester) async {
    await tester.pumpWidget(host(const PressScale(child: SizedBox.square(dimension: 100))));
    double scale() => tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;
    final gesture = await tester.startGesture(tester.getCenter(find.byType(PressScale)));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 30));
    await tester.pump();
    expect(scale(), 1);
    await gesture.up();
  });

  testWidgets('a disabled PressScale does not sink', (tester) async {
    await tester.pumpWidget(host(const PressScale(enabled: false, child: SizedBox.square(dimension: 100))));
    final gesture = await tester.startGesture(tester.getCenter(find.byType(PressScale)));
    await tester.pump();
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    await gesture.up();
  });

  testWidgets('RollingText swaps values with a transition, then settles', (tester) async {
    Widget at(String v) => host(RollingText(v));
    await tester.pumpWidget(at('50 %'));
    await tester.pumpWidget(at('63 %'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('50 %'), findsOneWidget); // leaving
    expect(find.text('63 %'), findsOneWidget); // arriving
    await tester.pumpAndSettle();
    expect(find.text('50 %'), findsNothing);
    expect(find.text('63 %'), findsOneWidget);
  });
}
