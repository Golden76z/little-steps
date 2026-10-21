import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/app.dart';
import 'package:little_steps/core/icons/phosphor_icons.dart';

Future<void> pumpApp(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(ProviderScope(child: LittleStepsApp(locale: locale)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('opens on Today with the floating bar', (tester) async {
    await pumpApp(tester);
    expect(find.text('Today'), findsOneWidget);
    expect(find.bySemanticsLabel('Main navigation'), findsOneWidget);
    expect(find.byIcon(PhosphorIconsFill.house), findsOneWidget);
    expect(find.byIcon(PhosphorIconsRegular.chartBar), findsOneWidget);
  });

  testWidgets('a tab switches screen and its icon to Fill', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.bySemanticsLabel('Progress'));
    await tester.pumpAndSettle();
    expect(find.text('Progress'), findsOneWidget);
    expect(find.byIcon(PhosphorIconsFill.chartBar), findsOneWidget);
    expect(find.byIcon(PhosphorIconsRegular.house), findsOneWidget);
  });

  testWidgets('+ opens the creation flow above the shell', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.bySemanticsLabel('New habit'));
    await tester.pumpAndSettle();
    expect(find.text('New habit'), findsOneWidget);
    expect(find.bySemanticsLabel('Main navigation'), findsNothing);
  });

  testWidgets('French strings', (tester) async {
    await pumpApp(tester, locale: const Locale('fr'));
    expect(find.text('Aujourd’hui'), findsOneWidget);
    expect(find.bySemanticsLabel('Navigation principale'), findsOneWidget);
    expect(find.bySemanticsLabel('Trophées'), findsOneWidget);
  });

  testWidgets('bar meets tap-target and label guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('holds with 2x system text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpApp(tester, locale: const Locale('fr'));
    expect(tester.takeException(), isNull);
  });
}
