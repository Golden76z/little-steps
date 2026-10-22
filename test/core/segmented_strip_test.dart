import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/theme/app_theme.dart';
import 'package:little_steps/core/widgets/segmented_strip.dart';

void main() {
  testWidgets('the selection slides from cell to cell', (tester) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSorbetTheme(),
        home: Scaffold(
          body: SizedBox(
            width: 308,
            child: StatefulBuilder(
              builder: (context, setState) => SegmentedStrip(
                count: 3,
                selected: selected,
                cellHeight: 40,
                onSelected: (i) => setState(() => selected = i),
                itemBuilder: (_, i, _) => Text('$i'),
              ),
            ),
          ),
        ),
      ),
    );
    double left() => tester.getTopLeft(find.byKey(SegmentedStrip.indicatorKey)).dx;
    final start = left();
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    final midway = left();
    await tester.pumpAndSettle();
    // 300 px of cells (308 − 2 × 4): each cell is 100 px wide.
    expect(left() - start, closeTo(200, 0.5));
    expect(midway, inExclusiveRange(start, start + 200));
  });
}
