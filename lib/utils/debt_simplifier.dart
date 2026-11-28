// Debt simplification: turns the balances of a group into a short list of
// payments that settles everybody. All amounts are in kuruş.
//
// Example: Ali +200 TL, Ayşe -100 TL, Mehmet -100 TL (from balance_calculator)
// -> Ayşe pays Ali 100 TL, Mehmet pays Ali 100 TL.
//
// The method (greedy):
// 1. Find the person who owes the most and the person who gets back the most.
// 2. The one who owes pays the other the smaller of the two amounts, so at
//    least one of them is at 0 afterwards.
// 3. Repeat until nobody owes anything.
// Every step brings at least one person to 0, so for n people there are at
// most n - 1 payments.

// One payment of the list: fromUserId pays toUserId the amount.
// It is only a suggestion shown on the screen; it is not saved. When the
// person really pays, a Settlement is saved (see models/settlement.dart).
class SuggestedPayment {
  final String fromUserId;
  final String toUserId;
  final int amount;

  SuggestedPayment({
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
  });
}

// balances: user id -> balance (positive: gets back, negative: owes).
// The balances of a group always add up to 0. The map of the caller is
// not changed.
List<SuggestedPayment> simplifyDebts(Map<String, int> balances) {
  // Work on a copy and leave out everybody who is already at 0.
  final remaining = <String, int>{};
  for (final userId in balances.keys) {
    if (balances[userId] != 0) {
      remaining[userId] = balances[userId]!;
    }
  }

  final payments = <SuggestedPayment>[];

  while (true) {
    // Find the biggest debtor (most negative) and the biggest creditor
    // (most positive). If two people have the same amount, the first one
    // in the map is taken, so the result is always the same.
    String? biggestDebtor;
    String? biggestCreditor;
    for (final userId in remaining.keys) {
      final balance = remaining[userId]!;
      if (balance < 0 &&
          (biggestDebtor == null || balance < remaining[biggestDebtor]!)) {
        biggestDebtor = userId;
      }
      if (balance > 0 &&
          (biggestCreditor == null || balance > remaining[biggestCreditor]!)) {
        biggestCreditor = userId;
      }
    }

    // Nobody owes anything (or nobody gets anything back): done.
    if (biggestDebtor == null || biggestCreditor == null) {
      break;
    }

    final debt = -remaining[biggestDebtor]!;
    final credit = remaining[biggestCreditor]!;
    int amount = credit;
    if (debt < credit) {
      amount = debt;
    }

    payments.add(
      SuggestedPayment(
        fromUserId: biggestDebtor,
        toUserId: biggestCreditor,
        amount: amount,
      ),
    );
    remaining[biggestDebtor] = remaining[biggestDebtor]! + amount;
    remaining[biggestCreditor] = remaining[biggestCreditor]! - amount;
  }

  return payments;
}
