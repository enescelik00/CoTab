// Splitting an expense between members. All amounts are in kuruş.
//
// When an amount does not divide evenly, the leftover kuruş goes to the
// person who paid, so the shares always add up to the exact total.
// Example: 10000 (100 TL) between 3 people, 'ali' paid:
// {'ali': 3334, 'ayse': 3333, 'mehmet': 3333}
//
// The result is a map: user id -> share amount.

// Everybody pays the same. userIds must not be empty.
Map<String, int> splitEqually(int amount, List<String> userIds, String paidBy) {
  final shares = <String, int>{};
  final shareOfEach = amount ~/ userIds.length; // ~/ divides and drops the rest
  for (final userId in userIds) {
    shares[userId] = shareOfEach;
  }
  _giveLeftoverToPayer(shares, amount, paidBy);
  return shares;
}

// Everybody pays a percentage of the amount, e.g. {'ali': 50, 'ayse': 50}.
// Percentages are whole numbers and must add up to 100
// (check with percentagesAddUpTo100 first).
Map<String, int> splitByPercentage(
  int amount,
  Map<String, int> percentages,
  String paidBy,
) {
  final shares = <String, int>{};
  for (final userId in percentages.keys) {
    shares[userId] = amount * percentages[userId]! ~/ 100;
  }
  _giveLeftoverToPayer(shares, amount, paidBy);
  return shares;
}

// For editing a percentage split. Only the share amounts are saved, not
// the percentages, so the percentages are calculated back from the shares
// and rounded to whole numbers: {'ali': 5000, 'ayse': 5000} of 10000 ->
// {'ali': 50, 'ayse': 50}.
// For very small amounts the leftover kuruş can change the rounding; then
// the percentages may not add up to 100 and the user corrects them.
Map<String, int> percentagesFromShares(int amount, Map<String, int> shares) {
  final percentages = <String, int>{};
  for (final userId in shares.keys) {
    // (x * 100 + amount ~/ 2) ~/ amount rounds x * 100 / amount to the
    // nearest whole number without using double.
    percentages[userId] = (shares[userId]! * 100 + amount ~/ 2) ~/ amount;
  }
  return percentages;
}

// For the percentage split: true if the percentages add up to 100.
bool percentagesAddUpTo100(Map<String, int> percentages) {
  return sumOf(percentages) == 100;
}

// For the exact split: true if the typed amounts add up to the total.
bool sharesMatchAmount(int amount, Map<String, int> shares) {
  return sumOf(shares) == amount;
}

// Adds up all values of the map.
int sumOf(Map<String, int> values) {
  int total = 0;
  for (final value in values.values) {
    total += value;
  }
  return total;
}

// Gives the kuruş that are left after dividing to the payer.
// If the payer is not part of the split, the first person gets them.
void _giveLeftoverToPayer(Map<String, int> shares, int amount, String paidBy) {
  final leftover = amount - sumOf(shares);
  if (leftover == 0) {
    return;
  }

  String receiver = shares.keys.first;
  if (shares.containsKey(paidBy)) {
    receiver = paidBy;
  }
  shares[receiver] = shares[receiver]! + leftover;
}
