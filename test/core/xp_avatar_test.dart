import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/theme/app_theme.dart';
import 'package:little_steps/core/widgets/xp_avatar.dart';

Widget avatar(double fraction, int level) => MaterialApp(
  theme: buildSorbetTheme(),
  home: Center(
    child: XpAvatar(fraction: fraction, level: level, semanticLabel: 'XP'),
  ),
);

double ring(WidgetTester tester) =>
    (tester
                    .widget<CustomPaint>(
                      find.descendant(
                        of: find.byType(XpAvatar),
                        matching: find.byType(CustomPaint),
                      ),
                    )
                    .painter!
                as dynamic)
            .fraction
        as double;

/// The ring, frame by frame, for 2 s.
Future<List<double>> run(WidgetTester tester) async {
  await tester.pump();
  return [
    for (var i = 0; i < 125; i++)
      await tester
          .pump(const Duration(milliseconds: 16))
          .then((_) => ring(tester)),
  ];
}

/// Indices where the ring jumps between full and empty.
List<int> wraps(List<double> seen) => [
  for (var i = 1; i < seen.length; i++)
    if ((seen[i] - seen[i - 1]).abs() > 0.5) i,
];

void main() {
  testWidgets('a level up fills the ring to the end, then starts from 0', (
    tester,
  ) async {
    await tester.pumpWidget(avatar(0.8, 1));
    await tester.pumpWidget(avatar(0.2, 2));
    final seen = await run(tester);
    expect(wraps(seen), hasLength(1));
    final w = wraps(seen).single;
    expect(seen[w - 1], closeTo(1, 0.01));
    // Never backwards, on either side of the wrap.
    for (var i = 1; i < seen.length; i++) {
      if (i != w) expect(seen[i], greaterThanOrEqualTo(seen[i - 1] - 1e-9));
    }
    expect(seen.last, closeTo(0.2, 1e-3));
  });

  testWidgets('a level lost empties the ring, then comes back from full', (
    tester,
  ) async {
    await tester.pumpWidget(avatar(0.2, 2));
    await tester.pumpWidget(avatar(0.8, 1));
    final seen = await run(tester);
    expect(wraps(seen), hasLength(1));
    final w = wraps(seen).single;
    expect(seen[w - 1], closeTo(0, 0.01));
    for (var i = 1; i < seen.length; i++) {
      if (i != w) expect(seen[i], lessThanOrEqualTo(seen[i - 1] + 1e-9));
    }
    expect(seen.last, closeTo(0.8, 1e-3));
  });
}
