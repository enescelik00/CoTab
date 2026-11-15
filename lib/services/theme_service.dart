import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

// Remembers whether the user chose light or dark mode.
// The choice is saved in the settings table, so it is still there the
// next time the app is opened.
class ThemeService {
  static const String _settingKey = 'theme_mode';

  // The mode the app is shown in. The MaterialApp in main.dart listens to
  // this value and rebuilds when it changes.
  // ThemeMode.system means "the user has not chosen yet": on the first
  // start the app follows the light/dark setting of the phone.
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(
    ThemeMode.system,
  );

  // Reads the saved choice. Called once in main() before the app starts.
  static Future<void> load() async {
    final db = await DatabaseHelper.getDatabase();
    final rows = await db.rawQuery(
      'SELECT value FROM settings WHERE key = ? AND deleted_at IS NULL',
      [_settingKey],
    );
    if (rows.isEmpty) {
      return;
    }

    if (rows.first['value'] == 'dark') {
      themeMode.value = ThemeMode.dark;
    } else {
      themeMode.value = ThemeMode.light;
    }
  }

  // Switches to dark or light mode right away and saves the choice.
  static Future<void> setDarkMode(bool isDark) async {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;

    final db = await DatabaseHelper.getDatabase();
    // "replace" updates the row if this setting was saved before.
    await db.insert('settings', {
      'key': _settingKey,
      'value': isDark ? 'dark' : 'light',
      'updated_at': DateTime.now().millisecondsSinceEpoch,
      'deleted_at': null,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
