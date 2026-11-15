import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

// The categories an expense can have. The key is saved in the database,
// the name shown to the user comes from the language files.
const List<String> expenseCategories = [
  'food',
  'rent',
  'bills',
  'transport',
  'other',
];

String categoryName(AppLocalizations texts, String category) {
  if (category == 'food') {
    return texts.categoryFood;
  }
  if (category == 'rent') {
    return texts.categoryRent;
  }
  if (category == 'bills') {
    return texts.categoryBills;
  }
  if (category == 'transport') {
    return texts.categoryTransport;
  }
  return texts.categoryOther;
}

IconData categoryIcon(String category) {
  if (category == 'food') {
    return Icons.shopping_cart;
  }
  if (category == 'rent') {
    return Icons.home;
  }
  if (category == 'bills') {
    return Icons.receipt_long;
  }
  if (category == 'transport') {
    return Icons.directions_bus;
  }
  return Icons.category;
}
