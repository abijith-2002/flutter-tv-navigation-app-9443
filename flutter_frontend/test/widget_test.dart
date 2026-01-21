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
    'Opening and closing the username editor dialog does not throw (focus tree regression)',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Tap Username tile to open the dialog.
      await tester.tap(find.widgetWithText(ListTile, 'Username'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      // Close dialog via Cancel.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
