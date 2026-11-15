import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'screens/auth_gate.dart';
import 'services/theme_service.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  // Firebase must be ready before the first screen is shown.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Read the saved light/dark choice, so the app opens in the right mode.
  await ThemeService.load();
  runApp(const CoTabApp());
}

class CoTabApp extends StatelessWidget {
  // The first screen. When it is null, the AuthGate decides between the
  // sign-in and home screens. Tests pass their own screen here, so they
  // do not need Firebase.
  final Widget? home;

  const CoTabApp({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder builds the app again every time
    // ThemeService.themeMode changes (the light/dark button on the home
    // screen changes it).
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          debugShowCheckedModeBanner: false,
          // The colors, font and button shapes are in utils/app_theme.dart.
          // Screens use Theme.of(context).colorScheme instead of fixed colors.
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: home ?? const AuthGate(),
        );
      },
    );
  }
}
