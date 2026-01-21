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
}
