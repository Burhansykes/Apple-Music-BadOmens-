import 'package:flutter/material.dart';
import 'Screens/splash_screens.dart';

void main() {
  runApp(const BadOmensApp());
}

class BadOmensApp extends StatelessWidget {
  const BadOmensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bad Omens Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: false,
      ),
      home: const SplashScreen(),
    );
  }
}
