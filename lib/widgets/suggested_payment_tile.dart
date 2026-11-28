import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../utils/money.dart';

// One suggested payment in the "Settle up" card: "Ayşe → Ali", the amount
// and a "Paid" button.
class SuggestedPaymentTile extends StatelessWidget {
  final String fromName;
  final String toName;
  final int amount; // in kuruş
  final VoidCallback onPaid;

  const SuggestedPaymentTile({
    super.key,
    required this.fromName,
    required this.toName,
    required this.amount,
    required this.onPaid,
  });

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
        child: const Icon(Icons.payments_outlined),
      ),
      title: Text('$fromName → $toName'),
      subtitle: Text(
        formatMoney(amount),
        style: TextStyle(color: colors.error, fontWeight: FontWeight.bold),
      ),
      trailing: TextButton(onPressed: onPaid, child: Text(texts.markAsPaid)),
    );
  }
}
