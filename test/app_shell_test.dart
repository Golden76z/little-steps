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
}
