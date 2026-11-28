import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/settlement.dart';
import '../utils/money.dart';

// A payment that was made, shown in the list together with the expenses:
// "Ayşe → Ali", "Payment · 28 Nov 2026" and the amount.
// Pressing and holding it calls onLongPress.
class SettlementTile extends StatelessWidget {
  final Settlement settlement;
  final String fromName;
  final String toName;
  final VoidCallback onLongPress;

  const SettlementTile({
    super.key,
    required this.settlement,
    required this.fromName,
    required this.toName,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    final date = DateTime.fromMillisecondsSinceEpoch(settlement.settledAt);
    final dateText = MaterialLocalizations.of(context).formatMediumDate(date);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
        child: const Icon(Icons.handshake_outlined),
      ),
      title: Text('$fromName → $toName'),
      subtitle: Text(texts.paymentLabel(dateText)),
      // Grey, so a payment does not look like a new expense.
      trailing: Text(
        formatMoney(settlement.amount),
        style: TextStyle(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
      onLongPress: onLongPress,
    );
  }
}
