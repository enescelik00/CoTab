import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cotab/main.dart';
import 'package:cotab/models/expense.dart';
import 'package:cotab/models/expense_share.dart';
import 'package:cotab/models/group.dart';
import 'package:cotab/screens/add_expense_screen.dart';

// These tests only check what happens before saving. Saving is never
// reached, so SQLite and Firebase are not needed here.
final testGroup = Group(
  id: 'group1',
  name: 'Kadıköy Evi',
  type: 'home',
  inviteCode: 'K7M2QX',
  updatedAt: 1763200000000,
);

final testMembers = <Map<String, Object?>>[
  {'user_id': 'ali', 'name': 'Ali', 'role': 'admin'},
  {'user_id': 'ayse', 'name': 'Ayşe', 'role': 'member'},
  {'user_id': 'mehmet', 'name': 'Mehmet', 'role': 'member'},
];

Future<void> openScreen(WidgetTester tester) async {
  // A tall screen, so the whole form fits and every button can be tapped.
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    CoTabApp(
      home: AddExpenseScreen(
        group: testGroup,
        members: testMembers,
        currentUserId: 'ali',
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Expense makeExpense({
  String paidBy = 'ali',
  String splitType = 'equal',
  String category = 'food',
}) {
  return Expense(
    id: 'e1',
    groupId: 'group1',
    title: 'Migros',
    amount: 10000,
    paidBy: paidBy,
    category: category,
    expenseDate: DateTime(2026, 11, 20).millisecondsSinceEpoch,
    splitType: splitType,
    updatedAt: 1763200000000,
  );
}

ExpenseShare makeShare(String userId, int amount) {
  return ExpenseShare(
    id: ExpenseShare.createId('e1', userId),
    groupId: 'group1',
    expenseId: 'e1',
    userId: userId,
    amount: amount,
    updatedAt: 1763200000000,
  );
}

Future<void> openEditScreen(
  WidgetTester tester,
  Expense expense,
  List<ExpenseShare> shares,
) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    CoTabApp(
      home: AddExpenseScreen(
        group: testGroup,
        members: testMembers,
        currentUserId: 'ali',
        expense: expense,
        shares: shares,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

// The ticked state of the equal split row with this name.
bool isTicked(WidgetTester tester, String name) {
  final tile = tester.widget<CheckboxListTile>(
    find.widgetWithText(CheckboxListTile, name),
  );
  return tile.value == true;
}

void main() {
  testWidgets('Empty title and amount show errors', (tester) async {
    await openScreen(tester);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a title.'), findsOneWidget);
    expect(
      find.text('Please enter a valid amount, e.g. 250,50.'),
      findsOneWidget,
    );
  });

  testWidgets('Equal split shows the share of everybody', (tester) async {
    await openScreen(tester);

    // The amount field is the second text field (after the title).
    await tester.enterText(find.byType(TextFormField).at(1), '100');
    await tester.pumpAndSettle();

    // Ali paid, so he gets the extra kuruş.
    expect(find.text('33,34 ₺'), findsOneWidget);
    expect(find.text('33,33 ₺'), findsNWidgets(2));
  });

  testWidgets('Percentages that are not 100 show an error', (tester) async {
    await openScreen(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'Migros');
    await tester.enterText(find.byType(TextFormField).at(1), '100');
    await tester.tap(find.text('Percent'));
    await tester.pumpAndSettle();

    // One field per member: 50 + 30 + 0 = 80.
    final percentFields = find.byType(TextField);
    await tester.enterText(percentFields.at(2), '50');
    await tester.enterText(percentFields.at(3), '30');
    await tester.pumpAndSettle();

    expect(find.text('Total: 80% of 100%'), findsOneWidget);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('The percentages must add up to 100.'), findsOneWidget);
  });

  group('editing', () {
    testWidgets('The form starts with the saved expense', (tester) async {
      await openEditScreen(tester, makeExpense(paidBy: 'ayse'), [
        makeShare('ali', 5000),
        makeShare('ayse', 5000),
      ]);

      expect(find.text('Edit expense'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
      expect(find.text('Migros'), findsOneWidget);
      expect(find.text('100,00'), findsOneWidget);
      // The payer dropdown shows Ayşe.
      expect(
        find.descendant(
          of: find.byType(DropdownButtonFormField<String>).first,
          matching: find.text('Ayşe'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Equal split: only the people in the split are ticked', (
      tester,
    ) async {
      await openEditScreen(tester, makeExpense(), [
        makeShare('ali', 5000),
        makeShare('ayse', 5000),
      ]);

      expect(isTicked(tester, 'Ali'), isTrue);
      expect(isTicked(tester, 'Ayşe'), isTrue);
      expect(isTicked(tester, 'Mehmet'), isFalse);
      expect(find.text('50,00 ₺'), findsNWidgets(2));
    });

    testWidgets('Percentage split: the percentages are filled in', (
      tester,
    ) async {
      await openEditScreen(tester, makeExpense(splitType: 'percentage'), [
        makeShare('ali', 7000),
        makeShare('ayse', 3000),
      ]);

      expect(find.text('70'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('Total: 100% of 100%'), findsOneWidget);
    });

    testWidgets('Exact split: the amounts are filled in', (tester) async {
      await openEditScreen(tester, makeExpense(splitType: 'exact'), [
        makeShare('ali', 2550),
        makeShare('mehmet', 7450),
      ]);

      expect(find.text('25,50'), findsOneWidget);
      expect(find.text('74,50'), findsOneWidget);
      expect(find.text('Total: 100,00 ₺ of 100,00 ₺'), findsOneWidget);
    });

    testWidgets('Someone who left the group is shown as Unknown', (
      tester,
    ) async {
      // 'zeynep' paid but is not a member any more.
      await openEditScreen(tester, makeExpense(paidBy: 'zeynep'), [
        makeShare('ali', 5000),
        makeShare('zeynep', 5000),
      ]);

      expect(tester.takeException(), isNull);
      // Once as the payer and once in the split list.
      expect(find.text('Unknown'), findsNWidgets(2));
      expect(isTicked(tester, 'Unknown'), isTrue);
    });

    testWidgets('A payer who left the group and is not in the split', (
      tester,
    ) async {
      // 'zeynep' paid for Ali and Ayşe only, and is not a member any more.
      // Without her in the payer list the dropdown would crash.
      await openEditScreen(tester, makeExpense(paidBy: 'zeynep'), [
        makeShare('ali', 5000),
        makeShare('ayse', 5000),
      ]);

      expect(tester.takeException(), isNull);
      expect(
        find.descendant(
          of: find.byType(DropdownButtonFormField<String>).first,
          matching: find.text('Unknown'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('A category that is not in the list becomes Other', (
      tester,
    ) async {
      await openEditScreen(tester, makeExpense(category: 'old-category'), [
        makeShare('ali', 10000),
      ]);

      expect(tester.takeException(), isNull);
      expect(find.text('Other'), findsOneWidget);
    });
  });
}
