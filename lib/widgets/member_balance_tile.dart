import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../utils/money.dart';

// One member of the group with their balance on the right:
// green "gets back 200,00 ₺", red "owes 100,00 ₺" or grey "settled up".
// The colors come from the theme (utils/app_theme.dart): green is the
// primary color and red is the error color, so both work in dark mode.
class MemberBalanceTile extends StatelessWidget {
  final String name;
  final bool isAdmin;
  final int balance; // in kuruş, see balance_calculator.dart

  const MemberBalanceTile({
    super.key,
    required this.name,
    required this.isAdmin,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    String balanceText;
    Color balanceColor;
    if (balance > 0) {
      balanceText = texts.balanceGetsBack(formatMoney(balance));
      balanceColor = colors.primary;
    } else if (balance < 0) {
      // The text already says "owes", so the amount is shown without minus.
      balanceText = texts.balanceOwes(formatMoney(-balance));
      balanceColor = colors.error;
    } else {
      balanceText = texts.balanceSettled;
      balanceColor = colors.onSurfaceVariant;
    }

    // The first letter of the name is shown in a circle, like a profile
    // picture. "characters" also works when the name starts with an emoji.
    String firstLetter = '?';
    if (name.isNotEmpty) {
      firstLetter = name.characters.first.toUpperCase();
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
        child: Text(firstLetter),
      ),
      title: Text(name),
      subtitle: isAdmin ? Text(texts.memberRoleAdmin) : null,
      trailing: Text(
        balanceText,
        style: TextStyle(color: balanceColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
