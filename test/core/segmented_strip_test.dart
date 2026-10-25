import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/feedback/feedback.dart';
import 'package:little_steps/core/theme/app_theme.dart';
import 'package:little_steps/core/widgets/segmented_strip.dart';

import '../helpers.dart';

const _red = Color(0xFFFF0000), _blue = Color(0xFF0000FF);

/// A one-row strip of 3 cells, 100 px each, in a stateful host.
Widget strip({Color? Function(bool on)? color}) => ProviderScope(
  overrides: [
    feedbackProvider.overrideWithValue(
      FeedbackService(
        FakeSoundPlayer(),
        haptics: true,
        sounds: true,
        sdkInt: 34,
      ),
    ),
  ],
  child: MaterialApp(
    theme: buildSorbetTheme(),
    home: Scaffold(
      body: SizedBox(
        width: 308,
        child: StatefulBuilder(
          builder: (context, setState) => SegmentedStrip(
            count: 3,
            selected: _selected,
            cellHeight: 40,
            onSelected: (i) => setState(() => _selected = i),
            itemBuilder: (_, i, on) =>
                Text('$i', style: TextStyle(color: color?.call(on))),
          ),
        ),
      ),
    ),
  ),
);

var _selected = 0;

void main() {
  setUp(() => _selected = 0);

  double left(WidgetTester tester) =>
      tester.getTopLeft(find.byKey(SegmentedStrip.indicatorKey)).dx;

  testWidgets('the selection slides from cell to cell', (tester) async {
    await tester.pumpWidget(strip());
    final start = left(tester);
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    final midway = left(tester);
    await tester.pumpAndSettle();
    // 300 px of cells (308 − 2 × 4): each cell is 100 px wide.
    expect(left(tester) - start, closeTo(200, 0.5));
    expect(midway, inExclusiveRange(start, start + 200));
  });

  testWidgets('a new target in flight keeps the momentum, no jump', (
    tester,
  ) async {
    await tester.pumpWidget(strip());
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    final before = left(tester);
    // Mid-fade the old look of cell 0 lies over it: tap the cell itself.
    await tester.tap(find.text('0').first);
    await tester.pump();
    expect(left(tester), closeTo(before, 0.5));
    await tester.pump(const Duration(milliseconds: 16));
    // Still heading right for a moment, as a spring carries its speed.
    expect(left(tester), greaterThan(before));
    await tester.pumpAndSettle();
    expect(left(tester), closeTo(4, 0.5));
  });

  testWidgets('the selected text colour fades even when the cell sets it', (
    tester,
  ) async {
    await tester.pumpWidget(strip(color: (on) => on ? _red : _blue));
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    final fades = find.ancestor(
      of: find.text('2'),
      matching: find.byType(FadeTransition),
    );
    expect([
      for (final e in fades.evaluate())
        (e.widget as FadeTransition).opacity.value,
    ], contains(inExclusiveRange(0, 1)));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.text('2')).style!.color, _red);
  });

  testWidgets('changing segment ticks', (tester) async {
    final haptics = recordHaptics(tester);
    await tester.pumpWidget(strip());
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    expect(haptics, ['HapticFeedbackType.selectionClick']);
  });
}
