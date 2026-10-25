import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/widgets/press_scale.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('PressSink', () {
    late double pressed;
    Widget sink({bool enabled = true}) => host(
      PressSink(
        depth: 4,
        enabled: enabled,
        builder: (context, p) {
          pressed = p;
          return const ColoredBox(
            color: Color(0xFF000000),
            child: SizedBox.square(dimension: 100),
          );
        },
      ),
    );

    testWidgets('sinks while the finger rests, then springs back', (
      tester,
    ) async {
      await tester.pumpWidget(sink());
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PressSink)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(pressed, greaterThan(0.9));
      // The child moves down by depth × pressed.
      expect(
        tester
            .getTopLeft(
              find.descendant(
                of: find.byType(PressSink),
                matching: find.byType(ColoredBox),
              ),
            )
            .dy,
        greaterThan(tester.getTopLeft(find.byType(PressSink)).dy + 3),
      );
      await gesture.up();
      await tester.pumpAndSettle();
      expect(pressed, 0);
    });

    testWidgets('a 10 ms tap still sinks at least 60 %', (tester) async {
      await tester.pumpWidget(sink());
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PressSink)),
      );
      await tester.pump(const Duration(milliseconds: 10));
      await gesture.up();
      var deepest = pressed;
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 8));
        if (pressed > deepest) deepest = pressed;
      }
      expect(deepest, greaterThanOrEqualTo(0.6));
      await tester.pumpAndSettle();
      expect(pressed, 0);
    });

    testWidgets('lets go once the finger starts a scroll', (tester) async {
      await tester.pumpWidget(sink());
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PressSink)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.moveBy(const Offset(0, kTouchSlop + 10));
      await tester.pumpAndSettle();
      expect(pressed, 0);
      await gesture.up();
    });

    testWidgets('a disabled PressSink does not sink', (tester) async {
      await tester.pumpWidget(sink(enabled: false));
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PressSink)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(pressed, 0);
      await gesture.up();
    });
  });

  group('PressScale', () {
    double scale(WidgetTester tester) => tester
        .widget<Transform>(
          find
              .descendant(
                of: find.byType(PressScale),
                matching: find.byType(Transform),
              )
              .at(1), // under PressSink's translation
        )
        .transform
        .storage[0]; // x scale

    testWidgets('shrinks while pressed, then springs back', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          PressScale(
            child: TextButton(onPressed: () => taps++, child: const Text('Go')),
          ),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Go')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(scale(tester), closeTo(0.96, 0.005));
      await gesture.up();
      await tester.pumpAndSettle();
      expect((scale(tester), taps), (1.0, 1));
    });

    testWidgets('lets go once the finger starts a scroll', (tester) async {
      await tester.pumpWidget(host(const PressScale(child: _Box())));
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PressScale)),
      );
      await tester.pump();
      await gesture.moveBy(const Offset(0, 30));
      await tester.pumpAndSettle();
      expect(scale(tester), 1);
      await gesture.up();
    });

    testWidgets('a disabled PressScale does not sink', (tester) async {
      await tester.pumpWidget(
        host(const PressScale(enabled: false, child: _Box())),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PressScale)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(scale(tester), 1);
      await gesture.up();
    });
  });
}

class _Box extends StatelessWidget {
  const _Box();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: Color(0xFF000000),
    child: SizedBox.square(dimension: 100),
  );
}
