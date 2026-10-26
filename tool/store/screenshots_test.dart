// Play Store screenshots, rendered by Flutter itself on demo data.
//   flutter test tool/store/screenshots_test.dart
// Raw screens land in build/store/raw/{fr,en}/; tool/store/frame.py then
// lays them out with their captions in docs/store/screenshots/.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/core/database/app_database.dart';
import 'package:little_steps/core/database/habit_repository.dart';
import 'package:little_steps/core/domain/day.dart';
import 'package:little_steps/core/domain/habit.dart';

import '../../test/helpers.dart';

/// A 1080 × 2400 phone (411 × 914 dp), with room for a status bar.
const _size = Size(1080, 2400);
const _ratio = 1080 / 411;

Future<void> _loadFonts() async {
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final family in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(family['family'] as String);
    for (final font in (family['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

/// Six habits and four weeks of mostly kept history up to [testNow].
Future<Map<String, int>> _seed(AppDatabase db, bool fr) async {
  final repo = HabitRepository(db);
  final today = Day(testNow.year, testNow.month, testNow.day);
  final start = today.addDays(-28);
  Habit h(
    String name,
    HabitType type,
    HabitColor color,
    String icon, {
    double goal = 1,
    double step = 1,
    QuantityUnit? unit,
    ScheduleMode mode = ScheduleMode.days,
    Moment moment = Moment.anytime,
  }) => Habit(
    id: 0,
    name: name,
    type: type,
    color: color,
    icon: icon,
    goal: goal,
    step: step,
    unit: unit,
    scheduleMode: mode,
    moment: moment,
    createdOn: start,
  );
  final ids = <String, int>{
    'water': await repo.createHabit(
      h(
        fr ? 'Boire de l’eau' : 'Drink water',
        HabitType.quantity,
        HabitColor.sky,
        'drop',
        goal: 2000,
        step: 250,
        unit: QuantityUnit.liters,
      ),
    ),
    'vitamins': await repo.createHabit(
      h(
        fr ? 'Vitamines' : 'Vitamins',
        HabitType.yesNo,
        HabitColor.lemon,
        'pill',
        moment: Moment.morning,
      ),
    ),
    'read': await repo.createHabit(
      h(
        fr ? 'Lire' : 'Read',
        HabitType.quantity,
        HabitColor.mint,
        'book',
        goal: 10,
        unit: QuantityUnit.pages,
      ),
    ),
    'meditate': await repo.createHabit(
      h(
        fr ? 'Méditer' : 'Meditate',
        HabitType.duration,
        HabitColor.lilac,
        'lotus',
        goal: 600,
        step: 300,
      ),
    ),
    'run': await repo.createHabit(
      h(
        fr ? 'Courir' : 'Run',
        HabitType.frequency,
        HabitColor.coral,
        'run',
        mode: ScheduleMode.weekly,
      ),
    ),
    'gratitude': await repo.createHabit(
      h(
        'Gratitude',
        HabitType.journal,
        HabitColor.peach,
        'note',
        goal: 3,
        moment: Moment.evening,
      ),
    ),
  };
  final goals = {
    'water': 2000.0,
    'vitamins': 1.0,
    'read': 10.0,
    'meditate': 600.0,
    'gratitude': 3.0,
  };
  for (var d = start; d.compareTo(today) < 0; d = d.addDays(1)) {
    final n = d.difference(start);
    for (final MapEntry(key: k, value: goal) in goals.entries) {
      // A few honest misses, none in the last twelve days.
      final miss = n < 16 && (n * 7 + k.length) % 9 == 0;
      if (miss) continue;
      await repo.setEntry(
        HabitEntry(
          habitId: ids[k]!,
          day: d,
          value: goal,
          note: k == 'gratitude'
              ? 'Un café au soleil\nUn appel\nUne balade'
              : null,
        ),
      );
    }
    if (d.weekday == DateTime.monday ||
        d.weekday == DateTime.thursday ||
        d.weekday == DateTime.saturday) {
      await repo.setEntry(HabitEntry(habitId: ids['run']!, day: d, value: 1));
    }
  }
  // Today, half way.
  await repo.setEntry(
    HabitEntry(habitId: ids['water']!, day: today, value: 1250),
  );
  await repo.setEntry(
    HabitEntry(habitId: ids['vitamins']!, day: today, value: 1),
  );
  await repo.setEntry(HabitEntry(habitId: ids['read']!, day: today, value: 10));
  await repo.setEntry(
    HabitEntry(habitId: ids['meditate']!, day: today, value: 300),
  );
  return ids;
}

Future<void> _shot(WidgetTester tester, String locale, String name) async {
  final view = tester.binding.renderViews.first;
  final layer = view.debugLayer! as OffsetLayer;
  final bytes = await tester.runAsync(() async {
    final image = await layer.toImage(Offset.zero & _size);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  });
  final file = File('build/store/raw/$locale/$name.png')
    ..createSync(recursive: true);
  file.writeAsBytesSync(bytes!);
}

Future<void> _phone(WidgetTester tester) async {
  tester.view
    ..physicalSize = _size
    ..devicePixelRatio = _ratio
    ..padding = const FakeViewPadding(top: 32 * _ratio, bottom: 16 * _ratio);
  addTearDown(tester.view.reset);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(_loadFonts);

  for (final locale in ['fr', 'en']) {
    final fr = locale == 'fr';
    String open(String name) => '$name, ${fr ? 'ouvrir' : 'open'}';

    testApp('$locale screens', (tester, db) async {
      await tester.runAsync(() => _seed(db, fr));
      await pumpApp(tester, db, locale: locale);
      await _phone(tester);
      await settle(tester);
      await _shot(tester, locale, '01-today');

      // The timer, a little way into a session.
      await tester.tap(find.text(fr ? 'Méditer' : 'Meditate'));
      await settle(tester);
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      await _shot(tester, locale, '02-timer');
      await tester.tap(find.bySemanticsLabel(fr ? 'Mettre en pause' : 'Pause'));
      await settle(tester);
      await tester.tap(find.bySemanticsLabel(fr ? 'Retour' : 'Back'));
      await settle(tester);

      final water = fr ? 'Boire de l’eau' : 'Drink water';
      await tester.tap(find.bySemanticsLabel(open(water)));
      await settle(tester);
      await _shot(tester, locale, '03-detail');
      await tester.tap(find.bySemanticsLabel(fr ? 'Retour' : 'Back'));
      await settle(tester);

      await tester.tap(find.bySemanticsLabel(fr ? 'Progrès' : 'Progress'));
      await settle(tester);
      await tester.tap(find.text(fr ? 'Mois' : 'Month'));
      await settle(tester);
      await _shot(tester, locale, '04-progress');

      await tester.tap(find.bySemanticsLabel(fr ? 'Trophées' : 'Trophies'));
      await settle(tester);
      await _shot(tester, locale, '05-trophies');

      await tester.tap(
        find.bySemanticsLabel(fr ? 'Nouvelle habitude' : 'New habit'),
      );
      await settle(tester);
      await _shot(tester, locale, '06-create');
    });
  }
}
