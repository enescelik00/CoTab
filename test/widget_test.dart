import 'package:flutter_test/flutter_test.dart';

import 'package:cotab/main.dart';
import 'package:cotab/models/group.dart';
import 'package:cotab/screens/home_screen.dart';

// The home screen gets a groupLoader here, so it does not read SQLite or
// call Firebase. Passing the home screen directly also skips the AuthGate.
void main() {
  testWidgets('Home screen shows the welcome text', (tester) async {
    await tester.pumpWidget(
      CoTabApp(home: HomeScreen(groupLoader: () async => [])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to CoTab!'), findsOneWidget);
    expect(find.text('You are not in any group yet.'), findsOneWidget);
    expect(find.byTooltip('Sign out'), findsOneWidget);
    expect(find.byTooltip('Join a group'), findsOneWidget);
    expect(find.text('New group'), findsOneWidget);
  });

  testWidgets('Home screen lists the groups', (tester) async {
    final groups = [
      Group(
        id: 'group1',
        name: 'Kadıköy Evi',
        type: 'home',
        inviteCode: 'K7M2QX',
        updatedAt: 1763200000000,
      ),
      Group(
        id: 'group2',
        name: 'Kapadokya',
        type: 'trip',
        inviteCode: 'ABC234',
        updatedAt: 1763200000000,
      ),
    ];

    await tester.pumpWidget(
      CoTabApp(home: HomeScreen(groupLoader: () async => groups)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kadıköy Evi'), findsOneWidget);
    expect(find.text('Kapadokya'), findsOneWidget);
    expect(find.text('Trip'), findsOneWidget);
    expect(find.text('You are not in any group yet.'), findsNothing);
  });
}
