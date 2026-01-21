import 'package:flutter/material.dart';

/// A simple placeholder home screen.
///
/// This can be replaced with a rails-based home UI later; the login flow
/// navigates here via the `/home` named route.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Text(
          'Home Screen',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
