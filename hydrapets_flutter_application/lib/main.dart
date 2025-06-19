import 'package:flutter/material.dart';
import 'package:hydrapets_flutter_application/views/login_screen.dart';
import 'views/dashboard_screen.dart';
import 'package:hydrapets_flutter_application/views/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HydraPets',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
