import 'package:flutter/material.dart';

// The look of the whole app: colors, font, buttons, text fields and cards.
// Screens do not choose their own colors or shapes. They use the normal
// Flutter widgets (FilledButton, Card, TextFormField, ...) and read colors
// with Theme.of(context).colorScheme, so every screen looks the same and
// also works in dark mode.
//
// The palette is "forest green + cream + mustard":
//   primary  = green   -> main buttons, links, "gets back" amounts
//   tertiary = mustard -> the floating "add" button (one warm accent)
//   surface  = cream   -> the background of every screen
//   error    = red     -> errors and "owes" amounts
// In dark mode the roles swap: the background becomes a very dark green,
// the texts become cream and the green becomes lighter.

const String appFontFamily = 'PlusJakartaSans';

final ColorScheme lightColors = ColorScheme.fromSeed(
  // The seed fills in every color that is not listed below.
  seedColor: const Color(0xFF2E6B4A),
  brightness: Brightness.light,
  primary: const Color(0xFF2E6B4A),
  onPrimary: const Color(0xFFFFFFFF),
  primaryContainer: const Color(0xFFD5E8D8),
  onPrimaryContainer: const Color(0xFF173D29),
  tertiary: const Color(0xFFE3AB2E),
  onTertiary: const Color(0xFF3B2A00),
  error: const Color(0xFFB3402E),
  onError: const Color(0xFFFFFFFF),
  // Background and texts.
  surface: const Color(0xFFF8F3E6),
  onSurface: const Color(0xFF1E2A22),
  onSurfaceVariant: const Color(0xFF66705F),
  // Cards and text fields use surfaceContainerLow. The darker ones are
  // used by Flutter for dialogs, menus and the offline line.
  surfaceContainerLowest: const Color(0xFFFFFFFF),
  surfaceContainerLow: const Color(0xFFFFFDF6),
  surfaceContainer: const Color(0xFFF3EDDD),
  surfaceContainerHigh: const Color(0xFFEEE7D5),
  surfaceContainerHighest: const Color(0xFFE8E0CC),
  // Thin lines around cards and text fields.
  outline: const Color(0xFF8C917F),
  outlineVariant: const Color(0xFFE2DAC5),
);

final ColorScheme darkColors = ColorScheme.fromSeed(
  seedColor: const Color(0xFF2E6B4A),
  brightness: Brightness.dark,
  primary: const Color(0xFF8ED1A8),
  onPrimary: const Color(0xFF0E3320),
  primaryContainer: const Color(0xFF264D38),
  onPrimaryContainer: const Color(0xFFCFEBD7),
  tertiary: const Color(0xFFF0C55E),
  onTertiary: const Color(0xFF3B2A00),
  error: const Color(0xFFF0958A),
  onError: const Color(0xFF5A1208),
  surface: const Color(0xFF131A15),
  onSurface: const Color(0xFFEFE8D6),
  onSurfaceVariant: const Color(0xFFA3AC9C),
  surfaceContainerLowest: const Color(0xFF0E1410),
  surfaceContainerLow: const Color(0xFF1D2620),
  surfaceContainer: const Color(0xFF232D26),
  surfaceContainerHigh: const Color(0xFF2A352D),
  surfaceContainerHighest: const Color(0xFF323E35),
  outline: const Color(0xFF6F7A70),
  outlineVariant: const Color(0xFF2F3A33),
);

final ThemeData lightTheme = buildTheme(lightColors);
final ThemeData darkTheme = buildTheme(darkColors);

// Builds the theme from a set of colors. Light and dark mode use the same
// shapes and sizes; only the colors are different.
ThemeData buildTheme(ColorScheme colors) {
  // Buttons and text fields share one corner radius, cards are rounder.
  const double buttonRadius = 14;
  const double cardRadius = 20;

  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(buttonRadius),
  );
  const buttonTextStyle = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
  // The border of a text field in the given color.
  OutlineInputBorder fieldBorder(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return ThemeData(
    colorScheme: colors,
    fontFamily: appFontFamily,
    scaffoldBackgroundColor: colors.surface,

    // Only the weights are changed here; sizes stay the Flutter defaults.
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontWeight: FontWeight.w700),
      headlineSmall: TextStyle(fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontWeight: FontWeight.w700),
      titleSmall: TextStyle(fontWeight: FontWeight.w600),
    ),

    // The app bar has the same color as the screen and does not change
    // color when the list is scrolled under it.
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),

    // Flat cards with a thin border instead of a shadow.
    cardTheme: CardThemeData(
      color: colors.surfaceContainerLow,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        side: BorderSide(color: colors.outlineVariant),
      ),
    ),

    // FilledButton: the main action of a screen (Save, Sign in, ...).
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: buttonShape,
        textStyle: buttonTextStyle,
      ),
    ),
    // OutlinedButton: a second, less important action next to it.
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: buttonShape,
        side: BorderSide(color: colors.primary, width: 1.5),
        textStyle: buttonTextStyle,
      ),
    ),
    // TextButton: small actions and links (Cancel, Forgot password, ...).
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: buttonShape,
        textStyle: buttonTextStyle.copyWith(fontSize: 14),
      ),
    ),
    // The floating button is the one mustard element on a screen.
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.tertiary,
      foregroundColor: colors.onTertiary,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      extendedTextStyle: buttonTextStyle.copyWith(fontSize: 15),
    ),

    // Text fields: a filled box with a thin border that turns green when
    // the field is selected and red when its value is wrong.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: fieldBorder(colors.outlineVariant, 1),
      enabledBorder: fieldBorder(colors.outlineVariant, 1),
      focusedBorder: fieldBorder(colors.primary, 2),
      errorBorder: fieldBorder(colors.error, 1),
      focusedErrorBorder: fieldBorder(colors.error, 2),
    ),

    // The small messages at the bottom float above the screen.
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: buttonShape,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
    ),

    dividerTheme: DividerThemeData(color: colors.outlineVariant, space: 1),
  );
}
