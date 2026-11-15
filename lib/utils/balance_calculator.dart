import '../models/expense.dart';
import '../models/expense_share.dart';

// Calculates the balance of every member of a group. Amounts are in kuruş.
//
// balance = what the person paid - what the person's shares are
// - Positive: the others owe this person money.
// - Negative: this person owes money.
// - Zero: settled.
// All balances of a group always add up to 0.
//
// Example: Ali pays 300 TL, split equally between Ali, Ayşe and Mehmet.
// Ali: 300 - 100 = +200, Ayşe: 0 - 100 = -100, Mehmet: 0 - 100 = -100
//
// memberIds makes sure every member is in the result, also with 0.
// Pass only active (not deleted) expenses and shares.
Map<String, int> calculateBalances(
  List<String> memberIds,
  List<Expense> expenses,
  List<ExpenseShare> shares,
) {
  final balances = <String, int>{};
  for (final memberId in memberIds) {
    balances[memberId] = 0;
  }

  for (final expense in expenses) {
    // ?? 0: someone who left the group may still have old expenses.
    final oldBalance = balances[expense.paidBy] ?? 0;
    balances[expense.paidBy] = oldBalance + expense.amount;
  }

  for (final share in shares) {
    final oldBalance = balances[share.userId] ?? 0;
    balances[share.userId] = oldBalance - share.amount;
  }

  return balances;
}
