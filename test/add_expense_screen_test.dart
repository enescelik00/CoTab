import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cotab/main.dart';
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
}
