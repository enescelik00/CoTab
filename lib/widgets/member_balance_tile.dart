import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../utils/money.dart';

// The theme has no green for "gets money back", so it is defined here.
// Red ("owes money") is the error color of the theme.
const Color getsBackColor = Color(0xFF2E7D32);

// One member of the group with their balance on the right:
// green "gets back 200,00 ₺", red "owes 100,00 ₺" or grey "settled up".
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
      balanceColor = getsBackColor;
    } else if (balance < 0) {
      // The text already says "owes", so the amount is shown without minus.
      balanceText = texts.balanceOwes(formatMoney(-balance));
      balanceColor = colors.error;
    } else {
      balanceText = texts.balanceSettled;
      balanceColor = colors.onSurfaceVariant;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.person),
      title: Text(name),
      subtitle: isAdmin ? Text(texts.memberRoleAdmin) : null,
      trailing: Text(
        balanceText,
        style: TextStyle(color: balanceColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
