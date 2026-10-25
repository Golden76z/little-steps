import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/widgets/rolling_text.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('RollingText swaps values with a transition, then settles', (
    tester,
  ) async {
    await tester.pumpWidget(host(const RollingText('50 %')));
    await tester.pumpWidget(host(const RollingText('63 %')));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('50 %'), findsOneWidget); // leaving
    expect(find.text('63 %'), findsOneWidget); // arriving
    await tester.pumpAndSettle();
    expect(find.text('50 %'), findsNothing);
    expect(find.text('63 %'), findsOneWidget);
  });

  Future<double> arrivingOffset(WidgetTester tester, int from, int to) async {
    await tester.pumpWidget(host(RollingText('$from', value: from)));
    final rest = tester.getTopLeft(find.text('$from')).dy;
    await tester.pumpWidget(host(RollingText('$to', value: to)));
    await tester.pump(const Duration(milliseconds: 30));
    return tester.getTopLeft(find.text('$to')).dy - rest;
  }

  testWidgets('a rise comes in from below', (tester) async {
    expect(await arrivingOffset(tester, 3, 4), greaterThan(0));
  });

  testWidgets('a drop comes in from above', (tester) async {
    expect(await arrivingOffset(tester, 4, 3), lessThan(0));
  });

  testWidgets('perCharacter rolls only the characters that change', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const RollingText('12:34', perCharacter: true)),
    );
    await tester.pumpWidget(
      host(const RollingText('12:35', perCharacter: true)),
    );
    await tester.pump(const Duration(milliseconds: 30));
    expect(find.text('4'), findsOneWidget); // leaving
    expect(find.text('5'), findsOneWidget); // arriving
    expect(find.text('1'), findsOneWidget); // untouched, not doubled
    expect(find.bySemanticsLabel('12:35'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('4'), findsNothing);
  });
}
