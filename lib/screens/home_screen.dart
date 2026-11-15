import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(texts.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: texts.signOutTooltip,
            // After signing out, the AuthGate shows the sign-in screen.
            onPressed: () => AuthService.signOut(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              texts.homeWelcome,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(texts.homeNoGroups),
          ],
        ),
      ),
    );
  }
}
