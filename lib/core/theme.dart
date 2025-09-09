import 'package:flutter/material.dart';

var kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 40, 112, 13),
);
var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 111, 170, 34),
);

final lightTheme = ThemeData().copyWith(
  colorScheme: kColorScheme,
  appBarTheme: const AppBarTheme().copyWith(
    backgroundColor: kColorScheme.onPrimaryContainer,
    foregroundColor: kColorScheme.primaryContainer,
  ),
  cardTheme: const CardThemeData().copyWith(
    color: kColorScheme.secondaryContainer,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kDarkColorScheme.primaryContainer,
      foregroundColor: kDarkColorScheme.onPrimaryContainer,
      disabledBackgroundColor:
          kColorScheme.onSurface.withOpacity(0.3), // رنگ پس‌زمینه غیرفعال
      disabledForegroundColor:
          kColorScheme.onSurface.withOpacity(0.7), // رنگ متن غیرفعال
    ),
  ),
);

final darkTheme = ThemeData.dark().copyWith(
  colorScheme: kDarkColorScheme,
  appBarTheme: const AppBarTheme().copyWith(
    backgroundColor: kDarkColorScheme.onPrimaryContainer,
    foregroundColor: kDarkColorScheme.primaryContainer,
  ),
  cardTheme: const CardThemeData().copyWith(
    color: kDarkColorScheme.primaryContainer,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kDarkColorScheme.primaryContainer,
      foregroundColor: kDarkColorScheme.onPrimaryContainer,
      disabledBackgroundColor:
          kDarkColorScheme.onSurface.withOpacity(0.3), // رنگ پس‌زمینه غیرفعال
      disabledForegroundColor:
          kDarkColorScheme.onSurface.withOpacity(0.7), // رنگ متن غیرفعال
    ),
  ),
);
