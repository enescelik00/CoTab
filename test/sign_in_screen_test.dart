import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cotab/main.dart';
import 'package:cotab/screens/sign_in_screen.dart';

// These tests only check form validation. Validation fails before any
// Firebase call, so Firebase is never needed here.
void main() {
  Future<void> openSignInScreen(WidgetTester tester) async {
    await tester.pumpWidget(const CoTabApp(home: SignInScreen()));
    await tester.pumpAndSettle();
  }

  Future<void> tapSignInButton(WidgetTester tester) async {
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
  }

  testWidgets('Empty fields show error texts', (tester) async {
    await openSignInScreen(tester);

    await tapSignInButton(tester);

    expect(find.text('Please enter your email.'), findsOneWidget);
    expect(find.text('Please enter your password.'), findsOneWidget);
  });

  testWidgets('Email without @ shows an error', (tester) async {
    await openSignInScreen(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'ayse.example');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tapSignInButton(tester);

    expect(find.text('Please enter a valid email.'), findsOneWidget);
    expect(find.text('Please enter your password.'), findsNothing);
  });

  testWidgets('Short password shows an error', (tester) async {
    await openSignInScreen(tester);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'ayse@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tapSignInButton(tester);

    expect(
      find.text('Password must be at least 6 characters.'),
      findsOneWidget,
    );
  });
}
