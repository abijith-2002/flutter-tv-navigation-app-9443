import 'package:flutter/material.dart';
import 'package:flutter_frontend/screens/home_screen.dart';
import 'package:flutter_frontend/screens/login_screen.dart';
import 'package:flutter_frontend/theme/material_theme.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

/// Root application widget for the Flutter Android TV app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final MaterialTheme materialTheme = MaterialTheme(
      GoogleFonts.redditSansTextTheme(),
    );

    return MaterialApp(
      title: 'AI Build Tool',
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      themeMode: ThemeMode.system,
      initialRoute: '/login',
      routes: <String, WidgetBuilder>{
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
