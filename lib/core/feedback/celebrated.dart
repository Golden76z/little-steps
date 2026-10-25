import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Celebrations already played while the app runs, so each one plays once:
/// keys like 'habit:$id:$day', 'perfect:$day', 'level:$n'.
final celebratedProvider = NotifierProvider<Celebrated, Set<String>>(
  Celebrated.new,
);

class Celebrated extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  /// True the first time [key] is claimed only.
  bool claim(String key) {
    if (state.contains(key)) return false;
    state = {...state, key};
    return true;
  }
}
