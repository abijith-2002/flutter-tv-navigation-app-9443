import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_frontend/main.dart';

void main() {
  testWidgets(
    'Login screen shows username/password tiles and login button',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.text('Sign in'), findsOneWidget);

      // Refactor: username/password are ListTile rows instead of TextFields.
      expect(find.widgetWithText(ListTile, 'Username'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Password'), findsOneWidget);

      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    },
  );

  testWidgets('MaterialApp is created', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets(
    'Username tile opens on-screen keyboard and applies submitted value',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Open keyboard by tapping the Username tile.
      await tester.tap(find.widgetWithText(ListTile, 'Username'));
      await tester.pumpAndSettle();

      // Fullscreen dialog content should be present.
      expect(find.text('Username'), findsWidgets);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap a couple of keys then Done.
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Username value should now show in the ListTile trailing text.
      expect(find.text('AB'), findsOneWidget);

      // No exceptions (e.g., focus attachment issues).
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'DPAD select opens on-screen keyboard when Username tile is focused',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // The login screen requests initial focus on Username tile.
      // Send Select/Enter and ensure the keyboard shows.
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();

      expect(find.text('Username'), findsWidgets);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Close the keyboard to ensure no focus-related exceptions.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );
}
