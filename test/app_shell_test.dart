import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/icons/phosphor_icons.dart';

import 'helpers.dart';

void main() {
  testApp('opens on Today with the floating bar', (tester, db) async {
    await pumpApp(tester, db);
    expect(find.text('Today'), findsOneWidget);
    expect(find.bySemanticsLabel('Main navigation'), findsOneWidget);
    expect(find.byIcon(PhosphorIconsFill.house), findsOneWidget);
    expect(find.byIcon(PhosphorIconsRegular.chartBar), findsOneWidget);
  });

  testApp('a tab switches screen and its icon to Fill', (tester, db) async {
    await pumpApp(tester, db);
    await tester.tap(find.bySemanticsLabel('Progress'));
    await tester.pumpAndSettle();
    expect(find.text('Progress'), findsOneWidget);
    expect(find.byIcon(PhosphorIconsFill.chartBar), findsOneWidget);
    expect(find.byIcon(PhosphorIconsRegular.house), findsOneWidget);
  });

  testApp('+ opens the creation flow above the shell', (tester, db) async {
    await pumpApp(tester, db);
    await tester.tap(find.bySemanticsLabel('New habit'));
    await tester.pumpAndSettle();
    expect(find.text('New habit'), findsOneWidget);
    expect(find.bySemanticsLabel('Main navigation'), findsNothing);
  });

  testApp('an opened screen slides in from the right', (tester, db) async {
    await pumpApp(tester, db);
    await tester.tap(find.bySemanticsLabel('New habit'));
    for (var i = 0; i < 30 && find.text('1/3').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump(const Duration(milliseconds: 60));
    final slides = tester.widgetList<SlideTransition>(
      find.ancestor(
        of: find.text('1/3'),
        matching: find.byType(SlideTransition),
      ),
    );
    expect(slides.any((s) => s.position.value.dx > 0), isTrue);
    await tester.pumpAndSettle();
  });

  testApp('French strings', (tester, db) async {
    await pumpApp(tester, db, locale: 'fr');
    expect(find.text('Aujourd’hui'), findsOneWidget);
    expect(find.bySemanticsLabel('Navigation principale'), findsOneWidget);
    expect(find.bySemanticsLabel('Trophées'), findsOneWidget);
  });

  testApp('bar meets tap-target and label guidelines', (tester, db) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, db);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testApp('holds with 2x system text', (tester, db) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpApp(tester, db, locale: 'fr');
    expect(tester.takeException(), isNull);
  });

  testApp('the new tab fades in', (tester, db) async {
    await pumpApp(tester, db);
    await tester.tap(find.bySemanticsLabel('Progress'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    final fade = tester.widget<FadeTransition>(
      find.ancestor(
        of: find.text('Progress'),
        matching: find.byKey(const ValueKey('branch-1')),
      ),
    );
    expect(fade.opacity.value, inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    expect(fade.opacity.value, 1);
  });

  testApp('a tab change mid-fade carries on from the current opacity', (
    tester,
    db,
  ) async {
    await pumpApp(tester, db);
    FadeTransition branch(int i) =>
        tester.widget<FadeTransition>(find.byKey(ValueKey('branch-$i')));
    await tester.tap(find.bySemanticsLabel('Progress'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    final midway = branch(1).opacity.value;
    expect(midway, inExclusiveRange(0, 1));
    await tester.tap(find.bySemanticsLabel('Trophies'));
    await tester.pump();
    expect(branch(2).opacity.value, greaterThanOrEqualTo(midway - 0.01));
    await tester.pumpAndSettle();
    expect(branch(2).opacity.value, 1);
  });

  testApp('a tab change ticks', (tester, db) async {
    await pumpApp(tester, db);
    final haptics = recordHaptics(tester);
    await tester.tap(find.bySemanticsLabel('Progress'));
    await tester.pumpAndSettle();
    expect(haptics, ['HapticFeedbackType.selectionClick']);
  });
}
