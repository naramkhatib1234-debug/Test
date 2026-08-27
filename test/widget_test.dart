import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stack_rush/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App boots to the main menu with default stats', (tester) async {
    await tester.pumpWidget(const StackRushApp());
    await tester.pumpAndSettle();

    expect(find.text('STACK'), findsOneWidget);
    expect(find.text('RUSH'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('SKINS'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2)); // best score and coins start at 0
  });

  testWidgets('Play button opens the game screen', (tester) async {
    await tester.pumpWidget(const StackRushApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('PLAY'));
    // The running Flame game animates every frame and never "settles",
    // so pump a few explicit frames instead of pumpAndSettle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('PLAY'), findsNothing);
  });
}
