// Converting money between what the user types or sees and kuruş.
// In the app, money is always an int in kuruş (12.50 TL is 1250).

// Reads a typed amount and returns it in kuruş, or null if it is not a
// valid amount. Both a comma and a dot work as the decimal separator:
// '250' -> 25000, '250,5' -> 25050, '250.50' -> 25050, '0,99' -> 99.
// Thousands separators ('1.250,50') are not supported.
int? parseMoney(String text) {
  final cleaned = text.trim().replaceAll(',', '.');
  final parts = cleaned.split('.');
  if (parts.length > 2) {
    return null;
  }

  final liraText = parts[0];
  String kurusText = '00';
  if (parts.length == 2) {
    kurusText = parts[1];
  }

  final onlyDigits = RegExp(r'^[0-9]+$');
  if (!onlyDigits.hasMatch(liraText) || !onlyDigits.hasMatch(kurusText)) {
    return null;
  }
  if (kurusText.length > 2) {
    return null;
  }
  // '250,5' means 250 TL and 50 kuruş, not 5 kuruş.
  if (kurusText.length == 1) {
    kurusText = '${kurusText}0';
  }

  return int.parse(liraText) * 100 + int.parse(kurusText);
}

// Shows an amount in kuruş as Turkish money: 125050 -> '1.250,50 ₺'.
// Negative amounts get a minus sign: -2000 -> '-20,00 ₺'.
String formatMoney(int amount) {
  String sign = '';
  if (amount < 0) {
    sign = '-';
    amount = -amount;
  }

  final lira = amount ~/ 100;
  final kurus = amount % 100;
  final kurusText = kurus.toString().padLeft(2, '0'); // 5 -> '05'

  return '$sign${_addThousandsDots(lira)},$kurusText ₺';
}

// For a text field that the user can change: 125050 -> '1250,50'.
// No thousands dots and no ₺, so parseMoney can read it back.
String formatMoneyForInput(int amount) {
  final lira = amount ~/ 100;
  final kurusText = (amount % 100).toString().padLeft(2, '0');
  return '$lira,$kurusText';
}

// 1250000 -> '1.250.000'
String _addThousandsDots(int number) {
  final digits = number.toString();
  String result = '';
  for (int i = 0; i < digits.length; i++) {
    // Put a dot before every group of three digits from the right.
    final digitsLeft = digits.length - i;
    if (i > 0 && digitsLeft % 3 == 0) {
      result += '.';
    }
    result += digits[i];
  }
  return result;
}
