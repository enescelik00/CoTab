import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/expense.dart';
import '../utils/expense_categories.dart';
import '../utils/money.dart';

// One expense in the list: category icon, title, who paid and when, and
// the amount on the right. Tapping it calls onTap (edit), pressing and
// holding it calls onLongPress (delete).
class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final String payerName;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ExpenseTile({
    super.key,
    required this.expense,
    required this.payerName,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    final date = DateTime.fromMillisecondsSinceEpoch(expense.expenseDate);
    final dateText = MaterialLocalizations.of(context).formatMediumDate(date);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
        child: Icon(categoryIcon(expense.category)),
      ),
      title: Text(expense.title),
      subtitle: Text(texts.expensePaidBy(payerName, dateText)),
      trailing: Text(
        formatMoney(expense.amount),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
