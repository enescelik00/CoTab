import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

// The top of the sign-in and sign-up screens: the app logo, the app name
// and a short tagline.
class AppLogoHeader extends StatelessWidget {
  const AppLogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The same logo as the app icon. The image already has its green
        // background and round corners.
        Center(
          child: Image.asset('assets/images/logo.png', width: 88, height: 88),
        ),
        const SizedBox(height: 16),
        Text(
          texts.appTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          texts.appTagline,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
