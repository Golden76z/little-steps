import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/feedback/feedback.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Bars are transparent: the app draws under them (see sorbetSystemUi).
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // The whole design is portrait (390 × 844).
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Feedback settings and the API level load now, before the first tap.
  final container = ProviderContainer()..listen(feedbackProvider, (_, _) {});
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const LittleStepsApp(),
    ),
  );
}
