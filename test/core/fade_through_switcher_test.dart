import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/theme/motion.dart';
import 'package:little_steps/core/widgets/fade_through_switcher.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  double opacity(WidgetTester tester, String text) {
    var o = 1.0;
    for (final f in tester.widgetList<FadeTransition>(
      find.ancestor(of: find.text(text), matching: find.byType(FadeTransition)),
    )) {
      o *= f.opacity.value;
    }
    return o;
  }

  testWidgets('the old child is gone before the new one fades in', (
    tester,
  ) async {
    Widget at(String v, double h) => host(
      FadeThroughSwitcher(
        direction: AxisDirection.left,
        child: SizedBox(key: ValueKey(v), height: h, child: Text(v)),
      ),
    );
    await tester.pumpWidget(at('A', 40));
    await tester.pumpWidget(at('B', 120));
    await tester.pump(Motion.medium ~/ 2);
    expect(opacity(tester, 'A'), 0);
    expect(opacity(tester, 'B'), inExclusiveRange(0, 1));
    // The height follows instead of jumping.
    final h = tester.getSize(find.byType(FadeThroughSwitcher)).height;
    expect(h, inExclusiveRange(40, 120));
    await tester.pumpAndSettle();
    expect(find.text('A'), findsNothing);
    expect(opacity(tester, 'B'), 1);
    expect(tester.getSize(find.byType(FadeThroughSwitcher)).height, 120);
  });
}
