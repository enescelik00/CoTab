import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cotab/main.dart';
import 'package:cotab/services/theme_service.dart';
import 'package:cotab/utils/app_theme.dart';

void main() {
  test('Light theme is cream and dark theme is dark green', () {
    expect(lightTheme.brightness, Brightness.light);
    expect(lightTheme.scaffoldBackgroundColor, const Color(0xFFF8F3E6));

    expect(darkTheme.brightness, Brightness.dark);
    expect(darkTheme.scaffoldBackgroundColor, const Color(0xFF131A15));
  });

  testWidgets('App switches to dark mode when the theme mode changes', (
    tester,
  ) async {
    // Go back to the starting value after the test, so other tests are
    // not shown in dark mode.
    addTearDown(() => ThemeService.themeMode.value = ThemeMode.system);

    await tester.pumpWidget(
      const CoTabApp(home: Scaffold(body: Text('Hello'))),
    );
    expect(
      Theme.of(tester.element(find.text('Hello'))).brightness,
      Brightness.light,
    );

    ThemeService.themeMode.value = ThemeMode.dark;
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Hello'))).brightness,
      Brightness.dark,
    );
  });
}
