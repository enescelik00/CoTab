import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cotab/main.dart';
import 'package:cotab/widgets/settle_up_dialog.dart';

// The dialog is opened from a button, like on the group screen. The value it
// closes with is written into result, so the tests can check it.
int? result;
bool closed = false;

Future<void> openDialog(WidgetTester tester) async {
  result = null;
  closed = false;

  await tester.pumpWidget(
    CoTabApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              result = await showDialog<int>(
                context: context,
                builder: (context) => const SettleUpDialog(
                  fromName: 'Ayşe',
                  toName: 'Ali',
                  suggestedAmount: 10000,
                ),
              );
              closed = true;
            },
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Shows who pays whom and the suggested amount', (tester) async {
    await openDialog(tester);

    expect(find.text('Ayşe → Ali'), findsOneWidget);
    expect(find.text('100,00'), findsOneWidget);
  });

  testWidgets('Save returns the suggested amount', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(result, 10000);
  });

  testWidgets('A part payment can be saved', (tester) async {
    await openDialog(tester);

    await tester.enterText(find.byType(TextField), '40');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, 4000);
  });

  testWidgets('More than the suggestion shows an error', (tester) async {
    await openDialog(tester);

    await tester.enterText(find.byType(TextField), '150');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('The amount can be at most 100,00 ₺.'), findsOneWidget);
    expect(closed, isFalse);
  });

  testWidgets('A wrong amount shows an error', (tester) async {
    await openDialog(tester);

    await tester.enterText(find.byType(TextField), 'abc');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.text('Please enter a valid amount, e.g. 250,50.'),
      findsOneWidget,
    );
    expect(closed, isFalse);
  });

  testWidgets('Cancel closes without a value', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(result, isNull);
  });
}
