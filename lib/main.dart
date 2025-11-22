import 'package:flutter/material.dart';
import 'banner.dart';
import 'login_page.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const BeginPage(),
      routes: {
        '/login': (context) => const Loginpage(),
        '/home': (context) => const Homepage(),
      },
    );
  }
}
