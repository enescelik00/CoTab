import '../models/expense.dart';
import '../models/expense_share.dart';
import '../models/settlement.dart';

// Calculates the balance of every member of a group. Amounts are in kuruş.
//
// balance = what the person paid - what the person's shares are
//           + payments the person made - payments the person received
// - Positive: the others owe this person money.
// - Negative: this person owes money.
// - Zero: settled.
// All balances of a group always add up to 0.
//
// Example: Ali pays 300 TL, split equally between Ali, Ayşe and Mehmet.
// Ali: 300 - 100 = +200, Ayşe: 0 - 100 = -100, Mehmet: 0 - 100 = -100
// Then Ayşe pays Ali back 100 TL (a settlement):
// Ali: +200 - 100 = +100, Ayşe: -100 + 100 = 0, Mehmet: -100
//
// memberIds makes sure every member is in the result, also with 0.
// Pass only active (not deleted) expenses, shares and settlements.
Map<String, int> calculateBalances(
  List<String> memberIds,
  List<Expense> expenses,
  List<ExpenseShare> shares, {
  List<Settlement> settlements = const [],
}) {
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

  // Paying back a debt brings both people closer to 0.
  for (final settlement in settlements) {
    final payerBalance = balances[settlement.fromUserId] ?? 0;
    balances[settlement.fromUserId] = payerBalance + settlement.amount;

    final receiverBalance = balances[settlement.toUserId] ?? 0;
    balances[settlement.toUserId] = receiverBalance - settlement.amount;
  }

  return balances;
}
