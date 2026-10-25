import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/theme/motion.dart';

Widget host(Widget child, {bool reduce = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduce),
    child: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('durations vanish when the system asks for less motion', (
    tester,
  ) async {
    late Duration normal, reduced;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (c) {
            normal = c.motion(Motion.medium);
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pumpWidget(
      host(
        Builder(
          builder: (c) {
            reduced = c.motion(Motion.medium);
            return const SizedBox();
          },
        ),
        reduce: true,
      ),
    );
    expect((normal, reduced), (Motion.medium, Duration.zero));
  });

  test('SpringCurve runs 0 → 1 without overshoot, fast then gentle', () {
    final curve = SpringCurve(Springs.smooth, Motion.resize);
    var last = 0.0;
    for (var i = 1; i <= 20; i++) {
      final v = curve.transform(i / 20);
      expect(v, greaterThanOrEqualTo(last));
      expect(v, lessThanOrEqualTo(1));
      last = v;
    }
    expect(curve.transform(1), 1);
    expect(curve.transform(0.3), greaterThan(0.5));
  });
}
