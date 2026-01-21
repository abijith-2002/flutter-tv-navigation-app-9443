import 'package:flutter/material.dart';
import 'package:flutter_frontend/screens/home_screen.dart';
import 'package:flutter_frontend/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

/// Root application widget for the Flutter Android TV app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Build Tool',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: <String, WidgetBuilder>{
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
