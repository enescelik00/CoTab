import 'package:flutter_test/flutter_test.dart';

import 'package:cotab/main.dart';
import 'package:cotab/screens/home_screen.dart';

void main() {
  testWidgets('Home screen shows the welcome text', (tester) async {
    // Pass the home screen directly, so the test does not need Firebase.
    await tester.pumpWidget(const CoTabApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to CoTab!'), findsOneWidget);
    expect(find.text('You are not in any group yet.'), findsOneWidget);
    expect(find.byTooltip('Sign out'), findsOneWidget);
  });
}
