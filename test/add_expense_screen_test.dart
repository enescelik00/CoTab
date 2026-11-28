import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cotab/main.dart';
import 'package:cotab/models/expense.dart';
import 'package:cotab/models/expense_item.dart';
import 'package:cotab/models/expense_share.dart';
import 'package:cotab/models/group.dart';
import 'package:cotab/screens/add_expense_screen.dart';
import 'package:cotab/widgets/item_split_card.dart';

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
  Expense? expense,
  List<ExpenseShare> shares, {
  List<ExpenseItem> items = const [],
}) async {
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
        items: items,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

ExpenseItem makeItem(String id, String name, int amount) {
  return ExpenseItem(
    id: id,
    groupId: 'group1',
    expenseId: 'e1',
    name: name,
    amount: amount,
    updatedAt: 1763200000000,
  );
}

ExpenseShare makeItemShare(String itemId, String userId, int amount) {
  return ExpenseShare(
    id: ExpenseShare.createItemShareId(itemId, userId),
    groupId: 'group1',
    expenseId: 'e1',
    itemId: itemId,
    userId: userId,
    amount: amount,
    updatedAt: 1763200000000,
  );
}

// The text field number fieldIndex (0: name, 1: amount) of item card
// number cardIndex.
Finder itemField(int cardIndex, int fieldIndex) {
  return find
      .descendant(
        of: find.byType(ItemSplitCard).at(cardIndex),
        matching: find.byType(TextField),
      )
      .at(fieldIndex);
}

// The chip of this person in item card number cardIndex.
Finder itemChip(int cardIndex, String name) {
  return find.descendant(
    of: find.byType(ItemSplitCard).at(cardIndex),
    matching: find.widgetWithText(FilterChip, name),
  );
}

bool isChipSelected(WidgetTester tester, int cardIndex, String name) {
  return tester.widget<FilterChip>(itemChip(cardIndex, name)).selected;
}

// Fills the title and the amount, then switches to the item split.
Future<void> startItemSplit(WidgetTester tester, String amount) async {
  await openScreen(tester);
  await tester.enterText(find.byType(TextFormField).at(0), 'Migros');
  await tester.enterText(find.byType(TextFormField).at(1), amount);
  await tester.tap(find.text('Items'));
  await tester.pumpAndSettle();
}

Future<void> addItem(WidgetTester tester, String name, String amount) async {
  await tester.tap(find.text('Add item'));
  await tester.pumpAndSettle();
  final index = find.byType(ItemSplitCard).evaluate().length - 1;
  await tester.enterText(itemField(index, 0), name);
  await tester.enterText(itemField(index, 1), amount);
  await tester.pumpAndSettle();
}

Future<void> tapSave(WidgetTester tester) async {
  await tester.tap(find.byType(FilledButton));
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

  group('item split', () {
    testWidgets('Shows item cards instead of the member rows', (tester) async {
      await startItemSplit(tester, '100');

      expect(find.byType(CheckboxListTile), findsNothing);
      expect(find.text('Add item'), findsOneWidget);
      expect(find.byType(ItemSplitCard), findsNothing);
    });

    testWidgets('A new item is shared by everybody at first', (tester) async {
      await startItemSplit(tester, '90');
      await addItem(tester, 'Süt', '90');

      expect(isChipSelected(tester, 0, 'Ali'), isTrue);
      expect(isChipSelected(tester, 0, 'Ayşe'), isTrue);
      expect(isChipSelected(tester, 0, 'Mehmet'), isTrue);
      expect(find.text('Per person'), findsOneWidget);
      expect(find.text('30,00 ₺'), findsNWidgets(3));
      expect(find.text('Total: 90,00 ₺ of 90,00 ₺'), findsOneWidget);
    });

    testWidgets('Choosing who had an item changes the totals', (tester) async {
      await startItemSplit(tester, '50');
      await addItem(tester, 'Süt', '40');
      await addItem(tester, 'Ekmek', '10');

      // Süt only for Ali and Ayşe, Ekmek only for Ali.
      await tester.tap(itemChip(0, 'Mehmet'));
      await tester.tap(itemChip(1, 'Ayşe'));
      await tester.tap(itemChip(1, 'Mehmet'));
      await tester.pumpAndSettle();

      // Ali: 20 + 10 = 30, Ayşe: 20, Mehmet is in no item.
      expect(find.text('30,00 ₺'), findsOneWidget);
      expect(find.text('20,00 ₺'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ListTile),
          matching: find.text('Mehmet'),
        ),
        findsNothing,
      );
    });

    testWidgets('Saving without items shows an error', (tester) async {
      await startItemSplit(tester, '100');
      await tapSave(tester);

      expect(find.text('Add at least one item.'), findsOneWidget);
    });

    testWidgets('An item without a name shows an error', (tester) async {
      await startItemSplit(tester, '100');
      await addItem(tester, '', '100');
      await tapSave(tester);

      expect(
        find.text(
          'Every item needs a name, an amount and at least one person.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('An item without people shows an error', (tester) async {
      await startItemSplit(tester, '100');
      await addItem(tester, 'Süt', '100');
      for (final name in ['Ali', 'Ayşe', 'Mehmet']) {
        await tester.tap(itemChip(0, name));
      }
      await tester.pumpAndSettle();
      await tapSave(tester);

      expect(
        find.text(
          'Every item needs a name, an amount and at least one person.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Items that do not add up to the total show an error', (
      tester,
    ) async {
      await startItemSplit(tester, '100');
      await addItem(tester, 'Süt', '40');

      expect(find.text('Total: 40,00 ₺ of 100,00 ₺'), findsOneWidget);
      await tapSave(tester);
      expect(find.text('The items must add up to the total.'), findsOneWidget);
    });

    testWidgets('An item can be removed', (tester) async {
      await startItemSplit(tester, '100');
      await addItem(tester, 'Süt', '40');
      await addItem(tester, 'Ekmek', '60');

      await tester.tap(
        find.descendant(
          of: find.byType(ItemSplitCard).at(0),
          matching: find.byIcon(Icons.delete_outline),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ItemSplitCard), findsOneWidget);
      // The card that is left is Ekmek, with its own text.
      expect(find.text('Ekmek'), findsOneWidget);
      expect(find.text('Süt'), findsNothing);
      expect(find.text('Total: 60,00 ₺ of 100,00 ₺'), findsOneWidget);
    });

    testWidgets('Editing an item split fills the cards', (tester) async {
      await openEditScreen(
        tester,
        makeExpense(splitType: 'items'),
        [
          makeItemShare('i1', 'ali', 3000),
          makeItemShare('i1', 'ayse', 3000),
          makeItemShare('i2', 'mehmet', 4000),
        ],
        items: [makeItem('i1', 'Süt', 6000), makeItem('i2', 'Ekmek', 4000)],
      );

      expect(find.byType(ItemSplitCard), findsNWidgets(2));
      expect(find.text('Süt'), findsOneWidget);
      expect(find.text('60,00'), findsOneWidget);
      expect(isChipSelected(tester, 0, 'Ali'), isTrue);
      expect(isChipSelected(tester, 0, 'Ayşe'), isTrue);
      expect(isChipSelected(tester, 0, 'Mehmet'), isFalse);
      expect(isChipSelected(tester, 1, 'Mehmet'), isTrue);
      expect(isChipSelected(tester, 1, 'Ali'), isFalse);
      expect(find.text('Total: 100,00 ₺ of 100,00 ₺'), findsOneWidget);
    });

    testWidgets('Items of a new expense start the item split', (tester) async {
      // For example the items read from a scanned receipt.
      await openEditScreen(
        tester,
        null,
        [],
        items: [makeItem('', 'Süt', 4000), makeItem('', 'Ekmek', 1000)],
      );

      expect(find.text('Add expense'), findsOneWidget);
      expect(find.byType(ItemSplitCard), findsNWidgets(2));
      expect(isChipSelected(tester, 0, 'Mehmet'), isTrue);
      expect(find.text('Total: 50,00 ₺ of 0,00 ₺'), findsOneWidget);
    });
  });
}
