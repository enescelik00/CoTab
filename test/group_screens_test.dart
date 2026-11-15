import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cotab/main.dart';
import 'package:cotab/screens/create_group_screen.dart';
import 'package:cotab/screens/join_group_screen.dart';

// These tests only check form validation. Validation fails before any
// Firebase call, so Firebase is never needed here.
void main() {
  testWidgets('Create group: empty name shows an error', (tester) async {
    await tester.pumpWidget(const CoTabApp(home: CreateGroupScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a group name.'), findsOneWidget);
  });

  testWidgets('Create group: home and trip can be chosen', (tester) async {
    await tester.pumpWidget(const CoTabApp(home: CreateGroupScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Trip'), findsOneWidget);

    await tester.tap(find.text('Trip'));
    await tester.pumpAndSettle();

    final button = tester.widget<SegmentedButton<String>>(
      find.byType(SegmentedButton<String>),
    );
    expect(button.selected, {'trip'});
  });

  testWidgets('Join group: empty code shows an error', (tester) async {
    await tester.pumpWidget(const CoTabApp(home: JoinGroupScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Please enter the 6-character code.'), findsOneWidget);
  });

  testWidgets('Join group: a short code shows an error', (tester) async {
    await tester.pumpWidget(const CoTabApp(home: JoinGroupScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'abc');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Please enter the 6-character code.'), findsOneWidget);
    // The code is shown in capital letters.
    expect(find.text('ABC'), findsOneWidget);
  });
}
