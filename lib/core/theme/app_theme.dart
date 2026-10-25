import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'sorbet_colors.dart';

const _font = 'SourGummy';

/// Sour Gummy is bundled in 400/500/600 only: never go above w600.
///
/// Slots map to the size/weight pairs used in the mockups:
/// display 64·48·40/600 (big goal numbers), headline 26·24·22/600
/// (26 = screen title), title 20·18·17/600, body 16·15/500 and 14/400,
/// label 14/500, 13/400, 12/500. Rarer pairs use `copyWith`.
TextTheme _textTheme(Color ink) {
  TextStyle s(double size, FontWeight w, {double? height}) => TextStyle(
    fontFamily: _font,
    fontSize: size,
    fontWeight: w,
    height: height,
    color: ink,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  const semi = FontWeight.w600, med = FontWeight.w500, reg = FontWeight.w400;
  return TextTheme(
    displayLarge: s(64, semi, height: 1),
    displayMedium: s(48, semi, height: 1),
    displaySmall: s(40, semi, height: 1),
    headlineLarge: s(26, semi, height: 1.1),
    headlineMedium: s(24, semi, height: 1.1),
    headlineSmall: s(22, semi, height: 1.1),
    titleLarge: s(20, semi, height: 1.1),
    titleMedium: s(18, semi, height: 1.1),
    titleSmall: s(17, semi, height: 1.1),
    bodyLarge: s(16, med),
    bodyMedium: s(15, med),
    bodySmall: s(14, reg),
    labelLarge: s(14, med),
    labelMedium: s(13, reg),
    labelSmall: s(12, med),
  );
}

ThemeData buildSorbetTheme([SorbetColors c = SorbetColors.light]) {
  final scheme = ColorScheme.fromSeed(seedColor: c.accent).copyWith(
    primary: c.accent,
    onPrimary: c.onAccent,
    surface: c.surface,
    onSurface: c.ink,
    onSurfaceVariant: c.muted,
    outlineVariant: c.divider,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    fontFamily: _font,
    // No ripple anywhere: presses sink instead (PressSink, PressScale);
    // list rows keep a soft tint that fades in and out.
    splashFactory: NoSplash.splashFactory,
    // Opened screens slide in from the right and back out (Android's system
    // back gesture keeps the edge; no predictive-back preview with this).
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    highlightColor: c.ink.withValues(alpha: 0.06),
    textTheme: _textTheme(c.ink),
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      foregroundColor: c.ink,
      surfaceTintColor: c.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.ink,
      contentTextStyle: TextStyle(
        fontFamily: _font,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: c.onAccent,
      ),
      actionTextColor: c.selectedBorder,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: c.surface,
      barrierColor: c.barrier,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: c.surface,
      headerBackgroundColor: c.surface,
      headerForegroundColor: c.ink,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    dividerTheme: DividerThemeData(
      color: c.divider,
      thickness: 1.5,
      space: 1.5,
    ),
    extensions: [c],
  );
}

/// Edge to edge: transparent status and navigation bars with dark icons,
/// so the app's background runs under them.
const sorbetSystemUi = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
  systemNavigationBarColor: Colors.transparent,
  systemNavigationBarDividerColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.dark,
  systemNavigationBarContrastEnforced: false,
);
