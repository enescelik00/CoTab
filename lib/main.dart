import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {
  // Firebase must be ready before the first screen is shown.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      // Green and cream: every color is made from the teal seed color,
      // only the background (surface) is changed to cream.
      // Screens use Theme.of(context).colorScheme instead of fixed colors.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          surface: const Color(0xFFFBF7EE),
        ),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home ?? const AuthGate(),
    );
  }
}
