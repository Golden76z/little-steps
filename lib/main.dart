import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Bars are transparent: the app draws under them (see sorbetSystemUi).
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // The whole design is portrait (390 × 844).
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: LittleStepsApp()));
}
